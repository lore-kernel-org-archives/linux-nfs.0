Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 178.141.211.66.inaddr.G4.NET ([66.211.141.178]:59299 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751242Ab1GZNCE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jul 2011 09:02:04 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc Devel List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] Autofs configure fails to detect IPv6 when libtirpc is enabled
Date: Tue, 26 Jul 2011 08:29:06 -0400
Message-Id: <1311683346-16881-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Ian Kent <raven@themaw.net>

The IPv6 client functions clntudp6_bufcreate(), clntudp6_create and
clnttcp6_create and the server functions svcudp6_bufcreate(),
svctcp6_create() and svcudp6_create() are not included in the library
whe libtirpc is built.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/rpc_soc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/src/rpc_soc.c b/src/rpc_soc.c
index c678429..584ac71 100644
--- a/src/rpc_soc.c
+++ b/src/rpc_soc.c
@@ -236,7 +236,7 @@ clnttcp_create(raddr, prog, vers, sockp, sendsz, recvsz)
 
 /* IPv6 version of clnt*_*create */
 
-#ifdef INET6_NOT_USED
+#ifdef INET6
 
 CLIENT *
 clntudp6_bufcreate(raddr, prog, vers, wait, sockp, sendsz, recvsz)
@@ -392,7 +392,7 @@ svcraw_create()
 
 
 /* IPV6 version */
-#ifdef INET6_NOT_USED
+#ifdef INET6
 SVCXPRT *
 svcudp6_bufcreate(fd, sendsz, recvsz)
 	int fd;
-- 
1.7.6

