From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/4] libexport.a: Allow client_init() to fail instead of exit
Date: Mon, 19 Apr 2010 16:21:23 -0400
Message-ID: <20100419202122.3567.63867.stgit@matisse.1015granger.net>
References: <20100419201855.3567.9644.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:64741 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751178Ab0DSUVZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Apr 2010 16:21:25 -0400
Received: by vws5 with SMTP id 5so2418494vws.19
        for <linux-nfs@vger.kernel.org>; Mon, 19 Apr 2010 13:21:25 -0700 (PDT)
In-Reply-To: <20100419201855.3567.9644.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

client_init()'s current callers can now deal correctly with a failure.
Get rid of code that can cause our process to exit in client_init(),
if address mask parsing or memory allocation fails.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/export/client.c |   24 +++++++++++++++++-------
 1 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/support/export/client.c b/support/export/client.c
index 859dcf1..8f83da3 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -30,7 +30,7 @@ extern int	innetgr(char *netgr, char *host, char *, char *);
 #endif
 
 static char	*add_name(char *old, const char *add);
-static void	client_init(nfs_client *clp, const char *hname,
+static int	client_init(nfs_client *clp, const char *hname,
 					struct hostent *hp);
 
 nfs_client	*clientlist[MCL_MAXTYPES] = { NULL, };
@@ -115,13 +115,18 @@ client_lookup(char *hname, int canonical)
 		clp = (nfs_client *) xmalloc(sizeof(*clp));
 		memset(clp, 0, sizeof(*clp));
 		clp->m_type = htype;
-		client_init(clp, hname, NULL);
+		if (!client_init(clp, hname, NULL)) {
+			client_free(clp);
+			clp = NULL;
+			goto out;
+		}
 		client_add(clp);
 	}
 
 	if (htype == MCL_FQDN && clp->m_naddr == 0)
 		init_addrlist(clp, hp);
 
+out:
 	if (hp)
 		free (hp);
 
@@ -138,12 +143,15 @@ client_dup(nfs_client *clp, struct hostent *hp)
 	new->m_type = MCL_FQDN;
 	new->m_hostname = NULL;
 
-	client_init(new, (char *) hp->h_name, hp);
+	if (!client_init(new, hp->h_name, hp)) {
+		client_free(new);
+		return NULL;
+	}
 	client_add(new);
 	return new;
 }
 
-static void
+static int
 client_init(nfs_client *clp, const char *hname, struct hostent *hp)
 {
 	xfree(clp->m_hostname);
@@ -173,15 +181,17 @@ client_init(nfs_client *clp, const char *hname, struct hostent *hp)
 					htonl ((uint32_t) ~0 << (32 - netmask));
 			}
 			else {
-				xlog(L_FATAL, "invalid netmask `%s' for %s",
-				     cp + 1, clp->m_hostname);
+				xlog(L_ERROR, "invalid netmask `%s' for %s",
+					     cp + 1, clp->m_hostname);
+				return 0;
 			}
 		}
 		*cp = '/';
-		return;
+		return 1;
 	}
 	
 	init_addrlist(clp, hp);
+	return 1;
 }
 
 void

