Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:56671 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754098Ab0KWRUd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Nov 2010 12:20:33 -0500
Received: by iwn33 with SMTP id 33so334010iwn.19
        for <linux-nfs@vger.kernel.org>; Tue, 23 Nov 2010 09:20:32 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NSM: Make use of AI_NUMERICSERV conditional
To: gzp@papp.h
Cc: linux-nfs@vger.kernel.org
Date: Tue, 23 Nov 2010 12:20:28 -0500
Message-ID: <20101123171816.28603.10491.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Gabor Papp reports nfs-utils-1.2.3 doesn't build on his system that
uses glibc-2.2.5:

make[3]: Entering directory
`/home/gzp/src/nfs-utils-1.2.3/utils/statd'
gcc -DHAVE_CONFIG_H -I. -I../../support/include   -D_GNU_SOURCE -Wall
-Wextra -Wstrict-prototypes  -pipe -g -O2 -MT sm-notify.o -MD -MP -MF .deps/sm-notify.Tpo -c -o sm-notify.o sm-notify.c sm-notify.c: In function 'smn_bind_address':
sm-notify.c:247: error: 'AI_NUMERICSERV' undeclared (first use in this function)
sm-notify.c:247: error: (Each undeclared identifier is reported only once
sm-notify.c:247: error: for each function it appears in.)
make[3]: *** [sm-notify.o] Error 1

According to the getaddrinfo(3) man page, AI_NUMERICSERV is available
only since glibc 2.3.4.

Additionally, there are uses of AI_NUMERICSERV in gssd and in
nfs_svc_create().  The one in nfs_svc_create() is behind
HAVE_LIBTIRPC, and the other is a problem only for those who want to
deploy Kerberos -- likely they have a more modern glibc.  So I'm going
to leave those two.

Reported-by: "Gabor Z. Papp" <gzp@papp.hu>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index b7f4371..1f490b0 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -34,6 +34,11 @@
 #include "nsm.h"
 #include "nfsrpc.h"
 
+/* glibc before 2.3.4 */
+#ifndef AI_NUMERICSERV
+#define AI_NUMERICSERV	0
+#endif
+
 #define NSM_TIMEOUT	2
 #define NSM_MAX_TIMEOUT	120	/* don't make this too big */
 
@@ -248,6 +253,7 @@ smn_bind_address(const char *srcaddr, const char *srcport)
 	if (srcaddr == NULL)
 		hint.ai_flags |= AI_PASSIVE;
 
+	/* Do not allow "node" and "service" parameters both to be NULL */
 	if (srcport == NULL)
 		error = getaddrinfo(srcaddr, "", &hint, &ai);
 	else

