From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH kNFSd 32 of 54] nfsd4: fix callback cred refcnt leak
Date: Tue, 8 Mar 2005 18:44:57 -0500
Message-ID: <20050308234457.GG26462@fieldses.org>
References: <20050308165419.3842.patches@notabene> <E1D8Xrg-00018r-Db@notabene.cse.unsw.edu.au> <1110262615.11712.20.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NeilBrown <neilb@cse.unsw.edu.au>, Andrew Morton <akpm@osdl.org>,
	nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8oNX-0002oS-5s
	for nfs@lists.sourceforge.net; Tue, 08 Mar 2005 15:44:43 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D8oNV-00009C-Lt
	for nfs@lists.sourceforge.net; Tue, 08 Mar 2005 15:44:43 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1110262615.11712.20.camel@lade.trondhjem.org>
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

On Tue, Mar 08, 2005 at 01:16:55AM -0500, Trond Myklebust wrote:
> ty den 08.03.2005 Klokka 17:06 (+1100) skreiv NeilBrown:
> > 
> > The rpc creds we look up in the callback code need puts.
> > 
> 
> <cough> Error checking on the results of nfsd4_lookupcred()? </cough>

Yeah, sorry for the confusion here.  My fault, but partly also a result
of there being another patch in Trond's NFS_ALL that changes
rpcauth_lookup_credcache() to return error codes instead of just NULL on
failure.  Depending on which patches get in first, there'll be some
trivial fixup to do.

Removing the spurious (!clnt) check, as in the following, will also simplify
that conflict resolution a bit.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---

 linux-2.6.11-mm2-bfields/fs/nfsd/nfs4callback.c |   17 ++++++++---------
 1 files changed, 8 insertions(+), 9 deletions(-)

diff -puN fs/nfsd/nfs4callback.c~nfsd4-fix-callback-cred-lookup fs/nfsd/nfs4callback.c
--- linux-2.6.11-mm2/fs/nfsd/nfs4callback.c~nfsd4-fix-callback-cred-lookup	2005-03-08 16:22:10.000000000 -0500
+++ linux-2.6.11-mm2-bfields/fs/nfsd/nfs4callback.c	2005-03-08 17:15:37.000000000 -0500
@@ -353,10 +353,8 @@ nfsd4_lookupcred(struct nfs4_client *clp
 {
         struct auth_cred acred;
 	struct rpc_clnt *clnt = clp->cl_callback.cb_client;
-        struct rpc_cred *ret = NULL;
+	struct rpc_cred *ret;
 
-	if (!clnt)
-		goto out;
         get_group_info(clp->cl_cred.cr_group_info);
         acred.uid = clp->cl_cred.cr_uid;
         acred.gid = clp->cl_cred.cr_gid;
@@ -366,7 +364,6 @@ nfsd4_lookupcred(struct nfs4_client *clp
                 clnt->cl_auth->au_ops->au_name);
         ret = rpcauth_lookup_credcache(clnt->cl_auth, &acred, taskflags);
         put_group_info(clp->cl_cred.cr_group_info);
-out:
         return ret;
 }
 
@@ -449,6 +446,8 @@ nfsd4_probe_callback(struct nfs4_client 
 	atomic_inc(&clp->cl_count);
 
 	msg.rpc_cred = nfsd4_lookupcred(clp,0);
+	if (msg.rpc_cred == NULL)
+		goto out_rpciod;
 	status = rpc_call_async(clnt, &msg, RPC_TASK_ASYNC, nfs4_cb_null, NULL);
 	put_rpccred(msg.rpc_cred);
 
@@ -513,7 +512,7 @@ nfsd4_cb_recall(struct nfs4_delegation *
 		return;
 
 	msg.rpc_cred = nfsd4_lookupcred(clp, 0);
-	if (IS_ERR(msg.rpc_cred))
+	if (msg.rpc_cred == NULL)
 		goto out;
 
 	cbr->cbr_trunc = 0; /* XXX need to implement truncate optimization */
@@ -530,19 +529,19 @@ nfsd4_cb_recall(struct nfs4_delegation *
 				 * before open reply granting delegation */
 				break;
 			default:
-				goto out;
+				goto out_put_cred;
 		}
 		ssleep(2);
 		status = rpc_call_sync(clnt, &msg, RPC_TASK_SOFT);
 	}
-
- out:
+out_put_cred:
+	put_rpccred(msg.rpc_cred);
+out:
 	if (status == -EIO)
 		atomic_set(&clp->cl_callback.cb_set, 0);
 	/* Success or failure, now we're either waiting for lease expiration
 	 * or deleg_return. */
 	nfs4_put_delegation(dp);
 	dprintk("NFSD: nfs4_cb_recall: dp %p dl_flock %p dl_count %d\n",dp, dp->dl_flock, atomic_read(&dp->dl_count));
-	put_rpccred(msg.rpc_cred);
 	return;
 }
_


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
