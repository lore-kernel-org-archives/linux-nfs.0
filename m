Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:62961 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753343Ab0IMRWq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Sep 2010 13:22:46 -0400
Received: by mail-yx0-f174.google.com with SMTP id 4so2096756yxp.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Sep 2010 10:22:45 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/12] mountd: Handle IPv6 addresses in kernel auth_unix_ip
	upcalls
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 13 Sep 2010 13:22:42 -0400
Message-ID: <20100913172242.19017.85340.stgit@seurat.1015granger.net>
In-Reply-To: <20100913171844.19017.13446.stgit@seurat.1015granger.net>
References: <20100913171844.19017.13446.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mountd/cache.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index ab873d5..0e8a2f4 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -80,7 +80,7 @@ static void auth_unix_ip(FILE *f)
 	 */
 	char *cp;
 	char class[20];
-	char ipaddr[20];
+	char ipaddr[INET6_ADDRSTRLEN];
 	char *client = NULL;
 	struct addrinfo *tmp = NULL;
 	struct addrinfo *ai = NULL;
@@ -95,7 +95,7 @@ static void auth_unix_ip(FILE *f)
 	    strcmp(class, "nfsd") != 0)
 		return;
 
-	if (qword_get(&cp, ipaddr, 20) <= 0)
+	if (qword_get(&cp, ipaddr, sizeof(ipaddr)) <= 0)
 		return;
 
 	tmp = host_pton(ipaddr);
@@ -953,7 +953,7 @@ int cache_export(nfs_export *exp, char *path)
 
 
 	qword_print(f, "nfsd");
-	qword_print(f, 
+	qword_print(f,
 		host_ntop(get_addrlist(exp->m_client, 0), buf, sizeof(buf)));
 	qword_printint(f, time(0)+30*60);
 	qword_print(f, exp->m_client->m_hostname);

