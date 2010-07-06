Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:41019 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751773Ab0GFRAD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jul 2010 13:00:03 -0400
Received: by iwn7 with SMTP id 7so6856513iwn.19
        for <linux-nfs@vger.kernel.org>; Tue, 06 Jul 2010 10:00:01 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] nfs-utils: Fix C aliasing rules violation in
	nfs_getrpccaller()
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 06 Jul 2010 12:59:58 -0400
Message-ID: <20100706165849.4436.13124.stgit@ellison.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Squelch compiler warnings reported with -Wextra:

In file included from statd.c:24:
../../support/include/rpcmisc.h: In function ‘nfs_getrpccaller_in’:
../../support/include/rpcmisc.h:58: warning: dereferencing type-punned
pointer might break strict-aliasing rules
../../support/include/rpcmisc.h: In function ‘nfs_getrpccaller’:
../../support/include/rpcmisc.h:63: warning: dereferencing type-punned
pointer might break strict-aliasing rules

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
Steve-

This minor clean-up patch has been floating around in my repo for a
while.  Please consider applying it for the next release of nfs-utils.


 support/include/rpcmisc.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/support/include/rpcmisc.h b/support/include/rpcmisc.h
index 1b8f411..c5847fa 100644
--- a/support/include/rpcmisc.h
+++ b/support/include/rpcmisc.h
@@ -60,12 +60,12 @@ extern int	_rpcsvcdirty;
 
 static inline struct sockaddr_in *nfs_getrpccaller_in(SVCXPRT *xprt)
 {
-	return (struct sockaddr_in *)svc_getcaller(xprt);
+	return (struct sockaddr_in *)(char *)svc_getcaller(xprt);
 }
 
 static inline struct sockaddr *nfs_getrpccaller(SVCXPRT *xprt)
 {
-	return (struct sockaddr *)svc_getcaller(xprt);
+	return (struct sockaddr *)(char *)svc_getcaller(xprt);
 }
 
 #endif /* RPCMISC_H */

