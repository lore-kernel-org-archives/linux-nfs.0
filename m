From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 077/112] NFS: Pull covers off IPv6 address parsing
Date: Fri, 25 Jan 2008 11:37:50 -0500
Message-ID: <20080125163750.31887.53110.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14393 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755119AbYAYRAR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:17 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH09UG010371
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:13 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Now that the needed IPv6 infrastructure is in place, allow the NFS client's
IP address parser to generate AF_INET6 addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/super.c |   21 ++++++++++++++++-----
 1 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 7efc6a3..3cbe32f 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -652,12 +652,23 @@ static void nfs_parse_server_address(char *value,
 				     struct sockaddr *sap,
 				     size_t *len)
 {
-	struct sockaddr_in *ap = (void *)sap;
+	if (strchr(value, ':')) {
+		struct sockaddr_in6 *ap = (struct sockaddr_in6 *)sap;
+		u8 *addr = (u8 *)&ap->sin6_addr.in6_u;
 
-	ap->sin_family = AF_INET;
-	*len = sizeof(*ap);
-	if (in4_pton(value, -1, (u8 *)&ap->sin_addr.s_addr, '\0', NULL))
-		return;
+		ap->sin6_family = AF_INET6;
+		*len = sizeof(*ap);
+		if (in6_pton(value, -1, addr, '\0', NULL))
+			return;
+	} else {
+		struct sockaddr_in *ap = (struct sockaddr_in *)sap;
+		u8 *addr = (u8 *)&ap->sin_addr.s_addr;
+
+		ap->sin_family = AF_INET;
+		*len = sizeof(*ap);
+		if (in4_pton(value, -1, addr, '\0', NULL))
+			return;
+	}
 
 	sap->sa_family = AF_UNSPEC;
 	*len = 0;
