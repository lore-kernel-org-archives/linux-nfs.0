From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] Fix IP address check in check_netgroup()
Date: Tue, 03 Aug 2010 15:13:06 -0400
Message-ID: <20100803191107.19326.19237.stgit@seurat.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: neilb@suse.de
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:47638 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756010Ab0HCTNL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Aug 2010 15:13:11 -0400
Received: by yxg6 with SMTP id 6so1705762yxg.19
        for <linux-nfs@vger.kernel.org>; Tue, 03 Aug 2010 12:13:10 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Neil Brown reports that recent changes to replace
gethostby{addr,name}(3) with get{addr,info}name(3) may have
inadvertently broken netgroup support.  There used to be a
gethostbyaddr(3) call in the third paragraph in check_netgroup().

See http://marc.info/?l=linux-nfs&m=128084830214653&w=2 .

Introduced by commit 0509d3428f523776ddd9d6e9fa318587d3ec7d84.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

Compile-tested only.

 support/export/client.c |   37 ++++++++++++++++++++++++++++---------
 1 files changed, 28 insertions(+), 9 deletions(-)

diff --git a/support/export/client.c b/support/export/client.c
index 91b17f3..0d34a55 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -583,43 +583,62 @@ static int
 check_netgroup(const nfs_client *clp, const struct addrinfo *ai)
 {
 	const char *netgroup = clp->m_hostname + 1;
-	const char *hname = ai->ai_canonname;
 	struct addrinfo *tmp = NULL;
 	struct hostent *hp;
+	char *dot, *hname;
 	int i, match;
-	char *dot;
+
+	match = 0;
+
+	hname = strdup(ai->ai_canonname);
+	if (hname == NULL) {
+		xlog(D_GENERAL, "%s: no memory for strdup", __func__);
+		goto out;
+	}
 
 	/* First, try to match the hostname without
 	 * splitting off the domain */
-	if (innetgr(netgroup, hname, NULL, NULL))
-		return 1;
+	if (innetgr(netgroup, hname, NULL, NULL)) {
+		match = 1;
+		goto out;
+	}
 
 	/* See if hname aliases listed in /etc/hosts or nis[+]
 	 * match the requested netgroup */
 	hp = gethostbyname(hname);
 	if (hp != NULL) {
 		for (i = 0; hp->h_aliases[i]; i++)
-			if (innetgr(netgroup, hp->h_aliases[i], NULL, NULL))
-				return 1;
+			if (innetgr(netgroup, hp->h_aliases[i], NULL, NULL)) {
+				match = 1;
+				goto out;
+			}
 	}
 
 	/* If hname is ip address convert to FQDN */
 	tmp = host_pton(hname);
 	if (tmp != NULL) {
+		char *cname = host_canonname(tmp->ai_addr);
 		freeaddrinfo(tmp);
-		if (innetgr(netgroup, hname, NULL, NULL))
-			return 1;
+		if (cname != NULL) {
+			hname = cname;
+			if (innetgr(netgroup, hname, NULL, NULL)) {
+				match = 1;
+				goto out;
+			}
+		}
 	}
 
 	/* Okay, strip off the domain (if we have one) */
 	dot = strchr(hname, '.');
 	if (dot == NULL)
-		return 0;
+		goto out;
 
 	*dot = '\0';
 	match = innetgr(netgroup, hname, NULL, NULL);
 	*dot = '.';
 
+out:
+	free(hname);
 	return match;
 }
 #else	/* !HAVE_INNETGR */

