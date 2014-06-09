Return-Path: linux-nfs-owner@vger.kernel.org
Received: from api.opinsys.fi ([217.112.254.4]:35422 "EHLO mail.opinsys.fi"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752770AbaFIKKD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jun 2014 06:10:03 -0400
Date: Mon, 9 Jun 2014 10:11:33 +0000 (UTC)
From: Tuomas =?utf-8?B?UsOkc8OkbmVu?= <tuomasjjrasanen@opinsys.fi>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>, linux-nfs@vger.kernel.org
Message-ID: <1726881404.72983.1402308693418.JavaMail.zimbra@opinsys.fi>
In-Reply-To: <20140521165304.4331255d@tlielax.poochiereds.net>
References: <199810131.34257.1400570367382.JavaMail.zimbra@opinsys.fi> <1176115795.34522.1400575248541.JavaMail.zimbra@opinsys.fi> <20140520102117.2582abac@tlielax.poochiereds.net> <2137177707.38241.1400684149690.JavaMail.zimbra@opinsys.fi> <20140521165304.4331255d@tlielax.poochiereds.net>
Subject: Re: Soft lockups on kerberised NFSv4.0 clients
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

----- Original Message -----
> From: "Jeff Layton" <jlayton@poochiereds.net>
> 
> Ok, now that I look closer at your stack trace the problem appears to
> be that the unlock code is waiting for the lock context's io_count to
> drop to zero before allowing the unlock to proceed.
> 
> That likely means that there is some outstanding I/O that isn't
> completing, but it's possible that the problem is the CB_RECALL is
> being ignored. This will probably require some analysis of wire captures.

Examining wire captures did not lead to anything concrete, so I tried to approach the problem from another angle, by examining the actual symptom, the softlockup. As you said, the stack trace seems to indicate that there are some pending IOs on the file the process is trying to unlock and the process keeps spinning inside __nfs_iocounter_wait().

static int
__nfs_iocounter_wait(struct nfs_io_counter *c)
{
        wait_queue_head_t *wq = bit_waitqueue(&c->flags, NFS_IO_INPROGRESS);
        DEFINE_WAIT_BIT(q, &c->flags, NFS_IO_INPROGRESS);
        int ret = 0;

        do {
                prepare_to_wait(wq, &q.wait, TASK_KILLABLE);
                set_bit(NFS_IO_INPROGRESS, &c->flags);
                if (atomic_read(&c->io_count) == 0)
		        break;
                ret = nfs_wait_bit_killable(&c->flags);
        } while (atomic_read(&c->io_count) != 0);
        finish_wait(wq, &q.wait);
        return ret;
}

The lockup mechnism seems to be as follows: the process (which is always firefox) is killed, and it tries to unlock the file (which is always a mmapped sqlite3 WAL index) which still has some pending IOs going on. The return value of nfs_wait_bit_killable() (-ERESTARTSYS from fatal_signal_pending(current)) is ignored and the process just keeps looṕing because io_count seems to be stuck at 1 (I still don't know why..). This raised few questions:

Why the return value of nfs_wait_bit_killable() is not handled? Should it be handled and if yes, how? 

Why the whole iocounter wait is not just implemented using wait_on_bit()?

I changed do_unlk() to use wait_on_bit() instead of nfs_iocounter_wait() and softlockups seem to have disappeared:

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 284ca90..eb41b32 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -781,7 +781,11 @@ do_unlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 
        l_ctx = nfs_get_lock_context(nfs_file_open_context(filp));
        if (!IS_ERR(l_ctx)) {
-               status = nfs_iocounter_wait(&l_ctx->io_count);
+               struct nfs_io_counter *io_count = &l_ctx->io_count;
+               status = wait_on_bit(&io_count->flags,
+                                    NFS_IO_INPROGRESS,
+                                    nfs_wait_bit_killable,
+                                    TASK_KILLABLE);
                nfs_put_lock_context(l_ctx);
                if (status < 0)
                        return status;
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 2ffebf2..6b9089c 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -87,6 +87,7 @@ nfs_page_free(struct nfs_page *p)
 static void
 nfs_iocounter_inc(struct nfs_io_counter *c)
 {
+       set_bit(NFS_IO_INPROGRESS, &c->flags);
        atomic_inc(&c->io_count);
 }
 
Any thoughts? I really want to understand the issue at hand and to help fixing it properly.

-- 
Tuomas
