Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:52652 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755583Ab2CBQxl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 Mar 2012 11:53:41 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q22GrePa003815
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 2 Mar 2012 11:53:41 -0500
Received: from badhat.bos.devel.redhat.com (vpn-11-150.rdu.redhat.com [10.11.11.150])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id q22GreaC004718
	for <linux-nfs@vger.kernel.org>; Fri, 2 Mar 2012 11:53:40 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] mount.nfs: strip of extra slashes in device name
Date: Fri,  2 Mar 2012 11:53:41 -0500
Message-Id: <1330707221-4005-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The kernel strips off extra '/' when the  device is entered
into /proc/mounts. So that umounts can this devices, strip off
any extra '/' before storing the device in the mtab.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/mount.c |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index eea00af..eb63f50 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -485,6 +485,24 @@ int main(int argc, char *argv[])
 		goto out;
 	}
 	/*
+	 * The kernel strips off extra '/' when the device is entered 
+	 * into /proc/mounts. So that umounts can this devices, strip off
+	 * any extra '/' before storing the device in the mtab.
+	 */
+	if (strstr(spec, "//") != NULL) {
+		char *colen, *slash;
+
+		if ((colen = strchr(spec, ':'))) {
+			slash = (colen + 1);
+			while (*slash && *(slash+1) == '/')
+				slash++;
+			while (*slash)
+				*(++colen) = *(slash++);
+			*(colen+1) = '\0';
+		}
+	}
+
+	/*
 	 * Concatenate mount options from the configuration file
 	 */
 	mount_opts = mount_config_opts(spec, mount_point, mount_opts);
-- 
1.7.1

