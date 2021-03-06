#
# Freesound is (c) MUSIC TECHNOLOGY GROUP, UNIVERSITAT POMPEU FABRA
#
# Freesound is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Freesound is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Authors:
#     See AUTHORS file.
#

from django.template import Library
from django.contrib.contenttypes.models import ContentType
from django.core.urlresolvers import reverse

register = Library()

@register.filter
def rating_url(object, rating):
    content_type = ContentType.objects.get_for_model(object.__class__)
    return reverse("ratings-add", kwargs=dict(content_type_id=content_type.id, object_id=object.id, rating=rating))