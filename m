Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:48094 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755707Ab0HXQf1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Aug 2010 12:35:27 -0400
Received: by iwn5 with SMTP id 5so4689906iwn.19
        for <linux-nfs@vger.kernel.org>; Tue, 24 Aug 2010 09:35:26 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/5] libexport.a: Prepare to recognize IPv6 addresses in
	client_gettype()
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 24 Aug 2010 12:35:22 -0400
Message-ID: <20100824163522.2433.38923.stgit@matisse.1015granger.net>
In-Reply-To: <20100824162926.2433.7535.stgit@matisse.1015granger.net>
References: <20100824162926.2433.7535.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The current open-coded parsing logic in client_gettype() will be hard
to modify to recognize IPv6 addresses.  Use a more generic mechanism
for detecting IP presentation addresses.

IPv6 will be enabled automatically in client_gettype() when host_pton()
is changed to support IPv6 addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/export/client.c |   23 ++++++++++++++---------
 1 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/support/export/client.c b/support/export/client.c
index 21001ce..3e797c9 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -602,7 +602,8 @@ client_check(const nfs_client *clp, const struct addrinfo *ai)
 int
 client_gettype(char *ident)
 {
-	char	*sp;
+	struct addrinfo *ai;
+	char *sp;
 
 	if (ident[0] == '\0' || strcmp(ident, "*")==0)
 		return MCL_ANONYMOUS;
@@ -622,12 +623,16 @@ client_gettype(char *ident)
 		if (*sp == '\\' && sp[1])
 			sp++;
 	}
-	/* check for N.N.N.N */
-	sp = ident;
-	if(!isdigit(*sp) || strtoul(sp, &sp, 10) > 255 || *sp != '.') return MCL_FQDN;
-	sp++; if(!isdigit(*sp) || strtoul(sp, &sp, 10) > 255 || *sp != '.') return MCL_FQDN;
-	sp++; if(!isdigit(*sp) || strtoul(sp, &sp, 10) > 255 || *sp != '.') return MCL_FQDN;
-	sp++; if(!isdigit(*sp) || strtoul(sp, &sp, 10) > 255 || *sp != '\0') return MCL_FQDN;
-	/* we lie here a bit. but technically N.N.N.N == N.N.N.N/32 :) */
-	return MCL_SUBNETWORK;
+
+	/*
+	 * Treat unadorned IP addresses as MCL_SUBNETWORK.
+	 * Everything else is MCL_FQDN.
+	 */
+	ai = host_pton(ident);
+	if (ai != NULL) {
+		freeaddrinfo(ai);
+		return MCL_SUBNETWORK;
+	}
+
+	return MCL_FQDN;
 }

