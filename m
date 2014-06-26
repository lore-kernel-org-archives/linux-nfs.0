Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46906 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755560AbaFZBsN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Jun 2014 21:48:13 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trondmy@gmail.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/8] nfsd: make NFSv2 null terminate symlink data
Date: Wed, 25 Jun 2014 21:48:02 -0400
Message-Id: <1403747288-21590-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1403747288-21590-1-git-send-email-bfields@redhat.com>
References: <20140624204418.GG2343@pad.redhat.com>
 <1403747288-21590-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

It's simple enough for NFSv2 to null-terminate the symlink data.

A bit weird (it depends on knowing that we've already read the following
byte, which is either padding or part of the mode), but no worse than
the conditional kstrdup it otherwise relies on in nfsd_symlink().

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfsproc.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 54c6b3d..aebe23c 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -403,8 +403,11 @@ nfsd_proc_symlink(struct svc_rqst *rqstp, struct nfsd_symlinkargs *argp,
 
 	fh_init(&newfh, NFS_FHSIZE);
 	/*
-	 * Create the link, look up new file and set attrs.
+	 * Crazy hack: the request fits in a page, and already-decoded
+	 * attributes follow argp->tname, so it's safe to just write a
+	 * null to ensure it's null-terminated:
 	 */
+	argp->tname[argp->tlen] = '\0';
 	nfserr = nfsd_symlink(rqstp, &argp->ffh, argp->fname, argp->flen,
 						 argp->tname, argp->tlen,
 				 		 &newfh, &argp->attrs);
-- 
1.7.9.5

