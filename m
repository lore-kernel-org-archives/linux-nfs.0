Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:43995 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751081Ab0KBULH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Nov 2010 16:11:07 -0400
Date: Tue, 2 Nov 2010 16:11:02 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 6/6] Various bug fixes and cleanups.
Message-ID: <137585fba5fda6b30148b046ab58278146cb36eb.1288726186.git.rees@umich.edu>
References: <cover.1288726186.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1288726186.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Don't log EUI errors.  These aren't really errors, since we'll fall back to
a different id type, or just use the file name.

Get rid of useless default case.

eliminate fd/pidfd confusion

use INFO syslog level instead of ERR for info messages

Remove atomicio.c from blkmapd now that it's in the support lib

Signed-off-by: Jim Rees <rees@umich.edu>
---
 utils/blkmapd/Makefile.am        |    1 -
 utils/blkmapd/atomicio.c         |   54 --------------------------------
 utils/blkmapd/device-discovery.c |   63 +++++++++++++++++++++----------------
 utils/blkmapd/device-discovery.h |    3 +-
 utils/blkmapd/device-inq.c       |   26 ++++++---------
 utils/blkmapd/device-process.c   |   28 ++++++-----------
 utils/blkmapd/dm-device.c        |    1 +
 7 files changed, 59 insertions(+), 117 deletions(-)
 delete mode 100644 utils/blkmapd/atomicio.c

diff --git a/utils/blkmapd/Makefile.am b/utils/blkmapd/Makefile.am
index 1e8720d..70e299e 100644
--- a/utils/blkmapd/Makefile.am
+++ b/utils/blkmapd/Makefile.am
@@ -6,7 +6,6 @@ AM_CFLAGS	+= -D_LARGEFILE64_SOURCE
 sbin_PROGRAMS	= blkmapd
 
 blkmapd_SOURCES = \
-	atomicio.c \
 	device-discovery.c \
 	device-inq.c \
 	device-process.c \
diff --git a/utils/blkmapd/atomicio.c b/utils/blkmapd/atomicio.c
deleted file mode 100644
index 8db626e..0000000
--- a/utils/blkmapd/atomicio.c
+++ /dev/null
@@ -1,54 +0,0 @@
-/*
- * Copyright (c) 2002 Marius Aamodt Eriksen <marius@monkey.org>
- * Copyright (c) 1995,1999 Theo de Raadt.  All rights reserved.
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions
- * are met:
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- *
- * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
- * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
- * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
- * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
- * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
- * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
- * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
- * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
- * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
- * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
- */
-
-#include <sys/types.h>
-#include <unistd.h>
-#include <errno.h>
-
-/*
- * ensure all of data on socket comes through. f==read || f==write
- */
-ssize_t atomicio(ssize_t(*f) (int, void *, size_t), int fd, void *_s, size_t n)
-{
-	char *s = _s;
-	ssize_t res, pos = 0;
-
-	while (n > pos) {
-		res = (f) (fd, s + pos, n - pos);
-		switch (res) {
-		case -1:
-			if (errno == EINTR || errno == EAGAIN)
-				continue;
-		case 0:
-			if (pos != 0)
-				return pos;
-			return res;
-		default:
-			pos += res;
-		}
-	}
-	return pos;
-}
diff --git a/utils/blkmapd/device-discovery.c b/utils/blkmapd/device-discovery.c
index 6b1f942..0497a11 100644
--- a/utils/blkmapd/device-discovery.c
+++ b/utils/blkmapd/device-discovery.c
@@ -153,7 +153,7 @@ void bl_add_disk(char *filepath)
 
 	dev = sb.st_rdev;
 	serial = bldev_read_serial(fd, filepath);
-	bldev_read_ap_state(fd, &ap_state);
+	ap_state = bldev_read_ap_state(fd);
 	close(fd);
 
 	if (ap_state == BL_PATH_STATE_PASSIVE)
@@ -173,7 +173,7 @@ void bl_add_disk(char *filepath)
 	if (disk && diskpath)
 		return;
 
-	BL_LOG_ERR("%s: %s\n", __func__, filepath);
+	BL_LOG_INFO("%s: %s\n", __func__, filepath);
 
 	/*
 	 * Not sure how to identify a pseudo device created by
@@ -320,7 +320,7 @@ int bl_disk_inquiry_process(int fd)
 		bl_discover_devices();
 		if (!process_deviceinfo(buf, buflen, &major, &minor)) {
 			head->status = BL_DEVICE_REQUEST_ERR;
-			goto out;
+			break;
 		}
 		tmp = realloc(head, sizeof(major) + sizeof(minor) +
 			      sizeof(struct pipefs_hdr));
@@ -342,6 +342,7 @@ int bl_disk_inquiry_process(int fd)
 		break;
 	default:
 		head->status = BL_DEVICE_REQUEST_ERR;
+		break;
 	}
 
 	head->totallen = sizeof(struct pipefs_hdr) + len;
@@ -398,7 +399,7 @@ int bl_run_disk_inquiry_process(int fd)
 /* Daemon */
 int main(int argc, char **argv)
 {
-	int fd = -1, opt, dflag = 0, fg = 0, ret = 1;
+	int fd, pidfd = -1, opt, dflag = 0, fg = 0, ret = 1;
 	struct stat statbuf;
 	char pidbuf[64];
 
@@ -417,44 +418,47 @@ int main(int argc, char **argv)
 		openlog("blkmapd", LOG_PERROR, 0);
 	} else {
 		if (!stat(PID_FILE, &statbuf)) {
-			fprintf(stderr, "Pid file already existed\n");
-			return -1;
+			fprintf(stderr, "Pid file %s already existed\n", PID_FILE);
+			exit(1);
 		}
 
 		if (daemon(0, 0) != 0) {
 			fprintf(stderr, "Daemonize failed\n");
-			return -1;
+			exit(1);
 		}
 
 		openlog("blkmapd", LOG_PID, 0);
-		fd = open(PID_FILE, O_WRONLY | O_CREAT, 0644);
-		if (fd < 0) {
-			BL_LOG_ERR("Create pid file failed\n");
-			return -1;
+		pidfd = open(PID_FILE, O_WRONLY | O_CREAT, 0644);
+		if (pidfd < 0) {
+			BL_LOG_ERR("Create pid file %s failed\n", PID_FILE);
+			exit(1);
 		}
 
-		if (lockf(fd, F_TLOCK, 0) < 0) {
-			BL_LOG_ERR("Lock pid file failed\n");
-			close(fd);
-			return -1;
+		if (lockf(pidfd, F_TLOCK, 0) < 0) {
+			BL_LOG_ERR("Lock pid file %s failed\n", PID_FILE);
+			close(pidfd);
+			exit(1);
 		}
-		ftruncate(fd, 0);
+		ftruncate(pidfd, 0);
 		sprintf(pidbuf, "%d\n", getpid());
-		write(fd, pidbuf, strlen(pidbuf));
+		write(pidfd, pidbuf, strlen(pidbuf));
+	}
 
-		/* open pipe file */
-		fd = open(BL_PIPE_FILE, O_RDWR);
-		if (fd < 0) {
-			BL_LOG_ERR("open pipe file error\n");
-			return -1;
-		}
+	if (dflag) {
+		bl_discover_devices();
+		exit(0);
+	}
+
+	/* open pipe file */
+	fd = open(BL_PIPE_FILE, O_RDWR);
+	if (fd < 0) {
+		BL_LOG_ERR("open pipe file %s error\n", BL_PIPE_FILE);
+		exit(1);
 	}
 
 	while (1) {
 		/* discover device when needed */
 		bl_discover_devices();
-		if (dflag)
-			break;
 
 		ret = bl_run_disk_inquiry_process(fd);
 		if (ret < 0) {
@@ -462,6 +466,11 @@ int main(int argc, char **argv)
 			BL_LOG_ERR("inquiry process return %d\n", ret);
 		}
 	}
-	close(fd);
-	return ret;
+
+	if (pidfd >= 0) {
+		close(pidfd);
+		unlink(PID_FILE);
+	}
+
+	exit(ret);
 }
diff --git a/utils/blkmapd/device-discovery.h b/utils/blkmapd/device-discovery.h
index b8d26a6..8cf88b8 100644
--- a/utils/blkmapd/device-discovery.h
+++ b/utils/blkmapd/device-discovery.h
@@ -151,9 +151,10 @@ uint64_t process_deviceinfo(const char *dev_addr_buf,
 extern ssize_t atomicio(ssize_t(*f) (int, void *, size_t),
 			int fd, void *_s, size_t n);
 extern struct bl_serial *bldev_read_serial(int fd, const char *filename);
-extern void bldev_read_ap_state(int fd, enum bl_path_state_e *ap_state_out);
+extern enum bl_path_state_e bldev_read_ap_state(int fd);
 extern int bl_discover_devices(void);
 
+#define BL_LOG_INFO(fmt...)		syslog(LOG_INFO, fmt)
 #define BL_LOG_WARNING(fmt...)		syslog(LOG_WARNING, fmt)
 #define BL_LOG_ERR(fmt...)		syslog(LOG_ERR, fmt)
 #define BL_LOG_DEBUG(fmt...)		syslog(LOG_DEBUG, fmt)
diff --git a/utils/blkmapd/device-inq.c b/utils/blkmapd/device-inq.c
index 7817c5a..e1c0128 100644
--- a/utils/blkmapd/device-inq.c
+++ b/utils/blkmapd/device-inq.c
@@ -52,9 +52,10 @@
 #define DEF_ALLOC_LEN	255
 #define MX_ALLOC_LEN	(0xc000 + 0x80)
 
-struct bl_serial *bl_create_scsi_string(int len, const char *bytes)
+static struct bl_serial *bl_create_scsi_string(int len, const char *bytes)
 {
 	struct bl_serial *s;
+
 	s = malloc(sizeof(*s) + len);
 	if (s) {
 		s->data = (char *)&s[1];
@@ -64,7 +65,7 @@ struct bl_serial *bl_create_scsi_string(int len, const char *bytes)
 	return s;
 }
 
-void bl_free_scsi_string(struct bl_serial *str)
+static void bl_free_scsi_string(struct bl_serial *str)
 {
 	if (str)
 		free(str);
@@ -107,7 +108,7 @@ static int bldev_inquire_page(int fd, int page, char *buffer, int len)
 	return -1;
 }
 
-int bldev_inquire_pages(int fd, int page, char **buffer)
+static int bldev_inquire_pages(int fd, int page, char **buffer)
 {
 	int status = 0;
 	char *tmp;
@@ -152,24 +153,22 @@ int bldev_inquire_pages(int fd, int page, char **buffer)
 /* For EMC multipath devices, use VPD page (0xc0) to get status.
  * For other devices, return ACTIVE for now
  */
-void bldev_read_ap_state(int fd, enum bl_path_state_e *ap_state_out)
+extern enum bl_path_state_e bldev_read_ap_state(int fd)
 {
 	int status = 0;
-	char *buffer;
-
-	*ap_state_out = BL_PATH_STATE_ACTIVE;
+	char *buffer = NULL;
+	enum bl_path_state_e ap_state = BL_PATH_STATE_ACTIVE;
 
 	status = bldev_inquire_pages(fd, 0xc0, &buffer);
 	if (status)
 		goto out;
 
-	printf("buffer[4]=%d\n", (int) buffer[4]);
 	if (buffer[4] < 0x02)
-		*ap_state_out = BL_PATH_STATE_PASSIVE;
+		ap_state = BL_PATH_STATE_PASSIVE;
  out:
 	if (buffer)
 		free(buffer);
-	return;
+	return ap_state;
 }
 
 struct bl_serial *bldev_read_serial(int fd, const char *filename)
@@ -200,11 +199,8 @@ struct bl_serial *bldev_read_serial(int fd, const char *filename)
 			 */
 		case 2:	/* EUI-64 based */
 			if ((dev_id->len != 8) && (dev_id->len != 12) &&
-			    (dev_id->len != 16)) {
-				BL_LOG_ERR("EUI-64 only decodes 8, "
-					   "12 and 16\n");
+			    (dev_id->len != 16))
 				break;
-			}
 		case 3:	/* NAA */
 			/* TODO: NAA validity judgement too complicated,
 			 * so just ingore it here.
@@ -221,8 +217,6 @@ struct bl_serial *bldev_read_serial(int fd, const char *filename)
 			serial_out = bl_create_scsi_string(dev_id->len,
 							   dev_id->data);
 			break;
-		default:
-			break;
 		}
 		if (current_id == 3)
 			break;
diff --git a/utils/blkmapd/device-process.c b/utils/blkmapd/device-process.c
index c4e72ea..a543769 100644
--- a/utils/blkmapd/device-process.c
+++ b/utils/blkmapd/device-process.c
@@ -82,7 +82,7 @@ static int decode_blk_signature(uint32_t **pp, uint32_t *end,
 		 * for mapping, then thrown away.
 		 */
 		sig->si_comps[i].bs_string = (char *)p;
-		BL_LOG_ERR("%s: si_comps[%d]: bs_length %d, bs_string %s\n",
+		BL_LOG_INFO("%s: si_comps[%d]: bs_length %d, bs_string %s\n",
 			   __func__, i, sig->si_comps[i].bs_length,
 			   sig->si_comps[i].bs_string);
 		p += ((tmp + 3) >> 2);
@@ -126,7 +126,7 @@ read_cmp_blk_sig(const char *dev_name, struct bl_sig_comp *comp,
 		goto error;
 	}
 
-	BL_LOG_ERR
+	BL_LOG_INFO
 	    ("%s: %s sig: %s, bs_string: %s, bs_length: %d, bs_offset: %lld\n",
 	     __func__, dev_name, sig, comp->bs_string, comp->bs_length,
 	     (long long)bs_offset);
@@ -155,7 +155,7 @@ static int verify_sig(struct bl_disk *disk, struct bl_sig *sig)
 		bs_offset = comp->bs_offset;
 		if (bs_offset < 0)
 			bs_offset += (((int64_t) disk->size) << 9);
-		BL_LOG_ERR("%s: bs_offset: %lld\n",
+		BL_LOG_INFO("%s: bs_offset: %lld\n",
 			   __func__, (long long) bs_offset);
 		ret = read_cmp_blk_sig(disk->valid_path->full_path,
 				       comp, bs_offset);
@@ -180,7 +180,7 @@ static int map_sig_to_device(struct bl_sig *sig, struct bl_volume *vol)
 	struct bl_disk *lolDisk = disk;
 
 	while (lolDisk) {
-		BL_LOG_ERR("%s: visible_disk_list: %s\n", __func__,
+		BL_LOG_INFO("%s: visible_disk_list: %s\n", __func__,
 			   lolDisk->valid_path->full_path);
 		lolDisk = lolDisk->next;
 	}
@@ -324,16 +324,14 @@ uint64_t process_deviceinfo(const char *dev_addr_buf,
 	uint32_t *p, *end;
 	struct bl_volume *vols = NULL, **arrays = NULL, **arrays_ptr = NULL;
 	uint64_t dev = 0;
-	int tried = 0;
 
- restart:
 	p = (uint32_t *) dev_addr_buf;
 	end = (uint32_t *) ((char *)p + dev_addr_len);
 	/* Decode block volume */
 	BLK_READBUF(p, end, 4);
 	READ32(num_vols);
 	if (num_vols <= 0) {
-		BL_LOG_WARNING("Error: number of vols: %d\n", num_vols);
+		BL_LOG_ERR("Error: number of vols: %d\n", num_vols);
 		goto out_err;
 	}
 
@@ -363,15 +361,6 @@ uint64_t process_deviceinfo(const char *dev_addr_buf,
 	for (i = 0; i < num_vols; i++) {
 		vols[i].bv_vols = arrays_ptr;
 		status = decode_blk_volume(&p, end, vols, i, &count);
-		if (status == -ENXIO && (tried <= 5)) {
-			sleep(1);
-			BL_LOG_DEBUG("%s: discover again!\n", __func__);
-			bl_discover_devices();
-			tried++;
-			free(vols);
-			free(arrays);
-			goto restart;
-		}
 		if (status)
 			goto out_err;
 		arrays_ptr += count;
@@ -383,8 +372,11 @@ uint64_t process_deviceinfo(const char *dev_addr_buf,
 	}
 
 	dev = dm_device_create(vols, num_vols);
-	*major = MAJOR(dev);
-	*minor = MINOR(dev);
+	if (dev) {
+		*major = MAJOR(dev);
+		*minor = MINOR(dev);
+	}
+
  out_err:
 	if (vols)
 		free(vols);
diff --git a/utils/blkmapd/dm-device.c b/utils/blkmapd/dm-device.c
index 8162706..14ad131 100644
--- a/utils/blkmapd/dm-device.c
+++ b/utils/blkmapd/dm-device.c
@@ -379,6 +379,7 @@ uint64_t dm_device_create(struct bl_volume *vols, int num_vols)
 	struct bl_dm_table *bl_table_head = NULL;
 	unsigned int len;
 	char *dev_name = NULL;
+
 	/* Create pseudo device here */
 	while (number < num_vols) {
 		node = &vols[number];
-- 
1.7.1

