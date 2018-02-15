Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:41171 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1033275AbeBOUW0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Feb 2018 15:22:26 -0500
Received: by mail-io0-f193.google.com with SMTP id e4so1969173iob.8
        for <linux-nfs@vger.kernel.org>; Thu, 15 Feb 2018 12:22:26 -0800 (PST)
Subject: [PATCH RFC 3/3] Avoid choosing reserved ports in clnt_tli_create(3)
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org, libtirpc-devel@lists.sourceforge.net
Date: Thu, 15 Feb 2018 15:22:25 -0500
Message-ID: <20180215202225.16924.80494.stgit@klimt.1015granger.net>
In-Reply-To: <20180215201832.16924.28659.stgit@klimt.1015granger.net>
References: <20180215201832.16924.28659.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Callers of clnt_tli_create(3) can specify that an arbitrary port
number be dynamically assigned for the client socket being
created. clnt_tli_create(3) tries bindresvport(3) first in this
case. bindresvport(3) chooses a reserved port if the caller has
CAP_NET_ADMIN_BIND privilege. If this fails, bind(2) is used to
assign a port number from the range above 1024.

This approach becomes a problem whenever bindresvport(3) happens to
choose the port number of a well-known service. If the caller is a
long-running service (like rpc.statd), it indefinitely prevents the
IANA-assigned well-known service from starting.

When using the AUTH_SYS authentication flavor, RPC services can use
the remote client's port number to determine whether the client is
privileged, and thus the UID and GID numbers in the RPC are
trustworthy. However, it's pretty easy for a man-in-the-middle to
replace these while the RPC is in flight anyway. The port number
provides no actual security.

Therefore, remove the bindresvport step to prevent svc_tli_create(3)
from choosing a port number that interferes with well-known services
assigned to a privileged port.

clnt_tli_create(3) will now never assign a privileged port
dynamically. If needed, a caller may still bind to a dynamically-
assigned reserved port by invoking bindresvport(3) directly and
passing the already-bound file descriptor to clnt_tli_create(3).

But that should be a special case. It is no longer the default
behavior.

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

