From: David Howells <dhowells@redhat.com>
Subject: Re: INFO: suspicious rcu_dereference_check()
Date: Mon, 29 Mar 2010 19:56:37 +0100
Message-ID: <18617.1269888997@redhat.com>
References: <1269882883.3181.25.camel@localhost.localdomain> <c4e36d111003250348q678eb2e6w4f3e8133e7fd6e58@mail.gmail.com> <1269531400.3648.1.camel@localhost.localdomain> <20100329152557.GD2569@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Cc: dhowells@redhat.com, paulmck@linux.vnet.ibm.com,
	Zdenek Kabelac <zdenek.kabelac@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24618 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752642Ab0C2S46 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Mar 2010 14:56:58 -0400
In-Reply-To: <1269882883.3181.25.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=

Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> I don't mind whether you or I push them to Linus, but IIRC you had a
> couple of comments about the last patchset I saw from David, so I was
> expecting to see either a reply from him or patch update. Did I miss
> that reply? (Ccing: David)

I was waiting to see what Arnd did, since Paul said:

	This looks good at the moment, however, the sparse changes that Arnd
	Bergmann is working on will invalidate a couple of the changes below.
	Of course, better a future problem than a here-and-now problem, but
	is there an easy way to fix both?

My message and Paul's reply are attached for Arnd's convenience.  Maybe Arnd
could include my changes, or supply me with his patch?

David


--=-=-=
Content-Type: message/rfc822
Content-Disposition: attachment; filename=10878

Return-Path: dhowells@redhat.com
Received: from mail.corp.redhat.com [10.5.5.52]
	by warthog.procyon.org.uk with IMAP (fetchmail-6.3.11)
	for <dhowells@localhost> (single-drop); Thu, 18 Mar 2010 13:33:37 +0000 (GMT)
Received: from zmta02.collab.prod.int.phx2.redhat.com (LHLO
 zmta02.collab.prod.int.phx2.redhat.com) (10.5.5.32) by
 mail06.corp.redhat.com with LMTP; Thu, 18 Mar 2010 09:33:06 -0400 (EDT)
Received: from localhost (localhost.localdomain [127.0.0.1])
	by zmta02.collab.prod.int.phx2.redhat.com (Postfix) with ESMTP id 5A0EA12800A
	for <dhowells@redhat.com>; Thu, 18 Mar 2010 09:33:06 -0400 (EDT)
Received: from zmta02.collab.prod.int.phx2.redhat.com ([127.0.0.1])
	by localhost (zmta02.collab.prod.int.phx2.redhat.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id cgBPB+f0SN5D for <dhowells@redhat.com>;
	Thu, 18 Mar 2010 09:33:06 -0400 (EDT)
Received: from int-mx03.intmail.prod.int.phx2.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	by zmta02.collab.prod.int.phx2.redhat.com (Postfix) with ESMTP id 4922F128003
	for <dhowells-/m+UfqrgI5QNLKR9yMNcA1aTQe2KTcn/@public.gmane.org>; Thu, 18 Mar 2010 09:33:06 -0400 (EDT)
Received: from warthog.cambridge.redhat.com (kibblesnbits.boston.devel.redhat.com [10.16.60.12])
	by int-mx03.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o2IDX35W021809
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO);
	Thu, 18 Mar 2010 09:33:05 -0400
Received: from [127.0.0.1] (helo=warthog.procyon.org.uk)
	by warthog.cambridge.redhat.com with esmtp (Exim 4.69 #1 (Red Hat Linux))
	id 1NsFqQ-0007kP-E5; Thu, 18 Mar 2010 13:33:02 +0000
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
	Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
	Kingdom.
	Registered in England and Wales under Company Registration No. 3798903
From: David Howells <dhowells@redhat.com>
Subject: [PATCH] NFS: Fix RCU warnings in
	nfs_inode_return_delegation_noreclaim() [ver #2]
To: Trond.Myklebust@netapp.com, paulmck@linux.vnet.ibm.com
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        David Howells <dhowells@redhat.com>
Date: Thu, 18 Mar 2010 13:33:02 +0000
Message-ID: <20100318133302.29754.1584.stgit-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org>
User-Agent: StGIT/0.14.3
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.67 on 10.5.11.16

Fix a number of RCU warnings in nfs_inode_return_delegation_noreclaim().
nfs_inode_return_delegation_noreclaim() and nfs_inode_return_delegation() don't
need to use rcu_dereference() outside the spinlocked region as they merely
examin the pointer and don't follow it, thus rendering unnecessary the need to
impose a partial ordering over the one item of interest.

nfs_detach_delegation_locked() doesn't need rcu_derefence() because it can only
be called if nfs_client::cl_lock is held, and that guards against anyone
changing nfsi->delegation under it.  Furthermore, the barrier in
rcu_derefence() is superfluous, given that the spin_lock() is also a barrier.

nfs_free_delegation() should be using rcu_dereference_check() to validate the
state that the data is in (the delegation inode must have been cleared).  By
this point, the delegation is being released, so no one else should be
attempting to use the saved credentials, and they can be cleared.  However,
rcu_assign_pointer() should be used to clear them, and the delegation itself
must still use call_rcu() as the list of delegations could be being traversed.


[ INFO: suspicious rcu_dereference_check() usage. ]
---------------------------------------------------
fs/nfs/delegation.c:332 invoked rcu_dereference_check() without protection!

other info that might help us debug this:


rcu_scheduler_active = 1, debug_locks = 0
2 locks held by mount.nfs4/2281:
 #0:  (&type->s_umount_key#34){+.+...}, at: [<ffffffff810b25b4>] deactivate_super+0x60/0x80
 #1:  (iprune_sem){+.+...}, at: [<ffffffff810c332a>] invalidate_inodes+0x39/0x13a

stack backtrace:
Pid: 2281, comm: mount.nfs4 Not tainted 2.6.34-rc1-cachefs #110
Call Trace:
 [<ffffffff8105149f>] lockdep_rcu_dereference+0xaa/0xb2
 [<ffffffffa00b4591>] nfs_inode_return_delegation_noreclaim+0x5b/0xa0 [nfs]
 [<ffffffffa0095d63>] nfs4_clear_inode+0x11/0x1e [nfs]
 [<ffffffff810c2d92>] clear_inode+0x9e/0xf8
 [<ffffffff810c3028>] dispose_list+0x67/0x10e
 [<ffffffff810c340d>] invalidate_inodes+0x11c/0x13a
 [<ffffffff810b1dc1>] generic_shutdown_super+0x42/0xf4
 [<ffffffff810b1ebe>] kill_anon_super+0x11/0x4f
 [<ffffffffa009893c>] nfs4_kill_super+0x3f/0x72 [nfs]
 [<ffffffff810b25bc>] deactivate_super+0x68/0x80
 [<ffffffff810c6744>] mntput_no_expire+0xbb/0xf8
 [<ffffffff810c681b>] release_mounts+0x9a/0xb0
 [<ffffffff810c689b>] put_mnt_ns+0x6a/0x79
 [<ffffffffa00983a1>] nfs_follow_remote_path+0x5a/0x146 [nfs]
 [<ffffffffa0098334>] ? nfs_do_root_mount+0x82/0x95 [nfs]
 [<ffffffffa00985a9>] nfs4_try_mount+0x75/0xaf [nfs]
 [<ffffffffa0098874>] nfs4_get_sb+0x291/0x31a [nfs]
 [<ffffffff810b2059>] vfs_kern_mount+0xb8/0x177
 [<ffffffff810b2176>] do_kern_mount+0x48/0xe8
 [<ffffffff810c810b>] do_mount+0x782/0x7f9
 [<ffffffff810c8205>] sys_mount+0x83/0xbe
 [<ffffffff81001eeb>] system_call_fastpath+0x16/0x1b

Also on:

fs/nfs/delegation.c:215 invoked rcu_dereference_check() without protection!
 [<ffffffff8105149f>] lockdep_rcu_dereference+0xaa/0xb2
 [<ffffffffa00b4223>] nfs_inode_set_delegation+0xfe/0x219 [nfs]
 [<ffffffffa00a9c6f>] nfs4_opendata_to_nfs4_state+0x2c2/0x30d [nfs]
 [<ffffffffa00aa15d>] nfs4_do_open+0x2a6/0x3a6 [nfs]
 ...

And:

fs/nfs/delegation.c:40 invoked rcu_dereference_check() without protection!
 [<ffffffff8105149f>] lockdep_rcu_dereference+0xaa/0xb2
 [<ffffffffa00b3bef>] nfs_free_delegation+0x3d/0x6e [nfs]
 [<ffffffffa00b3e71>] nfs_do_return_delegation+0x26/0x30 [nfs]
 [<ffffffffa00b406a>] __nfs_inode_return_delegation+0x1ef/0x1fe [nfs]
 [<ffffffffa00b448a>] nfs_client_return_marked_delegations+0xc9/0x124 [nfs]
 ...


Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/nfs/delegation.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 2563beb..fa9b7c5 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -37,7 +37,8 @@ static void nfs_free_delegation(struct nfs_delegation *delegation)
 {
 	struct rpc_cred *cred;
 
-	cred = rcu_dereference(delegation->cred);
+	cred = rcu_dereference_check(delegation->cred,
+				     delegation->inode == NULL);
 	rcu_assign_pointer(delegation->cred, NULL);
 	call_rcu(&delegation->rcu, nfs_free_delegation_callback);
 	if (cred)
@@ -167,7 +168,7 @@ static struct inode *nfs_delegation_grab_inode(struct nfs_delegation *delegation
 
 static struct nfs_delegation *nfs_detach_delegation_locked(struct nfs_inode *nfsi, const nfs4_stateid *stateid)
 {
-	struct nfs_delegation *delegation = rcu_dereference(nfsi->delegation);
+	struct nfs_delegation *delegation = nfsi->delegation;
 
 	if (delegation == NULL)
 		goto nomatch;
@@ -212,7 +213,7 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
 	spin_lock_init(&delegation->lock);
 
 	spin_lock(&clp->cl_lock);
-	if (rcu_dereference(nfsi->delegation) != NULL) {
+	if (nfsi->delegation != NULL) {
 		if (memcmp(&delegation->stateid, &nfsi->delegation->stateid,
 					sizeof(delegation->stateid)) == 0 &&
 				delegation->type == nfsi->delegation->type) {
@@ -329,7 +330,7 @@ void nfs_inode_return_delegation_noreclaim(struct inode *inode)
 	struct nfs_inode *nfsi = NFS_I(inode);
 	struct nfs_delegation *delegation;
 
-	if (rcu_dereference(nfsi->delegation) != NULL) {
+	if (nfsi->delegation != NULL) {
 		spin_lock(&clp->cl_lock);
 		delegation = nfs_detach_delegation_locked(nfsi, NULL);
 		spin_unlock(&clp->cl_lock);
@@ -345,7 +346,7 @@ int nfs_inode_return_delegation(struct inode *inode)
 	struct nfs_delegation *delegation;
 	int err = 0;
 
-	if (rcu_dereference(nfsi->delegation) != NULL) {
+	if (nfsi->delegation != NULL) {
 		spin_lock(&clp->cl_lock);
 		delegation = nfs_detach_delegation_locked(nfsi, NULL);
 		spin_unlock(&clp->cl_lock);


--=-=-=
Content-Type: message/rfc822
Content-Disposition: attachment; filename=10889

Return-Path: paulmck-sleguYLL0eYp96r9Hs7rR0HqhR2KayfoaymQpXI5994AvxtiuMwx3w@public.gmane.org
Received: from mail.corp.redhat.com [10.5.5.52]
	by warthog.procyon.org.uk with IMAP (fetchmail-6.3.11)
	for <dhowells@localhost> (single-drop); Fri, 19 Mar 2010 02:26:05 +0000 (GMT)
Received: from zmta02.collab.prod.int.phx2.redhat.com (LHLO
 zmta02.collab.prod.int.phx2.redhat.com) (10.5.5.32) by
 mail06.corp.redhat.com with LMTP; Thu, 18 Mar 2010 22:25:41 -0400 (EDT)
Received: from localhost (localhost.localdomain [127.0.0.1])
	by zmta02.collab.prod.int.phx2.redhat.com (Postfix) with ESMTP id E31519E6CC
	for <dhowells@redhat.com>; Thu, 18 Mar 2010 22:25:41 -0400 (EDT)
Received: from zmta02.collab.prod.int.phx2.redhat.com ([127.0.0.1])
	by localhost (zmta02.collab.prod.int.phx2.redhat.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id zc8aqHS8mlKB for <dhowells@redhat.com>;
	Thu, 18 Mar 2010 22:25:41 -0400 (EDT)
Received: from int-mx04.intmail.prod.int.phx2.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.17])
	by zmta02.collab.prod.int.phx2.redhat.com (Postfix) with ESMTP id C14609E6CB
	for <dhowells-/m+UfqrgI5QNLKR9yMNcA1aTQe2KTcn/@public.gmane.org>; Thu, 18 Mar 2010 22:25:41 -0400 (EDT)
Received: from mx1.redhat.com (ext-mx04.extmail.prod.ext.phx2.redhat.com [10.5.110.8])
	by int-mx04.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o2J2Pfcr013945
	for <dhowells@redhat.com>; Thu, 18 Mar 2010 22:25:41 -0400
Received: from e5.ny.us.ibm.com (e5.ny.us.ibm.com [32.97.182.145])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o2J2PUlC025727
	for <dhowells@redhat.com>; Thu, 18 Mar 2010 22:25:30 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e5.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o2J2BB7V009683
	for <dhowells@redhat.com>; Thu, 18 Mar 2010 22:11:11 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2J2PTPk1245220
	for <dhowells@redhat.com>; Thu, 18 Mar 2010 22:25:29 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2J2PTjt020272
	for <dhowells@redhat.com>; Thu, 18 Mar 2010 22:25:29 -0400
Received: from paulmck-laptop.localdomain (sig-9-65-43-134.mts.ibm.com [9.65.43.134])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVin) with ESMTP id o2J2PSNA020249;
	Thu, 18 Mar 2010 22:25:28 -0400
Received: by paulmck-laptop.localdomain (Postfix, from userid 1000)
	id CC80118179B; Thu, 18 Mar 2010 19:25:27 -0700 (PDT)
Date: Thu, 18 Mar 2010 19:25:27 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: David Howells <dhowells@redhat.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] NFS: Fix RCU warnings in
 nfs_inode_return_delegation_noreclaim() [ver #2]
Message-ID: <20100319022527.GC2894@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20100318133302.29754.1584.stgit-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100318133302.29754.1584.stgit-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org>
User-Agent: Mutt/1.5.20 (2009-06-14)
X-RedHat-Spam-Score: -2.31  (RCVD_IN_DNSWL_MED,T_RP_MATCHES_RCVD)
X-Scanned-By: MIMEDefang 2.67 on 10.5.11.17
X-Scanned-By: MIMEDefang 2.67 on 10.5.110.8

On Thu, Mar 18, 2010 at 01:33:02PM +0000, David Howells wrote:
> Fix a number of RCU warnings in nfs_inode_return_delegation_noreclaim().
> nfs_inode_return_delegation_noreclaim() and nfs_inode_return_delegation() don't
> need to use rcu_dereference() outside the spinlocked region as they merely
> examin the pointer and don't follow it, thus rendering unnecessary the need to
> impose a partial ordering over the one item of interest.
> 
> nfs_detach_delegation_locked() doesn't need rcu_derefence() because it can only
> be called if nfs_client::cl_lock is held, and that guards against anyone
> changing nfsi->delegation under it.  Furthermore, the barrier in
> rcu_derefence() is superfluous, given that the spin_lock() is also a barrier.
> 
> nfs_free_delegation() should be using rcu_dereference_check() to validate the
> state that the data is in (the delegation inode must have been cleared).  By
> this point, the delegation is being released, so no one else should be
> attempting to use the saved credentials, and they can be cleared.  However,
> rcu_assign_pointer() should be used to clear them, and the delegation itself
> must still use call_rcu() as the list of delegations could be being traversed.

Thank you for fixing these up!

This looks good at the moment, however, the sparse changes that Arnd
Bergmann is working on will invalidate a couple of the changes below.
Of course, better a future problem than a here-and-now problem, but
is there an easy way to fix both?

							Thanx, Paul

> [ INFO: suspicious rcu_dereference_check() usage. ]
> ---------------------------------------------------
> fs/nfs/delegation.c:332 invoked rcu_dereference_check() without protection!
> 
> other info that might help us debug this:
> 
> 
> rcu_scheduler_active = 1, debug_locks = 0
> 2 locks held by mount.nfs4/2281:
>  #0:  (&type->s_umount_key#34){+.+...}, at: [<ffffffff810b25b4>] deactivate_super+0x60/0x80
>  #1:  (iprune_sem){+.+...}, at: [<ffffffff810c332a>] invalidate_inodes+0x39/0x13a
> 
> stack backtrace:
> Pid: 2281, comm: mount.nfs4 Not tainted 2.6.34-rc1-cachefs #110
> Call Trace:
>  [<ffffffff8105149f>] lockdep_rcu_dereference+0xaa/0xb2
>  [<ffffffffa00b4591>] nfs_inode_return_delegation_noreclaim+0x5b/0xa0 [nfs]
>  [<ffffffffa0095d63>] nfs4_clear_inode+0x11/0x1e [nfs]
>  [<ffffffff810c2d92>] clear_inode+0x9e/0xf8
>  [<ffffffff810c3028>] dispose_list+0x67/0x10e
>  [<ffffffff810c340d>] invalidate_inodes+0x11c/0x13a
>  [<ffffffff810b1dc1>] generic_shutdown_super+0x42/0xf4
>  [<ffffffff810b1ebe>] kill_anon_super+0x11/0x4f
>  [<ffffffffa009893c>] nfs4_kill_super+0x3f/0x72 [nfs]
>  [<ffffffff810b25bc>] deactivate_super+0x68/0x80
>  [<ffffffff810c6744>] mntput_no_expire+0xbb/0xf8
>  [<ffffffff810c681b>] release_mounts+0x9a/0xb0
>  [<ffffffff810c689b>] put_mnt_ns+0x6a/0x79
>  [<ffffffffa00983a1>] nfs_follow_remote_path+0x5a/0x146 [nfs]
>  [<ffffffffa0098334>] ? nfs_do_root_mount+0x82/0x95 [nfs]
>  [<ffffffffa00985a9>] nfs4_try_mount+0x75/0xaf [nfs]
>  [<ffffffffa0098874>] nfs4_get_sb+0x291/0x31a [nfs]
>  [<ffffffff810b2059>] vfs_kern_mount+0xb8/0x177
>  [<ffffffff810b2176>] do_kern_mount+0x48/0xe8
>  [<ffffffff810c810b>] do_mount+0x782/0x7f9
>  [<ffffffff810c8205>] sys_mount+0x83/0xbe
>  [<ffffffff81001eeb>] system_call_fastpath+0x16/0x1b
> 
> Also on:
> 
> fs/nfs/delegation.c:215 invoked rcu_dereference_check() without protection!
>  [<ffffffff8105149f>] lockdep_rcu_dereference+0xaa/0xb2
>  [<ffffffffa00b4223>] nfs_inode_set_delegation+0xfe/0x219 [nfs]
>  [<ffffffffa00a9c6f>] nfs4_opendata_to_nfs4_state+0x2c2/0x30d [nfs]
>  [<ffffffffa00aa15d>] nfs4_do_open+0x2a6/0x3a6 [nfs]
>  ...
> 
> And:
> 
> fs/nfs/delegation.c:40 invoked rcu_dereference_check() without protection!
>  [<ffffffff8105149f>] lockdep_rcu_dereference+0xaa/0xb2
>  [<ffffffffa00b3bef>] nfs_free_delegation+0x3d/0x6e [nfs]
>  [<ffffffffa00b3e71>] nfs_do_return_delegation+0x26/0x30 [nfs]
>  [<ffffffffa00b406a>] __nfs_inode_return_delegation+0x1ef/0x1fe [nfs]
>  [<ffffffffa00b448a>] nfs_client_return_marked_delegations+0xc9/0x124 [nfs]
>  ...
> 
> 
> Signed-off-by: David Howells <dhowells@redhat.com>
> ---
> 
>  fs/nfs/delegation.c |   11 ++++++-----
>  1 files changed, 6 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
> index 2563beb..fa9b7c5 100644
> --- a/fs/nfs/delegation.c
> +++ b/fs/nfs/delegation.c
> @@ -37,7 +37,8 @@ static void nfs_free_delegation(struct nfs_delegation *delegation)
>  {
>  	struct rpc_cred *cred;
> 
> -	cred = rcu_dereference(delegation->cred);
> +	cred = rcu_dereference_check(delegation->cred,
> +				     delegation->inode == NULL);
>  	rcu_assign_pointer(delegation->cred, NULL);
>  	call_rcu(&delegation->rcu, nfs_free_delegation_callback);
>  	if (cred)
> @@ -167,7 +168,7 @@ static struct inode *nfs_delegation_grab_inode(struct nfs_delegation *delegation
> 
>  static struct nfs_delegation *nfs_detach_delegation_locked(struct nfs_inode *nfsi, const nfs4_stateid *stateid)
>  {
> -	struct nfs_delegation *delegation = rcu_dereference(nfsi->delegation);
> +	struct nfs_delegation *delegation = nfsi->delegation;

Arnd's work will flag this one.

> 
>  	if (delegation == NULL)
>  		goto nomatch;
> @@ -212,7 +213,7 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
>  	spin_lock_init(&delegation->lock);
> 
>  	spin_lock(&clp->cl_lock);
> -	if (rcu_dereference(nfsi->delegation) != NULL) {
> +	if (nfsi->delegation != NULL) {

And this one.  I thought that Trond said that clp->cl_lock protects
this one, in which case this should work:

	if (rcu_dereference_check(nfsi->delegation,
				  lockdep_is_held(&clp->cl_lock)) != NULL) {

>  		if (memcmp(&delegation->stateid, &nfsi->delegation->stateid,
>  					sizeof(delegation->stateid)) == 0 &&
>  				delegation->type == nfsi->delegation->type) {
> @@ -329,7 +330,7 @@ void nfs_inode_return_delegation_noreclaim(struct inode *inode)
>  	struct nfs_inode *nfsi = NFS_I(inode);
>  	struct nfs_delegation *delegation;
> 
> -	if (rcu_dereference(nfsi->delegation) != NULL) {
> +	if (nfsi->delegation != NULL) {

And this one, although the check for cp->cl_lock obviously won't work here.

>  		spin_lock(&clp->cl_lock);
>  		delegation = nfs_detach_delegation_locked(nfsi, NULL);
>  		spin_unlock(&clp->cl_lock);
> @@ -345,7 +346,7 @@ int nfs_inode_return_delegation(struct inode *inode)
>  	struct nfs_delegation *delegation;
>  	int err = 0;
> 
> -	if (rcu_dereference(nfsi->delegation) != NULL) {
> +	if (nfsi->delegation != NULL) {

Ditto...

>  		spin_lock(&clp->cl_lock);
>  		delegation = nfs_detach_delegation_locked(nfsi, NULL);
>  		spin_unlock(&clp->cl_lock);
> 


--=-=-=--
