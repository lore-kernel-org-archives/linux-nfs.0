Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2622 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754237Ab0AYQ7Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Jan 2010 11:59:24 -0500
Received: from int-mx04.intmail.prod.int.phx2.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.17])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o0PGxODT024437
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 25 Jan 2010 11:59:24 -0500
Received: from badhat.bos.devel.redhat.com (vpn-234-7.phx2.redhat.com [10.3.234.7])
	by int-mx04.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o0PGxNnI003458
	for <linux-nfs@vger.kernel.org>; Mon, 25 Jan 2010 11:59:24 -0500
Message-ID: <4B5DCDEB.60708@RedHat.com>
Date: Mon, 25 Jan 2010 11:59:23 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] statd: Teach nfs_compare_sockaddr() to handle NULL arguments.
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

It seems the list of interfaces returned by getifaddrs()
can contain a null address pointer (ifa->ifa_addr) even though 
the interface is marked UP (this happens with the tun0 interface).

So this patch makes nfs_compare_sockaddr() return false
if either one of its arguments is null..

Author: Steve Dickson <steved@redhat.com>
Date:   Mon Jan 25 11:42:36 2010 -0500

    Teach nfs_compare_sockaddr() to handle NULL arguments.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/support/include/sockaddr.h b/support/include/sockaddr.h
index 732514b..9af2543 100644
--- a/support/include/sockaddr.h
+++ b/support/include/sockaddr.h
@@ -20,6 +20,7 @@
 #ifndef NFS_UTILS_SOCKADDR_H
 #define NFS_UTILS_SOCKADDR_H
 
+#include <libio.h>
 #include <stdbool.h>
 #include <sys/socket.h>
 #include <netinet/in.h>
@@ -223,6 +224,9 @@ compare_sockaddr6(__attribute__ ((unused)) const struct sockaddr *sa1,
 static inline _Bool
 nfs_compare_sockaddr(const struct sockaddr *sa1, const struct sockaddr *sa2)
 {
+	if (sa1 == NULL || sa2 == NULL)
+		return false;
+
 	if (sa1->sa_family == sa2->sa_family)
 		switch (sa1->sa_family) {
 		case AF_INET:
