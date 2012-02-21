Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:36748 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754689Ab2BUSIG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Feb 2012 13:08:06 -0500
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 11/73] whiteout/NFSD: Don't return information about whiteouts
 to userspace [ver #2]
To: linux-fsdevel@vger.kernel.org, viro@ZenIV.linux.org.uk,
        valerie.aurora@gmail.com
Cc: linux-kernel@vger.kernel.org, Jan Blunck <jblunck@suse.de>,
        David Woodhouse <dwmw2@infradead.org>,
        Valerie Aurora <vaurora@redhat.com>,
        David Howells <dhowells@redhat.com>,
        "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        Neil Brown <neilb@suse.de>
Date: Tue, 21 Feb 2012 17:58:48 +0000
Message-ID: <20120221175848.25235.54294.stgit@warthog.procyon.org.uk>
In-Reply-To: <20120221175721.25235.8901.stgit@warthog.procyon.org.uk>
References: <20120221175721.25235.8901.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jan Blunck <jblunck@suse.de>

Userspace isn't ready for handling another file type, so silently drop
whiteout directory entries before they leave the kernel.

Signed-off-by: Jan Blunck <jblunck@suse.de>
Signed-off-by: David Woodhouse <dwmw2@infradead.org>
Signed-off-by: Valerie Aurora <vaurora@redhat.com>
Signed-off-by: David Howells <dhowells@redhat.com>
Acked-by: J. Bruce Fields <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Cc: Neil Brown <neilb@suse.de>
---

 fs/compat.c       |    9 +++++++++
 fs/nfsd/nfs3xdr.c |    5 +++++
 fs/nfsd/nfs4xdr.c |    5 +++++
 fs/nfsd/nfsxdr.c  |    4 ++++
 fs/readdir.c      |    9 +++++++++
 5 files changed, 32 insertions(+), 0 deletions(-)

diff --git a/fs/compat.c b/fs/compat.c
index 07880ba..9ed826e 100644
--- a/fs/compat.c
+++ b/fs/compat.c
@@ -842,6 +842,9 @@ static int compat_fillonedir(void *__buf, const char *name, int namlen,
 	struct compat_old_linux_dirent __user *dirent;
 	compat_ulong_t d_ino;
 
+	if (d_type == DT_WHT)
+		return 0;
+
 	if (buf->result)
 		return -EINVAL;
 	d_ino = ino;
@@ -914,6 +917,9 @@ static int compat_filldir(void *__buf, const char *name, int namlen,
 	int reclen = ALIGN(offsetof(struct compat_linux_dirent, d_name) +
 		namlen + 2, sizeof(compat_long_t));
 
+	if (d_type == DT_WHT)
+		return 0;
+
 	buf->error = -EINVAL;	/* only used if we fail.. */
 	if (reclen > buf->count)
 		return -EINVAL;
@@ -1003,6 +1009,9 @@ static int compat_filldir64(void * __buf, const char * name, int namlen, loff_t
 		sizeof(u64));
 	u64 off;
 
+	if (d_type == DT_WHT)
+		return 0;
+
 	buf->error = -EINVAL;	/* only used if we fail.. */
 	if (reclen > buf->count)
 		return -EINVAL;
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 08c6e36..69a60b6 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -887,6 +887,11 @@ encode_entry(struct readdir_cd *ccd, const char *name, int namlen,
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
index 0ec5a1b..6124f78 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2553,6 +2553,11 @@ nfsd4_encode_dirent(void *ccdv, const char *name, int namlen,
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
index 65ec595..2af74b2 100644
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

