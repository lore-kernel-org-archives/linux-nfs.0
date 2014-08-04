Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53972 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751274AbaHDPYN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Aug 2014 11:24:13 -0400
Date: Mon, 4 Aug 2014 11:24:11 -0400
To: Steve Dickson <SteveD@redhat.com>
Cc: Rishi Agrawal <Rishi_Agrawal@symantec.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Rajesh Ghanekar <Rajesh_Ghanekar@symantec.com>,
        Ram Pandiri <ram_pandiri@symantec.com>,
        Sreeharsha Sarabu <Sreeharsha_Sarabu@symantec.com>,
        Abhijit Dey <Abhijit_Dey@symantec.com>,
        Tushar Shinde <Tushar_Shinde@symantec.com>,
        "bfields@redhat.com" <bfields@redhat.com>
Subject: [PATCH] nfsd: allow turning off nfsv3 readdir_plus
Message-ID: <20140804152411.GB23341@fieldses.org>
References: <20AEB6A025F81A4288597093171D1B5719CF5813D2@APJ1XCHEVSPIN35.SYMC.SYMANTEC.COM>
 <53DF992D.6090404@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <53DF992D.6090404@RedHat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Rishi Agrawal <Rishi_Agrawal@symantec.com>

One of our customer's application only needs file names, not file
attributes. With directories having 10K+ inodes (assuming buffer cache
has directory blocks cached having file names, but inode cache is
limited and hence need eviction of older cached inodes), older inodes
are evicted periodically. So if they keep on doing readdir(2) from NSF
client on multiple directories, some directory's files are periodically
removed from inode cache and hence new readdir(2) on same directory
requires disk access to bring back inodes again to inode cache.

As READDIRPLUS request fetches attributes also, doing getattr on each
file on server, it causes unnecessary disk accesses. If READDIRPLUS on
NFS client is returned with -ENOTSUPP, NFS client uses READDIR request
which just gets the names of the files in a directory, not attributes,
hence avoiding disk accesses on server.

There's already a corresponding client-side mount option, but an export
option reduces the need for configuration across multiple clients.

This flag affects NFSv3 only.  If it turns out it's needed for NFSv4 as
well then we may have to figure out how to extend the behavior to NFSv4,
but it's not currently obvious how to do that.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/export.c                 |  1 +
 fs/nfsd/nfs3proc.c               | 34 ++++++++++++++++++++++++++++++----
 include/uapi/linux/nfsd/export.h |  5 +++--
 3 files changed, 34 insertions(+), 6 deletions(-)

On Mon, Aug 04, 2014 at 10:31:09AM -0400, Steve Dickson wrote:
> I just notice that the nfs-utils patch does not update
> the exports(5) man page. In that update please note
> this is a v3 only thing.... Not clear what we are going
> to do in the v4 case.
> 
> Finally, please inline your patch posting in the your
> email as its is explained there
>    https://www.kernel.org/doc/Documentation/SubmittingPatches
> 
> It just makes it easier for everyone to do the review... 

As an example, here's the kernel patch; could you do the same for the
nfs-utils patch?  Also:

	- am I correct to credit you as the author?  And,
	- could you let me know if you're OK with adding a signed-off-by
	  line for you to this patch?  (See the "Developer's Certificate
	  of Origin" in SubmittingPatches.)

--b.

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 72ffd7cce3c3..30a739d896ff 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1145,6 +1145,7 @@ static struct flags {
 	{ NFSEXP_ALLSQUASH, {"all_squash", ""}},
 	{ NFSEXP_ASYNC, {"async", "sync"}},
 	{ NFSEXP_GATHERED_WRITES, {"wdelay", "no_wdelay"}},
+	{ NFSEXP_NOREADDIRPLUS, {"nordirplus", ""}},
 	{ NFSEXP_NOHIDE, {"nohide", ""}},
 	{ NFSEXP_CROSSMOUNT, {"crossmnt", ""}},
 	{ NFSEXP_NOSUBTREECHECK, {"no_subtree_check", ""}},
diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index fa2525b2e9d7..a5bf378ab268 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -441,6 +441,26 @@ nfsd3_proc_readdir(struct svc_rqst *rqstp, struct nfsd3_readdirargs *argp,
 	RETURN_STATUS(nfserr);
 }
 
+static int
+nfsd3_is_readdirplus_supported(struct svc_rqst *rqstp, struct svc_fh *fhp)
+{
+	struct svc_export *exp;
+	int supported = 1; /* fall back to readdirplus supported in case of errors.*/
+	int err;
+
+	err = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_READ);
+	if (err) {
+		goto out;
+	}
+
+	exp = fhp->fh_export;
+	if (exp->ex_flags & NFSEXP_NOREADDIRPLUS) {
+		supported = 0;
+	}
+out:
+	return supported;
+}
+
 /*
  * Read a portion of a directory, including file handles and attrs.
  * For now, we choose to ignore the dircount parameter.
@@ -471,10 +491,16 @@ nfsd3_proc_readdirplus(struct svc_rqst *rqstp, struct nfsd3_readdirargs *argp,
 	resp->buflen = resp->count;
 	resp->rqstp = rqstp;
 	offset = argp->cookie;
-	nfserr = nfsd_readdir(rqstp, &resp->fh,
-				     &offset,
-				     &resp->common,
-				     nfs3svc_encode_entry_plus);
+
+	if (nfsd3_is_readdirplus_supported(rqstp, &resp->fh)) {
+		nfserr = nfsd_readdir(rqstp, &resp->fh,
+				&offset,
+				&resp->common,
+				nfs3svc_encode_entry_plus);
+	} else {
+		nfserr = nfserrno(-EOPNOTSUPP);
+	}
+
 	memcpy(resp->verf, argp->verf, 8);
 	for (p = rqstp->rq_respages + 1; p < rqstp->rq_next_page; p++) {
 		page_addr = page_address(*p);
diff --git a/include/uapi/linux/nfsd/export.h b/include/uapi/linux/nfsd/export.h
index cf47c313794e..584b6ef3a5e8 100644
--- a/include/uapi/linux/nfsd/export.h
+++ b/include/uapi/linux/nfsd/export.h
@@ -28,7 +28,8 @@
 #define NFSEXP_ALLSQUASH	0x0008
 #define NFSEXP_ASYNC		0x0010
 #define NFSEXP_GATHERED_WRITES	0x0020
-/* 40 80 100 currently unused */
+#define NFSEXP_NOREADDIRPLUS    0x0040
+/* 80 100 currently unused */
 #define NFSEXP_NOHIDE		0x0200
 #define NFSEXP_NOSUBTREECHECK	0x0400
 #define	NFSEXP_NOAUTHNLM	0x0800		/* Don't authenticate NLM requests - just trust */
@@ -47,7 +48,7 @@
  */
 #define	NFSEXP_V4ROOT		0x10000
 /* All flags that we claim to support.  (Note we don't support NOACL.) */
-#define NFSEXP_ALLFLAGS		0x17E3F
+#define NFSEXP_ALLFLAGS		0x1FE7F
 
 /* The flags that may vary depending on security flavor: */
 #define NFSEXP_SECINFO_FLAGS	(NFSEXP_READONLY | NFSEXP_ROOTSQUASH \
-- 
1.9.3

