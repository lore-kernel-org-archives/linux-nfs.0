Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37126 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752265Ab2FOQ2M (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Jun 2012 12:28:12 -0400
Date: Fri, 15 Jun 2012 12:28:09 -0400
From: bfields <bfields@fieldses.org>
To: Joerg Platte <jplatte@naasa.net>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Kernel 3.4.X NFS server regression
Message-ID: <20120615162808.GC18953@fieldses.org>
References: <4FD47D4E.9070307@naasa.net>
 <1339340441.4751.1.camel@lade.trondhjem.org>
 <4FDB539A.8060409@naasa.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FDB539A.8060409@naasa.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 15, 2012 at 05:24:10PM +0200, Joerg Platte wrote:
> I'm replying to this bug report since I found another nfs server
> regression with the same kernel version (3.4.2), so the subject
> matches. This time it is a "kernel BUG at fs/nfsd/nfs4state.c:1044"
> 
> Since the machine was not responsive after the BUG and rebooted I
> was only able to take a picture of the full stacktrace. You can
> download it from here:
> 
> https://ferdi.naasa.net/url/jplatte/IMG_3139.JPG
> 
> The patch "[PATCH] rpc_pipefs: allow rpc_purge_list to take a NULL
> waitq pointer" was not applied for this trace, but the bug is the
> same with this patch applied. So there must be another problem.
> 
> The crash is reproducable just by creating some nfs traffic and I
> can hit it within minutes.

This is fixed by a patch submitted for 3.5.

If things go normally I assume Linus will pull this when he bets back
from vacation in the next few days and then it should go to stable not
too long after.

--b.

commit bc2df47a408f2d64cf81bcfd0f6e3e14c84cb0ab
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Tue Jun 12 08:28:48 2012 -0400

    nfsd4: BUG_ON(!is_spin_locked()) no good on UP kernels
    
    Most frequent symptom was a BUG triggering in expire_client, with the
    server locking up shortly thereafter.
    
    Introduced by 508dc6e110c6dbdc0bbe84298ccfe22de7538486 "nfsd41:
    free_session/free_client must be called under the client_lock".
    
    Cc: stable@kernel.org
    Cc: Benny Halevy <bhalevy@tonian.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8fdc9ec..94effd5 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -900,7 +900,7 @@ static void free_session(struct kref *kref)
 	struct nfsd4_session *ses;
 	int mem;
 
-	BUG_ON(!spin_is_locked(&client_lock));
+	lockdep_assert_held(&client_lock);
 	ses = container_of(kref, struct nfsd4_session, se_ref);
 	nfsd4_del_conns(ses);
 	spin_lock(&nfsd_drc_lock);
@@ -1080,7 +1080,7 @@ static struct nfs4_client *alloc_client(struct xdr_netobj name)
 static inline void
 free_client(struct nfs4_client *clp)
 {
-	BUG_ON(!spin_is_locked(&client_lock));
+	lockdep_assert_held(&client_lock);
 	while (!list_empty(&clp->cl_sessions)) {
 		struct nfsd4_session *ses;
 		ses = list_entry(clp->cl_sessions.next, struct nfsd4_session,
