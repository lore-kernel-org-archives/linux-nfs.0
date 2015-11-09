Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from anor.bigon.be ([91.121.173.99]:60442 "EHLO anor.bigon.be"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751312AbbKIXcd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Nov 2015 18:32:33 -0500
Received: from anor.bigon.be (localhost.localdomain [127.0.0.1])
	by anor.bigon.be (Postfix) with ESMTP id B69A71A1BB
	for <linux-nfs@vger.kernel.org>; Tue, 10 Nov 2015 00:25:22 +0100 (CET)
Received: from anor.bigon.be ([127.0.0.1])
	by anor.bigon.be (anor.bigon.be [127.0.0.1]) (amavisd-new, port 10026)
	with ESMTP id HXJwT-lsYN6g for <linux-nfs@vger.kernel.org>;
	Tue, 10 Nov 2015 00:25:19 +0100 (CET)
Received: from fornost.bigon.be (unknown [IPv6:2a02:578:85fc:1:226:18ff:fe08:6073])
	(using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	(Authenticated sender: bigon)
	by anor.bigon.be (Postfix) with ESMTPSA id 7CA821A070
	for <linux-nfs@vger.kernel.org>; Tue, 10 Nov 2015 00:25:19 +0100 (CET)
From: Laurent Bigonville <bigon@debian.org>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] Delete the unix socket only if we have created it
Date: Tue, 10 Nov 2015 00:25:17 +0100
Message-Id: <1447111517-5448-1-git-send-email-bigon@debian.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Laurent Bigonville <bigon@bigon.be>

If systemd has created the unix socket on our behalf, we shouldn't try
to delete it.

https://bugzilla.redhat.com/show_bug.cgi?id=1279076

Signed-off-by: Laurent Bigonville <bigon@bigon.be>
---
 src/rpcbind.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/src/rpcbind.c b/src/rpcbind.c
index 045daa1..c4265cd 100644
--- a/src/rpcbind.c
+++ b/src/rpcbind.c
@@ -87,6 +87,7 @@ static inline void __nss_configure_lookup(const char *db, const char *s) {}
 int debugging = 0;	/* Tell me what's going on */
 int doabort = 0;	/* When debugging, do an abort on errors */
 int dofork = 1;		/* fork? */
+int createdsocket = 0;  /* Did I create the socket or systemd did it for me? */
 
 rpcblist_ptr list_rbl;	/* A list of version 3/4 rpcbind services */
 
@@ -445,6 +446,7 @@ init_transport(struct netconfig *nconf)
 		memset(&sun, 0, sizeof sun);
 		sun.sun_family = AF_LOCAL;
 		unlink(_PATH_RPCBINDSOCK);
+		createdsocket = 1; /* We are now in the process of creating the unix socket */
 		strcpy(sun.sun_path, _PATH_RPCBINDSOCK);
 		addrlen = SUN_LEN(&sun);
 		sa = (struct sockaddr *)&sun;
@@ -846,7 +848,8 @@ static void
 terminate(int dummy /*__unused*/)
 {
 	close(rpcbindlockfd);
-	unlink(_PATH_RPCBINDSOCK);
+	if(createdsocket)
+		unlink(_PATH_RPCBINDSOCK);
 	unlink(RPCBINDDLOCK);
 #ifdef WARMSTART
 	write_warmstart();	/* Dump yourself */
-- 
2.6.2

