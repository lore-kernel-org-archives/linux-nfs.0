Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45846 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762142Ab0HFWgP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Aug 2010 18:36:15 -0400
From: Valerie Aurora <vaurora@redhat.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Miklos Szeredi <miklos@szeredi.hu>, Jan Blunck <jblunck@suse.de>,
        Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, David Woodhouse <dwmw2@infradead.org>,
        Valerie Aurora <vaurora@redhat.com>, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>
Subject: [PATCH 05/38] whiteout/NFSD: Don't return information about whiteouts to userspace
Date: Fri,  6 Aug 2010 15:34:51 -0700
Message-Id: <1281134124-17041-6-git-send-email-vaurora@redhat.com>
In-Reply-To: <1281134124-17041-1-git-send-email-vaurora@redhat.com>
References: <1281134124-17041-1-git-send-email-vaurora@redhat.com>
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
Cc: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Neil Brown <neilb@suse.de>
---
 fs/compat.c       |    9 +++++++++
 fs/nfsd/nfs3xdr.c |    5 +++++
 fs/nfsd/nfs4xdr.c |    5 +++++
 fs/nfsd/nfsxdr.c  |    4 ++++
 fs/readdir.c      |    9 +++++++++
 5 files changed, 32 insertions(+), 0 deletions(-)

diff --git a/fs/compat.c b/fs/compat.c
index 6490d21..7e7b3a4 100644
--- a/fs/compat.c
+++ b/fs/compat.c
@@ -912,6 +912,9 @@ static int compat_fillonedir(void *__buf, const char *name, int namlen,
 	struct compat_old_linux_dirent __user *dirent;
 	compat_ulong_t d_ino;
 
+	if (d_type == DT_WHT)
+		return 0;
+
 	if (buf->result)
 		return -EINVAL;
 	d_ino = ino;
@@ -983,6 +986,9 @@ static int compat_filldir(void *__buf, const char *name, int namlen,
 	compat_ulong_t d_ino;
 	int reclen = ALIGN(NAME_OFFSET(dirent) + namlen + 2, sizeof(compat_long_t));
 
+	if (d_type == DT_WHT)
+		return 0;
+
 	buf->error = -EINVAL;	/* only used if we fail.. */
 	if (reclen > buf->count)
 		return -EINVAL;
@@ -1072,6 +1078,9 @@ static int compat_filldir64(void * __buf, const char * name, int namlen, loff_t
 	int reclen = ALIGN(jj + namlen + 1, sizeof(u64));
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
index ac17a70..fb67254 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2279,6 +2279,11 @@ nfsd4_encode_dirent(void *ccdv, const char *name, int namlen,
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
index 7723401..3a48491 100644
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
@@ -154,6 +157,9 @@ static int filldir(void * __buf, const char * name, int namlen, loff_t offset,
 	unsigned long d_ino;
 	int reclen = ALIGN(NAME_OFFSET(dirent) + namlen + 2, sizeof(long));
 
+	if (d_type == DT_WHT)
+		return 0;
+
 	buf->error = -EINVAL;	/* only used if we fail.. */
 	if (reclen > buf->count)
 		return -EINVAL;
@@ -239,6 +245,9 @@ static int filldir64(void * __buf, const char * name, int namlen, loff_t offset,
 	struct getdents_callback64 * buf = (struct getdents_callback64 *) __buf;
 	int reclen = ALIGN(NAME_OFFSET(dirent) + namlen + 1, sizeof(u64));
 
+	if (d_type == DT_WHT)
+		return 0;
+
 	buf->error = -EINVAL;	/* only used if we fail.. */
 	if (reclen > buf->count)
 		return -EINVAL;
-- 
1.6.3.3

