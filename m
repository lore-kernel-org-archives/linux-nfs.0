Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:36611 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751260Ab1HKSUy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Aug 2011 14:20:54 -0400
From: Jim Rees <rees@umich.edu>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH] nfs-utils/blkmapd: Add complex block layout discovery and mapping daemon
Date: Thu, 11 Aug 2011 14:20:48 -0400
Message-Id: <1313086848-7435-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This daemon is required to handle upcalls from the kernel pnfs block layout
driver.

Signed-off-by: Jim Rees <rees@umich.edu>
---
 .gitignore                       |    1 +
 configure.ac                     |    4 +
 utils/Makefile.am                |    4 +
 utils/blkmapd/Makefile.am        |   19 ++
 utils/blkmapd/blkmapd.man        |   54 ++++
 utils/blkmapd/device-discovery.c |  453 +++++++++++++++++++++++++++++++++
 utils/blkmapd/device-discovery.h |  162 ++++++++++++
 utils/blkmapd/device-inq.c       |  233 +++++++++++++++++
 utils/blkmapd/device-process.c   |  407 ++++++++++++++++++++++++++++++
 utils/blkmapd/dm-device.c        |  518 ++++++++++++++++++++++++++++++++++++++
 10 files changed, 1855 insertions(+), 0 deletions(-)
 create mode 100644 utils/blkmapd/Makefile.am
 create mode 100644 utils/blkmapd/blkmapd.man
 create mode 100644 utils/blkmapd/device-discovery.c
 create mode 100644 utils/blkmapd/device-discovery.h
 create mode 100644 utils/blkmapd/device-inq.c
 create mode 100644 utils/blkmapd/device-process.c
 create mode 100644 utils/blkmapd/dm-device.c

diff --git a/.gitignore b/.gitignore
index f5b5cf0..7bd9921 100644
--- a/.gitignore
+++ b/.gitignore
@@ -36,6 +36,7 @@ support/include/stamp-h1
 lib*.a
 tools/rpcgen/rpcgen
 tools/rpcdebug/rpcdebug
+utils/blkmapd/blkmapd
 utils/exportfs/exportfs
 utils/idmapd/idmapd
 utils/lockd/lockd
diff --git a/configure.ac b/configure.ac
index c9fb27b..08ef029 100644
--- a/configure.ac
+++ b/configure.ac
@@ -64,11 +64,14 @@ AC_ARG_ENABLE(nfsv4,
 	enable_nfsv4=yes)
 	if test "$enable_nfsv4" = yes; then
 		AC_DEFINE(NFS4_SUPPORTED, 1, [Define this if you want NFSv4 support compiled in])
+		BLKMAPD=blkmapd
 		IDMAPD=idmapd
 	else
 		enable_nfsv4=
+		BLKMAPD=
 		IDMAPD=
 	fi
+	AC_SUBST(BLKMAPD)
 	AC_SUBST(IDMAPD)
 	AC_SUBST(enable_nfsv4)
 	AM_CONDITIONAL(CONFIG_NFSV4, [test "$enable_nfsv4" = "yes"])
@@ -450,6 +453,7 @@ AC_CONFIG_FILES([
 	tools/mountstats/Makefile
 	tools/nfs-iostat/Makefile
 	utils/Makefile
+	utils/blkmapd/Makefile
 	utils/exportfs/Makefile
 	utils/gssd/Makefile
 	utils/idmapd/Makefile
diff --git a/utils/Makefile.am b/utils/Makefile.am
index a0ea116..0d222f0 100644
--- a/utils/Makefile.am
+++ b/utils/Makefile.am
@@ -9,6 +9,10 @@ OPTDIRS += nfsidmap
 endif
 endif
 
+if CONFIG_NFSV4
+OPTDIRS += blkmapd
+endif
+
 if CONFIG_GSS
 OPTDIRS += gssd
 endif
diff --git a/utils/blkmapd/Makefile.am b/utils/blkmapd/Makefile.am
new file mode 100644
index 0000000..70e299e
--- /dev/null
+++ b/utils/blkmapd/Makefile.am
@@ -0,0 +1,19 @@
+## Process this file with automake to produce Makefile.in
+
+#man8_MANS	= blkmapd.man
+
+AM_CFLAGS	+= -D_LARGEFILE64_SOURCE
+sbin_PROGRAMS	= blkmapd
+
+blkmapd_SOURCES = \
+	device-discovery.c \
+	device-inq.c \
+	device-process.c \
+	dm-device.c \
+	\
+	device-discovery.h
+
+blkmapd_LDADD = -ldevmapper ../../support/nfs/libnfs.a
+
+MAINTAINERCLEANFILES = Makefile.in
+
diff --git a/utils/blkmapd/blkmapd.man b/utils/blkmapd/blkmapd.man
new file mode 100644
index 0000000..fd38122
--- /dev/null
+++ b/utils/blkmapd/blkmapd.man
@@ -0,0 +1,54 @@
+.\"
+.\" Copyright 2011, Jim Rees.
+.\"
+.\" You may distribute under the terms of the GNU General Public
+.\" License as specified in the file COPYING that comes with the
+.\" nfs-utils distribution.
+.\"
+.TH blkmapd 8 "11 August 2011"
+.SH NAME
+blkmapd \- pNFS block layout mapping daemon
+.SH SYNOPSIS
+.B "blkmapd [-d] [-f]"
+.SH DESCRIPTION
+The
+.B blkmapd
+daemon performs device discovery and mapping for the parallel NFS (pNFS) block layout
+client [RFC5663].
+.PP
+The pNFS block layout protocol builds a complex storage hierarchy from a set
+of
+.I simple volumes.
+These simple volumes are addressed by content, using a signature on the
+volume to uniquely name each one.
+The daemon locates a volume by examining each block device in the system for
+the given signature.
+.PP
+The topology typically consists of a hierarchy of volumes built by striping,
+slicing, and concatenating the simple volumes.
+The
+.B blkmapd
+daemon uses the device-mapper driver to construct logical devices that
+reflect the server topology, and passes these devices to the kernel for use
+by the pNFS block layout client.
+.SH OPTIONS
+.TP
+.B -d
+Performs device discovery only then exits.
+.TP
+.B -f
+Runs
+.B blkmapd
+in the foreground and sends output to stderr (as opposed to syslogd)
+.SH SEE ALSO
+.BR nfs (5),
+.BR dmsetup (8)
+.sp
+RFC 5661 for the NFS version 4.1 specification.
+.br
+RFC 5663 for the pNFS block layout specification.
+.SH AUTHORS
+.br
+Haiying Tang <Tang_Haiying@emc.com>
+.br
+Jim Rees <rees@umich.edu>
diff --git a/utils/blkmapd/device-discovery.c b/utils/blkmapd/device-discovery.c
new file mode 100644
index 0000000..c21de3e
--- /dev/null
+++ b/utils/blkmapd/device-discovery.c
@@ -0,0 +1,453 @@
+/*
+ * device-discovery.c: main function, discovering device and processing
+ * pipe request from kernel.
+ *
+ * Copyright (c) 2010 EMC Corporation, Haiying Tang <Tang_Haiying@emc.com>
+ * All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
+ * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
+ * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
+ * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
+ * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
+ * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
+ * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <sys/ioctl.h>
+#include <sys/mount.h>
+#include <sys/select.h>
+#include <linux/kdev_t.h>
+#include <scsi/scsi.h>
+#include <scsi/scsi_ioctl.h>
+#include <scsi/sg.h>
+
+#include <stdlib.h>
+#include <stdio.h>
+#include <string.h>
+#include <syslog.h>
+#include <dirent.h>
+#include <ctype.h>
+#include <fcntl.h>
+#include <unistd.h>
+#include <libgen.h>
+#include <errno.h>
+#include <libdevmapper.h>
+
+#include "device-discovery.h"
+
+#define BL_PIPE_FILE	"/var/lib/nfs/rpc_pipefs/nfs/blocklayout"
+#define PID_FILE	"/var/run/blkmapd.pid"
+
+struct bl_disk *visible_disk_list;
+
+struct bl_disk_path *bl_get_path(const char *filepath,
+				 struct bl_disk_path *paths)
+{
+	struct bl_disk_path *tmp = paths;
+
+	while (tmp) {
+		if (!strcmp(tmp->full_path, filepath))
+			break;
+		tmp = tmp->next;
+	}
+	return tmp;
+}
+
+/* Check whether valid_path is a substring(partition) of path */
+int bl_is_partition(struct bl_disk_path *valid_path, struct bl_disk_path *path)
+{
+	if (!strncmp(valid_path->full_path, path->full_path,
+		     strlen(valid_path->full_path)))
+		return 1;
+
+	return 0;
+}
+
+/*
+ * For multipath devices, devices state could be PASSIVE/ACTIVE/PSEUDO,
+ * where PSEUDO > ACTIVE > PASSIVE. Device with highest state is used to
+ * create pseudo device. So if state is higher, the device path needs to
+ * be updated.
+ * If device-mapper multipath support is a must, pseudo devices should
+ * exist for each multipath device. If not, active device path will be
+ * chosen for device creation.
+ * Treat partition as invalid path.
+ */
+int bl_update_path(struct bl_disk_path *path, enum bl_path_state_e state,
+		   struct bl_disk *disk)
+{
+	struct bl_disk_path *valid_path = disk->valid_path;
+
+	if (valid_path) {
+		if (valid_path->state >= state) {
+			if (bl_is_partition(valid_path, path))
+				return 0;
+		}
+	}
+	return 1;
+}
+
+void bl_release_disk(void)
+{
+	struct bl_disk *disk;
+	struct bl_disk_path *path = NULL;
+
+	while (visible_disk_list) {
+		disk = visible_disk_list;
+		path = disk->paths;
+		while (path) {
+			disk->paths = path->next;
+			free(path->full_path);
+			free(path);
+			path = disk->paths;
+		}
+		if (disk->serial)
+			free(disk->serial);
+		visible_disk_list = disk->next;
+		free(disk);
+	}
+}
+
+void bl_add_disk(char *filepath)
+{
+	struct bl_disk *disk = NULL;
+	int fd = 0;
+	struct stat sb;
+	off_t size = 0;
+	struct bl_serial *serial = NULL;
+	enum bl_path_state_e ap_state;
+	struct bl_disk_path *diskpath = NULL, *path = NULL;
+	dev_t dev;
+
+	fd = open(filepath, O_RDONLY | O_LARGEFILE);
+	if (fd < 0)
+		return;
+
+	if (fstat(fd, &sb)) {
+		close(fd);
+		return;
+	}
+
+	if (!sb.st_size)
+		ioctl(fd, BLKGETSIZE, &size);
+	else
+		size = sb.st_size;
+
+	if (!size) {
+		close(fd);
+		return;
+	}
+
+	dev = sb.st_rdev;
+	serial = bldev_read_serial(fd, filepath);
+	if (dm_is_dm_major(major(dev)))
+		ap_state = BL_PATH_STATE_PSEUDO;
+	else
+		ap_state = bldev_read_ap_state(fd);
+	close(fd);
+
+	if (ap_state != BL_PATH_STATE_ACTIVE)
+		return;
+
+	for (disk = visible_disk_list; disk != NULL; disk = disk->next) {
+		/* Already scanned or a partition?
+		 * XXX: if released each time, maybe not need to compare
+		 */
+		if ((serial->len == disk->serial->len) &&
+		    !memcmp(serial->data, disk->serial->data, serial->len)) {
+			diskpath = bl_get_path(filepath, disk->paths);
+			break;
+		}
+	}
+
+	if (disk && diskpath)
+		return;
+
+	/* add path */
+	path = malloc(sizeof(struct bl_disk_path));
+	if (!path) {
+		BL_LOG_ERR("%s: Out of memory!\n", __func__);
+		goto out_err;
+	}
+	path->next = NULL;
+	path->state = ap_state;
+	path->full_path = strdup(filepath);
+	if (!path->full_path)
+		goto out_err;
+
+	if (!disk) {		/* add disk */
+		disk = malloc(sizeof(struct bl_disk));
+		if (!disk) {
+			BL_LOG_ERR("%s: Out of memory!\n", __func__);
+			goto out_err;
+		}
+		disk->next = visible_disk_list;
+		disk->dev = dev;
+		disk->size = size;
+		disk->serial = serial;
+		disk->valid_path = path;
+		disk->paths = path;
+		visible_disk_list = disk;
+	} else {
+		path->next = disk->paths;
+		disk->paths = path;
+		/* check whether we need to update disk info */
+		if (bl_update_path(path, path->state, disk)) {
+			disk->dev = dev;
+			disk->size = size;
+			disk->valid_path = path;
+		}
+	}
+	return;
+
+ out_err:
+	if (path) {
+		if (path->full_path)
+			free(path->full_path);
+		free(path);
+	}
+	return;
+}
+
+int bl_discover_devices(void)
+{
+	FILE *f;
+	int n;
+	char buf[PATH_MAX], devname[PATH_MAX], fulldevname[PATH_MAX];
+
+	/* release previous list */
+	bl_release_disk();
+
+	/* scan all block devices */
+	f = fopen("/proc/partitions", "r");
+	if (f == NULL)
+		return 0;
+
+	while (1) {
+		if (fgets(buf, sizeof buf, f) == NULL)
+			break;
+		n = sscanf(buf, "%*d %*d %*d %31s", devname);
+		if (n != 1)
+			continue;
+		snprintf(fulldevname, sizeof fulldevname, "/sys/block/%s",
+			 devname);
+		if (access(fulldevname, F_OK) < 0)
+			continue;
+		snprintf(fulldevname, sizeof fulldevname, "/dev/%s", devname);
+		bl_add_disk(fulldevname);
+	}
+
+	fclose(f);
+
+	return 0;
+}
+
+/* process kernel request
+ * return 0: request processed, and no more request waiting;
+ * return 1: request processed, and more requests waiting;
+ * return < 0: error
+ */
+int bl_disk_inquiry_process(int fd)
+{
+	int ret = 0;
+	struct bl_pipemsg_hdr head;
+	char *buf = NULL;
+	uint32_t major, minor;
+	uint16_t buflen;
+	struct bl_dev_msg reply;
+
+	/* read request */
+	if (atomicio(read, fd, &head, sizeof(head)) != sizeof(head)) {
+		/* Note that an error in this or the next read is pretty
+		 * catastrophic, as there is no good way to resync into
+		 * the pipe's stream.
+		 */
+		BL_LOG_ERR("Read pipefs head error!\n");
+		ret = -EIO;
+		goto out;
+	}
+
+	buflen = head.totallen;
+	buf = malloc(buflen);
+	if (!buf) {
+		BL_LOG_ERR("%s: Out of memory!\n", __func__);
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	if (atomicio(read, fd, buf, buflen) != buflen) {
+		BL_LOG_ERR("Read pipefs content error!\n");
+		ret = -EIO;
+		goto out;
+	}
+
+	reply.status = BL_DEVICE_REQUEST_PROC;
+
+	switch (head.type) {
+	case BL_DEVICE_MOUNT:
+		/*
+		 * It shouldn't be necessary to discover devices here, since
+		 * process_deviceinfo() will re-discover if it can't find
+		 * the devices it needs.  But in the case of multipath
+		 * devices (ones that appear more than once, for example an
+		 * active and a standby LUN), this will re-order them in the
+		 * correct priority.
+		 */
+		bl_discover_devices();
+		if (!process_deviceinfo(buf, buflen, &major, &minor)) {
+			reply.status = BL_DEVICE_REQUEST_ERR;
+			break;
+		}
+		reply.major = major;
+		reply.minor = minor;
+		break;
+	case BL_DEVICE_UMOUNT:
+		if (!dm_device_remove_all((uint64_t *) buf))
+			reply.status = BL_DEVICE_REQUEST_ERR;
+		break;
+	default:
+		reply.status = BL_DEVICE_REQUEST_ERR;
+		break;
+	}
+
+	/* write to pipefs */
+	if (atomicio((void *)write, fd, &reply, sizeof(reply))
+	    != sizeof(reply)) {
+		BL_LOG_ERR("Write pipefs error!\n");
+		ret = -EIO;
+	}
+
+ out:
+	if (buf)
+		free(buf);
+	return ret;
+}
+
+/* TODO: set bl_process_stop to 1 in command */
+unsigned int bl_process_stop;
+
+int bl_run_disk_inquiry_process(int fd)
+{
+	fd_set rset;
+	int ret;
+
+	bl_process_stop = 0;
+
+	for (;;) {
+		if (bl_process_stop)
+			return 1;
+		FD_ZERO(&rset);
+		FD_SET(fd, &rset);
+		ret = 0;
+		switch (select(fd + 1, &rset, NULL, NULL, NULL)) {
+		case -1:
+			if (errno == EINTR)
+				continue;
+			else {
+				ret = -errno;
+				goto out;
+			}
+		case 0:
+			goto out;
+		default:
+			if (FD_ISSET(fd, &rset))
+				ret = bl_disk_inquiry_process(fd);
+		}
+	}
+ out:
+	return ret;
+}
+
+/* Daemon */
+int main(int argc, char **argv)
+{
+	int fd, pidfd = -1, opt, dflag = 0, fg = 0, ret = 1;
+	struct stat statbuf;
+	char pidbuf[64];
+
+	while ((opt = getopt(argc, argv, "df")) != -1) {
+		switch (opt) {
+		case 'd':
+			dflag = 1;
+			break;
+		case 'f':
+			fg = 1;
+			break;
+		}
+	}
+
+	if (fg) {
+		openlog("blkmapd", LOG_PERROR, 0);
+	} else {
+		if (!stat(PID_FILE, &statbuf)) {
+			fprintf(stderr, "Pid file %s already existed\n", PID_FILE);
+			exit(1);
+		}
+
+		if (daemon(0, 0) != 0) {
+			fprintf(stderr, "Daemonize failed\n");
+			exit(1);
+		}
+
+		openlog("blkmapd", LOG_PID, 0);
+		pidfd = open(PID_FILE, O_WRONLY | O_CREAT, 0644);
+		if (pidfd < 0) {
+			BL_LOG_ERR("Create pid file %s failed\n", PID_FILE);
+			exit(1);
+		}
+
+		if (lockf(pidfd, F_TLOCK, 0) < 0) {
+			BL_LOG_ERR("Lock pid file %s failed\n", PID_FILE);
+			close(pidfd);
+			exit(1);
+		}
+		ftruncate(pidfd, 0);
+		sprintf(pidbuf, "%d\n", getpid());
+		write(pidfd, pidbuf, strlen(pidbuf));
+	}
+
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
+	}
+
+	while (1) {
+		/* discover device when needed */
+		bl_discover_devices();
+
+		ret = bl_run_disk_inquiry_process(fd);
+		if (ret < 0) {
+			/* what should we do with process error? */
+			BL_LOG_ERR("inquiry process return %d\n", ret);
+		}
+	}
+
+	if (pidfd >= 0) {
+		close(pidfd);
+		unlink(PID_FILE);
+	}
+
+	exit(ret);
+}
diff --git a/utils/blkmapd/device-discovery.h b/utils/blkmapd/device-discovery.h
new file mode 100644
index 0000000..a86eed9
--- /dev/null
+++ b/utils/blkmapd/device-discovery.h
@@ -0,0 +1,162 @@
+/*
+ * bl-device-discovery.h
+ *
+ * Copyright (c) 2010 EMC Corporation, Haiying Tang <Tang_Haiying@emc.com>
+ * All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
+ * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
+ * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
+ * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
+ * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
+ * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
+ * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+#ifndef BL_DEVICE_DISCOVERY_H
+#define BL_DEVICE_DISCOVERY_H
+
+#include <stdint.h>
+
+enum blk_vol_type {
+	BLOCK_VOLUME_SIMPLE = 0,	/* maps to a single LU */
+	BLOCK_VOLUME_SLICE = 1,		/* slice of another volume */
+	BLOCK_VOLUME_CONCAT = 2,	/* concatenation of multiple volumes */
+	BLOCK_VOLUME_STRIPE = 3,	/* striped across multiple volumes */
+	BLOCK_VOLUME_PSEUDO = 4,
+};
+
+/* All disk offset/lengths are stored in 512-byte sectors */
+struct bl_volume {
+	uint32_t bv_type;
+	off_t bv_size;
+	struct bl_volume **bv_vols;
+	int bv_vol_n;
+	union {
+		dev_t bv_dev;		/* for BLOCK_VOLUME_SIMPLE(PSEUDO) */
+		off_t bv_stripe_unit;	/* for BLOCK_VOLUME_STRIPE(CONCAT) */
+		off_t bv_offset;	/* for BLOCK_VOLUME_SLICE */
+	} param;
+};
+
+struct bl_sig_comp {
+	int64_t bs_offset;		/* In bytes */
+	uint32_t bs_length;		/* In bytes */
+	char *bs_string;
+};
+
+/* Maximum number of signatures components in a simple volume */
+# define BLOCK_MAX_SIG_COMP 16
+
+struct bl_sig {
+	int si_num_comps;
+	struct bl_sig_comp si_comps[BLOCK_MAX_SIG_COMP];
+};
+
+/*
+ * Multipath support: ACTIVE or PSEUDO device is valid,
+ *		      PASSIVE is a standby for ACTIVE.
+ */
+enum bl_path_state_e {
+	BL_PATH_STATE_PASSIVE = 1,
+	BL_PATH_STATE_ACTIVE = 2,
+	BL_PATH_STATE_PSEUDO = 3,
+};
+
+struct bl_serial {
+	int len;
+	char *data;
+};
+
+struct bl_disk_path {
+	struct bl_disk_path *next;
+	char *full_path;
+	enum bl_path_state_e state;
+};
+
+struct bl_disk {
+	struct bl_disk *next;
+	struct bl_serial *serial;
+	dev_t dev;
+	off_t size;			/* in 512-byte sectors */
+	struct bl_disk_path *valid_path;
+	struct bl_disk_path *paths;
+};
+
+struct bl_dev_id {
+	unsigned char type;
+	unsigned char ids;
+	unsigned char reserve;
+	unsigned char len;
+	char data[0];
+};
+
+struct bl_dev_msg {
+	int status;
+	uint32_t major, minor;
+};
+
+struct bl_pipemsg_hdr {
+	uint8_t type;
+	uint16_t totallen;		/* length of message excluding hdr */
+};
+
+#define BL_DEVICE_UMOUNT                0x0	/* Umount--delete devices */
+#define BL_DEVICE_MOUNT                 0x1	/* Mount--create devices */
+#define BL_DEVICE_REQUEST_INIT          0x0	/* Start request */
+#define BL_DEVICE_REQUEST_PROC          0x1	/* User process succeeds */
+#define BL_DEVICE_REQUEST_ERR           0x2	/* User process fails */
+
+uint32_t *blk_overflow(uint32_t * p, uint32_t * end, size_t nbytes);
+
+#define BLK_READBUF(p, e, nbytes)  do { \
+	p = blk_overflow(p, e, nbytes); \
+	if (!p) {\
+		goto out_err;\
+	} \
+} while (0)
+
+#define READ32(x)         (x) = ntohl(*p++)
+
+#define READ64(x)         do {                  \
+	(x) = (uint64_t)ntohl(*p++) << 32;           \
+	(x) |= ntohl(*p++);                     \
+} while (0)
+
+#define READ_SECTOR(x)     do { \
+	READ64(tmp); \
+	if (tmp & 0x1ff) { \
+		goto out_err; \
+	} \
+	(x) = tmp >> 9; \
+} while (0)
+
+extern struct bl_disk *visible_disk_list;
+uint64_t dm_device_create(struct bl_volume *vols, int num_vols);
+int dm_device_remove_all(uint64_t *dev);
+uint64_t process_deviceinfo(const char *dev_addr_buf,
+			    unsigned int dev_addr_len,
+			    uint32_t *major, uint32_t *minor);
+
+extern ssize_t atomicio(ssize_t(*f) (int, void *, size_t),
+			int fd, void *_s, size_t n);
+extern struct bl_serial *bldev_read_serial(int fd, const char *filename);
+extern enum bl_path_state_e bldev_read_ap_state(int fd);
+extern int bl_discover_devices(void);
+
+#define BL_LOG_INFO(fmt...)		syslog(LOG_INFO, fmt)
+#define BL_LOG_WARNING(fmt...)		syslog(LOG_WARNING, fmt)
+#define BL_LOG_ERR(fmt...)		syslog(LOG_ERR, fmt)
+#define BL_LOG_DEBUG(fmt...)		syslog(LOG_DEBUG, fmt)
+#endif
diff --git a/utils/blkmapd/device-inq.c b/utils/blkmapd/device-inq.c
new file mode 100644
index 0000000..eabc70c
--- /dev/null
+++ b/utils/blkmapd/device-inq.c
@@ -0,0 +1,233 @@
+/*
+ * device-inq.c: inquire SCSI device information.
+ *
+ * Copyright (c) 2010 EMC Corporation, Haiying Tang <Tang_Haiying@emc.com>
+ * All rights reserved.
+ *
+ * This program refers to "SCSI Primary Commands - 3 (SPC-3)
+ * at http://www.t10.org and sg_inq.c in sg3_utils-1.26 for
+ * Linux OS SCSI subsystem, by D. Gilbert.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
+ * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
+ * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
+ * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
+ * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
+ * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
+ * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <sys/ioctl.h>
+#include <sys/mount.h>
+#include <sys/select.h>
+#include <scsi/scsi.h>
+#include <scsi/scsi_ioctl.h>
+#include <scsi/sg.h>
+
+#include <stdlib.h>
+#include <stdio.h>
+#include <unistd.h>
+#include <string.h>
+#include <syslog.h>
+#include <dirent.h>
+#include <ctype.h>
+#include <fcntl.h>
+#include <libgen.h>
+#include <errno.h>
+
+#include "device-discovery.h"
+
+#define DEF_ALLOC_LEN	255
+#define MX_ALLOC_LEN	(0xc000 + 0x80)
+
+static struct bl_serial *bl_create_scsi_string(int len, const char *bytes)
+{
+	struct bl_serial *s;
+
+	s = malloc(sizeof(*s) + len);
+	if (s) {
+		s->data = (char *)&s[1];
+		s->len = len;
+		memcpy(s->data, bytes, len);
+	}
+	return s;
+}
+
+static void bl_free_scsi_string(struct bl_serial *str)
+{
+	if (str)
+		free(str);
+}
+
+#define sg_io_ok(io_hdr) \
+	((((io_hdr).status & 0x7e) == 0) && \
+	((io_hdr).host_status == 0) && \
+	(((io_hdr).driver_status & 0x0f) == 0))
+
+static int sg_timeout = 1 * 1000;
+
+static int bldev_inquire_page(int fd, int page, char *buffer, int len)
+{
+	unsigned char cmd[] = { INQUIRY, 0, 0, 0, 0, 0 };
+	unsigned char sense_b[28];
+	struct sg_io_hdr io_hdr;
+	if (page >= 0) {
+		cmd[1] = 1;
+		cmd[2] = page;
+	}
+	cmd[3] = (unsigned char)((len >> 8) & 0xff);
+	cmd[4] = (unsigned char)(len & 0xff);
+
+	memset(&io_hdr, 0, sizeof(struct sg_io_hdr));
+	io_hdr.interface_id = 'S';
+	io_hdr.cmd_len = sizeof(cmd);
+	io_hdr.mx_sb_len = sizeof(sense_b);
+	io_hdr.dxfer_direction = SG_DXFER_FROM_DEV;
+	io_hdr.dxfer_len = len;
+	io_hdr.dxferp = buffer;
+	io_hdr.cmdp = cmd;
+	io_hdr.sbp = sense_b;
+	io_hdr.timeout = sg_timeout;
+	if (ioctl(fd, SG_IO, &io_hdr) < 0)
+		return -1;
+
+	if (sg_io_ok(io_hdr))
+		return 0;
+	return -1;
+}
+
+static int bldev_inquire_pages(int fd, int page, char **buffer)
+{
+	int status = 0;
+	char *tmp;
+	int len;
+
+	*buffer = calloc(DEF_ALLOC_LEN, sizeof(char));
+	if (!*buffer) {
+		BL_LOG_ERR("%s: Out of memory!\n", __func__);
+		return -ENOMEM;
+	}
+
+	status = bldev_inquire_page(fd, page, *buffer, DEF_ALLOC_LEN);
+	if (status)
+		goto out;
+
+	status = -1;
+	if ((*(*buffer + 1) & 0xff) != page)
+		goto out;
+
+	len = (*(*buffer + 2) << 8) + *(*buffer + 3) + 4;
+	if (len > MX_ALLOC_LEN) {
+		BL_LOG_ERR("SCSI response length too long: %d\n", len);
+		goto out;
+	}
+	if (len > DEF_ALLOC_LEN) {
+		tmp = realloc(*buffer, len);
+		if (!tmp) {
+			BL_LOG_ERR("%s: Out of memory!\n", __func__);
+			status = -ENOMEM;
+			goto out;
+		}
+		*buffer = tmp;
+		status = bldev_inquire_page(fd, page, *buffer, len);
+		if (status)
+			goto out;
+	}
+	status = 0;
+ out:
+	return status;
+}
+
+/* For EMC multipath devices, use VPD page (0xc0) to get status.
+ * For other devices, return ACTIVE for now
+ */
+extern enum bl_path_state_e bldev_read_ap_state(int fd)
+{
+	int status = 0;
+	char *buffer = NULL;
+	enum bl_path_state_e ap_state = BL_PATH_STATE_ACTIVE;
+
+	status = bldev_inquire_pages(fd, 0xc0, &buffer);
+	if (status)
+		goto out;
+
+	if (buffer[4] < 0x02)
+		ap_state = BL_PATH_STATE_PASSIVE;
+ out:
+	if (buffer)
+		free(buffer);
+	return ap_state;
+}
+
+struct bl_serial *bldev_read_serial(int fd, const char *filename)
+{
+	struct bl_serial *serial_out = NULL;
+	int status = 0;
+	char *buffer;
+	struct bl_dev_id *dev_root, *dev_id;
+	unsigned int pos, len, current_id = 0;
+
+	status = bldev_inquire_pages(fd, 0x83, &buffer);
+	if (status)
+		goto out;
+
+	dev_root = (struct bl_dev_id *)buffer;
+
+	pos = 0;
+	current_id = 0;
+	len = dev_root->len;
+	while (pos < (len - sizeof(struct bl_dev_id) + sizeof(unsigned char))) {
+		dev_id = (struct bl_dev_id *)&(dev_root->data[pos]);
+		if ((dev_id->ids & 0xf) < current_id)
+			continue;
+		switch (dev_id->ids & 0xf) {
+			/* We process SCSI ID with four ID cases: 0, 1, 2 and 3.
+			 * When more than one ID is available, priority is
+			 * 3>2>1>0.
+			 */
+		case 2:	/* EUI-64 based */
+			if ((dev_id->len != 8) && (dev_id->len != 12) &&
+			    (dev_id->len != 16))
+				break;
+		case 3:	/* NAA */
+			/* TODO: NAA validity judgement too complicated,
+			 * so just ingore it here.
+			 */
+			if ((dev_id->type & 0xf) != 1) {
+				BL_LOG_ERR("Binary code_set expected\n");
+				break;
+			}
+		case 0:	/* vendor specific */
+		case 1:	/* T10 vendor identification */
+			current_id = dev_id->ids & 0xf;
+			if (serial_out)
+				bl_free_scsi_string(serial_out);
+			serial_out = bl_create_scsi_string(dev_id->len,
+							   dev_id->data);
+			break;
+		}
+		if (current_id == 3)
+			break;
+		pos += (dev_id->len + sizeof(struct bl_dev_id) -
+			sizeof(unsigned char));
+	}
+ out:
+	if (!serial_out)
+		serial_out = bl_create_scsi_string(strlen(filename), filename);
+	if (buffer)
+		free(buffer);
+	return serial_out;
+}
diff --git a/utils/blkmapd/device-process.c b/utils/blkmapd/device-process.c
new file mode 100644
index 0000000..27ff374
--- /dev/null
+++ b/utils/blkmapd/device-process.c
@@ -0,0 +1,407 @@
+/*
+ * device-process.c: detailed processing of device information sent
+ * from kernel.
+ *
+ * Copyright (c) 2006 The Regents of the University of Michigan.
+ * All rights reserved.
+ *
+ *  Andy Adamson <andros@citi.umich.edu>
+ *  Fred Isaman <iisaman@umich.edu>
+ *
+ * Copyright (c) 2010 EMC Corporation, Haiying Tang <Tang_Haiying@emc.com>
+ *
+ * Used codes in linux/fs/nfs/blocklayout/blocklayoutdev.c.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
+ * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
+ * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
+ * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
+ * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
+ * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
+ * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <sys/user.h>
+#include <arpa/inet.h>
+#include <linux/kdev_t.h>
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <unistd.h>
+#include <syslog.h>
+#include <fcntl.h>
+#include <errno.h>
+
+#include "device-discovery.h"
+
+static char *pretty_sig(char *sig, uint32_t siglen)
+{
+	static char rs[100];
+	uint64_t sigval;
+	unsigned int i;
+
+	if (siglen <= sizeof(sigval)) {
+		sigval = 0;
+		for (i = 0; i < siglen; i++)
+			sigval |= ((unsigned char *)sig)[i] << (i * 8);
+		sprintf(rs, "0x%0llx", (unsigned long long) sigval);
+	} else {
+		if (siglen > sizeof rs - 4) {
+			siglen = sizeof rs - 4;
+			sprintf(&rs[siglen], "...");
+		} else
+			rs[siglen] = '\0';
+		memcpy(rs, sig, siglen);
+	}
+	return rs;
+}
+
+uint32_t *blk_overflow(uint32_t * p, uint32_t * end, size_t nbytes)
+{
+	uint32_t *q = p + ((nbytes + 3) >> 2);
+
+	if (q > end || q < p)
+		return NULL;
+	return p;
+}
+
+static int decode_blk_signature(uint32_t **pp, uint32_t * end,
+				struct bl_sig *sig)
+{
+	int i;
+	uint32_t siglen, *p = *pp;
+
+	BLK_READBUF(p, end, 4);
+	READ32(sig->si_num_comps);
+	if (sig->si_num_comps == 0) {
+		BL_LOG_ERR("0 components in sig\n");
+		goto out_err;
+	}
+	if (sig->si_num_comps >= BLOCK_MAX_SIG_COMP) {
+		BL_LOG_ERR("number of sig comps %i >= BLOCK_MAX_SIG_COMP\n",
+			   sig->si_num_comps);
+		goto out_err;
+	}
+	for (i = 0; i < sig->si_num_comps; i++) {
+		struct bl_sig_comp *comp = &sig->si_comps[i];
+
+		BLK_READBUF(p, end, 12);
+		READ64(comp->bs_offset);
+		READ32(siglen);
+		comp->bs_length = siglen;
+		BLK_READBUF(p, end, siglen);
+		/* Note we rely here on fact that sig is used immediately
+		 * for mapping, then thrown away.
+		 */
+		comp->bs_string = (char *)p;
+		BL_LOG_INFO("%s: si_comps[%d]: bs_length %d, bs_string %s\n",
+			    __func__, i, siglen,
+			    pretty_sig(comp->bs_string, siglen));
+		p += ((siglen + 3) >> 2);
+	}
+	*pp = p;
+	return 0;
+ out_err:
+	return -EIO;
+}
+
+/*
+ * Read signature from device and compare to sig_comp
+ * return: 0=match, 1=no match, -1=error
+ */
+static int
+read_cmp_blk_sig(struct bl_disk *disk, int fd, struct bl_sig_comp *comp)
+{
+	const char *dev_name = disk->valid_path->full_path;
+	int ret = -1;
+	ssize_t siglen = comp->bs_length;
+	int64_t bs_offset = comp->bs_offset;
+	char *sig = NULL;
+
+	sig = (char *)malloc(siglen);
+	if (!sig) {
+		BL_LOG_ERR("%s: Out of memory\n", __func__);
+		goto out;
+	}
+
+	if (bs_offset < 0)
+		bs_offset += (((int64_t) disk->size) << 9);
+	if (lseek64(fd, bs_offset, SEEK_SET) == -1) {
+		BL_LOG_ERR("File %s lseek error\n", dev_name);
+		goto out;
+	}
+
+	if (read(fd, sig, siglen) != siglen) {
+		BL_LOG_ERR("File %s read error\n", dev_name);
+		goto out;
+	}
+
+	ret = memcmp(sig, comp->bs_string, siglen);
+	if (!ret)
+		BL_LOG_INFO("%s: %s sig %s at %lld\n", __func__, dev_name,
+			    pretty_sig(sig, siglen),
+			    (long long)comp->bs_offset);
+
+ out:
+	if (sig)
+		free(sig);
+	return ret;
+}
+
+/*
+ * All signatures in sig must be found on disk for verification.
+ * Returns True if sig matches, False otherwise.
+ */
+static int verify_sig(struct bl_disk *disk, struct bl_sig *sig)
+{
+	const char *dev_name = disk->valid_path->full_path;
+	int fd, i, rv;
+
+	fd = open(dev_name, O_RDONLY | O_LARGEFILE);
+	if (fd < 0) {
+		BL_LOG_ERR("%s: %s could not be opened for read\n", __func__,
+			   dev_name);
+		return 0;
+	}
+
+	rv = 1;
+
+	for (i = 0; i < sig->si_num_comps; i++) {
+		if (read_cmp_blk_sig(disk, fd, &sig->si_comps[i])) {
+			rv = 0;
+			break;
+		}
+	}
+
+	if (fd >= 0)
+		close(fd);
+	return rv;
+}
+
+/*
+ * map_sig_to_device()
+ * Given a signature, walk the list of visible disks searching for
+ * a match. Returns True if mapping was done, False otherwise.
+ *
+ * While we're at it, fill in the vol->bv_size.
+ */
+static int map_sig_to_device(struct bl_sig *sig, struct bl_volume *vol)
+{
+	int mapped = 0;
+	struct bl_disk *disk;
+
+	/* scan disk list to find out match device */
+	for (disk = visible_disk_list; disk; disk = disk->next) {
+		/* FIXME: should we use better algorithm for disk scan? */
+		mapped = verify_sig(disk, sig);
+		if (mapped) {
+			vol->param.bv_dev = disk->dev;
+			vol->bv_size = disk->size;
+			break;
+		}
+	}
+	return mapped;
+}
+
+/* We are given an array of XDR encoded array indices, each of which should
+ * refer to a previously decoded device.  Translate into a list of pointers
+ * to the appropriate pnfs_blk_volume's.
+ */
+static int set_vol_array(uint32_t **pp, uint32_t *end,
+			 struct bl_volume *vols, int working)
+{
+	int i, index;
+	uint32_t *p = *pp;
+	struct bl_volume **array = vols[working].bv_vols;
+
+	for (i = 0; i < vols[working].bv_vol_n; i++) {
+		BLK_READBUF(p, end, 4);
+		READ32(index);
+		if ((index < 0) || (index >= working)) {
+			BL_LOG_ERR("set_vol_array: Id %i out of range\n",
+				   index);
+			goto out_err;
+		}
+		array[i] = &vols[index];
+	}
+	*pp = p;
+	return 0;
+ out_err:
+	return -EIO;
+}
+
+static uint64_t sum_subvolume_sizes(struct bl_volume *vol)
+{
+	int i;
+	uint64_t sum = 0;
+
+	for (i = 0; i < vol->bv_vol_n; i++)
+		sum += vol->bv_vols[i]->bv_size;
+	return sum;
+}
+
+static int
+decode_blk_volume(uint32_t **pp, uint32_t *end, struct bl_volume *vols, int voln,
+		  int *array_cnt)
+{
+	int status = 0, j;
+	struct bl_sig sig;
+	uint32_t *p = *pp;
+	struct bl_volume *vol = &vols[voln];
+	uint64_t tmp;
+
+	BLK_READBUF(p, end, 4);
+	READ32(vol->bv_type);
+
+	switch (vol->bv_type) {
+	case BLOCK_VOLUME_SIMPLE:
+		*array_cnt = 0;
+		status = decode_blk_signature(&p, end, &sig);
+		if (status)
+			return status;
+		status = map_sig_to_device(&sig, vol);
+		if (!status) {
+			BL_LOG_ERR("Could not find disk for device\n");
+			return -ENXIO;
+		}
+		BL_LOG_INFO("%s: simple %d\n", __func__, voln);
+		status = 0;
+		break;
+	case BLOCK_VOLUME_SLICE:
+		BLK_READBUF(p, end, 16);
+		READ_SECTOR(vol->param.bv_offset);
+		READ_SECTOR(vol->bv_size);
+		*array_cnt = vol->bv_vol_n = 1;
+		BL_LOG_INFO("%s: slice %d\n", __func__, voln);
+		status = set_vol_array(&p, end, vols, voln);
+		break;
+	case BLOCK_VOLUME_STRIPE:
+		BLK_READBUF(p, end, 8);
+		READ_SECTOR(vol->param.bv_stripe_unit);
+		off_t stripe_unit = vol->param.bv_stripe_unit;
+		/* Check limitations imposed by device-mapper */
+		if ((stripe_unit & (stripe_unit - 1)) != 0
+		    || stripe_unit < (off_t) (PAGE_SIZE >> 9))
+			return -EIO;
+		BLK_READBUF(p, end, 4);
+		READ32(vol->bv_vol_n);
+		if (!vol->bv_vol_n)
+			return -EIO;
+		*array_cnt = vol->bv_vol_n;
+		BL_LOG_INFO("%s: stripe %d nvols=%d unit=%ld\n", __func__, voln,
+			    vol->bv_vol_n, (long)stripe_unit);
+		status = set_vol_array(&p, end, vols, voln);
+		if (status)
+			return status;
+		for (j = 1; j < vol->bv_vol_n; j++) {
+			if (vol->bv_vols[j]->bv_size !=
+			    vol->bv_vols[0]->bv_size) {
+				BL_LOG_ERR("varying subvol size\n");
+				return -EIO;
+			}
+		}
+		vol->bv_size = vol->bv_vols[0]->bv_size * vol->bv_vol_n;
+		break;
+	case BLOCK_VOLUME_CONCAT:
+		BLK_READBUF(p, end, 4);
+		READ32(vol->bv_vol_n);
+		if (!vol->bv_vol_n)
+			return -EIO;
+		*array_cnt = vol->bv_vol_n;
+		BL_LOG_INFO("%s: concat %d %d\n", __func__, voln,
+			    vol->bv_vol_n);
+		status = set_vol_array(&p, end, vols, voln);
+		if (status)
+			return status;
+		vol->bv_size = sum_subvolume_sizes(vol);
+		break;
+	default:
+		BL_LOG_ERR("Unknown volume type %i\n", vol->bv_type);
+ out_err:
+		return -EIO;
+	}
+	*pp = p;
+	return status;
+}
+
+uint64_t process_deviceinfo(const char *dev_addr_buf,
+			    unsigned int dev_addr_len,
+			    uint32_t *major, uint32_t *minor)
+{
+	int num_vols, i, status, count;
+	uint32_t *p, *end;
+	struct bl_volume *vols = NULL, **arrays = NULL, **arrays_ptr = NULL;
+	uint64_t dev = 0;
+
+	p = (uint32_t *) dev_addr_buf;
+	end = (uint32_t *) ((char *)p + dev_addr_len);
+
+	/* Decode block volume */
+	BLK_READBUF(p, end, 4);
+	READ32(num_vols);
+	BL_LOG_INFO("%s: %d vols\n", __func__, num_vols);
+	if (num_vols <= 0)
+		goto out_err;
+
+	vols = (struct bl_volume *)malloc(num_vols * sizeof(struct bl_volume));
+	if (!vols) {
+		BL_LOG_ERR("%s: Out of memory\n", __func__);
+		goto out_err;
+	}
+
+	/* Each volume in vols array needs its own array.  Save time by
+	 * allocating them all in one large hunk.  Because each volume
+	 * array can only reference previous volumes, and because once
+	 * a concat or stripe references a volume, it may never be
+	 * referenced again, the volume arrays are guaranteed to fit
+	 * in the suprisingly small space allocated.
+	 */
+	arrays_ptr = arrays =
+	    (struct bl_volume **)malloc(num_vols * 2 *
+					sizeof(struct bl_volume *));
+	if (!arrays) {
+		BL_LOG_ERR("%s: Out of memory\n", __func__);
+		goto out_err;
+	}
+
+	for (i = 0; i < num_vols; i++) {
+		vols[i].bv_vols = arrays_ptr;
+		status = decode_blk_volume(&p, end, vols, i, &count);
+		if (status)
+			goto out_err;
+		arrays_ptr += count;
+	}
+
+	if (p != end) {
+		BL_LOG_ERR("p is not equal to end!\n");
+		goto out_err;
+	}
+
+	dev = dm_device_create(vols, num_vols);
+	if (dev) {
+		*major = MAJOR(dev);
+		*minor = MINOR(dev);
+	}
+
+ out_err:
+	if (vols)
+		free(vols);
+	if (arrays)
+		free(arrays);
+	return dev;
+}
diff --git a/utils/blkmapd/dm-device.c b/utils/blkmapd/dm-device.c
new file mode 100644
index 0000000..0f4f148
--- /dev/null
+++ b/utils/blkmapd/dm-device.c
@@ -0,0 +1,518 @@
+/*
+ * dm-device.c: create or remove device via device mapper API.
+ *
+ * Copyright (c) 2010 EMC Corporation, Haiying Tang <Tang_Haiying@emc.com>
+ * All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
+ * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
+ * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
+ * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
+ * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
+ * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
+ * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <linux/kdev_t.h>
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <string.h>
+#include <syslog.h>
+#include <fcntl.h>
+#include <errno.h>
+#include <libdevmapper.h>
+
+#include "device-discovery.h"
+
+#define DM_DEV_NAME_LEN		256
+
+#ifndef DM_MAX_TYPE_NAME
+#define DM_MAX_TYPE_NAME	16
+#endif
+
+#define DM_PARAMS_LEN		512	/* XXX: is this enough for target? */
+#define TYPE_HAS_DEV(type)	((type == BLOCK_VOLUME_SIMPLE) || \
+			 (type == BLOCK_VOLUME_PSEUDO))
+
+struct bl_dm_table {
+	uint64_t offset;
+	uint64_t size;
+	char target_type[DM_MAX_TYPE_NAME];
+	char params[DM_PARAMS_LEN];
+	struct bl_dm_table *next;
+};
+
+struct bl_dm_tree {
+	uint64_t dev;
+	struct dm_tree *tree;
+	struct bl_dm_tree *next;
+};
+
+static const char dm_name[] = "pnfs_vol_%u";
+
+static unsigned int dev_count;
+
+static inline struct bl_dm_table *bl_dm_table_alloc(void)
+{
+	return (struct bl_dm_table *)calloc(1, sizeof(struct bl_dm_table));
+}
+
+static void bl_dm_table_free(struct bl_dm_table *bl_table_head)
+{
+	struct bl_dm_table *p;
+
+	while (bl_table_head) {
+		p = bl_table_head->next;
+		free(bl_table_head);
+		bl_table_head = p;
+	}
+}
+
+static void add_to_bl_dm_table(struct bl_dm_table **bl_table_head,
+			struct bl_dm_table *table)
+{
+	struct bl_dm_table *p;
+
+	if (!*bl_table_head) {
+		*bl_table_head = table;
+		return;
+	}
+	p = *bl_table_head;
+	while (p->next)
+		p = p->next;
+	p->next = table;
+}
+
+struct bl_dm_tree *bl_tree_head;
+
+static struct bl_dm_tree *find_bl_dm_tree(uint64_t dev)
+{
+	struct bl_dm_tree *p;
+
+	for (p = bl_tree_head; p; p = p->next) {
+		if (p->dev == dev)
+			break;
+	}
+	return p;
+}
+
+static void del_from_bl_dm_tree(uint64_t dev)
+{
+	struct bl_dm_tree *p, *pre = bl_tree_head;
+
+	for (p = pre; p; p = p->next) {
+		if (p->dev == dev) {
+			pre->next = p->next;
+			if (p == bl_tree_head)
+				bl_tree_head = bl_tree_head->next;
+			free(p);
+			break;
+		}
+		pre = p;
+	}
+}
+
+static void add_to_bl_dm_tree(struct bl_dm_tree *tree)
+{
+	struct bl_dm_tree *p;
+
+	if (!bl_tree_head) {
+		bl_tree_head = tree;
+		return;
+	}
+	p = bl_tree_head;
+	while (p->next)
+		p = p->next;
+	p->next = tree;
+	return;
+}
+
+/*
+ * Create device via device mapper
+ * return 0 when creation failed
+ * return dev no for created device
+ */
+static uint64_t
+dm_device_create_mapped(const char *dev_name, struct bl_dm_table *p)
+{
+	struct dm_task *dmt;
+	struct dm_info dminfo;
+	int ret = 0;
+
+	dmt = dm_task_create(DM_DEVICE_CREATE);
+	if (!dmt) {
+		BL_LOG_ERR("Create dm_task for %s failed\n", dev_name);
+		return 0;
+	}
+	ret = dm_task_set_name(dmt, dev_name);
+	if (!ret)
+		goto err_out;
+
+	while (p) {
+		ret =
+		    dm_task_add_target(dmt, p->offset, p->size, p->target_type,
+				       p->params);
+		if (!ret)
+			goto err_out;
+		p = p->next;
+	}
+
+	ret = dm_task_run(dmt) && dm_task_get_info(dmt, &dminfo)
+	    && dminfo.exists;
+
+	if (!ret)
+		goto err_out;
+
+	dm_task_update_nodes();
+
+ err_out:
+	dm_task_destroy(dmt);
+
+	if (!ret) {
+		BL_LOG_ERR("Create device %s failed\n", dev_name);
+		return 0;
+	}
+	return MKDEV(dminfo.major, dminfo.minor);
+}
+
+static int dm_device_remove_byname(const char *dev_name)
+{
+	struct dm_task *dmt;
+	int ret = 0;
+
+	BL_LOG_INFO("%s: %s\n", __func__, dev_name);
+
+	dmt = dm_task_create(DM_DEVICE_REMOVE);
+	if (!dmt)
+		return 0;
+
+	ret = dm_task_set_name(dmt, dev_name) && dm_task_run(dmt);
+
+	dm_task_update_nodes();
+	dm_task_destroy(dmt);
+
+	return ret;
+}
+
+int dm_device_remove(uint64_t dev)
+{
+	struct dm_task *dmt;
+	struct dm_names *dmnames;
+	char *name = NULL;
+	int ret = 0;
+
+	/* Look for dev_name via dev, if dev_name could be transferred here,
+	   we could jump to DM_DEVICE_REMOVE directly */
+
+	dmt = dm_task_create(DM_DEVICE_LIST);
+	if (!dmt) {
+		BL_LOG_ERR("dm_task creation failed\n");
+		goto out;
+	}
+
+	ret = dm_task_run(dmt);
+	if (!ret) {
+		BL_LOG_ERR("dm_task_run failed\n");
+		goto out;
+	}
+
+	dmnames = dm_task_get_names(dmt);
+	if (!dmnames || !dmnames->dev) {
+		BL_LOG_ERR("dm_task_get_names failed\n");
+		goto out;
+	}
+
+	while (dmnames) {
+		if (dmnames->dev == dev) {
+			name = strdup(dmnames->name);
+			break;
+		}
+		dmnames = (void *)dmnames + dmnames->next;
+	}
+
+	if (!name) {
+		BL_LOG_ERR("Could not find device\n");
+		goto out;
+	}
+
+	dm_task_update_nodes();
+
+ out:
+	if (dmt)
+		dm_task_destroy(dmt);
+
+	/* Start to remove device */
+	if (name) {
+		ret = dm_device_remove_byname(name);
+		free(name);
+	}
+
+	return ret;
+}
+
+static void dm_devicelist_remove(unsigned int start, unsigned int end)
+{
+	char dev_name[DM_DEV_NAME_LEN];
+	unsigned int count;
+
+	if (start >= dev_count || end <= 1 || start >= end - 1)
+		return;
+
+	for (count = end - 1; count > start; count--) {
+		snprintf(dev_name, sizeof dev_name, dm_name, count - 1);
+		dm_device_remove_byname(dev_name);
+	}
+
+	return;
+}
+
+static void bl_dm_remove_tree(uint64_t dev)
+{
+	struct bl_dm_tree *p;
+
+	p = find_bl_dm_tree(dev);
+	if (!p)
+		return;
+
+	dm_tree_free(p->tree);
+	del_from_bl_dm_tree(dev);
+}
+
+static int bl_dm_create_tree(uint64_t dev)
+{
+	struct dm_tree *tree;
+	struct bl_dm_tree *bl_tree;
+
+	bl_tree = find_bl_dm_tree(dev);
+	if (bl_tree)
+		return 1;
+
+	tree = dm_tree_create();
+	if (!tree)
+		return 0;
+
+	if (!dm_tree_add_dev(tree, MAJOR(dev), MINOR(dev))) {
+		dm_tree_free(tree);
+		return 0;
+	}
+
+	bl_tree = malloc(sizeof(struct bl_dm_tree));
+	if (!bl_tree) {
+		dm_tree_free(tree);
+		return 0;
+	}
+
+	bl_tree->dev = dev;
+	bl_tree->tree = tree;
+	bl_tree->next = NULL;
+	add_to_bl_dm_tree(bl_tree);
+
+	return 1;
+}
+
+int dm_device_remove_all(uint64_t *dev)
+{
+	struct bl_dm_tree *p;
+	struct dm_tree_node *node;
+	const char *uuid;
+	int ret = 0;
+	uint32_t major, minor;
+	uint64_t bl_dev;
+
+	memcpy(&major, dev, sizeof(uint32_t));
+	memcpy(&minor, (void *)dev + sizeof(uint32_t), sizeof(uint32_t));
+	bl_dev = MKDEV(major, minor);
+	p = find_bl_dm_tree(bl_dev);
+	if (!p)
+		return ret;
+
+	node = dm_tree_find_node(p->tree, MAJOR(bl_dev), MINOR(bl_dev));
+	if (!node)
+		return ret;
+
+	uuid = dm_tree_node_get_uuid(node);
+	if (!uuid)
+		return ret;
+
+	dm_device_remove(bl_dev);
+	ret = dm_tree_deactivate_children(node, uuid, strlen(uuid));
+	dm_task_update_nodes();
+	bl_dm_remove_tree(bl_dev);
+
+	return ret;
+}
+
+static int dm_device_exists(char *dev_name)
+{
+	char fullname[DM_DEV_NAME_LEN];
+
+	snprintf(fullname, sizeof fullname, "/dev/mapper/%s", dev_name);
+	return (access(fullname, F_OK) >= 0);
+}
+
+/* TODO: check the value for DM_DEV_NAME_LEN, DM_TYPE_LEN, DM_PARAMS_LEN */
+uint64_t dm_device_create(struct bl_volume *vols, int num_vols)
+{
+	uint64_t size, stripe_unit, dev = 0;
+	unsigned int count = dev_count;
+	int volnum, i, pos;
+	struct bl_volume *node;
+	char *tmp;
+	struct bl_dm_table *table = NULL;
+	struct bl_dm_table *bl_table_head = NULL;
+	unsigned int len;
+	char *dev_name = NULL;
+
+	/* Create pseudo device here */
+	for (volnum = 0; volnum < num_vols; volnum++) {
+		node = &vols[volnum];
+		switch (node->bv_type) {
+		case BLOCK_VOLUME_SIMPLE:
+			/* Do not need to create device here */
+			dev = node->param.bv_dev;
+			goto continued;
+		case BLOCK_VOLUME_SLICE:
+			table = bl_dm_table_alloc();
+			if (!table)
+				goto out;
+			table->offset = 0;
+			table->size = node->bv_size;
+			strcpy(table->target_type, "linear");
+			if (!TYPE_HAS_DEV(node->bv_vols[0]->bv_type)) {
+				free(table);
+				goto out;
+			}
+			dev = node->bv_vols[0]->param.bv_dev;
+			tmp = table->params;
+			if (!dm_format_dev(tmp, DM_PARAMS_LEN,
+					   MAJOR(dev), MINOR(dev))) {
+				free(table);
+				goto out;
+			}
+			tmp += strlen(tmp);
+			sprintf(tmp, " %lu", node->param.bv_offset);
+			add_to_bl_dm_table(&bl_table_head, table);
+			break;
+		case BLOCK_VOLUME_STRIPE:
+			table = bl_dm_table_alloc();
+			if (!table)
+				goto out;
+			table->offset = 0;
+			/* Truncate size to a stripe unit boundary */
+			stripe_unit = node->param.bv_stripe_unit;
+			table->size =
+			    node->bv_size - (node->bv_size % stripe_unit);
+			strcpy(table->target_type, "striped");
+			sprintf(table->params, "%d %llu %n", node->bv_vol_n,
+				(long long unsigned) stripe_unit, &pos);
+			/* Copy subdev major:minor to params */
+			tmp = table->params + pos;
+			len = DM_PARAMS_LEN - pos;
+			for (i = 0; i < node->bv_vol_n; i++) {
+				if (!TYPE_HAS_DEV(node->bv_vols[i]->bv_type)) {
+					free(table);
+					goto out;
+				}
+				dev = node->bv_vols[i]->param.bv_dev;
+				if (!dm_format_dev(tmp, len, MAJOR(dev),
+						   MINOR(dev))) {
+					free(table);
+					goto out;
+				}
+				pos = strlen(tmp);
+				tmp += pos;
+				len -= pos;
+				sprintf(tmp, " %d ", 0);
+				tmp += 3;
+				len -= 3;
+			}
+			add_to_bl_dm_table(&bl_table_head, table);
+			break;
+		case BLOCK_VOLUME_CONCAT:
+			size = 0;
+			for (i = 0; i < node->bv_vol_n; i++) {
+				table = bl_dm_table_alloc();
+				if (!table)
+					goto out;
+				table->offset = size;
+				table->size = node->bv_vols[i]->bv_size;
+				if (!TYPE_HAS_DEV(node->bv_vols[i]->bv_type)) {
+					free(table);
+					goto out;
+				}
+				strcpy(table->target_type, "linear");
+				tmp = table->params;
+				dev = node->bv_vols[i]->param.bv_dev;
+				if (!dm_format_dev(tmp, DM_PARAMS_LEN,
+						   MAJOR(dev), MINOR(dev))) {
+					free(table);
+					goto out;
+				}
+				tmp += strlen(tmp);
+				sprintf(tmp, " %d", 0);
+				size += table->size;
+				add_to_bl_dm_table(&bl_table_head, table);
+			}
+			break;
+		default:
+			/* Delete previous temporary devices */
+			dm_devicelist_remove(count, dev_count);
+			goto out;
+		}		/* end of swtich */
+		/* Create dev_name here. Name of device is pnfs_vol_XXX */
+		if (dev_name)
+			free(dev_name);
+		dev_name = (char *)calloc(DM_DEV_NAME_LEN, sizeof(char));
+		if (!dev_name) {
+			BL_LOG_ERR("%s: Out of memory\n", __func__);
+			goto out;
+		}
+		do {
+			snprintf(dev_name, DM_DEV_NAME_LEN, dm_name,
+				 dev_count++);
+		} while (dm_device_exists(dev_name));
+
+		dev = dm_device_create_mapped(dev_name, bl_table_head);
+		BL_LOG_INFO("%s: %d %s %d:%d\n", __func__, volnum, dev_name,
+			    (int) MAJOR(dev), (int) MINOR(dev));
+		if (!dev) {
+			/* Delete previous temporary devices */
+			dm_devicelist_remove(count, dev_count);
+			goto out;
+		}
+		node->param.bv_dev = dev;
+		/* TODO: extend use with PSEUDO later */
+		node->bv_type = BLOCK_VOLUME_PSEUDO;
+
+ continued:
+		if (bl_table_head)
+			bl_dm_table_free(bl_table_head);
+		bl_table_head = NULL;
+	}
+ out:
+	if (bl_table_head) {
+		bl_dm_table_free(bl_table_head);
+		bl_table_head = NULL;
+	}
+	if (dev)
+		bl_dm_create_tree(dev);
+	if (dev_name)
+		free(dev_name);
+	return dev;
+}
-- 
1.7.4.1

