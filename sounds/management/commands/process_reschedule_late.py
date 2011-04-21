from django.core.management.base import BaseCommand
from sounds.models import Sound
from datetime import datetime

class Command(BaseCommand):
    args = '<num_hours>'
    help = 'Take all sounds that have been sitting (for num_hours) the processing queue marked as "being processed" and reschedule them'

    def handle(self, *args, **options):
        num_hours = int(args[0])
        for sound in Sound.objects.filter(processing_state="PR", processing_date__lt=datetime.now()-datetime.timedelta(hours=num_hours)):
            sound.processing_state = "PE"
            sound.save()