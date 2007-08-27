From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 11/15] knfsd: fix callback rpc cred
Date: Mon, 27 Aug 2007 16:22:52 -0400
Message-ID: <11882461773657-git-send-email-bfields@fieldses.org>
References: <11882461763072-git-send-email-bfields@fieldses.org>
	<1188246176681-git-send-email-bfields@fieldses.org>
	<1188246176897-git-send-email-bfields@fieldses.org>
	<1188246177833-git-send-email-bfields@fieldses.org>
	<11882461773576-git-send-email-bfields@fieldses.org>
	<11882461771774-git-send-email-bfields@fieldses.org>
	<1188246177195-git-send-email-bfields@fieldses.org>
	<11882461773396-git-send-email-bfields@fieldses.org>
	<1188246177259-git-send-email-bfields@fieldses.org>
	<1188246177192-git-send-email-bfields@fieldses.org>
	<11882461773221-git-send-email-bfields@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	"J. Bruce Fields" <bfields@citi.umich.edu>, nfs@lists.sourceforge.net
To: linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IPl77-0004n5-Sn
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 13:23:10 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IPl7B-0003Wf-QK
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 13:23:14 -0700
In-Reply-To: <11882461773221-git-send-email-bfields@fieldses.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: J. Bruce Fields <bfields@fieldses.org>

It doesn't make sense to make the callback with credentials that the
client made the setclientid with.  Instead the spec requires that the
callback occur with the credentials the client authenticated *to*.
It probably doesn't matter what we use for auth_unix, and some more
infrastructure will be needed for auth_gss, so let's just remove the
cred lookup for now.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c |   33 ---------------------------------
 1 files changed, 0 insertions(+), 33 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index c17a520..c1cb7e0 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -344,28 +344,6 @@ static struct rpc_version *	nfs_cb_version[] = {
 	&nfs_cb_version4,
 };
 
-/*
- * Use the SETCLIENTID credential
- */
-static struct rpc_cred *
-nfsd4_lookupcred(struct nfs4_client *clp, int taskflags)
-{
-        struct auth_cred acred;
-	struct rpc_clnt *clnt = clp->cl_callback.cb_client;
-	struct rpc_cred *ret;
-
-        get_group_info(clp->cl_cred.cr_group_info);
-        acred.uid = clp->cl_cred.cr_uid;
-        acred.gid = clp->cl_cred.cr_gid;
-        acred.group_info = clp->cl_cred.cr_group_info;
-
-        dprintk("NFSD:     looking up %s cred\n",
-                clnt->cl_auth->au_ops->au_name);
-        ret = rpcauth_lookup_credcache(clnt->cl_auth, &acred, taskflags);
-        put_group_info(clp->cl_cred.cr_group_info);
-        return ret;
-}
-
 /* Reference counting, callback cleanup, etc., all look racy as heck.
  * And why is cb_set an atomic? */
 
@@ -379,18 +357,13 @@ static int do_probe_callback(void *data)
 	};
 	int status;
 
-	msg.rpc_cred = nfsd4_lookupcred(clp, 0);
-	if (IS_ERR(msg.rpc_cred))
-		goto out;
 	status = rpc_call_sync(cb->cb_client, &msg, RPC_TASK_SOFT);
-	put_rpccred(msg.rpc_cred);
 
 	if (status) {
 		rpc_shutdown_client(cb->cb_client);
 		cb->cb_client = NULL;
 	} else
 		atomic_set(&cb->cb_set, 1);
-out:
 	put_nfs4_client(clp);
 	return 0;
 }
@@ -488,10 +461,6 @@ nfsd4_cb_recall(struct nfs4_delegation *dp)
 	if ((!atomic_read(&clp->cl_callback.cb_set)) || !clnt)
 		return;
 
-	msg.rpc_cred = nfsd4_lookupcred(clp, 0);
-	if (IS_ERR(msg.rpc_cred))
-		goto out;
-
 	cbr->cbr_trunc = 0; /* XXX need to implement truncate optimization */
 	cbr->cbr_dp = dp;
 
@@ -512,8 +481,6 @@ nfsd4_cb_recall(struct nfs4_delegation *dp)
 		status = rpc_call_sync(clnt, &msg, RPC_TASK_SOFT);
 	}
 out_put_cred:
-	put_rpccred(msg.rpc_cred);
-out:
 	if (status == -EIO)
 		atomic_set(&clp->cl_callback.cb_set, 0);
 	/* Success or failure, now we're either waiting for lease expiration
-- 
1.5.3.rc5.19.g0734d


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
