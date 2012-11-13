Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:17753 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754799Ab2KMPpw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Nov 2012 10:45:52 -0500
Subject: [PATCH 01/15] nfsd: use service net instead of hard-coded net where
	possible
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, devel@openvz.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, jlayton@redhat.com
Date: Tue, 13 Nov 2012 18:48:23 +0300
Message-ID: <20121113154823.12577.89371.stgit@localhost.localdomain>
In-Reply-To: <20121113154722.12577.57671.stgit@localhost.localdomain>
References: <20121113154722.12577.57671.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/nfs4state.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d6b602a..6a3661b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2257,7 +2257,7 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 	nfs4_verifier confirm = setclientid_confirm->sc_confirm; 
 	clientid_t * clid = &setclientid_confirm->sc_clientid;
 	__be32 status;
-	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
+	struct nfsd_net	*nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
 	if (STALE_CLIENTID(clid, nn))
 		return nfserr_stale_clientid;
@@ -3129,7 +3129,7 @@ nfsd4_renew(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 {
 	struct nfs4_client *clp;
 	__be32 status;
-	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
+	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
 	nfs4_lock_state();
 	dprintk("process_renew(%08x/%08x): starting\n", 
@@ -4082,7 +4082,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	bool new_state = false;
 	int lkflg;
 	int err;
-	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
+	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
 	dprintk("NFSD: nfsd4_lock: start=%Ld length=%Ld\n",
 		(long long) lock->lk_offset,
@@ -4255,7 +4255,7 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct file_lock *file_lock = NULL;
 	struct nfs4_lockowner *lo;
 	__be32 status;
-	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
+	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
 	if (locks_in_grace(SVC_NET(rqstp)))
 		return nfserr_grace;
@@ -4431,7 +4431,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 	struct list_head matches;
 	unsigned int hashval = ownerstr_hashval(clid->cl_id, owner);
 	__be32 status;
-	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
+	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
 	dprintk("nfsd4_release_lockowner clientid: (%08x/%08x):\n",
 		clid->cl_boot, clid->cl_id);

