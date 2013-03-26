Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38318 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933497Ab3CZOql (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Mar 2013 10:46:41 -0400
Date: Tue, 26 Mar 2013 10:46:40 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Toralf =?utf-8?Q?F=C3=B6rster?= <toralf.foerster@gmx.de>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>
Subject: Re: kernel 3.8.4 : kernel BUG at fs/locks.c:2093!   part #2
Message-ID: <20130326144640.GB3353@fieldses.org>
References: <514F31AF.3080709@gmx.de>
 <20130325220143.GD10887@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20130325220143.GD10887@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 25, 2013 at 06:01:43PM -0400, bfields wrote:
> On Sun, Mar 24, 2013 at 06:02:39PM +0100, Toralf Förster wrote:
> > The following bug was triggered twice under a stable 3.8.4 kernel if I export a NFS (v4) directory
> > and mount it within a user mode linux (running at the same system) and run within that UML trinity
> > (16 UML trinity processes at a 4-core host CPU) with victim files+directories within that NFS directory.
> > 
> > I could not trigger that bug at the host kernel if I run trinity within UML without victim files
> > - therefore the issue seems to be tied to NFS. The syslog messages are :
> 
> Thanks!
> 
> fs/locks.c:2093 says that we did the final fput of a file that still had
> posix locks held on it.
> 
> I can't see how that would happen, but admittedly the nfsd4 code here is
> much too complicated for its own good.
> 
> If it were possible it would be useful to know what lead up to this.  A
> network trace (tcpdump -s0 -wtmp.pcap, then send me tmp.pcap) would be
> useful for that, but I fear it's probably too huge by the time you hit
> the bug.
> 
> (The following warning ("rcu_sched self-detected stall") looks like the
> result of BUGing while holding file_lock_lock.  That BUG should probably
> be downgraded to a WARN_ON_ONCE.)

Can you run with test patches?

This just makes nfsd's fput calls synchronous so that we see in the
backtrace who called them.

(But assuming it does turn out to be one of these callers, we may then
need some more printk's in the nfsd code...).

--b.

commit 27a3395a72e1d9be121f5493e7a330d60b3d1de3
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Tue Mar 26 09:37:07 2013 -0400

    nfsd4: convert fput to fput_sync for debugging purposes
    
    Just a temporary hack to get backtraces out of __fput failures.
    
    Also, demote a BUG to a WARN_ON_ONCE.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/file_table.c b/fs/file_table.c
index de9e965..79cb999 100644
--- a/fs/file_table.c
+++ b/fs/file_table.c
@@ -337,6 +337,8 @@ void __fput_sync(struct file *file)
 	}
 }
 
+EXPORT_SYMBOL(__fput_sync);
+
 EXPORT_SYMBOL(fput);
 
 void put_filp(struct file *file)
diff --git a/fs/locks.c b/fs/locks.c
index a94e331..c962161 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -2090,7 +2090,7 @@ void locks_remove_flock(struct file *filp)
 				continue;
 			}
 			/* What? */
-			BUG();
+			WARN_ON_ONCE(1);
  		}
 		before = &fl->fl_next;
 	}
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 9d1c5db..c01c60c 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -951,7 +951,7 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 			     write->wr_offset, rqstp->rq_vec, nvecs,
 			     &cnt, &write->wr_how_written);
 	if (filp)
-		fput(filp);
+		__fput_sync(filp);
 
 	write->wr_bytes_written = cnt;
 
@@ -1325,7 +1325,7 @@ encode_op:
 		}
 		/* XXX Ugh, we need to get rid of this kind of special case: */
 		if (op->opnum == OP_READ && op->u.read.rd_filp)
-			fput(op->u.read.rd_filp);
+			__fput_sync(op->u.read.rd_filp);
 
 		nfsd4_increment_op_stats(op->opnum);
 	}
diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index ba6fdd4..dfdf54c 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -546,7 +546,7 @@ nfsd4_shutdown_recdir(struct nfsd_net *nn)
 {
 	if (!nn->rec_file)
 		return;
-	fput(nn->rec_file);
+	__fput_sync(nn->rec_file);
 	nn->rec_file = NULL;
 }
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a8309c6..0f38b39 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -201,7 +201,7 @@ static void nfs4_file_get_access(struct nfs4_file *fp, int oflag)
 static void nfs4_file_put_fd(struct nfs4_file *fp, int oflag)
 {
 	if (fp->fi_fds[oflag]) {
-		fput(fp->fi_fds[oflag]);
+		__fput_sync(fp->fi_fds[oflag]);
 		fp->fi_fds[oflag] = NULL;
 	}
 }
@@ -353,7 +353,7 @@ static void nfs4_put_deleg_lease(struct nfs4_file *fp)
 	if (atomic_dec_and_test(&fp->fi_delegees)) {
 		vfs_setlease(fp->fi_deleg_file, F_UNLCK, &fp->fi_lease);
 		fp->fi_lease = NULL;
-		fput(fp->fi_deleg_file);
+		__fput_sync(fp->fi_deleg_file);
 		fp->fi_deleg_file = NULL;
 	}
 }
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index d586117..76bb67c 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -826,7 +826,7 @@ out:
 void
 nfsd_close(struct file *filp)
 {
-	fput(filp);
+	__fput_sync(filp);
 }
 
 /*
