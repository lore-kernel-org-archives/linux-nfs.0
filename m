Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49156 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751551Ab2JARfO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Oct 2012 13:35:14 -0400
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1TIjti-0007lV-4S
	for linux-nfs@vger.kernel.org; Mon, 01 Oct 2012 13:35:14 -0400
Date: Mon, 1 Oct 2012 13:35:14 -0400
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: stricter endianness in reply cache hash
Message-ID: <20121001173513.GA29803@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Just a dumb patch to make u32/__be32 use more consistent, queuing for
3.7.--b.

commit 46056c57875540e945b9fc84042f2e4d7777b2d3
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Fri Jul 27 11:57:00 2012 -0400

    nfsd: stricter endianness in reply cache hash
    
    Admittedly this is just to shut up sparse; the byte-swapping has no
    effect on the result.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 2cbac34..6e5b8a8 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -29,10 +29,10 @@ static int			cache_disabled = 1;
 /*
  * Calculate the hash index from an XID.
  */
-static inline u32 request_hash(u32 xid)
+static inline u32 request_hash(__be32 xid)
 {
-	u32 h = xid;
-	h ^= (xid >> 24);
+	u32 h = ntohl(xid);
+	h ^= (h >> 24);
 	return h & (HASHSIZE-1);
 }
 
