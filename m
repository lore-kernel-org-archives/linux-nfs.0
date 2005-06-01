From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 003 of 28] nfsd4: fix probe_callback
Date: Thu, 02 Jun 2005 08:50:56 +1000
Message-ID: <E1Ddc36-0006hl-1o@notabene.cse.unsw.edu.au>
References: <20050602084410.25538.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ddc3J-0005w0-2a
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:09 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Ddc3G-0002Ov-N2
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:08 -0700
To: Andrew Morton <akpm@osdl.org>
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


rpc_create_client was modified recently to do its own (synchronous) NULL ping
of the server.  We'd rather do that on our own, asynchronously, so that we
don't have to block the nfsd thread doing the probe, and so that setclientid
handling (hence, client mounts) can proceed normally whether the callback is
succesful or not.  (We can still function fine without the callback channel--we
just won't be able to give out delegations till it's verified to work.)

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4callback.c   |    2 +-
 ./net/sunrpc/sunrpc_syms.c |    1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff ./fs/nfsd/nfs4callback.c~current~ ./fs/nfsd/nfs4callback.c
--- ./fs/nfsd/nfs4callback.c~current~	2005-05-31 14:20:58.000000000 +1000
+++ ./fs/nfsd/nfs4callback.c	2005-05-31 14:20:58.000000000 +1000
@@ -427,7 +427,7 @@ nfsd4_probe_callback(struct nfs4_client 
 	 * XXX AUTH_UNIX only - need AUTH_GSS....
 	 */
 	sprintf(hostname, "%u.%u.%u.%u", NIPQUAD(addr.sin_addr.s_addr));
-	clnt = rpc_create_client(xprt, hostname, program, 1, RPC_AUTH_UNIX);
+	clnt = rpc_new_client(xprt, hostname, program, 1, RPC_AUTH_UNIX);
 	if (IS_ERR(clnt)) {
 		dprintk("NFSD: couldn't create callback client\n");
 		goto out_err;

diff ./net/sunrpc/sunrpc_syms.c~current~ ./net/sunrpc/sunrpc_syms.c
--- ./net/sunrpc/sunrpc_syms.c~current~	2005-05-31 14:20:58.000000000 +1000
+++ ./net/sunrpc/sunrpc_syms.c	2005-05-31 14:20:58.000000000 +1000
@@ -41,6 +41,7 @@ EXPORT_SYMBOL(rpc_release_task);
 
 /* RPC client functions */
 EXPORT_SYMBOL(rpc_create_client);
+EXPORT_SYMBOL(rpc_new_client);
 EXPORT_SYMBOL(rpc_clone_client);
 EXPORT_SYMBOL(rpc_bind_new_program);
 EXPORT_SYMBOL(rpc_destroy_client);


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
