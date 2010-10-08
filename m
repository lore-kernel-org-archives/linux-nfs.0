Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:34229 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756163Ab0JHQJn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Oct 2010 12:09:43 -0400
Date: Fri, 8 Oct 2010 12:09:22 -0400
From: Jim Rees <rees@umich.edu>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org, sfaibish <sfaibish@emc.com>,
        peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 4/4] blkmapd: don't try to distinguish between
 active/passive devices
Message-ID: <941d12dfd13f7a23cff3a1ca07f43ff05a29e19c.1286552019.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1286552019.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This test really only works for EMC servers, and isn't even needed because
the passive devices will be skipped over during signature detection.  Just
remove the detection code.

Signed-off-by: Jim Rees <rees@umich.edu>
---
 utils/blkmapd/device-discovery.c |   24 ++++++++++++----------
 utils/blkmapd/device-discovery.h |    1 -
 utils/blkmapd/device-inq.c       |   40 +++++++++----------------------------
 3 files changed, 23 insertions(+), 42 deletions(-)

diff --git a/utils/blkmapd/device-discovery.c b/utils/blkmapd/device-discovery.c
index 71b4d48..271c7ed 100644
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
 
@@ -169,7 +170,6 @@ void bl_add_disk(char *filepath)
 		return;
 	}
 
-	bldev_read_ap_state(fd, &ap_state);
 	close(fd);
 
 	BL_LOG_ERR("%s: %s\n", __func__, filepath);
@@ -180,6 +180,8 @@ void bl_add_disk(char *filepath)
 	 */
 	if (strncmp(filepath, "/dev/mapper", 11) == 0)
 		ap_state = BL_PATH_STATE_PSEUDO;
+	else
+		ap_state = BL_PATH_STATE_ACTIVE;
 
 	/* add path */
 	path = malloc(sizeof(struct bl_disk_path));
diff --git a/utils/blkmapd/device-discovery.h b/utils/blkmapd/device-discovery.h
index b8d26a6..4d12cba 100644
--- a/utils/blkmapd/device-discovery.h
+++ b/utils/blkmapd/device-discovery.h
@@ -151,7 +151,6 @@ uint64_t process_deviceinfo(const char *dev_addr_buf,
 extern ssize_t atomicio(ssize_t(*f) (int, void *, size_t),
 			int fd, void *_s, size_t n);
 extern struct bl_serial *bldev_read_serial(int fd, const char *filename);
-extern void bldev_read_ap_state(int fd, enum bl_path_state_e *ap_state_out);
 extern int bl_discover_devices(void);
 
 #define BL_LOG_WARNING(fmt...)		syslog(LOG_WARNING, fmt)
diff --git a/utils/blkmapd/device-inq.c b/utils/blkmapd/device-inq.c
index ff38fd6..c817e72 100644
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
@@ -147,28 +149,6 @@ int bldev_inquire_pages(int fd, int page, char **buffer)
 	return status;
 }
 
-/* For EMC multipath devices, use VPD page (0xc0) to get status.
- * For other devices, return ACTIVE for now
- */
-void bldev_read_ap_state(int fd, enum bl_path_state_e *ap_state_out)
-{
-	int status = 0;
-	char *buffer;
-
-	*ap_state_out = BL_PATH_STATE_ACTIVE;
-
-	status = bldev_inquire_pages(fd, 0xc0, &buffer);
-	if (status)
-		goto out;
-
-	if (buffer[4] < 0x02)
-		*ap_state_out = BL_PATH_STATE_PASSIVE;
- out:
-	if (buffer)
-		free(buffer);
-	return;
-}
-
 struct bl_serial *bldev_read_serial(int fd, const char *filename)
 {
 	struct bl_serial *serial_out = NULL;
-- 
1.7.0.4

