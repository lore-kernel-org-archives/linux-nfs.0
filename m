From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/2] libexport.a: Add helper for populating m_addrlist[]
Date: Mon, 12 Apr 2010 15:57:25 -0400
Message-ID: <20100412195724.9839.34953.stgit@localhost.localdomain>
References: <20100412195538.9839.76495.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:8994 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753162Ab0DLT51 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Apr 2010 15:57:27 -0400
Received: by qw-out-2122.google.com with SMTP id 8so2148021qwh.37
        for <linux-nfs@vger.kernel.org>; Mon, 12 Apr 2010 12:57:27 -0700 (PDT)
In-Reply-To: <20100412195538.9839.76495.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Move common code that populates an nfs_client record's
m_addrlist to a helper function.  This eliminates a little code
duplication, and makes it simpler to add IPv6 support later.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/export/client.c |   38 ++++++++++++++++++++------------------
 1 files changed, 20 insertions(+), 18 deletions(-)

diff --git a/support/export/client.c b/support/export/client.c
index e06c874..6a25928 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -36,6 +36,22 @@ static void	client_init(nfs_client *clp, const char *hname,
 nfs_client	*clientlist[MCL_MAXTYPES] = { NULL, };
 
 
+static void
+init_addrlist(nfs_client *clp, const struct hostent *hp)
+{
+	char **ap;
+	int i;
+
+	if (hp == NULL)
+		return;
+
+	ap = hp->h_addr_list;
+	for (i = 0; *ap != NULL && i < NFSCLNT_ADDRMAX; i++, ap++)
+		clp->m_addrlist[i] = *(struct in_addr *)*ap;
+
+	clp->m_naddr = i;
+}
+
 /* if canonical is set, then we *know* this is already a canonical name
  * so hostname lookup is avoided.
  * This is used when reading /proc/fs/nfs/exports
@@ -96,14 +112,8 @@ client_lookup(char *hname, int canonical)
 		client_add(clp);
 	}
 
-	if (htype == MCL_FQDN && clp->m_naddr == 0 && hp != NULL) {
-		char	**ap = hp->h_addr_list;
-		int	i;
-
-		for (i = 0; *ap && i < NFSCLNT_ADDRMAX; i++, ap++)
-			clp->m_addrlist[i] = *(struct in_addr *)*ap;
-		clp->m_naddr = i;
-	}
+	if (htype == MCL_FQDN && clp->m_naddr == 0)
+		init_addrlist(clp, hp);
 
 	if (hp)
 		free (hp);
@@ -163,16 +173,8 @@ client_init(nfs_client *clp, const char *hname, struct hostent *hp)
 		*cp = '/';
 		return;
 	}
-
-	if (hp) {
-		char	**ap = hp->h_addr_list;
-		int	i;
-
-		for (i = 0; *ap && i < NFSCLNT_ADDRMAX; i++, ap++) {
-			clp->m_addrlist[i] = *(struct in_addr *)*ap;
-		}
-		clp->m_naddr = i;
-	}
+	
+	init_addrlist(clp, hp);
 }
 
 void

