Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:59288 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756263Ab1CWCAj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Mar 2011 22:00:39 -0400
From: Valerie Aurora <valerie.aurora@gmail.com>
To: linux-fsdevel@vger.kernel.org, linux@vger.kernel.org
Cc: viro@zeniv.linux.org.uk, Jan Blunck <jblunck@suse.de>,
        David Woodhouse <dwmw2@infradead.org>,
        Valerie Aurora <vaurora@redhat.com>, linux-nfs@vger.kernel.org,
        Neil Brown <neilb@suse.de>, Valerie Aurora <valerie.aurora@gmail.com>
Subject: [PATCH 05/74] whiteout/NFSD: Don't return information about whiteouts to userspace
Date: Tue, 22 Mar 2011 18:58:41 -0700
Message-Id: <1300845590-14184-6-git-send-email-valerie.aurora@gmail.com>
In-Reply-To: <1300845590-14184-1-git-send-email-valerie.aurora@gmail.com>
References: <1300845590-14184-1-git-send-email-valerie.aurora@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Jan Blunck <jblunck@suse.de>

Userspace isn't ready for handling another file type, so silently drop
whiteout directory entries before they leave the kernel.

Signed-off-by: Jan Blunck <jblunck@suse.de>
Signed-off-by: David Woodhouse <dwmw2@infradead.org>
Signed-off-by: Valerie Aurora <vaurora@redhat.com>
Acked-by: J. Bruce Fields <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Cc: Neil Brown <neilb@suse.de>
Signed-off-by: Valerie Aurora <valerie.aurora@gmail.com>
---
 fs/compat.c       |    9 +++++++++
 fs/nfsd/nfs3xdr.c |    5 +++++
 fs/nfsd/nfs4xdr.c |    5 +++++
 fs/nfsd/nfsxdr.c  |    4 ++++
 fs/readdir.c      |    9 +++++++++
 5 files changed, 32 insertions(+), 0 deletions(-)

diff --git a/fs/compat.c b/fs/compat.c
index 718c706..825bb7b 100644
--- a/fs/compat.c
+++ b/fs/compat.c
@@ -914,6 +914,9 @@ static int compat_fillonedir(void *__buf, const char *name, int namlen,
 	struct compat_old_linux_dirent __user *dirent;
 	compat_ulong_t d_ino;
 
+	if (d_type == DT_WHT)
+		return 0;
+
 	if (buf->result)
 		return -EINVAL;
 	d_ino = ino;
@@ -986,6 +989,9 @@ static int compat_filldir(void *__buf, const char *name, int namlen,
 	int reclen = ALIGN(offsetof(struct compat_linux_dirent, d_name) +
 		namlen + 2, sizeof(compat_long_t));
 
+	if (d_type == DT_WHT)
+		return 0;
+
 	buf->error = -EINVAL;	/* only used if we fail.. */
 	if (reclen > buf->count)
 		return -EINVAL;
@@ -1075,6 +1081,9 @@ static int compat_filldir64(void * __buf, const char * name, int namlen, loff_t
 		sizeof(u64));
 	u64 off;
 
+	if (d_type == DT_WHT)
+		return 0;
+
 	buf->error = -EINVAL;	/* only used if we fail.. */
 	if (reclen > buf->count)
 		return -EINVAL;
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 2a533a0..9b96f5a 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -885,6 +885,11 @@ encode_entry(struct readdir_cd *ccd, const char *name, int namlen,
 	int		elen;		/* estimated entry length in words */
 	int		num_entry_words = 0;	/* actual number of words */
 
+	if (d_type == DT_WHT) {
+		cd->common.err = nfs_ok;
+		return 0;
+	}
+
 	if (cd->offset) {
 		u64 offset64 = offset;
 
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 1a468bb..136944d 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2283,6 +2283,11 @@ nfsd4_encode_dirent(void *ccdv, const char *name, int namlen,
 		return 0;
 	}
 
+	if (d_type == DT_WHT) {
+		cd->common.err = nfs_ok;
+		return 0;
+	}
+
 	if (cd->offset)
 		xdr_encode_hyper(cd->offset, (u64) offset);
 
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index 4ce005d..0e57d4b 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -503,6 +503,10 @@ nfssvc_encode_entry(void *ccdv, const char *name,
 			namlen, name, offset, ino);
 	 */
 
+	if (d_type == DT_WHT) {
+		cd->common.err = nfs_ok;
+		return 0;
+	}
 	if (offset > ~((u32) 0)) {
 		cd->common.err = nfserr_fbig;
 		return -EINVAL;
diff --git a/fs/readdir.c b/fs/readdir.c
index 356f715..de703d6 100644
--- a/fs/readdir.c
+++ b/fs/readdir.c
@@ -77,6 +77,9 @@ static int fillonedir(void * __buf, const char * name, int namlen, loff_t offset
 	struct old_linux_dirent __user * dirent;
 	unsigned long d_ino;
 
+	if (d_type == DT_WHT)
+		return 0;
+
 	if (buf->result)
 		return -EINVAL;
 	d_ino = ino;
@@ -155,6 +158,9 @@ static int filldir(void * __buf, const char * name, int namlen, loff_t offset,
 	int reclen = ALIGN(offsetof(struct linux_dirent, d_name) + namlen + 2,
 		sizeof(long));
 
+	if (d_type == DT_WHT)
+		return 0;
+
 	buf->error = -EINVAL;	/* only used if we fail.. */
 	if (reclen > buf->count)
 		return -EINVAL;
@@ -241,6 +247,9 @@ static int filldir64(void * __buf, const char * name, int namlen, loff_t offset,
 	int reclen = ALIGN(offsetof(struct linux_dirent64, d_name) + namlen + 1,
 		sizeof(u64));
 
+	if (d_type == DT_WHT)
+		return 0;
+
 	buf->error = -EINVAL;	/* only used if we fail.. */
 	if (reclen > buf->count)
 		return -EINVAL;
-- 
1.7.0.4

