Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41304 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751912AbaFWVeg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Jun 2014 17:34:36 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/3] nfsd: fix rare symlink decoding bug
Date: Mon, 23 Jun 2014 17:34:30 -0400
Message-Id: <1403559272-11019-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

An NFS operation that creates a new symlink includes the symlink data,
which is xdr-encoded as a length followed by the data plus 0 to 3 bytes
of zero-padding as required to reach a 4-byte boundary.

The vfs, on the other hand, wants null-terminated data.

The simple way to handle this would be by copying the data into a newly
allocated buffer with space for the final null.

The current nfsd_symlink code tries to be more clever by skipping that
step in the (likely) case where the byte following the string is already
0.

But that assumes that the byte following the string is ours to look at.
In fact, it might be the first byte of a page that we can't read, or of
some object that another task might modify.

Worse, the NFSv4 code tries to fix the problem by actually writing to
that byte.

In the NFSv2/v3 cases this actually appears to be safe:

	- nfs3svc_decode_symlinkargs explicitly null-terminates the data
	  (after first checking its length and copying it to a new
	  page).
	- NFSv2 limits symlinks to 1k.  The buffer holding the rpc
	  request is always at least a page, and the link data (and
	  previous fields) have maximum lengths that prevent the request
	  from reaching the end of a page.

In the NFSv4 case the CREATE op is potentially just one part of a long
compound so can end up on the end of a page if you're unlucky.

The minimal fix here is to copy and null-terminate in the NFSv4 case.
The nfsd_symlink() interface here seems too fragile, though.  It should
really either do the copy itself every time or just require a
null-terminated string.

Reported-by: Jeff Layton <jlayton@primarydata.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c |   22 +++++++++++++---------
 1 file changed, 13 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 6851b00..453c907 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -601,6 +601,8 @@ nfsd4_create(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 {
 	struct svc_fh resfh;
 	__be32 status;
+	u32 len;
+	char *data;
 	dev_t rdev;
 
 	fh_init(&resfh, NFS4_FHSIZE);
@@ -617,19 +619,21 @@ nfsd4_create(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	switch (create->cr_type) {
 	case NF4LNK:
-		/* ugh! we have to null-terminate the linktext, or
-		 * vfs_symlink() will choke.  it is always safe to
-		 * null-terminate by brute force, since at worst we
-		 * will overwrite the first byte of the create namelen
-		 * in the XDR buffer, which has already been extracted
-		 * during XDR decode.
+		len = create->cr_linklen;
+		data = kmalloc(len + 1, GFP_KERNEL);
+		/*
+		 * Null-terminating in place isn't safe since
+		 * cr_linkname might end on a page boundary.
 		 */
-		create->cr_linkname[create->cr_linklen] = 0;
-
+		if (!data)
+			return nfserr_jukebox;
+		memcpy(data, create->cr_linkname, len + 1);
+		data[len] = '\0';
 		status = nfsd_symlink(rqstp, &cstate->current_fh,
 				      create->cr_name, create->cr_namelen,
-				      create->cr_linkname, create->cr_linklen,
+				      data, len,
 				      &resfh, &create->cr_iattr);
+		kfree(data);
 		break;
 
 	case NF4BLK:
-- 
1.7.9.5

