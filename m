From: Greg Banks <gnb@sgi.com>
Subject: [patch 14/29] knfsd: better hashing in the reply cache
Date: Wed, 01 Apr 2009 07:28:14 +1100
Message-ID: <20090331202942.848645000@sgi.com>
References: <20090331202800.739621000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [218.185.19.242] ([218.185.19.242]:22583 "EHLO inara.melbourne"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1762405AbZCaVCo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2009 17:02:44 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Improve the hash function to handle clients which increment the XID
in the unexpected byte order, by folding down the top bits of the XID.

Signed-off-by: Greg Banks <gnb@sgi.com>
---

 fs/nfsd/nfscache.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

Index: bfields/fs/nfsd/nfscache.c
===================================================================
--- bfields.orig/fs/nfsd/nfscache.c
+++ bfields/fs/nfsd/nfscache.c
@@ -35,12 +35,15 @@ static struct list_head 	lru_head;
 static int			cache_disabled = 1;
 
 /*
- * Calculate the hash index from an XID.
+ * Calculate the hash index from an XID.  Note, some clients increment
+ * their XIDs in host order, which can result in all the variation being
+ * in the top bits we see here.  So we fold those bits down.
  */
 static inline u32 request_hash(u32 xid)
 {
 	u32 h = xid;
 	h ^= (xid >> 24);
+	h ^= ((xid & 0xff0000) >> 8);
 	return h & (HASHSIZE-1);
 }
 

--
Greg
