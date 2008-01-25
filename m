From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 014/100] knfsd: fix cache.c comment
Date: Fri, 25 Jan 2008 18:15:54 -0500
Message-ID: <1201303040-7779-14-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-10-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-11-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-12-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-13-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47319 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762012AbYAYXRY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:24 -0500
In-Reply-To: <1201303040-7779-13-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The path here must be left over from some earlier draft; fix it.  And do
some more minor cleanup while we're there.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/cache.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 578084f..0d747e2 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -634,13 +634,13 @@ void cache_clean_deferred(void *owner)
 /*
  * communicate with user-space
  *
- * We have a magic /proc file - /proc/sunrpc/cache
- * On read, you get a full request, or block
- * On write, an update request is processed
- * Poll works if anything to read, and always allows write
+ * We have a magic /proc file - /proc/sunrpc/<cachename>/channel.
+ * On read, you get a full request, or block.
+ * On write, an update request is processed.
+ * Poll works if anything to read, and always allows write.
  *
  * Implemented by linked list of requests.  Each open file has
- * a ->private that also exists in this list.  New request are added
+ * a ->private that also exists in this list.  New requests are added
  * to the end and may wakeup and preceding readers.
  * New readers are added to the head.  If, on read, an item is found with
  * CACHE_UPCALLING clear, we free it from the list.
-- 
1.5.4.rc2.60.gb2e62

