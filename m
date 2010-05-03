From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/3] libexport.a: Clean up client_add()
Date: Mon, 03 May 2010 15:24:14 -0400
Message-ID: <20100503192414.29316.84745.stgit@localhost.localdomain>
References: <20100503192041.29316.35846.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f171.google.com ([209.85.210.171]:48072 "EHLO
	mail-yx0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756192Ab0ECTYU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 May 2010 15:24:20 -0400
Received: by yxe1 with SMTP id 1so493339yxe.33
        for <linux-nfs@vger.kernel.org>; Mon, 03 May 2010 12:24:18 -0700 (PDT)
In-Reply-To: <20100503192041.29316.35846.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: client_add()'s current callers never set unknown m_type
values, so the m_type check is unnecessary.

All of client_add()'s callers are in the same source file where it is
defined, so make it a static helper function.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/export/client.c    |   26 ++++++++++++--------------
 support/include/exportfs.h |    1 -
 2 files changed, 12 insertions(+), 15 deletions(-)

diff --git a/support/export/client.c b/support/export/client.c
index 9259180..4600255 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -113,6 +113,18 @@ client_init(nfs_client *clp, const char *hname, const struct hostent *hp)
 	return 1;
 }
 
+static void
+client_add(nfs_client *clp)
+{
+	nfs_client **cpp;
+
+	cpp = &clientlist[clp->m_type];
+	while (*cpp != NULL)
+		cpp = &((*cpp)->m_next);
+	clp->m_next = NULL;
+	*cpp = clp;
+}
+
 /* if canonical is set, then we *know* this is already a canonical name
  * so hostname lookup is avoided.
  * This is used when reading /proc/fs/nfs/exports
@@ -209,20 +221,6 @@ client_dup(nfs_client *clp, struct hostent *hp)
 }
 
 void
-client_add(nfs_client *clp)
-{
-	nfs_client	**cpp;
-
-	if (clp->m_type < 0 || clp->m_type >= MCL_MAXTYPES)
-		xlog(L_FATAL, "unknown client type in client_add");
-	cpp = clientlist + clp->m_type;
-	while (*cpp)
-		cpp = &((*cpp)->m_next);
-	clp->m_next = NULL;
-	*cpp = clp;
-}
-
-void
 client_release(nfs_client *clp)
 {
 	if (clp->m_count <= 0)
diff --git a/support/include/exportfs.h b/support/include/exportfs.h
index 9a19cbb..05891c5 100644
--- a/support/include/exportfs.h
+++ b/support/include/exportfs.h
@@ -69,7 +69,6 @@ extern exp_hash_table exportlist[MCL_MAXTYPES];
 extern nfs_client *		clientlist[MCL_MAXTYPES];
 
 nfs_client *			client_lookup(char *hname, int canonical);
-void				client_add(nfs_client *);
 nfs_client *			client_dup(nfs_client *, struct hostent *);
 int				client_gettype(char *hname);
 int				client_check(nfs_client *, struct hostent *);

