Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:43849 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751369Ab0KBUK2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Nov 2010 16:10:28 -0400
Date: Tue, 2 Nov 2010 16:10:25 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 4/6] ignore passive devices before checking serial numbers
Message-ID: <673c29dbf194eaca69848538d814bfd92aa0dbf9.1288726186.git.rees@umich.edu>
References: <cover.1288726186.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1288726186.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Jim Rees <rees@umich.edu>
---
 utils/blkmapd/device-discovery.c |   33 +++++++++++++++++----------------
 utils/blkmapd/device-inq.c       |   19 +++++++++++--------
 2 files changed, 28 insertions(+), 24 deletions(-)

diff --git a/utils/blkmapd/device-discovery.c b/utils/blkmapd/device-discovery.c
index 71b4d48..c8bd39c 100644
--- a/utils/blkmapd/device-discovery.c
+++ b/utils/blkmapd/device-discovery.c
@@ -26,24 +26,25 @@
  * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
 
-#include <stdlib.h>
-#include <stdio.h>
-#include <string.h>
-#include <dirent.h>
-#include <ctype.h>
-#include <linux/kdev_t.h>
 #include <sys/types.h>
 #include <sys/stat.h>
 #include <sys/ioctl.h>
 #include <sys/mount.h>
 #include <sys/select.h>
+#include <linux/kdev_t.h>
+#include <scsi/scsi.h>
+#include <scsi/scsi_ioctl.h>
+#include <scsi/sg.h>
+
+#include <stdlib.h>
+#include <stdio.h>
+#include <string.h>
+#include <dirent.h>
+#include <ctype.h>
 #include <fcntl.h>
 #include <unistd.h>
 #include <libgen.h>
 #include <errno.h>
-#include <scsi/scsi.h>
-#include <scsi/scsi_ioctl.h>
-#include <scsi/sg.h>
 
 #include "device-discovery.h"
 
@@ -127,7 +128,7 @@ void bl_add_disk(char *filepath)
 	struct stat sb;
 	off_t size = 0;
 	struct bl_serial *serial = NULL;
-	enum bl_path_state_e ap_state = BL_PATH_STATE_PASSIVE;
+	enum bl_path_state_e ap_state;
 	struct bl_disk_path *diskpath = NULL, *path = NULL;
 	dev_t dev;
 
@@ -152,6 +153,11 @@ void bl_add_disk(char *filepath)
 
 	dev = sb.st_rdev;
 	serial = bldev_read_serial(fd, filepath);
+	bldev_read_ap_state(fd, &ap_state);
+	close(fd);
+
+	if (ap_state == BL_PATH_STATE_PASSIVE)
+		return;
 
 	for (disk = visible_disk_list; disk != NULL; disk = disk->next) {
 		/* Already scanned or a partition?
@@ -164,13 +170,8 @@ void bl_add_disk(char *filepath)
 		}
 	}
 
-	if (disk && diskpath) {
-		close(fd);
+	if (disk && diskpath)
 		return;
-	}
-
-	bldev_read_ap_state(fd, &ap_state);
-	close(fd);
 
 	BL_LOG_ERR("%s: %s\n", __func__, filepath);
 
diff --git a/utils/blkmapd/device-inq.c b/utils/blkmapd/device-inq.c
index ff38fd6..7817c5a 100644
--- a/utils/blkmapd/device-inq.c
+++ b/utils/blkmapd/device-inq.c
@@ -28,23 +28,25 @@
  * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
  * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
-#include <stdlib.h>
-#include <stdio.h>
-#include <string.h>
-#include <dirent.h>
-#include <ctype.h>
 #include <sys/types.h>
 #include <sys/stat.h>
 #include <sys/ioctl.h>
 #include <sys/mount.h>
 #include <sys/select.h>
+#include <scsi/scsi.h>
+#include <scsi/scsi_ioctl.h>
+#include <scsi/sg.h>
+
+#include <stdlib.h>
+#include <stdio.h>
+#include <string.h>
+#include <dirent.h>
+#include <ctype.h>
 #include <fcntl.h>
 #include <unistd.h>
 #include <libgen.h>
 #include <errno.h>
-#include <scsi/scsi.h>
-#include <scsi/scsi_ioctl.h>
-#include <scsi/sg.h>
+
 #include "device-discovery.h"
 
 #define DEF_ALLOC_LEN	255
@@ -161,6 +163,7 @@ void bldev_read_ap_state(int fd, enum bl_path_state_e *ap_state_out)
 	if (status)
 		goto out;
 
+	printf("buffer[4]=%d\n", (int) buffer[4]);
 	if (buffer[4] < 0x02)
 		*ap_state_out = BL_PATH_STATE_PASSIVE;
  out:
-- 
1.7.1

