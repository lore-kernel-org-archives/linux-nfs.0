Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:35695 "EHLO
	mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755042AbcGHMrL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jul 2016 08:47:11 -0400
Received: by mail-oi0-f45.google.com with SMTP id r2so59447687oih.2
        for <linux-nfs@vger.kernel.org>; Fri, 08 Jul 2016 05:47:11 -0700 (PDT)
Date: Fri, 8 Jul 2016 07:47:08 -0500
From: Seth Forshee <seth.forshee@canonical.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Tycho Andersen <tycho.andersen@canonical.com>
Subject: Re: Hang due to nfs letting tasks freeze with locked inodes
Message-ID: <20160708124708.GA16921@ubuntu-hedt>
References: <20160706174655.GD45215@ubuntu-hedt>
 <1467842838.2908.45.camel@redhat.com>
 <20160708122224.GA20200@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20160708122224.GA20200@dhcp22.suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 08, 2016 at 02:22:24PM +0200, Michal Hocko wrote:
> On Wed 06-07-16 18:07:18, Jeff Layton wrote:
> > On Wed, 2016-07-06 at 12:46 -0500, Seth Forshee wrote:
> > > We're seeing a hang when freezing a container with an nfs bind mount while
> > > running iozone. Two iozone processes were hung with this stack trace.
> > > 
> > >  [] schedule+0x35/0x80
> > >  [] schedule_preempt_disabled+0xe/0x10
> > >  [] __mutex_lock_slowpath+0xb9/0x130
> > >  [] mutex_lock+0x1f/0x30
> > >  [] do_unlinkat+0x12b/0x2d0
> > >  [] SyS_unlink+0x16/0x20
> > >  [] entry_SYSCALL_64_fastpath+0x16/0x71
> > > 
> > > This seems to be due to another iozone thread frozen during unlink with
> > > this stack trace:
> > > 
> > >  [] __refrigerator+0x7a/0x140
> > >  [] nfs4_handle_exception+0x118/0x130 [nfsv4]
> > >  [] nfs4_proc_remove+0x7d/0xf0 [nfsv4]
> > >  [] nfs_unlink+0x149/0x350 [nfs]
> > >  [] vfs_unlink+0xf1/0x1a0
> > >  [] do_unlinkat+0x279/0x2d0
> > >  [] SyS_unlink+0x16/0x20
> > >  [] entry_SYSCALL_64_fastpath+0x16/0x71
> > > 
> > > Since nfs is allowing the thread to be frozen with the inode locked it's
> > > preventing other threads trying to lock the same inode from freezing. It
> > > seems like a bad idea for nfs to be doing this.
> > > 
> > 
> > Yeah, known problem. Not a simple one to fix though.
> 
> Apart from alternative Dave was mentioning in other email, what is the
> point to use freezable wait from this path in the first place?
> 
> nfs4_handle_exception does nfs4_wait_clnt_recover from the same path and
> that does wait_on_bit_action with TASK_KILLABLE so we are waiting in two
> different modes from the same path AFAICS. There do not seem to be other
> callers of nfs4_delay outside of nfs4_handle_exception. Sounds like
> something is not quite right here to me. If the nfs4_delay did regular
> wait then the freezing would fail as well but at least it would be clear
> who is the culrprit rather than having an indirect dependency.

It turns out there are more paths than this one doing a freezable wait,
and they're all also killable. This leads me to a slightly different
question than yours, why nfs can give up waiting in the case of a signal
but not when the task is frozen.

I know the changes below aren't "correct," but I've been experimenting
with them anyway to see what would happen. So far things seem to be
fine, and the deadlock is gone. That should give you an idea of all the
places I found using a freezable wait.

Seth


diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index f714b98..62dbe59 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -77,8 +77,8 @@ nfs_fattr_to_ino_t(struct nfs_fattr *fattr)
  */
 int nfs_wait_bit_killable(struct wait_bit_key *key, int mode)
 {
-	freezable_schedule_unsafe();
-	if (signal_pending_state(mode, current))
+	schedule();
+	if (signal_pending_state(mode, current) || freezing(current))
 		return -ERESTARTSYS;
 	return 0;
 }
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index cb28cce..2315183 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -35,9 +35,9 @@ nfs3_rpc_wrapper(struct rpc_clnt *clnt, struct rpc_message *msg, int flags)
 		res = rpc_call_sync(clnt, msg, flags);
 		if (res != -EJUKEBOX)
 			break;
-		freezable_schedule_timeout_killable_unsafe(NFS_JUKEBOX_RETRY_TIME);
+		schedule_timeout_killable(NFS_JUKEBOX_RETRY_TIME);
 		res = -ERESTARTSYS;
-	} while (!fatal_signal_pending(current));
+	} while (!fatal_signal_pending(current) && !freezing(current));
 	return res;
 }
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 98a4415..0dad2fb 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -334,9 +334,8 @@ static int nfs4_delay(struct rpc_clnt *clnt, long *timeout)
 
 	might_sleep();
 
-	freezable_schedule_timeout_killable_unsafe(
-		nfs4_update_delay(timeout));
-	if (fatal_signal_pending(current))
+	schedule_timeout_killable(nfs4_update_delay(timeout));
+	if (fatal_signal_pending(current) || freezing(current))
 		res = -ERESTARTSYS;
 	return res;
 }
@@ -5447,7 +5446,7 @@ int nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4
 static unsigned long
 nfs4_set_lock_task_retry(unsigned long timeout)
 {
-	freezable_schedule_timeout_killable_unsafe(timeout);
+	schedule_timeout_killable(timeout);
 	timeout <<= 1;
 	if (timeout > NFS4_LOCK_MAXTIMEOUT)
 		return NFS4_LOCK_MAXTIMEOUT;
@@ -6148,7 +6147,7 @@ nfs4_proc_lock(struct file *filp, int cmd, struct file_lock *request)
 			break;
 		timeout = nfs4_set_lock_task_retry(timeout);
 		status = -ERESTARTSYS;
-		if (signalled())
+		if (signalled() || freezing(current))
 			break;
 	} while(status < 0);
 	return status;
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 73ad57a..0218dc2 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -252,8 +252,8 @@ EXPORT_SYMBOL_GPL(rpc_destroy_wait_queue);
 
 static int rpc_wait_bit_killable(struct wait_bit_key *key, int mode)
 {
-	freezable_schedule_unsafe();
-	if (signal_pending_state(mode, current))
+	schedule();
+	if (signal_pending_state(mode, current) || freezing(current))
 		return -ERESTARTSYS;
 	return 0;
 }
