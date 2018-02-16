Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:39179 "EHLO
        mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758803AbeBPREB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Feb 2018 12:04:01 -0500
Received: by mail-it0-f54.google.com with SMTP id l187so2579423ith.4
        for <linux-nfs@vger.kernel.org>; Fri, 16 Feb 2018 09:04:01 -0800 (PST)
Subject: [PATCH v2 2/4] Avoid choosing reserved ports in svc_tli_create(3)
From: Chuck Lever <chuck.lever@oracle.com>
To: steve.dickson@redhat.com
Cc: linux-nfs@vger.kernel.org, libtirpc-devel@lists.sourceforge.net
Date: Fri, 16 Feb 2018 12:03:59 -0500
Message-ID: <20180216170359.9986.21607.stgit@klimt.1015granger.net>
In-Reply-To: <20180216164846.9986.58128.stgit@klimt.1015granger.net>
References: <20180216164846.9986.58128.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Callers of svc_tli_create(3) can specify that an arbitrary port
number be dynamically assigned for the service listener being
created. svc_tli_create(3) tries bindresvport(3) first in this
case. bindresvport(3) chooses a reserved port if the caller has
CAP_NET_ADMIN_BIND privilege. If this fails, bind(2) is used to
assign a port number from the range above 1024.

This approach becomes a problem should bindresvport(3) or bind(2)
happen to choose the port number of a well-known service. If the
caller is a long-running service (like rpc.statd), the caller's
listener indefinitely blocks the IANA-assigned well-known service
for that port from starting.

Moreover, it seems that a reserved port is completely unnecessary
for listener sockets. It does not confer any extra privilege or
functionality to the listener socket, nor do remote clients infer
any extra privilege from a listener on a port number lower than
1024.

Therefore, remove the bindresvport step, and instead of invoking
bind(2) directly, use a mechanism which allocates the port number
from the dynamic port range described in RFC 6335 Section 6.

This also impacts all users of svc_tli_create(3) within the library,
such as svc_tp_create(3).

BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=320
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 src/svc_generic.c |   12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/src/svc_generic.c b/src/svc_generic.c
index 7aae796..52a56c2 100644
--- a/src/svc_generic.c
+++ b/src/svc_generic.c
@@ -53,6 +53,7 @@
 #include <rpc/svc.h>
 
 extern int __svc_vc_setflag(SVCXPRT *, int);
+extern int __binddynport(int fd);
 
 /*
  * The highest level interface for server creation.
@@ -220,15 +221,10 @@ svc_tli_create(fd, nconf, bindaddr, sendsz, recvsz)
 	 */
 	if (madefd || !__rpc_sockisbound(fd)) {
 		if (bindaddr == NULL) {
-			if (bindresvport(fd, NULL) < 0) {
-				memset(&ss, 0, sizeof ss);
-				ss.ss_family = si.si_af;
-				if (bind(fd, (struct sockaddr *)(void *)&ss,
-				    (socklen_t)si.si_alen) < 0) {
-					warnx(
+			if (__binddynport(fd) == -1) {
+				warnx(
 			"svc_tli_create: could not bind to anonymous port");
-					goto freedata;
-				}
+				goto freedata;
 			}
 			listen(fd, SOMAXCONN);
 		} else {

