Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f48.google.com ([209.85.214.48]:52687 "EHLO
        mail-it0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751558AbeBYSRl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 25 Feb 2018 13:17:41 -0500
Received: by mail-it0-f48.google.com with SMTP id k135so3312739ite.2
        for <linux-nfs@vger.kernel.org>; Sun, 25 Feb 2018 10:17:41 -0800 (PST)
Subject: [PATCH v3 3/4] Avoid choosing reserved ports in clnt_tli_create(3)
From: Chuck Lever <chuck.lever@oracle.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, libtirpc-devel@lists.sourceforge.net
Date: Sun, 25 Feb 2018 13:17:39 -0500
Message-ID: <20180225181739.2983.93606.stgit@klimt.1015granger.net>
In-Reply-To: <20180225180530.2983.82980.stgit@klimt.1015granger.net>
References: <20180225180530.2983.82980.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Callers of clnt_tli_create(3) can specify that an arbitrary port
number be dynamically assigned for the client socket being created.
clnt_tli_create(3) tries bindresvport(3) first in this case.
bindresvport(3) chooses a reserved port if the caller has
CAP_NET_ADMIN_BIND privilege. If this fails, bind(2) is used to
assign a port number from the range above 1024.

This approach becomes a problem should bindresvport(3) or bind(2)
happen to choose the port number of a well-known service. If the
caller is a long-running service (like rpc.statd), it indefinitely
blocks the IANA-assigned well-known service for that port from
starting.

When using the AUTH_SYS authentication flavor, RPC services can use
the remote client's source port number to determine whether the
client is privileged, and thus the UID and GID numbers in the RPC
are trustworthy. However, it's pretty easy for a man-in-the-middle
to replace these values while the RPC is in flight. The source port
number is no guarantee of actual security.

Therefore, remove the bindresvport step, and instead of invoking
bind(2) directly, use a mechanism which allocates the port number
from the dynamic port range described in RFC 6335 Section 6.

This also impacts all users of clnt_tli_create(3) within the
library, such as clnt_tp_create(3), and the portmap/rpcbind clients.

BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=320
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 src/clnt_generic.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/src/clnt_generic.c b/src/clnt_generic.c
index 3f3dabf..e5a314f 100644
--- a/src/clnt_generic.c
+++ b/src/clnt_generic.c
@@ -47,6 +47,7 @@
 
 extern bool_t __rpc_is_local_host(const char *);
 int __rpc_raise_fd(int);
+extern int __binddynport(int fd);
 
 #ifndef NETIDLEN
 #define	NETIDLEN 32
@@ -340,7 +341,8 @@ clnt_tli_create(int fd, const struct netconfig *nconf,
 		servtype = nconf->nc_semantics;
 		if (!__rpc_fd2sockinfo(fd, &si))
 			goto err;
-		bindresvport(fd, NULL);
+		if (__binddynport(fd) == -1)
+			goto err;
 	} else {
 		if (!__rpc_fd2sockinfo(fd, &si))
 			goto err;

