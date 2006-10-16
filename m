From: NeilBrown <neilb@suse.de>
Subject: [PATCH 003 of 5] knfsd: nfsd4: Fix error handling in nfsd's
	callback client
Date: Tue, 17 Oct 2006 09:30:19 +1000
Message-ID: <1061016233019.11342@suse.de>
References: <20061017092702.11224.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GZbud-00016k-RF
	for nfs@lists.sourceforge.net; Mon, 16 Oct 2006 16:30:27 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GZbue-00016e-BD
	for nfs@lists.sourceforge.net; Mon, 16 Oct 2006 16:30:28 -0700
To: Andrew Morton <akpm@osdl.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


From: "J. Bruce Fields" <bfields@fieldses.org>
Coverity noticed that the error handling code in the NFSv4 callback client
sets cb->cb_client to NULL, then calls rpc_shutdown_client with the NULL
pointer.

Coverity: #cid 1397

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4callback.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff .prev/fs/nfsd/nfs4callback.c ./fs/nfsd/nfs4callback.c
--- .prev/fs/nfsd/nfs4callback.c	2006-10-17 09:05:30.000000000 +1000
+++ ./fs/nfsd/nfs4callback.c	2006-10-17 09:05:30.000000000 +1000
@@ -421,7 +421,7 @@ nfsd4_probe_callback(struct nfs4_client 
 
 	/* Create RPC client */
 	cb->cb_client = rpc_create(&args);
-	if (!cb->cb_client) {
+	if (IS_ERR(cb->cb_client)) {
 		dprintk("NFSD: couldn't create callback client\n");
 		goto out_err;
 	}
@@ -448,10 +448,10 @@ nfsd4_probe_callback(struct nfs4_client 
 out_rpciod:
 	atomic_dec(&clp->cl_count);
 	rpciod_down();
-	cb->cb_client = NULL;
 out_clnt:
 	rpc_shutdown_client(cb->cb_client);
 out_err:
+	cb->cb_client = NULL;
 	dprintk("NFSD: warning: no callback path to client %.*s\n",
 		(int)clp->cl_name.len, clp->cl_name.data);
 }

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
