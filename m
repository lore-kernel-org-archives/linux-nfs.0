Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f46.google.com ([209.85.192.46]:62697 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751512AbaHOOpZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Aug 2014 10:45:25 -0400
Received: by mail-qg0-f46.google.com with SMTP id z60so2249228qgd.5
        for <linux-nfs@vger.kernel.org>; Fri, 15 Aug 2014 07:45:25 -0700 (PDT)
Received: from tlielax.poochiereds.net ([2001:470:8:d63:3a60:77ff:fe93:a95d])
        by mx.google.com with ESMTPSA id t107sm3989900qgt.28.2014.08.15.07.45.23
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Aug 2014 07:45:24 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils RFC PATCH 2/7] nfsdcltrack: update comments in sqlite.c
Date: Fri, 15 Aug 2014 10:45:10 -0400
Message-Id: <1408113915-5573-3-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1408113915-5573-1-git-send-email-jlayton@primarydata.com>
References: <1408113915-5573-1-git-send-email-jlayton@primarydata.com>
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

