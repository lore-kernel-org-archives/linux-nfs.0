Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f42.google.com ([209.85.216.42]:56144 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754593AbaIHQab (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Sep 2014 12:30:31 -0400
Received: by mail-qa0-f42.google.com with SMTP id dc16so10340242qab.1
        for <linux-nfs@vger.kernel.org>; Mon, 08 Sep 2014 09:30:30 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org
Subject: [PATCH v3 2/7] nfsdcltrack: update comments in sqlite.c
Date: Mon,  8 Sep 2014 12:30:16 -0400
Message-Id: <1410193821-25109-3-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1410193821-25109-1-git-send-email-jlayton@primarydata.com>
References: <1410193821-25109-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up and fix some inaccuracies.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 utils/nfsdcltrack/sqlite.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/utils/nfsdcltrack/sqlite.c b/utils/nfsdcltrack/sqlite.c
index bac678980938..352f029d55c0 100644
--- a/utils/nfsdcltrack/sqlite.c
+++ b/utils/nfsdcltrack/sqlite.c
@@ -21,17 +21,15 @@
  * Explanation:
  *
  * This file contains the code to manage the sqlite backend database for the
- * clstated upcall daemon.
+ * nfsdcltrack usermodehelper upcall program.
  *
  * The main database is called main.sqlite and contains the following tables:
  *
  * parameters: simple key/value pairs for storing database info
  *
- * clients: one column containing a BLOB with the as sent by the client
- * 	    and a timestamp (in epoch seconds) of when the record was
- * 	    established
- *
- * FIXME: should we also record the fsid being accessed?
+ * clients: an "id" column containing a BLOB with the long-form clientid as
+ * 	    sent by the client, a "time" column containing a timestamp (in
+ * 	    epoch seconds) of when the record was last updated.
  */
 
 #ifdef HAVE_CONFIG_H
-- 
1.9.3

