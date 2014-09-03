Return-Path: linux-nfs-owner@vger.kernel.org
Received: from api.opinsys.fi ([217.112.254.4]:57842 "EHLO mail.opinsys.fi"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751598AbaICHJM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Sep 2014 03:09:12 -0400
Date: Wed, 3 Sep 2014 07:01:32 +0000 (UTC)
From: Tuomas =?utf-8?B?UsOkc8OkbmVu?= <tuomasjjrasanen@opinsys.fi>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>, linux-nfs@vger.kernel.org
Message-ID: <927052272.63158.1409727692986.JavaMail.zimbra@opinsys.fi>
In-Reply-To: <1726881404.72983.1402308693418.JavaMail.zimbra@opinsys.fi>
References: <199810131.34257.1400570367382.JavaMail.zimbra@opinsys.fi> <1176115795.34522.1400575248541.JavaMail.zimbra@opinsys.fi> <20140520102117.2582abac@tlielax.poochiereds.net> <2137177707.38241.1400684149690.JavaMail.zimbra@opinsys.fi> <20140521165304.4331255d@tlielax.poochiereds.net> <1726881404.72983.1402308693418.JavaMail.zimbra@opinsys.fi>
Subject: Re: Soft lockups on kerberised NFSv4.0 clients
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

----- Original Message -----
> From: "Tuomas Räsänen" <tuomasjjrasanen@opinsys.fi>
> 
> ----- Original Message -----
> > From: "Jeff Layton" <jlayton@poochiereds.net>
> > 
> > Ok, now that I look closer at your stack trace the problem appears to
> > be that the unlock code is waiting for the lock context's io_count to
> > drop to zero before allowing the unlock to proceed.
> > 
> > That likely means that there is some outstanding I/O that isn't
> > completing, but it's possible that the problem is the CB_RECALL is
> > being ignored. This will probably require some analysis of wire captures.
> 
> The lockup mechnism seems to be as follows: the process (which is always
> firefox) is killed, and it tries to unlock the file (which is always a
> mmapped sqlite3 WAL index) which still has some pending IOs going on. The
> return value of nfs_wait_bit_killable() (-ERESTARTSYS from
> fatal_signal_pending(current)) is ignored and the process just keeps looṕing
> because io_count seems to be stuck at 1 (I still don't know why..). This
> raised few questions:
> 
> Why the return value of nfs_wait_bit_killable() is not handled? Should it be
> handled and if yes, how?
> 
> Why the whole iocounter wait is not just implemented using wait_on_bit()?
> 
> I changed do_unlk() to use wait_on_bit() instead of nfs_iocounter_wait() and
> softlockups seem to have disappeared:
> 
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index 284ca90..eb41b32 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -781,7 +781,11 @@ do_unlk(struct file *filp, int cmd, struct file_lock
> *fl, int is_local)
>  
>         l_ctx = nfs_get_lock_context(nfs_file_open_context(filp));
>         if (!IS_ERR(l_ctx)) {
> -               status = nfs_iocounter_wait(&l_ctx->io_count);
> +               struct nfs_io_counter *io_count = &l_ctx->io_count;
> +               status = wait_on_bit(&io_count->flags,
> +                                    NFS_IO_INPROGRESS,
> +                                    nfs_wait_bit_killable,
> +                                    TASK_KILLABLE);
>                 nfs_put_lock_context(l_ctx);
>                 if (status < 0)
>                         return status;
> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
> index 2ffebf2..6b9089c 100644
> --- a/fs/nfs/pagelist.c
> +++ b/fs/nfs/pagelist.c
> @@ -87,6 +87,7 @@ nfs_page_free(struct nfs_page *p)
>  static void
>  nfs_iocounter_inc(struct nfs_io_counter *c)
>  {
> +       set_bit(NFS_IO_INPROGRESS, &c->flags);
>         atomic_inc(&c->io_count);
>  }
>  
> Any thoughts? I really want to understand the issue at hand and to help
> fixing it properly.

The same kind of patch was proposed by David Jeffery in http://www.spinics.net/lists/linux-nfs/msg45806.html and the discussion in that thread answered lot of my questions.

The proposed patch was not accepted but David's another patch fixes the softlockup symptom (as tested with jam.c) as well: http://www.spinics.net/lists/linux-nfs/msg45807.html

Case closed.

-- 
Tuomas
