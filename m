Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f51.google.com ([209.85.192.51]:50572 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751626AbaHSSuD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Aug 2014 14:50:03 -0400
Received: by mail-qg0-f51.google.com with SMTP id a108so6466135qge.10
        for <linux-nfs@vger.kernel.org>; Tue, 19 Aug 2014 11:49:58 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/7] nfsdcltrack: update comments in sqlite.c
Date: Tue, 19 Aug 2014 14:49:44 -0400
Message-Id: <1408474189-14491-3-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1408474189-14491-1-git-send-email-jlayton@primarydata.com>
References: <1408474189-14491-1-git-send-email-jlayton@primarydata.com>
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

