Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:52550 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753173Ab0HWRLG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Aug 2010 13:11:06 -0400
Received: by iwn5 with SMTP id 5so3716912iwn.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Aug 2010 10:11:05 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/5] libexport: Fix IP address check in check_netgroup()
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 23 Aug 2010 13:11:02 -0400
Message-ID: <20100823171101.2123.49893.stgit@matisse.1015granger.net>
In-Reply-To: <20100823170552.2123.43124.stgit@matisse.1015granger.net>
References: <20100823170552.2123.43124.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Neil Brown reports that recent changes to replace
gethostby{addr,name}(3) with get{addr,info}name(3) may have
inadvertently broken netgroup support.

There used to be a gethostbyaddr(3) call in the third paragraph in
check_netgroup().  The reason for that gethostbyaddr(3) call was that
the first innetgr(3) call has already confirmed that hname is not a
member of the netgroup.  We also need to confirm that, if hname
happens to be an IP address, the hostname bound to that IP address is
not a member of the netgroup, either.

Fix this by restoring appropriate address to hostname mapping of hname
before retrying the innetgr(3) call.

See http://marc.info/?l=linux-nfs&m=128084830214653&w=2 .

Introduced by commit 0509d3428f523776ddd9d6e9fa318587d3ec7d84.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Neil Brown <neilb@suse.de>
---

 support/export/client.c |   27 ++++++++++++++++++++-------
 1 files changed, 20 insertions(+), 7 deletions(-)

diff --git a/support/export/client.c b/support/export/client.c
index b1a3a09..21001ce 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -490,14 +490,19 @@ static int
 check_netgroup(const nfs_client *clp, const struct addrinfo *ai)
 {
 	const char *netgroup = clp->m_hostname + 1;
-	const char *hname = ai->ai_canonname;
 	struct addrinfo *tmp = NULL;
 	struct hostent *hp;
+	char *dot, *hname;
 	int i, match;
-	char *dot;
 
 	match = 0;
 
+	hname = strdup(ai->ai_canonname);
+	if (hname == NULL) {
+		xlog(D_GENERAL, "%s: no memory for strdup", __func__);
+		goto out;
+	}
+
 	/* First, try to match the hostname without
 	 * splitting off the domain */
 	if (innetgr(netgroup, hname, NULL, NULL)) {
@@ -516,13 +521,21 @@ check_netgroup(const nfs_client *clp, const struct addrinfo *ai)
 			}
 	}
 
-	/* If hname is ip address convert to FQDN */
+	/* If hname happens to be an IP address, convert it
+	 * to a the canonical DNS name bound to this address. */
 	tmp = host_pton(hname);
 	if (tmp != NULL) {
+		char *cname = host_canonname(tmp->ai_addr);
 		freeaddrinfo(tmp);
-		if (innetgr(netgroup, hname, NULL, NULL)) {
-			match = 1;
-			goto out;
+
+		/* The resulting FQDN may be in our netgroup. */
+		if (cname != NULL) {
+			free(hname);
+			hname = cname;
+			if (innetgr(netgroup, hname, NULL, NULL)) {
+				match = 1;
+				goto out;
+			}
 		}
 	}
 
@@ -533,9 +546,9 @@ check_netgroup(const nfs_client *clp, const struct addrinfo *ai)
 
 	*dot = '\0';
 	match = innetgr(netgroup, hname, NULL, NULL);
-	*dot = '.';
 
 out:
+	free(hname);
 	return match;
 }
 #else	/* !HAVE_INNETGR */

