Return-Path: <kinglongmee@gmail.com>
Message-ID: <552BB264.8010104@gmail.com>
Date: Mon, 13 Apr 2015 20:11:16 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>
CC: bcodding@redhat.com,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH] mount: Writes signal number to kernel as command line
Content-Type: text/plain; charset=utf-8
List-ID: <linux-nfs.vger.kernel.org>

When mounting nfs with -overs=4,minorversion=2, want getting
nfs mounts with vers=4.2, but got vers=4.0 as,

# mount -t nfs -onfsvers=4,minorversion=2 127.0.0.1:/ /mnt/
# cat /proc/mounts | grep vers
127.0.0.1:/ /mnt nfs4 rw,relatime,vers=4.0,rsize=262144,wsize=262144,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=127.0.0.1,local_lock=none,addr=127.0.0.1 0 0

It's caused by mount.nfs writing bad vers to kernel. This patch
lets mount.nfs writing signal number to kernel as command line.

Note： This patch is based on my last patch,
"mount: make sure mounting nfs with v4,vers=4 and nfsvers=4"

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 utils/mount/stropts.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 2ae532e..c8f5a6d 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -737,8 +737,13 @@ static int nfs_do_mount_v4(struct nfsmount_info *mi,
 	}
 
 	if (mi->version.v_mode != V_SPECIFIC) {
-		snprintf(version_opt, sizeof(version_opt) - 1,
-			"vers=%lu.%lu", mi->version.major, mi->version.minor);
+		if (mi->version.v_mode == V_GENERAL)
+			snprintf(version_opt, sizeof(version_opt) - 1,
+				"vers=%lu", mi->version.major);
+		else
+			snprintf(version_opt, sizeof(version_opt) - 1,
+				"vers=%lu.%lu", mi->version.major,
+				mi->version.minor);
 
 		if (po_append(options, version_opt) == PO_FAILED) {
 			errno = EINVAL;
-- 
2.3.5
