From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/3] libexport.a: Refactor client_init()
Date: Mon, 03 May 2010 15:24:03 -0400
Message-ID: <20100503192403.29316.59111.stgit@localhost.localdomain>
References: <20100503192041.29316.35846.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f202.google.com ([209.85.223.202]:59001 "EHLO
	mail-iw0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756192Ab0ECTYH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 May 2010 15:24:07 -0400
Received: by iwn40 with SMTP id 40so3674098iwn.1
        for <linux-nfs@vger.kernel.org>; Mon, 03 May 2010 12:24:07 -0700 (PDT)
In-Reply-To: <20100503192041.29316.35846.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up:  Move subnet hostname parsing logic out of client_init() to
make it simpler to introduce IPv6 support.

Make client_init() a helper, since it's already static.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/export/client.c |   99 +++++++++++++++++++++++++++--------------------
 1 files changed, 56 insertions(+), 43 deletions(-)

diff --git a/support/export/client.c b/support/export/client.c
index eafc2bf..9259180 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -30,8 +30,6 @@ extern int	innetgr(char *netgr, char *host, char *, char *);
 #endif
 
 static char	*add_name(char *old, const char *add);
-static int	client_init(nfs_client *clp, const char *hname,
-					struct hostent *hp);
 
 nfs_client	*clientlist[MCL_MAXTYPES] = { NULL, };
 
@@ -59,6 +57,62 @@ client_free(nfs_client *clp)
 	free(clp);
 }
 
+static int
+init_netmask(nfs_client *clp, const char *slash)
+{
+	if (strchr(slash + 1, '.') != NULL)
+		clp->m_addrlist[1].s_addr = inet_addr(slash + 1);
+	else {
+		int prefixlen = atoi(slash + 1);
+		if (0 < prefixlen && prefixlen <= 32)
+			clp->m_addrlist[1].s_addr =
+					htonl((uint32_t)~0 << (32 - prefixlen));
+		else
+			goto out_badprefix;
+	}
+
+	return 1;
+
+out_badprefix:
+	xlog(L_ERROR, "Invalid prefix `%s' for %s", slash + 1, clp->m_hostname);
+	return 0;
+}
+
+static int
+init_subnetwork(nfs_client *clp)
+{
+	static char slash32[] = "/32";
+	char *cp;
+
+	cp = strchr(clp->m_hostname, '/');
+	if (cp == NULL)
+		cp = slash32;
+
+	*cp = '\0';
+	clp->m_addrlist[0].s_addr = inet_addr(clp->m_hostname);
+	*cp = '/';
+
+	return init_netmask(clp, cp);
+}
+
+static int
+client_init(nfs_client *clp, const char *hname, const struct hostent *hp)
+{
+	clp->m_hostname = strdup(hname);
+	if (clp->m_hostname == NULL)
+		return 0;
+
+	clp->m_exported = 0;
+	clp->m_count = 0;
+	clp->m_naddr = 0;
+
+	if (clp->m_type == MCL_SUBNETWORK)
+		return init_subnetwork(clp);
+
+	init_addrlist(clp, hp);
+	return 1;
+}
+
 /* if canonical is set, then we *know* this is already a canonical name
  * so hostname lookup is avoided.
  * This is used when reading /proc/fs/nfs/exports
@@ -154,47 +208,6 @@ client_dup(nfs_client *clp, struct hostent *hp)
 	return new;
 }
 
-static int
-client_init(nfs_client *clp, const char *hname, struct hostent *hp)
-{
-	clp->m_hostname = strdup(hname);
-	if (clp->m_hostname == NULL)
-		return 0;
-
-	clp->m_exported = 0;
-	clp->m_count = 0;
-	clp->m_naddr = 0;
-
-	if (clp->m_type == MCL_SUBNETWORK) {
-		char	*cp = strchr(clp->m_hostname, '/');
-		static char slash32[] = "/32";
-
-		if(!cp) cp = slash32;
-		*cp = '\0';
-		clp->m_addrlist[0].s_addr = inet_addr(clp->m_hostname);
-		if (strchr(cp + 1, '.')) {
-			clp->m_addrlist[1].s_addr = inet_addr(cp+1);
-		}
-		else {
-			int netmask = atoi(cp + 1);
-			if (0 < netmask && netmask <= 32) {
-				clp->m_addrlist[1].s_addr =
-					htonl ((uint32_t) ~0 << (32 - netmask));
-			}
-			else {
-				xlog(L_ERROR, "invalid netmask `%s' for %s",
-					     cp + 1, clp->m_hostname);
-				return 0;
-			}
-		}
-		*cp = '/';
-		return 1;
-	}
-	
-	init_addrlist(clp, hp);
-	return 1;
-}
-
 void
 client_add(nfs_client *clp)
 {

