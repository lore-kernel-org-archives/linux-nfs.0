From: Olaf Kirch <okir@suse.de>
Subject: [PATCH] Auto-load RPC authentication kernel modules (client-side)
Date: Tue, 31 Jan 2006 11:13:37 +0100
Message-ID: <20060131101337.GF1462@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F3sW6-0007CY-MP
	for nfs@lists.sourceforge.net; Tue, 31 Jan 2006 02:13:42 -0800
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1F3sW5-0000ET-7y
	for nfs@lists.sourceforge.net; Tue, 31 Jan 2006 02:13:42 -0800
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 9409E1BEA3
	for <nfs@lists.sourceforge.net>; Tue, 31 Jan 2006 11:13:37 +0100 (CET)
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Summary: Auto-load RPC authentication kernel modules (client-side)

This patch adds a request_module call to rpcauth_create which will try
to auto-load the kernel module for the requested authentication flavor.
For kernels with modular sunrpc, this reduces the admin overhead for
the user.

Signed-off-by: Olaf Kirch <okir@suse.de>

 net/sunrpc/auth.c |   16 ++++++++++++++--
 1 files changed, 14 insertions(+), 2 deletions(-)

Index: build/net/sunrpc/auth.c
===================================================================
--- build.orig/net/sunrpc/auth.c
+++ build/net/sunrpc/auth.c
@@ -64,14 +64,26 @@ rpcauth_create(rpc_authflavor_t pseudofl
 	struct rpc_authops	*ops;
 	u32			flavor = pseudoflavor_to_flavor(pseudoflavor);
 
-	if (flavor >= RPC_AUTH_MAXFLAVOR || !(ops = auth_flavors[flavor]))
-		return ERR_PTR(-EINVAL);
+	auth = ERR_PTR(-EINVAL);
+	if (flavor >= RPC_AUTH_MAXFLAVOR)
+		goto out;
+
+	/* FIXME - auth_flavors[] really needs an rw lock,
+	 * and module refcounting. */
+#ifdef CONFIG_KMOD
+	if ((ops = auth_flavors[flavor]) == NULL)
+		request_module("rpc-auth-%u", flavor);
+#endif
+	if ((ops = auth_flavors[flavor]) == NULL)
+		goto out;
 	auth = ops->create(clnt, pseudoflavor);
 	if (IS_ERR(auth))
 		return auth;
 	if (clnt->cl_auth)
 		rpcauth_destroy(clnt->cl_auth);
 	clnt->cl_auth = auth;
+
+out:
 	return auth;
 }
 
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
