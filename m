From: NeilBrown <neilb@suse.de>
Subject: [PATCH 001 of 9] knfsd: nfsd4: fix non-terminated string
Date: Tue, 13 Feb 2007 10:44:02 +1100
Message-ID: <1070212234402.29224@suse.de>
References: <20070213103941.28958.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HGkqi-0005WA-BV
	for nfs@lists.sourceforge.net; Mon, 12 Feb 2007 15:44:44 -0800
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HGkqi-00025x-UD
	for nfs@lists.sourceforge.net; Mon, 12 Feb 2007 15:44:46 -0800
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


From: J. Bruce Fields <bfields@citi.umich.edu>
The server name is expected to be a null-terminated string, so we can't
pass in the raw client identifier.

What's more, the client identifier is just a binary, not necessarily
printable, blob.  Let's just use the ip address instead.  The server
name appears to exist just to help debugging by making some printk's
more informative.

Note that the string is copies into the rpc client structure, so
the pointer to the local variable does not outlive the function call.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4callback.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff .prev/fs/nfsd/nfs4callback.c ./fs/nfsd/nfs4callback.c
--- .prev/fs/nfsd/nfs4callback.c	2007-02-13 09:50:26.000000000 +1100
+++ ./fs/nfsd/nfs4callback.c	2007-02-13 10:00:59.000000000 +1100
@@ -387,7 +387,6 @@ nfsd4_probe_callback(struct nfs4_client 
 		.address	= (struct sockaddr *)&addr,
 		.addrsize	= sizeof(addr),
 		.timeout	= &timeparms,
-		.servername	= clp->cl_name.data,
 		.program	= program,
 		.version	= nfs_cb_version[1]->number,
 		.authflavor	= RPC_AUTH_UNIX,	/* XXX: need AUTH_GSS... */
@@ -397,6 +396,7 @@ nfsd4_probe_callback(struct nfs4_client 
 		.rpc_proc       = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_NULL],
 		.rpc_argp       = clp,
 	};
+	char clientname[16];
 	int status;
 
 	if (atomic_read(&cb->cb_set))
@@ -419,6 +419,11 @@ nfsd4_probe_callback(struct nfs4_client 
 	memset(program->stats, 0, sizeof(cb->cb_stat));
 	program->stats->program = program;
 
+	/* Just here to make some printk's more useful: */
+	snprintf(clientname, sizeof(clientname),
+		"%u.%u.%u.%u", NIPQUAD(addr.sin_addr));
+	args.servername = clientname;
+
 	/* Create RPC client */
 	cb->cb_client = rpc_create(&args);
 	if (IS_ERR(cb->cb_client)) {

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
