Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:55387 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758263Ab0HDGuq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Aug 2010 02:50:46 -0400
From: Neil Brown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>, Steve Dickson <steved@redhat.com>
Date: Wed, 04 Aug 2010 16:49:45 +1000
Subject: [PATCH 1/3] Make buffers large enough for IPv6 addresses
Cc: linux-nfs@vger.kernel.org
Message-ID: <20100804064945.16641.40216.stgit@localhost.localdomain>
In-Reply-To: <20100804064553.16641.92857.stgit@localhost.localdomain>
References: <20100804064553.16641.92857.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Each of these buffers is use to hold the presentation format for an
address which could be either IPv4 or IPv6, so make the buffers large
enough for either.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 support/export/hostname.c |    2 +-
 utils/mountd/cache.c      |    6 +++---
 utils/mountd/rmtab.c      |    2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/support/export/hostname.c b/support/export/hostname.c
index 232e040..f6a59f1 100644
--- a/support/export/hostname.c
+++ b/support/export/hostname.c
@@ -299,7 +299,7 @@ struct addrinfo *
 host_numeric_addrinfo(const struct sockaddr *sap)
 {
 	socklen_t salen = sockaddr_size(sap);
-	char buf[INET_ADDRSTRLEN];
+	char buf[INET6_ADDRSTRLEN];
 	struct addrinfo *ai;
 	int error;
 
diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index bf18a9a..736668e 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -75,7 +75,7 @@ void auth_unix_ip(FILE *f)
 	 */
 	char *cp;
 	char class[20];
-	char ipaddr[20];
+	char ipaddr[INET6_ADDRSTRLEN];
 	char *client = NULL;
 	struct addrinfo *tmp = NULL;
 	struct addrinfo *ai = NULL;
@@ -90,7 +90,7 @@ void auth_unix_ip(FILE *f)
 	    strcmp(class, "nfsd") != 0)
 		return;
 
-	if (qword_get(&cp, ipaddr, 20) <= 0)
+	if (qword_get(&cp, ipaddr, sizeof(ipaddr)) <= 0)
 		return;
 
 	tmp = host_pton(ipaddr);
@@ -920,7 +920,7 @@ int cache_export_ent(char *domain, struct exportent *exp, char *path)
 
 int cache_export(nfs_export *exp, char *path)
 {
-	char buf[INET_ADDRSTRLEN];
+	char buf[INET6_ADDRSTRLEN];
 	int err;
 	FILE *f;
 
diff --git a/utils/mountd/rmtab.c b/utils/mountd/rmtab.c
index ba0fcf6..d86b0db 100644
--- a/utils/mountd/rmtab.c
+++ b/utils/mountd/rmtab.c
@@ -143,7 +143,7 @@ mountlist_del_all(struct sockaddr_in *sin)
 		return;
 	hostname = host_canonname((struct sockaddr *)sin);
 	if (hostname == NULL) {
-		char buf[INET_ADDRSTRLEN];
+		char buf[INET6_ADDRSTRLEN];
 		xlog(L_ERROR, "can't get hostname of %s",
 			host_ntop((struct sockaddr *)sin, buf, sizeof(buf)));
 		goto out_unlock;


