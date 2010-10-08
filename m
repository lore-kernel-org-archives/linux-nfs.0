Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:60419 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757526Ab0JHQH3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Oct 2010 12:07:29 -0400
Date: Fri, 8 Oct 2010 12:07:15 -0400
From: Jim Rees <rees@umich.edu>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org, sfaibish <sfaibish@emc.com>,
        peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 1/4] blkmapd: get rid of config file and instead examine
 all block devices
Message-ID: <fb9c48c5e1ce2023d3dc2e279537e158130a6ba0.1286552019.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1286552019.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Only examine actual block devices rather than everything in /dev.  Since
we're looking for pnfs signatures, it usually doesn't hurt to examine a
device that isn't part of a layout, and in general it's hard to tell ahead
of time which devices should be considered, so I think having a config file
does more harm than good.

It may be useful later on to be able to blacklist some devices but I'd
rather not do this through yet another config file.  Maybe this can be done
via udev rules.

Signed-off-by: Jim Rees <rees@umich.edu>
---
 utils/blkmapd/Makefile.am        |    2 -
 utils/blkmapd/cfg.c              |  248 --------------------------------------
 utils/blkmapd/cfg.h              |   47 -------
 utils/blkmapd/device-discovery.c |  103 ++++------------
 4 files changed, 26 insertions(+), 374 deletions(-)
 delete mode 100644 utils/blkmapd/cfg.c
 delete mode 100644 utils/blkmapd/cfg.h

diff --git a/utils/blkmapd/Makefile.am b/utils/blkmapd/Makefile.am
index f23c073..1e8720d 100644
--- a/utils/blkmapd/Makefile.am
+++ b/utils/blkmapd/Makefile.am
@@ -7,13 +7,11 @@ sbin_PROGRAMS	= blkmapd
 
 blkmapd_SOURCES = \
 	atomicio.c \
-	cfg.c \
 	device-discovery.c \
 	device-inq.c \
 	device-process.c \
 	dm-device.c \
 	\
-	cfg.h \
 	device-discovery.h
 
 blkmapd_LDADD = -ldevmapper ../../support/nfs/libnfs.a
diff --git a/utils/blkmapd/cfg.c b/utils/blkmapd/cfg.c
deleted file mode 100644
index dab9d0f..0000000
--- a/utils/blkmapd/cfg.c
+++ /dev/null
@@ -1,248 +0,0 @@
-/*
- * Copyright (c) 2010 EMC Corporation, Haiying Tang <Tang_Haiying@emc.com>
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
-#include <sys/param.h>
-#include <sys/stat.h>
-#include <linux/errno.h>
-#include <stdio.h>
-#include <stdlib.h>
-#include <unistd.h>
-#include <string.h>
-#include <fcntl.h>
-#include <ctype.h>
-
-#include "device-discovery.h"
-#include "cfg.h"
-
-char *conf_path = "/etc/blkmapd.conf";
-
-struct scan_root_list *scan_root_list_head;
-
-void bl_release_list(void)
-{
-	struct scan_root_list *root = scan_root_list_head;
-	struct scan_device_list *disk;
-
-	while (root) {
-		disk = root->disk;
-		while (disk) {
-			root->disk = disk->next;
-			free(disk->name);
-			free(disk);
-			disk = root->disk;
-		}
-		scan_root_list_head = root->next;
-		free(root->name);
-		free(root);
-		root = scan_root_list_head;
-	}
-}
-
-struct scan_root_list *bl_alloc_root_list(char *name, int all_disk)
-{
-	struct scan_root_list *root;
-
-	root = malloc(sizeof(struct scan_root_list));
-	if (!root)
-		goto nomem;
-
-	root->name = strdup(name);
-	if (!root->name)
-		goto nomem;
-	root->next = scan_root_list_head;
-	root->all_disk = all_disk;
-	scan_root_list_head = root;
-	return root;
-
- nomem:
-	BL_LOG_ERR("%s: Out of memory!\n", __func__);
-	if (root)
-		free(root);
-	return NULL;
-}
-
-struct scan_device_list *bl_alloc_device_list(struct scan_root_list *root,
-					      char *name)
-{
-	struct scan_device_list *device;
-
-	device = malloc(sizeof(struct scan_device_list));
-	if (!device)
-		goto nomem;
-
-	device->name = strdup(name);
-	if (!device->name)
-		goto nomem;
-	device->next = root->disk;
-	root->disk = device;
-	return device;
-
- nomem:
-	BL_LOG_ERR("%s: Out of memory!\n", __func__);
-	if (device)
-		free(device);
-	return NULL;
-}
-
-struct scan_device_list *bl_insert_device_list(struct scan_root_list *root,
-					       char *name)
-{
-	struct scan_device_list *device = root->disk;
-
-	/* Check whether this device has been inserted */
-	while (device) {
-		if (device->name && !strcmp(device->name, name))
-			return device;
-		device = device->next;
-	}
-
-	return bl_alloc_device_list(root, name);
-}
-
-struct scan_root_list *bl_insert_root_list(char *name, int all_disk)
-{
-	struct scan_root_list *root = scan_root_list_head;
-
-	/* Check whether this root has been inserted */
-	while (root) {
-		if (root->name && !strcmp(root->name, name))
-			return root;
-		root = root->next;
-	}
-
-	return bl_alloc_root_list(name, all_disk);
-}
-
-int bl_parse_line(char *line, struct scan_root_list **bl_root)
-{
-	char *root, *device, *end;
-
-	root = strdup(line);
-	end = root + strlen(line);
-
-	/* Skip comments */
-	if (*root == '#')
-		return 0;
-
-	/* Trim leading space */
-	while (*root != '\0' && isspace(*root))
-		root++;
-	if (*root == '\0')
-		return 0;
-
-	/* Trim trailing space and set "end" to last char */
-	while ((isspace(*end) || (*end == '\0')) && (end > root))
-		end--;
-
-	/* For lines ending with '/' or '/','*': add as a dir root */
-	if ((*end == '/') ||
-	    ((*end == '*') && (end - root >= 1) && (*(end - 1) == '/'))) {
-		if (*end == '*')
-			end--;
-		if (*end == '/')
-			end--;
-		*(end + 1) = '\0';
-		*bl_root = bl_insert_root_list(root, 1);
-		return 0;
-	}
-
-	/* Other lines: add as a device */
-	device = end;
-	while ((*device != '/') && (device > root))
-		device--;
-	if (device == root) {
-		BL_LOG_ERR("%s: invalid config line\n", __func__);
-		return -1;
-	}
-	*device = '\0';
-	*bl_root = bl_insert_root_list(root, 0);
-	if (*bl_root == NULL)
-		return -ENOMEM;
-	if (*end == '*')
-		end--;
-	*(end + 1) = '\0';
-	if (bl_insert_device_list(*bl_root, device + 1) == NULL)
-		return -ENOMEM;
-
-	return 0;
-}
-
-int bl_set_default_conf(void)
-{
-	struct scan_root_list *root = NULL;
-	int rv;
-
-	bl_release_list();
-	rv = bl_parse_line("/dev/sd*", &root);
-	if (rv < 0)
-		return rv;
-	rv = bl_parse_line("/dev/mapper/", &root);
-	return rv;
-}
-
-int bl_parse_conf(char *buf)
-{
-	char *tmp = buf, *line = buf, *end = buf + strlen(buf);
-	struct scan_root_list *bl_root = NULL;
-	int rv;
-
-	while (tmp < end) {
-		if (*tmp == '\n') {
-			*tmp = '\0';
-			rv = bl_parse_line(line, &bl_root);
-			if (rv < 0)
-				return rv;
-			line = tmp + 1;
-		}
-		tmp++;
-	}
-
-	return 0;
-}
-
-int bl_cfg_init(void)
-{
-	struct scan_root_list *root = NULL;
-	FILE *f = NULL;
-	char buf[PATH_MAX];
-	int rv = 0;
-
-	f = fopen(conf_path, "r");
-	if (f == NULL)
-		rv = bl_set_default_conf();
-	else {
-		while (fgets(buf, sizeof buf, f) != NULL) {
-			rv = bl_parse_line(buf, &root);
-			if (rv < 0)
-				break;
-		}
-	}
-	if (!scan_root_list_head)
-		rv = -EINVAL;
-
-	if (f)
-		fclose(f);
-	return rv;
-}
diff --git a/utils/blkmapd/cfg.h b/utils/blkmapd/cfg.h
deleted file mode 100644
index b9bf930..0000000
--- a/utils/blkmapd/cfg.h
+++ /dev/null
@@ -1,47 +0,0 @@
-/*
- * bl-cfg.h
- *
- * Copyright (c) 2010 EMC Corporation, Haiying Tang <Tang_Haiying@emc.com>
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
-#ifndef BL_CFG_H
-#define BL_CFG_H
-
-extern char *conf_path;
-extern struct scan_root_list *scan_root_list_head;
-
-struct scan_device_list {
-	struct scan_device_list *next;
-	char *name;
-};
-
-struct scan_root_list {
-	struct scan_root_list *next;
-	unsigned int all_disk;
-	char *name;
-	struct scan_device_list *disk;
-};
-
-int bl_cfg_init(void);
-
-#endif
diff --git a/utils/blkmapd/device-discovery.c b/utils/blkmapd/device-discovery.c
index f42ddc8..0fc8fd3 100644
--- a/utils/blkmapd/device-discovery.c
+++ b/utils/blkmapd/device-discovery.c
@@ -44,8 +44,8 @@
 #include <scsi/scsi.h>
 #include <scsi/scsi_ioctl.h>
 #include <scsi/sg.h>
+
 #include "device-discovery.h"
-#include "cfg.h"
 
 #define BL_PIPE_FILE	"/var/lib/nfs/rpc_pipefs/bl_device_pipe"
 #define PID_FILE	"/var/run/blkmapd.pid"
@@ -56,6 +56,7 @@ struct bl_disk_path *bl_get_path(const char *filepath,
 				 struct bl_disk_path *paths)
 {
 	struct bl_disk_path *tmp = paths;
+
 	while (tmp) {
 		if (!strcmp(tmp->full_path, filepath))
 			break;
@@ -130,8 +131,6 @@ void bl_add_disk(char *filepath)
 	struct bl_disk_path *diskpath = NULL, *path = NULL;
 	dev_t dev;
 
-	BL_LOG_ERR("%s: %s\n", __func__, filepath);
-
 	fd = open(filepath, O_RDONLY | O_LARGEFILE);
 	if (fd < 0)
 		return;
@@ -173,6 +172,8 @@ void bl_add_disk(char *filepath)
 	bldev_read_ap_state(fd, &ap_state);
 	close(fd);
 
+	BL_LOG_ERR("%s: %s\n", __func__, filepath);
+
 	/*
 	 * Not sure how to identify a pseudo device created by
 	 * device-mapper, so leave /dev/mapper for now.
@@ -226,75 +227,36 @@ void bl_add_disk(char *filepath)
 	return;
 }
 
-void bl_devicescan(const char *filename, struct scan_root_list *root)
-{
-	/* scan all disks */
-	char filepath[PATH_MAX];
-	struct scan_device_list *device;
-
-	if (!strcmp(filename, ".") || !strcmp(filename, ".."))
-		return;
-
-	memset(filepath, 0, sizeof(filepath));
-	if (strlen(filename) < (PATH_MAX - strlen(root->name) - 2))
-		sprintf(filepath, "%s/%s", root->name, filename);
-	else {
-		BL_LOG_ERR("%s: name too long\n", __func__);
-		return;
-	}
-	if (root->all_disk)
-		goto valid;
-
-	device = root->disk;
-	while (device) {
-		/* If device->name is a subset of filename, this disk should be
-		 * valid for scanning.
-		 * For example, device->name is "sd", filename is "sda".
-		 */
-		if (device->name
-		    && !memcmp(filename, device->name, strlen(device->name)))
-			goto valid;
-		device = device->next;
-	}
-
-	return;
-
- valid:
-	/*
-	 * sg device is not a real device, but a device created according
-	 * to each scsi device. It won't be used for pseudo device creation.
-	 * I moved it here, so that sg devices will not be scanned.
-	 */
-	if (!strncmp(filepath, "/dev/sg", 7))
-		return;
-	bl_add_disk(filepath);
-	return;
-}
-
 int bl_discover_devices(void)
 {
-	DIR *dir;
-	struct dirent *dp;
-	struct scan_root_list *root = scan_root_list_head;
+	FILE *f;
+	int n;
+	char buf[PATH_MAX], devname[PATH_MAX], fulldevname[PATH_MAX];
 
 	/* release previous list */
 	bl_release_disk();
 
-	/* scan all disks */
-	while (root) {
-		dir = opendir(root->name);
-		if (dir == NULL) {
-			root = root->next;
-			continue;
-		}
+	/* scan all block devices */
+	f = fopen("/proc/partitions", "r");
+	if (f == NULL)
+		return 0;
 
-		while ((dp = readdir(dir)) != NULL)
-			bl_devicescan(dp->d_name, root);
-
-		root = root->next;
-		closedir(dir);
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
 	}
 
+	fclose(f);
+
 	return 0;
 }
 
@@ -433,11 +395,8 @@ int main(int argc, char **argv)
 	struct stat statbuf;
 	char pidbuf[64];
 
-	while ((opt = getopt(argc, argv, "c:f")) != -1) {
+	while ((opt = getopt(argc, argv, "f")) != -1) {
 		switch (opt) {
-		case 'c':
-			conf_path = optarg;
-			break;
 		case 'f':
 			fg = 1;
 			break;
@@ -477,16 +436,6 @@ int main(int argc, char **argv)
 		return -1;
 	}
 
-	ret = bl_cfg_init();
-	if (ret < 0) {
-		if (ret == -ENOENT)
-			BL_LOG_WARNING("Config file not exist, use default\n");
-		else {
-			BL_LOG_ERR("Open/read Block pNFS config file error\n");
-			return -1;
-		}
-	}
-
 	while (1) {
 		/* discover device when needed */
 		bl_discover_devices();
-- 
1.7.0.4

