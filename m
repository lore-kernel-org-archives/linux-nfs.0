Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f175.google.com ([209.85.216.175]:34539 "EHLO
	mail-qt0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758601AbcHDNRi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Aug 2016 09:17:38 -0400
Received: by mail-qt0-f175.google.com with SMTP id u25so158238571qtb.1
        for <linux-nfs@vger.kernel.org>; Thu, 04 Aug 2016 06:16:50 -0700 (PDT)
Message-ID: <1470316606.22052.17.camel@redhat.com>
Subject: Re: [RFC PATCH] sunrpc: do not allow process to freeze within RPC
 state machine
From: Jeff Layton <jlayton@redhat.com>
To: skinsbursky@virtuozzo.com, bfields@fieldses.org,
        trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, gorcunov@virtuozzo.com,
        davem@davemloft.net, devel@openvz.org
Date: Thu, 04 Aug 2016 09:16:46 -0400
In-Reply-To: <cb097e9e-760b-5512-ff4a-276b31bfc83f@virtuozzo.com>
References: <20160803165412.22407.47399.stgit@localhost.localdomain>
	 <1470245777.13804.34.camel@redhat.com>
	 <cb097e9e-760b-5512-ff4a-276b31bfc83f@virtuozzo.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2016-08-04 at 12:55 +0200, Stanislav Kinsburskiy wrote:
> 
> 03.08.2016 19:36, Jeff Layton пишет:
> > 
> > On Wed, 2016-08-03 at 20:54 +0400, Stanislav Kinsburskiy wrote:
> > > 
> > > Otherwise freezer cgroup state might never become "FROZEN".
> > > 
> > > Here is a deadlock scheme for 2 processes in one freezer cgroup,
> > > which is
> > > freezing:
> > > 
> > > CPU 0                                   CPU 1
> > > --------                                --------
> > > do_last
> > > inode_lock(dir->d_inode)
> > > vfs_create
> > > nfs_create
> > > ...
> > > __rpc_execute
> > > rpc_wait_bit_killable
> > > __refrigerator
> > >                                          do_last
> > >                                          inode_lock(dir->d_inode)
> > > 
> > > So, the problem is that one process takes directory inode mutex,
> > > executes
> > > creation request and goes to refrigerator.
> > > Another one waits till directory lock is released, remains "thawed"
> > > and thus
> > > freezer cgroup state never becomes "FROZEN".
> > > 
> > > Notes:
> > > 1) Interesting, that this is not a pure deadlock: one can thaw cgroup
> > > and then
> > > freeze it again.
> > > 2) The issue was introduced by commit
> > > d310310cbff18ec385c6ab4d58f33b100192a96a.
> > > 3) This patch is not aimed to fix the issue, but to show the problem
> > > root.
> > > Look like this problem moght be applicable to other hunks from the
> > > commit,
> > > mentioned above.
> > > 
> > > 
> > > > > > Signed-off-by: Stanislav Kinsburskiy <skinsbursky@virtuozzo.com>
> > > ---
> > >   net/sunrpc/sched.c |    1 -
> > >   1 file changed, 1 deletion(-)
> > > 
> > > diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
> > > index 9ae5885..ec7ccc1 100644
> > > --- a/net/sunrpc/sched.c
> > > +++ b/net/sunrpc/sched.c
> > > @@ -253,7 +253,6 @@ EXPORT_SYMBOL_GPL(rpc_destroy_wait_queue);
> > >   
> > >   static int rpc_wait_bit_killable(struct wait_bit_key *key, int mode)
> > >   {
> > > > > > -	freezable_schedule_unsafe();
> > > > > >   	if (signal_pending_state(mode, current))
> > > > > >   		return -ERESTARTSYS;
> > > > > >   	return 0;
> > > 
> > Ummm...so what actually does the schedule() with this patch?
> 
> Schedule() replaces freezable_schedule_unsafe() of course, sorry for this.
> 
> > 
> > There was a bit of discussion on this recently -- see the thread with
> > this subject line in linux-nfs:
> > 
> >      Re: Hang due to nfs letting tasks freeze with locked inodes
> 
> Thanks, had a look.
> 
> > 
> > Basically it comes down to this:
> > 
> > All of the proposals so far to fix this problem just switch out the
> > freezable_schedule_unsafe (and similar) calls for those that don't
> > allow the process to freeze.
> > 
> > The problem there is that we originally added that stuff in response to
> > bug reports about machines failing to suspend. What often happens is
> > that the network interfaces come down, and then the freezer runs over
> > all of the processes, which never return because they're blocked
> > waiting on the server to reply.
> 
> I probably don't understand something, but this sounds somewhat wrong to 
> me: freezing processes _after_ network is down.
> 
> 
> > 
> > 
> > ...shrug...
> > 
> > Maybe we should just go ahead and do it (and to CIFS as well). Just be
> > prepared for the inevitable complaints about laptops failing to suspend
> > once you do.
> 
> The worst part in all of this, from my POW, is that current behavior
> makes NFS non-freezable in a generic case, even in case of freezing a
> container, which has it's own net ns and NFS mount.
> So, I would say, that returning of previous logic would make the
> world better.
> 
> > 
> > Part of the fix, I think is to add a return code (similar to
> > ERESTARTSYS) that gets interpreted near the kernel-userland boundary
> > as: "allow the process to be frozen, and then retry the call once it's
> > resumed".
> > 
> > With that, filesystems could return the error code when they want to
> > redrive the entire syscall from that level. That won't work for non-
> > idempotent requests though. We'd need to do something more elaborate
> > there.
> > 
> 
> Might be, that breaking rpc request is something that should be avoided 
> at all.
> With all these locks being held, almost all (any?) of the requests to 
> remote server
> should be considered as an atomic operation from freezer point of view.
> The process always can be frozen on signal handling.
> 
> IOW, I might worth considering a scenario, when NFS is not freezable at all,
> and any problems with suspend on laptops/whatever have to solved in 
> suspend code.
> 
> 

Fair enough. At this point, I don't care much one way or another. Maybe
if we make this change and laptops start failing to suspend, we'll be
able to use that as leverage pursue other avenues to make the
suspend/resume subsystem work with NFS.

That said, the patch you have really isn't sufficient. There are places
where the NFS client can sleep while waiting for things other than RPC
calls.

I think what you'd want is something like the patch below. This also
has a similar delta for cifs.ko, which will have similar problems.

You can pick these from here as well:

     https://git.samba.org/?p=jlayton/linux.git;a=shortlog;h=refs/heads/netfs-freeze

This is untested, of course, and we can probably eliminate some of the
_freezable_ macros with this change as well.

Trond, Anna...what are your thoughts here?

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index fcfd48d263f6..ac1cf968a07d 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -252,7 +252,7 @@ EXPORT_SYMBOL_GPL(rpc_destroy_wait_queue);
 
 static int rpc_wait_bit_killable(struct wait_bit_key *key, int mode)
 {
-	freezable_schedule_unsafe();
+	schedule();
 	if (signal_pending_state(mode, current))
 		return -ERESTARTSYS;
 	return 0;
diff --git a/fs/cifs/inode.c b/fs/cifs/inode.c
index b87efd0c92d6..7707df9d5ca7 100644
--- a/fs/cifs/inode.c
+++ b/fs/cifs/inode.c
@@ -22,7 +22,6 @@
 #include <linux/stat.h>
 #include <linux/slab.h>
 #include <linux/pagemap.h>
-#include <linux/freezer.h>
 #include <asm/div64.h>
 #include "cifsfs.h"
 #include "cifspdu.h"
@@ -1871,7 +1870,7 @@ cifs_invalidate_mapping(struct inode *inode)
 static int
 cifs_wait_bit_killable(struct wait_bit_key *key, int mode)
 {
-	freezable_schedule_unsafe();
+	schedule();
 	if (signal_pending_state(mode, current))
 		return -ERESTARTSYS;
 	return 0;
diff --git a/fs/cifs/transport.c b/fs/cifs/transport.c
index 206a597b2293..5ec700e9d7ed 100644
--- a/fs/cifs/transport.c
+++ b/fs/cifs/transport.c
@@ -26,7 +26,6 @@
 #include <linux/wait.h>
 #include <linux/net.h>
 #include <linux/delay.h>
-#include <linux/freezer.h>
 #include <linux/tcp.h>
 #include <linux/highmem.h>
 #include <asm/uaccess.h>
@@ -438,7 +437,7 @@ wait_for_response(struct TCP_Server_Info *server, struct mid_q_entry *midQ)
 {
 	int error;
 
-	error = wait_event_freezekillable_unsafe(server->response_q,
+	error = wait_event_killable(server->response_q,
 				    midQ->mid_state != MID_REQUEST_SUBMITTED);
 	if (error < 0)
 		return -ERESTARTSYS;
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index bf4ec5ecc97e..b9f31854db7a 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -37,7 +37,6 @@
 #include <linux/nfs_xdr.h>
 #include <linux/slab.h>
 #include <linux/compat.h>
-#include <linux/freezer.h>
 
 #include <asm/uaccess.h>
 
@@ -73,7 +72,7 @@ nfs_fattr_to_ino_t(struct nfs_fattr *fattr)
 
 static int nfs_wait_killable(int mode)
 {
-	freezable_schedule_unsafe();
+	schedule();
 	if (signal_pending_state(mode, current))
 		return -ERESTARTSYS;
 	return 0;
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index cb28cceefebe..f938d245f256 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -17,7 +17,6 @@
 #include <linux/nfs_page.h>
 #include <linux/lockd/bind.h>
 #include <linux/nfs_mount.h>
-#include <linux/freezer.h>
 #include <linux/xattr.h>
 
 #include "iostat.h"
@@ -35,7 +34,7 @@ nfs3_rpc_wrapper(struct rpc_clnt *clnt, struct rpc_message *msg, int flags)
 		res = rpc_call_sync(clnt, msg, flags);
 		if (res != -EJUKEBOX)
 			break;
-		freezable_schedule_timeout_killable_unsafe(NFS_JUKEBOX_RETRY_TIME);
+		schedule_timeout_killable(NFS_JUKEBOX_RETRY_TIME);
 		res = -ERESTARTSYS;
 	} while (!fatal_signal_pending(current));
 	return res;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index da5c9e58e907..304b080c519b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -54,7 +54,6 @@
 #include <linux/module.h>
 #include <linux/xattr.h>
 #include <linux/utsname.h>
-#include <linux/freezer.h>
 
 #include "nfs4_fs.h"
 #include "delegation.h"
@@ -348,8 +347,7 @@ static int nfs4_delay(struct rpc_clnt *clnt, long *timeout)
 
 	might_sleep();
 
-	freezable_schedule_timeout_killable_unsafe(
-		nfs4_update_delay(timeout));
+	schedule_timeout_killable(nfs4_update_delay(timeout));
 	if (fatal_signal_pending(current))
 		res = -ERESTARTSYS;
 	return res;
@@ -5484,7 +5482,7 @@ int nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4
 static unsigned long
 nfs4_set_lock_task_retry(unsigned long timeout)
 {
-	freezable_schedule_timeout_killable_unsafe(timeout);
+	schedule_timeout_killable(timeout);
 	timeout <<= 1;
 	if (timeout > NFS4_LOCK_MAXTIMEOUT)
 		return NFS4_LOCK_MAXTIMEOUT;
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 9ae588511aaf..73946acc01d2 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -18,7 +18,6 @@
 #include <linux/smp.h>
 #include <linux/spinlock.h>
 #include <linux/mutex.h>
-#include <linux/freezer.h>
 
 #include <linux/sunrpc/clnt.h>
 
@@ -253,7 +252,7 @@ EXPORT_SYMBOL_GPL(rpc_destroy_wait_queue);
 
 static int rpc_wait_bit_killable(struct wait_bit_key *key, int mode)
 {
-	freezable_schedule_unsafe();
+	schedule();
 	if (signal_pending_state(mode, current))
 		return -ERESTARTSYS;
 	return 0;


-- 
Jeff Layton <jlayton@redhat.com>
