From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Oops on flock on NFS3 krb5 mount
Date: Sat, 29 Jan 2005 12:03:59 -0800
Message-ID: <1107029039.11814.32.camel@lade.trondhjem.org>
References: <41F9FB44.9060002@csua.berkeley.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-5ibCS7HWeLKPLoj2eQ4r"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CuypN-0004x6-5c
	for nfs@lists.sourceforge.net; Sat, 29 Jan 2005 12:04:17 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CuypL-0006L1-Uy
	for nfs@lists.sourceforge.net; Sat, 29 Jan 2005 12:04:16 -0800
To: Mark Goodman <mgoodman@CSUA.Berkeley.EDU>
In-Reply-To: <41F9FB44.9060002@csua.berkeley.edu>
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


--=-5ibCS7HWeLKPLoj2eQ4r
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Mark,

Does the following patch help? AFAIK, we should not be using RPCSEC_GSS
against NLM servers if we want to be able to interoperate with other
implementations.

I've been told that Solaris will, for instance, only use AUTH_SYS for
locking.

Cheers,
  Trond  

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>

--=-5ibCS7HWeLKPLoj2eQ4r
Content-Disposition: inline; filename=linux-2.6.11-12-fixup_nlm_auth.dif
Content-Type: text/plain; name=linux-2.6.11-12-fixup_nlm_auth.dif; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

 clntproc.c |    7 +------
 host.c     |    3 ++-
 2 files changed, 3 insertions(+), 7 deletions(-)

Index: linux-2.6.11-rc2/fs/lockd/host.c
===================================================================
--- linux-2.6.11-rc2.orig/fs/lockd/host.c
+++ linux-2.6.11-rc2/fs/lockd/host.c
@@ -191,8 +191,9 @@ nlm_bind_host(struct nlm_host *host)
 
 		xprt_set_timeout(&xprt->timeout, 5, nlmsvc_timeout);
 
+		/* Existing NLM servers accept AUTH_UNIX only */
 		clnt = rpc_create_client(xprt, host->h_name, &nlm_program,
-					host->h_version, host->h_authflavor);
+					host->h_version, RPC_AUTH_UNIX);
 		if (IS_ERR(clnt)) {
 			xprt_destroy(xprt);
 			goto forgetit;
Index: linux-2.6.11-rc2/fs/lockd/clntproc.c
===================================================================
--- linux-2.6.11-rc2.orig/fs/lockd/clntproc.c
+++ linux-2.6.11-rc2/fs/lockd/clntproc.c
@@ -339,9 +339,6 @@ nlmclnt_call(struct nlm_rqst *req, u32 p
 	dprintk("lockd: call procedure %d on %s\n",
 			(int)proc, host->h_name);
 
-	if (filp)
-		msg.rpc_cred = nfs_file_cred(filp);
-
 	do {
 		if (host->h_reclaiming && !argp->reclaim)
 			goto in_grace_period;
@@ -450,11 +447,9 @@ nlmclnt_async_call(struct nlm_rqst *req,
 		return -ENOLCK;
 	msg.rpc_proc = &clnt->cl_procinfo[proc];
 
-        /* bootstrap and kick off the async RPC call */
-	if (file)
-		msg.rpc_cred = nfs_file_cred(file);
 	/* Increment host refcount */
 	nlm_get_host(host);
+        /* bootstrap and kick off the async RPC call */
         status = rpc_call_async(clnt, &msg, RPC_TASK_ASYNC, callback, req);
 	if (status < 0)
 		nlm_release_host(host);

--=-5ibCS7HWeLKPLoj2eQ4r--



-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
