Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45509 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754019Ab2EBV4U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 May 2012 17:56:20 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@redhat.com>,
        NeilBrown <neilb@suse.de>, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 5/5] mountd: handle allocation failures in auth_unix_ip upcall
Date: Wed,  2 May 2012 17:56:15 -0400
Message-Id: <1335995775-12009-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1335995775-12009-1-git-send-email-bfields@redhat.com>
References: <1335995775-12009-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 utils/mountd/cache.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 6710eca..8f14032 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -84,7 +84,6 @@ static void auth_unix_ip(FILE *f)
 	char ipaddr[INET6_ADDRSTRLEN];
 	char *client = NULL;
 	struct addrinfo *tmp = NULL;
-	struct addrinfo *ai = NULL;
 	if (readline(fileno(f), &lbuf, &lbuflen) != 1)
 		return;
 
@@ -107,12 +106,16 @@ static void auth_unix_ip(FILE *f)
 
 	/* addr is a valid, interesting address, find the domain name... */
 	if (!use_ipaddr) {
+		struct addrinfo *ai = NULL;
+
 		ai = client_resolve(tmp->ai_addr);
+		if (ai == NULL)
+			goto out;
 		client = client_compose(ai);
 		freeaddrinfo(ai);
+		if (!client)
+			goto out;
 	}
-	freeaddrinfo(tmp);
-
 	qword_print(f, "nfsd");
 	qword_print(f, ipaddr);
 	qword_printuint(f, time(0) + DEFAULT_TTL);
@@ -124,6 +127,9 @@ static void auth_unix_ip(FILE *f)
 	xlog(D_CALL, "auth_unix_ip: client %p '%s'", client, client?client: "DEFAULT");
 
 	free(client);
+out:
+	freeaddrinfo(tmp);
+
 }
 
 static void auth_unix_gid(FILE *f)
-- 
1.7.7.6

