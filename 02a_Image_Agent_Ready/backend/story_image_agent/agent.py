import json
import logging
from typing import AsyncGenerator

from google.adk.agents import BaseAgent, InvocationContext
from google.adk.tools import ToolContext
from google.adk.tools.events import Event, EventOrigin

from story_image_agent.imagen_tool import ImagenTool


class CustomImageAgent(BaseAgent):
    """A custom agent for generating images directly using ImagenTool."""

    def __init__(self, name: str = "custom_image_agent") -> None:
        super().__init__(name=name)
        self.imagen_tool = ImagenTool()

    async def _run_async_impl(
        self, ctx: InvocationContext
    ) -> AsyncGenerator[Event, None]:
        """Directly executes ImagenTool without LLM intermediation."""
        logging.info("CustomImageAgent._run_async_impl called")

        if not ctx.user_content or not ctx.user_content.parts:
            yield Event(
                origin=EventOrigin.AGENT,
                type="error",
                payload={"message": "User content is empty."},
            )
            return

        user_message = ctx.user_content.parts[0].text
        logging.info("User message: %s", user_message)

        try:
            # Try to parse the message as JSON
            data = json.loads(user_message)
            scene_description = data.get("scene_description", "")
            character_descriptions = data.get("character_descriptions", {})
        except json.JSONDecodeError:
            # Fallback to plain text if not JSON
            scene_description = user_message
            character_descriptions = {}
            logging.warning("Input was not valid JSON, treating as plain text.")

        # Build the image prompt
        style_prefix = "Children's book cartoon illustration with bright vibrant colors, simple shapes, friendly characters."
        
        character_details = []
        for name, desc in character_descriptions.items():
            character_details.append(f"{name}: {desc}")
        
        prompt = f"{style_prefix} {scene_description}"
        if character_details:
            prompt += " " + " ".join(character_details)

        logging.info("Generated prompt for Imagen: %s", prompt)

        try:
            # Directly call the ImagenTool. We pass None for ctx as it's not used by the tool.
            # The tool's run method expects kwargs, so we pass the prompt that way.
            image_result_str = await self.imagen_tool.run(ctx=None, prompt=prompt)
            image_result = json.loads(image_result_str)

            if not image_result.get("success"):
                error_message = image_result.get("error", "Image generation failed.")
                ctx.session.state["image_result"] = json.dumps({
                    "status": "error",
                    "message": error_message
                })
            else:
                ctx.session.state["image_result"] = json.dumps({
                    "status": "success",
                    "images": image_result.get("images", [])
                })
            
            yield Event(
                origin=EventOrigin.AGENT,
                type="result",
                payload={"result": ctx.session.state["image_result"]},
            )

        except Exception as e:
            logging.error(f"Error calling ImagenTool: {e}", exc_info=True)
            error_message = f"An unexpected error occurred: {e}"
            ctx.session.state["image_result"] = json.dumps({
                "status": "error",
                "message": error_message
            })
            yield Event(
                origin=EventOrigin.AGENT,
                type="error",
                payload={"message": error_message},
            )
