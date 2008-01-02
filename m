From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] lockdep warnings in nfs4 (v2.6.24-rc6-125-g5356f66)
Date: Wed, 02 Jan 2008 13:55:56 -0500
Message-ID: <1199300156.13519.5.camel@heimdal.trondhjem.org>
References: <200712242040.lBOKeiFA003845@agora.fsl.cs.sunysb.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Oqf3jdfnS84wtE7QvIZH"
Cc: nfs@lists.sourceforge.net
To: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:51381 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752775AbYABS4X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Jan 2008 13:56:23 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JA8lI-0000CA-I3
	for linux-nfs@vger.kernel.org; Thu, 03 Jan 2008 05:56:20 +1100
In-Reply-To: <200712242040.lBOKeiFA003845-zop+azHP2WsZjdeEBZXbMidm6ipF23ct@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-Oqf3jdfnS84wtE7QvIZH
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


On Mon, 2007-12-24 at 15:40 -0500, Erez Zadok wrote:
> My setup: ext2 partition, exported to localhost; nfs4 mounted on localhost;
> unionfs mounted on top of nfs4 mount.  Issuing assorted regression tests via
> the union.  Kernel compiled with lockdep.  Four of my tests (rmdir, readdir,
> rename, and rename with whiteouts), trigger the same lockdep warning when
> unmounting nfs4.  It doesn't happen when unionfs is mounted on top of
> anything else, including nfs2 and nfs3.
> 
> I've not tried to reproduce it w/o unionfs, but the lockdep warning below
> appears to be unrelated to unionfs.  If you'd like me to try and reproduce
> it w/o unionfs, let me know.
> 
> Cheers,
> Erez.

The following patch should fix it.

Cheers
  Trond

--=-Oqf3jdfnS84wtE7QvIZH
Content-Disposition: inline;
	filename*0=linux-2.6.24-002-fix_circular_locking_dependency_in_nfs4_kill;
	filename*1=_renewd.dif
Content-Type: message/rfc822;
	name*0=linux-2.6.24-002-fix_circular_locking_dependency_in_nfs4_kill_ren;
	name*1=ewd.dif

From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Wed, 2 Jan 2008 13:52:03 -0500
NFSv4: Fix circular locking dependency in nfs4_kill_renewd
Subject: No Subject
Message-Id: <1199300156.13519.6.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit

Erez Zadok reports:

=======================================================
[ INFO: possible circular locking dependency detected ]
2.6.24-rc6-unionfs2 #80
-------------------------------------------------------
umount.nfs4/4017 is trying to acquire lock:
 (&(&clp->cl_renewd)->work){--..}, at: [<c0223e53>]
__cancel_work_timer+0x83/0x17f

but task is already holding lock:
 (&clp->cl_sem){----}, at: [<f8879897>] nfs4_kill_renewd+0x17/0x29 [nfs]

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #1 (&clp->cl_sem){----}:
       [<c0230699>] __lock_acquire+0x9cc/0xb95
       [<c0230c39>] lock_acquire+0x5f/0x78
       [<c0397cb8>] down_read+0x3a/0x4c
       [<f88798e6>] nfs4_renew_state+0x1c/0x1b8 [nfs]
       [<c0223821>] run_workqueue+0xd9/0x1ac
       [<c0224220>] worker_thread+0x7a/0x86
       [<c0226b49>] kthread+0x3b/0x62
       [<c02033a3>] kernel_thread_helper+0x7/0x10
       [<ffffffff>] 0xffffffff

-> #0 (&(&clp->cl_renewd)->work){--..}:
       [<c0230589>] __lock_acquire+0x8bc/0xb95
       [<c0230c39>] lock_acquire+0x5f/0x78
       [<c0223e87>] __cancel_work_timer+0xb7/0x17f
       [<c0223f5a>] cancel_delayed_work_sync+0xb/0xd
       [<f887989e>] nfs4_kill_renewd+0x1e/0x29 [nfs]
       [<f885a8f6>] nfs_free_client+0x37/0x9e [nfs]
       [<f885ab20>] nfs_put_client+0x5d/0x62 [nfs]
       [<f885ab9a>] nfs_free_server+0x75/0xae [nfs]
       [<f8862672>] nfs4_kill_super+0x27/0x2b [nfs]
       [<c0258aab>] deactivate_super+0x3f/0x51
       [<c0269668>] mntput_no_expire+0x42/0x67
       [<c025d0e4>] path_release_on_umount+0x15/0x18
       [<c0269d30>] sys_umount+0x1a3/0x1cb
       [<c0269d71>] sys_oldumount+0x19/0x1b
       [<c02026ca>] sysenter_past_esp+0x5f/0xa5
       [<ffffffff>] 0xffffffff

Looking at the code, it would seem that taking the clp->cl_sem in
nfs4_kill_renewd is completely redundant, since we're already guaranteed to
have exclusive access to the nfs_client (we're shutting down).

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4renewd.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4renewd.c b/fs/nfs/nfs4renewd.c
index 3ea352d..5e2e4af 100644
--- a/fs/nfs/nfs4renewd.c
+++ b/fs/nfs/nfs4renewd.c
@@ -133,9 +133,7 @@ nfs4_renewd_prepare_shutdown(struct nfs_server *server)
 void
 nfs4_kill_renewd(struct nfs_client *clp)
 {
-	down_read(&clp->cl_sem);
 	cancel_delayed_work_sync(&clp->cl_renewd);
-	up_read(&clp->cl_sem);
 }
 
 /*

--=-Oqf3jdfnS84wtE7QvIZH
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--=-Oqf3jdfnS84wtE7QvIZH
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

--=-Oqf3jdfnS84wtE7QvIZH--



