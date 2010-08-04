Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:64648 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752914Ab0HDRNF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Aug 2010 13:13:05 -0400
Received: by gwb20 with SMTP id 20so2074163gwb.19
        for <linux-nfs@vger.kernel.org>; Wed, 04 Aug 2010 10:13:03 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/2] libexport: Add a common exit label to check_netgroup()
To: steved@redhat.com
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
Date: Wed, 04 Aug 2010 13:13:00 -0400
Message-ID: <20100804171259.2657.58455.stgit@seurat.1015granger.net>
In-Reply-To: <20100804171036.2657.8657.stgit@seurat.1015granger.net>
References: <20100804171036.2657.8657.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I'm about to change check_netgroup() to free dynamically allocated
resources before it returns, so a common exit point is needed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Neil Brown <neilb@suse.de>
---

 support/export/client.c |   23 ++++++++++++++++-------
 1 files changed, 16 insertions(+), 7 deletions(-)

diff --git a/support/export/client.c b/support/export/client.c
index 91b17f3..6667200 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -589,37 +589,46 @@ check_netgroup(const nfs_client *clp, const struct addrinfo *ai)
 	int i, match;
 	char *dot;
 
+	match = 0;
+
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
 		freeaddrinfo(tmp);
-		if (innetgr(netgroup, hname, NULL, NULL))
-			return 1;
+		if (innetgr(netgroup, hname, NULL, NULL)) {
+			match = 1;
+			goto out;
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
 	return match;
 }
 #else	/* !HAVE_INNETGR */

