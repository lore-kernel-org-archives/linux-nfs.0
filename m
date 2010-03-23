From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/6] libexport.a: replace xlog(L_FATAL) in client_check()
Date: Tue, 23 Mar 2010 12:53:57 -0400
Message-ID: <20100323165357.4368.65171.stgit@localhost.localdomain>
References: <20100323165122.4368.43659.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f179.google.com ([209.85.221.179]:51663 "EHLO
	mail-qy0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774Ab0CWQyA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Mar 2010 12:54:00 -0400
Received: by mail-qy0-f179.google.com with SMTP id 9so952529qyk.1
        for <linux-nfs@vger.kernel.org>; Tue, 23 Mar 2010 09:53:59 -0700 (PDT)
In-Reply-To: <20100323165122.4368.43659.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Prevent the process from exiting in client_check().  Report
bad m_type values, but return 0.

This removes another site where a mountd or exportfs process can exit
sideways.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/export/client.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/support/export/client.c b/support/export/client.c
index bf2a359..aa28fcf 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -451,9 +451,13 @@ check_netgroup(__attribute__((unused)) const nfs_client *clp,
 }
 #endif	/* !HAVE_INNETGR */
 
-/*
- * Match a host (given its hostent record) to a client record. This
- * is usually called from mountd.
+/**
+ * client_check - check if IP address information matches a cached nfs_client
+ * @clp: pointer to a cached nfs_client record
+ * @hp: pointer to hostent containing host IP information
+ *
+ * Returns 1 if the address information matches the cached nfs_client,
+ * otherwise zero.
  */
 int
 client_check(nfs_client *clp, struct hostent *hp)
@@ -472,7 +476,8 @@ client_check(nfs_client *clp, struct hostent *hp)
 	case MCL_GSS:
 		return 0;
 	default:
-		xlog(L_FATAL, "internal: bad client type %d", clp->m_type);
+		xlog(D_GENERAL, "%s: unrecognized client type: %d",
+				__func__, clp->m_type);
 	}
 
 	return 0;

