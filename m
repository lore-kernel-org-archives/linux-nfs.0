Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:63356 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755723Ab0HXQfl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Aug 2010 12:35:41 -0400
Received: by gyd8 with SMTP id 8so2603500gyd.19
        for <linux-nfs@vger.kernel.org>; Tue, 24 Aug 2010 09:35:40 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/5] libexport.a: Use host helper to parse address in
	client_init()
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 24 Aug 2010 12:35:32 -0400
Message-ID: <20100824163532.2433.10443.stgit@matisse.1015granger.net>
In-Reply-To: <20100824162926.2433.7535.stgit@matisse.1015granger.net>
References: <20100824162926.2433.7535.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Take the first step towards making it possible to parse either IPv4 or
IPv6 addresses in client_init().  It won't handle IPv6 until
host_pton() has IPv6 support enabled, and it still doesn't deal with
IPv6 netmasks yet.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/export/client.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/support/export/client.c b/support/export/client.c
index 3e797c9..a89142d 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -86,10 +86,8 @@ out_badprefix:
 static int
 init_subnetwork(nfs_client *clp)
 {
-	struct sockaddr_in sin = {
-		.sin_family		= AF_INET,
-	};
 	static char slash32[] = "/32";
+	struct addrinfo *ai;
 	char *cp;
 
 	cp = strchr(clp->m_hostname, '/');
@@ -97,9 +95,14 @@ init_subnetwork(nfs_client *clp)
 		cp = slash32;
 
 	*cp = '\0';
-	sin.sin_addr.s_addr = inet_addr(clp->m_hostname);
-	set_addrlist_in(clp, 0, &sin);
+	ai = host_pton(clp->m_hostname);
 	*cp = '/';
+	if (ai == NULL) {
+		xlog(L_ERROR, "Invalid IP address %s", clp->m_hostname);
+		return false;
+	}
+	set_addrlist(clp, 0, ai->ai_addr);
+	freeaddrinfo(ai);
 
 	return init_netmask(clp, cp);
 }

