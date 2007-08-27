From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 02/15] nfsd: remove unused cache_for_each macro
Date: Mon, 27 Aug 2007 16:22:43 -0400
Message-ID: <1188246176897-git-send-email-bfields@fieldses.org>
References: <11882461763072-git-send-email-bfields@fieldses.org>
	<1188246176681-git-send-email-bfields@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@citi.umich.edu>, nfs@lists.sourceforge.net
To: linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IPl6y-0004gx-B8
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 13:23:00 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IPl71-0003NA-I0
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 13:23:04 -0700
In-Reply-To: <1188246176681-git-send-email-bfields@fieldses.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: J. Bruce Fields <bfields@citi.umich.edu>

This macro is unused.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
---
 include/linux/sunrpc/cache.h |   10 ----------
 1 files changed, 0 insertions(+), 10 deletions(-)

diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 3699dff..bd7a6b0 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -136,16 +136,6 @@ sunrpc_cache_update(struct cache_detail *detail,
 		    struct cache_head *new, struct cache_head *old, int hash);
 
 
-#define cache_for_each(pos, detail, index, member) 						\
-	for (({read_lock(&(detail)->hash_lock); index = (detail)->hash_size;}) ;		\
-	     ({if (index==0)read_unlock(&(detail)->hash_lock); index--;});			\
-		)										\
-		for (pos = container_of((detail)->hash_table[index], typeof(*pos), member);	\
-		     &pos->member;								\
-		     pos = container_of(pos->member.next, typeof(*pos), member))
-
-	     
-
 extern void cache_clean_deferred(void *owner);
 
 static inline struct cache_head  *cache_get(struct cache_head *h)
-- 
1.5.3.rc5.19.g0734d


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
