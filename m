Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:58013 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936061Ab3DIPzB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Apr 2013 11:55:01 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r39Ft0Sf007915
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 9 Apr 2013 11:55:01 -0400
Received: from caprica.fab.redhat.com (wlan-5-126.fab.redhat.com [10.33.5.126])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r39Ft0no004759
	for <linux-nfs@vger.kernel.org>; Tue, 9 Apr 2013 11:55:00 -0400
From: Jose Castillo <jcastillo@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] Add the missing '$' in auth_unix_ip()
Date: Tue,  9 Apr 2013 16:54:59 +0100
Message-Id: <1365522899-29123-1-git-send-email-jcastillo@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jose Castillo <jcastillo@redhat.com>
---
 utils/mountd/cache.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 978698d..e1027f3 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -80,7 +80,7 @@ static void auth_unix_ip(FILE *f)
 	 */
 	char *cp;
 	char class[20];
-	char ipaddr[INET6_ADDRSTRLEN];
+	char ipaddr[INET6_ADDRSTRLEN + 1];
 	char *client = NULL;
 	struct addrinfo *tmp = NULL;
 	if (readline(fileno(f), &lbuf, &lbuflen) != 1)
@@ -94,7 +94,7 @@ static void auth_unix_ip(FILE *f)
 	    strcmp(class, "nfsd") != 0)
 		return;
 
-	if (qword_get(&cp, ipaddr, sizeof(ipaddr)) <= 0)
+	if (qword_get(&cp, ipaddr, sizeof(ipaddr) - 1) <= 0)
 		return;
 
 	tmp = host_pton(ipaddr);
@@ -116,9 +116,11 @@ static void auth_unix_ip(FILE *f)
 	qword_print(f, "nfsd");
 	qword_print(f, ipaddr);
 	qword_printtimefrom(f, DEFAULT_TTL);
-	if (use_ipaddr)
+	if (use_ipaddr) {
+		memmove(ipaddr + 1, ipaddr, strlen(ipaddr) + 1);
+		ipaddr[0] = '$';
 		qword_print(f, ipaddr);
-	else if (client)
+	} else if (client)
 		qword_print(f, *client?client:"DEFAULT");
 	qword_eol(f);
 	xlog(D_CALL, "auth_unix_ip: client %p '%s'", client, client?client: "DEFAULT");
-- 
1.7.11.7

