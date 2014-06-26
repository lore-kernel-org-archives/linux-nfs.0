Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46901 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754799AbaFZBsM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Jun 2014 21:48:12 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trondmy@gmail.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/8] nfsd: fix rare symlink decoding bug
Date: Wed, 25 Jun 2014 21:48:01 -0400
Message-Id: <1403747288-21590-1-git-send-email-bfields@redhat.com>
In-Reply-To: <20140624204418.GG2343@pad.redhat.com>
References: <20140624204418.GG2343@pad.redhat.com>
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
 fs/nfsd/nfs4proc.c |    9 ---------
 fs/nfsd/nfs4xdr.c  |   13 ++++++++++++-
 2 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index a6be9d3..2b3795a 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -621,15 +621,6 @@ nfsd4_create(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	switch (create->cr_type) {
 	case NF4LNK:
-		/* ugh! we have to null-terminate the linktext, or
-		 * vfs_symlink() will choke.  it is always safe to
-		 * null-terminate by brute force, since at worst we
-		 * will overwrite the first byte of the create namelen
-		 * in the XDR buffer, which has already been extracted
-		 * during XDR decode.
-		 */
-		create->cr_linkname[create->cr_linklen] = 0;
-
 		status = nfsd_symlink(rqstp, &cstate->current_fh,
 				      create->cr_name, create->cr_namelen,
 				      create->cr_linkname, create->cr_linklen,
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 30913c8..a1c48b4 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -600,7 +600,18 @@ nfsd4_decode_create(struct nfsd4_compoundargs *argp, struct nfsd4_create *create
 		READ_BUF(4);
 		create->cr_linklen = be32_to_cpup(p++);
 		READ_BUF(create->cr_linklen);
-		SAVEMEM(create->cr_linkname, create->cr_linklen);
+		/*
+		 * The VFS will want a null-terminated string, and
+		 * null-terminating in place isn't safe since this might
+		 * end on a page boundary:
+		 */
+		create->cr_linkname =
+				kmalloc(create->cr_linklen + 1, GFP_KERNEL);
+		if (!create->cr_linkname)
+			return nfserr_jukebox;
+		memcpy(create->cr_linkname, p, create->cr_linklen);
+		create->cr_linkname[create->cr_linklen] = '\0';
+		defer_free(argp, kfree, create->cr_linkname);
 		break;
 	case NF4BLK:
 	case NF4CHR:
-- 
1.7.9.5

