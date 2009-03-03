From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 16/17] lockd: Start PF_INET6 listener only if IPv6 support is
	available
Date: Tue, 03 Mar 2009 17:34:10 -0500
Message-ID: <20090303223410.2933.90223.stgit@ingres.1015granger.net>
References: <20090303220539.2933.15015.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com, bfields@fieldses.org, steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:54166 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753664AbZCCWfD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 17:35:03 -0500
In-Reply-To: <20090303220539.2933.15015.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Apparently a lot of people need to disable IPv6 completely on their
distributor-built systems, which have CONFIG_IPV6_MODULE enabled.

They do this by blacklisting the ipv6.ko module.  This causes the
creation of the lockd service listener to fail if CONFIG_IPV6_MODULE
is set, but the module cannot be loaded.

Now that the kernel's PF_INET6 RPC listeners are completely separate
from PF_INET listeners, we can always start PF_INET.  Then lockd can
try to start PF_INET6, but it isn't required to be available.

Note this has the added benefit that NLM callbacks from AF_INET6
servers will never come from AF_INET remotes.  We no longer have to
worry about matching mapped IPv4 addresses to AF_INET when comparing
addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/svc.c |   28 ++++++++++++++++++++--------
 1 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 566932b..4342b41 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -194,19 +194,29 @@ lockd(void *vrqstp)
 }
 
 static int create_lockd_listener(struct svc_serv *serv, char *name,
-				 unsigned short port)
+				 const int family, const unsigned short port)
 {
 	struct svc_xprt *xprt;
 
-	xprt = svc_find_xprt(serv, name, 0, 0);
+	xprt = svc_find_xprt(serv, name, family, 0);
 	if (xprt == NULL)
-		return svc_create_xprt(serv, name, PF_INET,
-					port, SVC_SOCK_DEFAULTS);
-
+		return svc_create_xprt(serv, name, family, port,
+						SVC_SOCK_DEFAULTS);
 	svc_xprt_put(xprt);
 	return 0;
 }
 
+static int create_lockd_family(struct svc_serv *serv, const int family)
+{
+	int err;
+
+	err = create_lockd_listener(serv, "udp", family, nlm_udpport);
+	if (err < 0)
+		return err;
+
+	return create_lockd_listener(serv, "tcp", family, nlm_tcpport);
+}
+
 /*
  * Ensure there are active UDP and TCP listeners for lockd.
  *
@@ -222,13 +232,15 @@ static int make_socks(struct svc_serv *serv)
 	static int warned;
 	int err;
 
-	err = create_lockd_listener(serv, "udp", nlm_udpport);
+	err = create_lockd_family(serv, PF_INET);
 	if (err < 0)
 		goto out_err;
 
-	err = create_lockd_listener(serv, "tcp", nlm_tcpport);
-	if (err < 0)
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	err = create_lockd_family(serv, PF_INET6);
+	if (err < 0 && err != -EAFNOSUPPORT)
 		goto out_err;
+#endif	/* CONFIG_IPV6 || CONFIG_IPV6_MODULE */
 
 	warned = 0;
 	return 0;

