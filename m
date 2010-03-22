From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/4] libexport.a: Fix whitespace damage in
	support/export/export.c
Date: Sun, 21 Mar 2010 20:38:23 -0400
Message-ID: <20100322003823.30360.7616.stgit@localhost.localdomain>
References: <20100322003317.30360.18289.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:16671 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753404Ab0CVAi0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Mar 2010 20:38:26 -0400
Received: by qw-out-2122.google.com with SMTP id 8so1035473qwh.37
        for <linux-nfs@vger.kernel.org>; Sun, 21 Mar 2010 17:38:25 -0700 (PDT)
In-Reply-To: <20100322003317.30360.18289.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up whitespace damage introduced by commit 4cacc965.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/export/export.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/support/export/export.c b/support/export/export.c
index 2943466..ba643b2 100644
--- a/support/export/export.c
+++ b/support/export/export.c
@@ -128,6 +128,7 @@ export_dup(nfs_export *exp, struct hostent *hp)
 
 	return new;
 }
+
 /*
  * Add export entry to hash table
  */
@@ -280,11 +281,11 @@ export_freeall(void)
 			xfree(exp->m_export.e_hostname);
 			xfree(exp);
 		}
-      for(j = 0; j < HASH_TABLE_SIZE; j++) {
-        exportlist[i].entries[j].p_first = NULL;
-        exportlist[i].entries[j].p_last = NULL;
-      }
-      exportlist[i].p_head = NULL;
+		for (j = 0; j < HASH_TABLE_SIZE; j++) {
+			exportlist[i].entries[j].p_first = NULL;
+			exportlist[i].entries[j].p_last = NULL;
+		}
+		exportlist[i].p_head = NULL;
 	}
 	client_freeall();
 }

