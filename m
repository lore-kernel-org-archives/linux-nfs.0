From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 2 of 23] Check the callback netid in gen_callback.
Date: Fri, 17 Dec 2004 16:23:55 +1100
Message-ID: <E1CfAap-0002dU-8W@notabene.cse.unsw.edu.au>
References: <20041217162128.9968.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CfAbL-00059N-PM
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:24:27 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CfAbI-00066Q-6F
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:24:27 -0800
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


since we only support tcp, don't save the netinfo.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c        |   21 ++++++++++++++-------
 ./include/linux/nfsd/state.h |    1 -
 2 files changed, 14 insertions(+), 8 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-12-15 11:44:49.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2004-12-15 11:46:29.000000000 +1100
@@ -420,17 +420,24 @@ gen_callback(struct nfs4_client *clp, st
 {
 	struct nfs4_callback *cb = &clp->cl_callback;
 
+	/* Currently, we only support tcp for the callback channel */
+	if ((se->se_callback_netid_len != 3) || memcmp((char *)se->se_callback_netid_val, "tcp", 3))
+		goto out_err;
+
 	if ( !(parse_ipv4(se->se_callback_addr_len, se->se_callback_addr_val,
-		         &cb->cb_addr, &cb->cb_port))) {
-		printk(KERN_INFO "NFSD: BAD callback address. client will not receive delegations\n");
-		cb->cb_parsed = 0;
-		return;
-	}
-	cb->cb_netid.len = se->se_callback_netid_len;
-	cb->cb_netid.data = se->se_callback_netid_val;
+	                 &cb->cb_addr, &cb->cb_port)))
+		goto out_err;
 	cb->cb_prog = se->se_callback_prog;
 	cb->cb_ident = se->se_callback_ident;
 	cb->cb_parsed = 1;
+	return;
+out_err:
+	printk(KERN_INFO "NFSD: this client (clientid %08x/%08x) "
+		"will not receive delegations\n",
+		clp->cl_clientid.cl_boot, clp->cl_clientid.cl_id);
+
+	cb->cb_parsed = 0;
+	return;
 }
 
 /*

diff ./include/linux/nfsd/state.h~current~ ./include/linux/nfsd/state.h
--- ./include/linux/nfsd/state.h~current~	2004-12-15 11:44:49.000000000 +1100
+++ ./include/linux/nfsd/state.h	2004-12-15 11:46:29.000000000 +1100
@@ -75,7 +75,6 @@ struct nfs4_callback {
 	unsigned short          cb_port;
 	u32                     cb_prog;
 	u32                     cb_ident;
-	struct xdr_netobj	cb_netid;
 	/* RPC client info */
 	u32			cb_set;     /* successful CB_NULL call */
 	struct rpc_program      cb_program;


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
