Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:48034 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809AbbD3Ohi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2015 10:37:38 -0400
Date: Thu, 30 Apr 2015 07:37:31 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH, RFC] backchannel overflows
Message-ID: <20150430143731.GA22038@infradead.org>
References: <20150428202157.GA23972@infradead.org>
 <1C0C92C2-FBCF-49D8-BB31-3C23A520B075@oracle.com>
 <20150429151404.GA12936@infradead.org>
 <CAHQdGtSzdoymP=8_KQJ1A6iCKe+v3qexsQMvJ3Hx2J+bo96RhA@mail.gmail.com>
 <20150429173454.GA23284@fieldses.org>
 <20150430062558.GA25660@infradead.org>
 <2ED34DBC-D928-4F1F-B5EF-B9F77D8AA075@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <2ED34DBC-D928-4F1F-B5EF-B9F77D8AA075@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 30, 2015 at 10:34:02AM -0400, Chuck Lever wrote:
> I?ve been discussing the possibility of adding more session slots on
> the Linux NFS client with jlayton. We think it would be straightforward,
> once the workqueue-based NFSD patches are in, to make the backchannel
> service into a workqueue. Then it would be a simple matter to increase
> the number of session slots.
> 
> We haven?t discussed what would be needed on the server side of this
> equation, but sounds like it has some deeper problems if it is not
> obeying the session slot table limits advertised by the client.

No, the client isn't obeying it's own slot limits

The problem is when the client responds to a callback it still
holds a references on rpc_rqst for a while.  If the server
sends the next callback fast enough to hit that race window the
client incorrectly rejects it.  Note that we never even get
to the nfs code that check the slot id in this case, it's low-level
sunrpc code that is the problem.

Note that with my patches the server can recover from this client
problem by resetting the connection, but that's not very optimal
behavior.

My current patch which includes the explanation is below.

---
commit 7e995048c9917766e0ae96889ef48733c2229b7e
Author: Christoph Hellwig <hch@lst.de>
Date:   Thu Apr 30 11:53:11 2015 +0200

    nfs: overallocate backchannel requests
    
    The RPC code releases the rpc_rqst much later than sending the reply
    to the server.  To avoid low-level errors that lead connection requests
    under load allocate twice as many rpc_rqst structures as callback
    slots to allow for double buffering.
    
    Signed-off-by: Christoph Hellwig <hch@lst.de>

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 84326e9..7f79345 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -200,13 +200,18 @@ extern int nfs4_validate_delegation_stateid(struct nfs_delegation *delegation,
 					    const nfs4_stateid *stateid);
 extern int nfs4_set_callback_sessionid(struct nfs_client *clp);
 #endif /* CONFIG_NFS_V4 */
+
 /*
  * nfs41: Callbacks are expected to not cause substantial latency,
  * so we limit their concurrency to 1 by setting up the maximum number
  * of slots for the backchannel.
+ *
+ * Note that we allocate a second RPC request structure because the
+ * RPC code holds on to the buffer for a while after sending a reply
+ * to the server.
  */
-#define NFS41_BC_MIN_CALLBACKS 1
-#define NFS41_BC_MAX_CALLBACKS 1
+#define NFS41_BC_SLOTS 1
+#define NFS41_BC_REQUESTS (NFS41_BC_SLOTS * 2)
 
 extern unsigned int nfs_callback_set_tcpport;
 extern unsigned short nfs_callback_tcpport;
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 197806f..d733f04 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -320,7 +320,7 @@ validate_seqid(struct nfs4_slot_table *tbl, struct cb_sequenceargs * args)
 	dprintk("%s enter. slotid %u seqid %u\n",
 		__func__, args->csa_slotid, args->csa_sequenceid);
 
-	if (args->csa_slotid >= NFS41_BC_MAX_CALLBACKS)
+	if (args->csa_slotid >= NFS41_BC_SLOTS)
 		return htonl(NFS4ERR_BADSLOT);
 
 	slot = tbl->slots + args->csa_slotid;
@@ -465,8 +465,8 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
 	       sizeof(res->csr_sessionid));
 	res->csr_sequenceid = args->csa_sequenceid;
 	res->csr_slotid = args->csa_slotid;
-	res->csr_highestslotid = NFS41_BC_MAX_CALLBACKS - 1;
-	res->csr_target_highestslotid = NFS41_BC_MAX_CALLBACKS - 1;
+	res->csr_highestslotid = NFS41_BC_SLOTS - 1;
+	res->csr_target_highestslotid = NFS41_BC_SLOTS - 1;
 
 out:
 	cps->clp = clp; /* put in nfs4_callback_compound */
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index e42be52..e36717c 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -248,7 +248,7 @@ static int nfs4_init_callback(struct nfs_client *clp)
 	xprt = rcu_dereference_raw(clp->cl_rpcclient->cl_xprt);
 
 	if (nfs4_has_session(clp)) {
-		error = xprt_setup_backchannel(xprt, NFS41_BC_MIN_CALLBACKS);
+		error = xprt_setup_backchannel(xprt, NFS41_BC_REQUESTS);
 		if (error < 0)
 			return error;
 	}
diff --git a/fs/nfs/nfs4session.c b/fs/nfs/nfs4session.c
index e23366e..3ad4da4 100644
--- a/fs/nfs/nfs4session.c
+++ b/fs/nfs/nfs4session.c
@@ -500,7 +500,7 @@ void nfs4_destroy_session(struct nfs4_session *session)
 	rcu_read_unlock();
 	dprintk("%s Destroy backchannel for xprt %p\n",
 		__func__, xprt);
-	xprt_destroy_backchannel(xprt, NFS41_BC_MIN_CALLBACKS);
+	xprt_destroy_backchannel(xprt, NFS41_BC_REQUESTS);
 	nfs4_destroy_session_slot_tables(session);
 	kfree(session);
 }
