Return-Path: <kinglongmee@gmail.com>
Message-ID: <552A5F3F.1090206@gmail.com>
Date: Sun, 12 Apr 2015 20:04:15 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>
CC: bcodding@redhat.com,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH] mount: make sure mounting nfs with v4,vers=4 and nfsvers=4
Content-Type: text/plain; charset=utf-8
List-ID: <linux-nfs.vger.kernel.org>

When mounting nfs with -ov4, -overs=4 or -onfsvers=4, fail as,

# mount -t nfs -ov4 192.168.31.12:/ /testidr/
mount.nfs: access denied by server while mounting 192.168.31.12:/

Fixes: f980298853 "mount.nfs: configurable minor version defaults" 
Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 utils/mount/stropts.c | 12 +++---------
 1 file changed, 3 insertions(+), 9 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index df67fac..2ae532e 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -108,12 +108,6 @@ static void nfs_default_version(struct nfsmount_info *mi)
 		return;
 	}
 
-	if (mi->version.v_mode == V_GENERAL &&
-		config_default_vers.v_mode == V_DEFAULT) {
-		mi->version.v_mode = V_SPECIFIC;
-		return;
-	}
-
 	if (mi->version.v_mode == V_DEFAULT &&
 		config_default_vers.v_mode != V_DEFAULT) {
 		mi->version.major = config_default_vers.major;
@@ -121,9 +115,9 @@ static void nfs_default_version(struct nfsmount_info *mi)
 		return;
 	}
 
-	if (mi->version.v_mode == V_GENERAL &&
-		config_default_vers.v_mode != V_DEFAULT) {
-		if (mi->version.major == config_default_vers.major)
+	if (mi->version.v_mode == V_GENERAL) {
+		if (config_default_vers.v_mode != V_DEFAULT &&
+		    mi->version.major == config_default_vers.major)
 			mi->version.minor = config_default_vers.minor;
 		return;
 	}
-- 
2.3.5
