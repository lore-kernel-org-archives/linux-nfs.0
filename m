From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/4] libexport.a: Remove dead code
Date: Sun, 21 Mar 2010 20:38:06 -0400
Message-ID: <20100322003806.30360.79546.stgit@localhost.localdomain>
References: <20100322003317.30360.18289.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:16671 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753404Ab0CVAiJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Mar 2010 20:38:09 -0400
Received: by qw-out-2122.google.com with SMTP id 8so1035473qwh.37
        for <linux-nfs@vger.kernel.org>; Sun, 21 Mar 2010 17:38:08 -0700 (PDT)
In-Reply-To: <20100322003317.30360.18289.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up:  I can't find any call sites for client_find() or
client_match().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/export/client.c    |   22 ----------------------
 support/include/exportfs.h |    2 --
 2 files changed, 0 insertions(+), 24 deletions(-)

diff --git a/support/export/client.c b/support/export/client.c
index 6236561..f8c84de 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -211,28 +211,6 @@ client_freeall(void)
 	}
 }
 
-nfs_client *
-client_find(struct hostent *hp)
-{
-	nfs_client	*clp;
-	int		i;
-
-	for (i = 0; i < MCL_MAXTYPES; i++) {
-		for (clp = clientlist[i]; clp; clp = clp->m_next) {
-			if (!client_check(clp, hp))
-				continue;
-#ifdef notdef
-			if (clp->m_type == MCL_FQDN)
-				return clp;
-			return client_dup(clp, hp);
-#else
-			return clp;
-#endif
-		}
-	}
-	return NULL;
-}
-
 struct hostent *
 client_resolve(struct in_addr addr)
 {
diff --git a/support/include/exportfs.h b/support/include/exportfs.h
index 470b2ec..3eb03d9 100644
--- a/support/include/exportfs.h
+++ b/support/include/exportfs.h
@@ -69,12 +69,10 @@ extern exp_hash_table exportlist[MCL_MAXTYPES];
 extern nfs_client *		clientlist[MCL_MAXTYPES];
 
 nfs_client *			client_lookup(char *hname, int canonical);
-nfs_client *			client_find(struct hostent *);
 void				client_add(nfs_client *);
 nfs_client *			client_dup(nfs_client *, struct hostent *);
 int				client_gettype(char *hname);
 int				client_check(nfs_client *, struct hostent *);
-int				client_match(nfs_client *, char *hname);
 void				client_release(nfs_client *);
 void				client_freeall(void);
 char *				client_compose(struct hostent *he);

