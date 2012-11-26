Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35535 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753569Ab2KZOkD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 09:40:03 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/8] nfsd4: no, we're not going to check tags for utf8
Date: Mon, 26 Nov 2012 09:39:53 -0500
Message-Id: <1353940799-11763-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1353940799-11763-1-git-send-email-bfields@redhat.com>
References: <1353940799-11763-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c |    6 ------
 1 file changed, 6 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 406d0c4..9dfad58 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1595,12 +1595,6 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 	bool cachethis = false;
 	int i;
 
-	/*
-	 * XXX: According to spec, we should check the tag
-	 * for UTF-8 compliance.  I'm postponing this for
-	 * now because it seems that some clients do use
-	 * binary tags.
-	 */
 	READ_BUF(4);
 	READ32(argp->taglen);
 	READ_BUF(argp->taglen + 8);
-- 
1.7.9.5

