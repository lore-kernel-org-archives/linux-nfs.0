Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:47709 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752914Ab0HDRNO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Aug 2010 13:13:14 -0400
Received: by mail-gx0-f174.google.com with SMTP id 23so2071760gxk.19
        for <linux-nfs@vger.kernel.org>; Wed, 04 Aug 2010 10:13:14 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/2] libexport: Fix IP address check in check_netgroup()
To: steved@redhat.com
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
Date: Wed, 04 Aug 2010 13:13:11 -0400
Message-ID: <20100804171310.2657.35125.stgit@seurat.1015granger.net>
In-Reply-To: <20100804171036.2657.8657.stgit@seurat.1015granger.net>
References: <20100804171036.2657.8657.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Neil Brown reports that recent changes to replace
gethostby{addr,name}(3) with get{addr,info}name(3) may have
inadvertently broken netgroup support.  There used to be a
gethostbyaddr(3) call in the third paragraph in check_netgroup().

See http://marc.info/?l=linux-nfs&m=128084830214653&w=2 .

Introduced by commit 0509d3428f523776ddd9d6e9fa318587d3ec7d84.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Neil Brown <neilb@suse.de>
---

 support/export/client.c |   22 ++++++++++++++++------
 1 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/support/export/client.c b/support/export/client.c
index 6667200..278a990 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -583,14 +583,19 @@ static int
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
@@ -612,10 +617,15 @@ check_netgroup(const nfs_client *clp, const struct addrinfo *ai)
 	/* If hname is ip address convert to FQDN */
 	tmp = host_pton(hname);
 	if (tmp != NULL) {
+		char *cname = host_canonname(tmp->ai_addr);
 		freeaddrinfo(tmp);
-		if (innetgr(netgroup, hname, NULL, NULL)) {
-			match = 1;
-			goto out;
+		if (cname != NULL) {
+			free(hname);
+			hname = cname;
+			if (innetgr(netgroup, hname, NULL, NULL)) {
+				match = 1;
+				goto out;
+			}
 		}
 	}
 
@@ -626,9 +636,9 @@ check_netgroup(const nfs_client *clp, const struct addrinfo *ai)
 
 	*dot = '\0';
 	match = innetgr(netgroup, hname, NULL, NULL);
-	*dot = '.';
 
 out:
+	free(hname);
 	return match;
 }
 #else	/* !HAVE_INNETGR */

