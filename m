Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21729 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758196Ab1CCUDD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Mar 2011 15:03:03 -0500
Message-ID: <4D6FF3F4.8040602@RedHat.com>
Date: Thu, 03 Mar 2011 15:03:00 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Karel Zak <kzak@redhat.com>
CC: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 1.5/2] mount: Remove MOUNT_CONFIG warning
References: <1299159822-25190-1-git-send-email-kzak@redhat.com> <1299159822-25190-2-git-send-email-kzak@redhat.com>
In-Reply-To: <1299159822-25190-2-git-send-email-kzak@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The following changes are needed to remove compile warnings when
MOUNT_CONFIG is not define

Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/mount/mount_config.h b/utils/mount/mount_config.h
index e86b4ba..69ffd1e 100644
--- a/utils/mount/mount_config.h
+++ b/utils/mount/mount_config.h
@@ -39,10 +39,10 @@ static inline char *mount_config_opts(char *spec,
 
 #else /* MOUNT_CONFIG */
 
-static inline void mount_config_init(char *program) { }
+static inline void mount_config_init(__attribute__ ((unused)) char *program) { }
 
-static inline char *mount_config_opts(char *spec,
-		char *mount_point, char *mount_opts)
+static inline char *mount_config_opts(__attribute__ ((unused)) char *spec,
+		__attribute__ ((unused)) char *mount_point, char *mount_opts)
 {
 	return mount_opts;
 }
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index e314b82..f1aa503 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -110,7 +110,7 @@ static void nfs_default_version(struct nfsmount_info *mi)
 	}
 }
 #else
-inline void nfs_default_version(struct nfsmount_info *mi) {}
+inline void nfs_default_version(__attribute__ ((unused)) struct nfsmount_info *mi) {}
 #endif /* MOUNT_CONFIG */
