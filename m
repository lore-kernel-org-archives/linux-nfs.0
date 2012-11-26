Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43768 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755837Ab2KZWDo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 17:03:44 -0500
Date: Mon, 26 Nov 2012 17:03:43 -0500
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] Revert "mountd: handle allocation failures in auth_unix_ip
 upcall"
Message-ID: <20121126220343.GA18140@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

This reverts commit 485f7a21e1649797f29317b865cbb094c1f6a71d.  The
failures handled there could be any sort of name resolution failure, not
just an allocation, and failing to downcall (hence leaving the client
hanging) is not the correct thing to do in those cases.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 utils/mountd/cache.c | 12 +++---------
 1 file changed, 3 insertions(+), 9 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 8f14032..6710eca 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -84,6 +84,7 @@ static void auth_unix_ip(FILE *f)
 	char ipaddr[INET6_ADDRSTRLEN];
 	char *client = NULL;
 	struct addrinfo *tmp = NULL;
+	struct addrinfo *ai = NULL;
 	if (readline(fileno(f), &lbuf, &lbuflen) != 1)
 		return;
 
@@ -106,16 +107,12 @@ static void auth_unix_ip(FILE *f)
 
 	/* addr is a valid, interesting address, find the domain name... */
 	if (!use_ipaddr) {
-		struct addrinfo *ai = NULL;
-
 		ai = client_resolve(tmp->ai_addr);
-		if (ai == NULL)
-			goto out;
 		client = client_compose(ai);
 		freeaddrinfo(ai);
-		if (!client)
-			goto out;
 	}
+	freeaddrinfo(tmp);
+
 	qword_print(f, "nfsd");
 	qword_print(f, ipaddr);
 	qword_printuint(f, time(0) + DEFAULT_TTL);
@@ -127,9 +124,6 @@ static void auth_unix_ip(FILE *f)
 	xlog(D_CALL, "auth_unix_ip: client %p '%s'", client, client?client: "DEFAULT");
 
 	free(client);
-out:
-	freeaddrinfo(tmp);
-
 }
 
 static void auth_unix_gid(FILE *f)
-- 
1.7.11.7

