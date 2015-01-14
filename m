Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f169.google.com ([209.85.216.169]:48249 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751996AbbANR15 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Jan 2015 12:27:57 -0500
Received: by mail-qc0-f169.google.com with SMTP id w7so8275213qcr.0
        for <linux-nfs@vger.kernel.org>; Wed, 14 Jan 2015 09:27:56 -0800 (PST)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Wed, 14 Jan 2015 12:27:51 -0500
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Bruce Fields <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: don't call blocking operations while !TASK_RUNNING
Message-ID: <20150114122751.0e1ac594@tlielax.poochiereds.net>
In-Reply-To: <CAHQdGtSgcy_wAOCiNJwutLOC-e2t4RxyVRV5pOQP5JeboR_FGg@mail.gmail.com>
References: <1421249572-12038-1-git-send-email-jlayton@primarydata.com>
	<CAHQdGtSgcy_wAOCiNJwutLOC-e2t4RxyVRV5pOQP5JeboR_FGg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 14 Jan 2015 12:13:43 -0500
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> On Wed, Jan 14, 2015 at 10:32 AM, Jeff Layton <jlayton@primarydata.com> wrote:
> > Bruce reported seeing this warning pop when mounting using v4.1:
> >
> >      ------------[ cut here ]------------
> >      WARNING: CPU: 1 PID: 1121 at kernel/sched/core.c:7300 __might_sleep+0xbd/0xd0()
> >     do not call blocking ops when !TASK_RUNNING; state=1 set at [<ffffffff810ff58f>] prepare_to_wait+0x2f/0x90
> >     Modules linked in: rpcsec_gss_krb5 auth_rpcgss nfsv4 dns_resolver nfs lockd grace sunrpc fscache ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 xt_conntrack ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_security ip6table_raw ip6table_filter ip6_tables iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_security iptable_raw snd_hda_codec_generic snd_hda_intel snd_hda_controller snd_hda_codec snd_hwdep snd_pcm snd_timer ppdev joydev snd virtio_console virtio_balloon pcspkr serio_raw parport_pc parport pvpanic floppy soundcore i2c_piix4 virtio_blk virtio_net qxl drm_kms_helper ttm drm virtio_pci virtio_ring ata_generic virtio pata_acpi
> >     CPU: 1 PID: 1121 Comm: nfsv4.1-svc Not tainted 3.19.0-rc4+ #25
> >     Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140709_153950- 04/01/2014
> >      0000000000000000 000000004e5e3f73 ffff8800b998fb48 ffffffff8186ac78
> >      0000000000000000 ffff8800b998fba0 ffff8800b998fb88 ffffffff810ac9da
> >      ffff8800b998fb68 ffffffff81c923e7 00000000000004d9 0000000000000000
> >     Call Trace:
> >      [<ffffffff8186ac78>] dump_stack+0x4c/0x65
> >      [<ffffffff810ac9da>] warn_slowpath_common+0x8a/0xc0
> >      [<ffffffff810aca65>] warn_slowpath_fmt+0x55/0x70
> >      [<ffffffff810ff58f>] ? prepare_to_wait+0x2f/0x90
> >      [<ffffffff810ff58f>] ? prepare_to_wait+0x2f/0x90
> >      [<ffffffff810dd2ad>] __might_sleep+0xbd/0xd0
> >      [<ffffffff8124c973>] kmem_cache_alloc_trace+0x243/0x430
> >      [<ffffffff810d941e>] ? groups_alloc+0x3e/0x130
> >      [<ffffffff810d941e>] groups_alloc+0x3e/0x130
> >      [<ffffffffa0301b1e>] svcauth_unix_accept+0x16e/0x290 [sunrpc]
> >      [<ffffffffa0300571>] svc_authenticate+0xe1/0xf0 [sunrpc]
> >      [<ffffffffa02fc564>] svc_process_common+0x244/0x6a0 [sunrpc]
> >      [<ffffffffa02fd044>] bc_svc_process+0x1c4/0x260 [sunrpc]
> >      [<ffffffffa03d5478>] nfs41_callback_svc+0x128/0x1f0 [nfsv4]
> >      [<ffffffff810ff970>] ? wait_woken+0xc0/0xc0
> >      [<ffffffffa03d5350>] ? nfs4_callback_svc+0x60/0x60 [nfsv4]
> >      [<ffffffff810d45bf>] kthread+0x11f/0x140
> >      [<ffffffff810ea815>] ? local_clock+0x15/0x30
> >      [<ffffffff810d44a0>] ? kthread_create_on_node+0x250/0x250
> >      [<ffffffff81874bfc>] ret_from_fork+0x7c/0xb0
> >      [<ffffffff810d44a0>] ? kthread_create_on_node+0x250/0x250
> >     ---[ end trace 675220a11e30f4f2 ]---
> >
> > nfs41_callback_svc does most of its work while in TASK_INTERRUPTIBLE,
> > which is just wrong. Fix that by finishing the wait immediately if we've
> > found that the list has something on it.
> 
> ACK.
> 
> > Also, we don't expect this kthread to accept signals, so we should be
> > using a TASK_UNINTERRUPTIBLE sleep instead.
> 
> Umm... Won't that end up triggering the hung task watchdog for every
> 120seconds with no callback activity?
> 

Doh! You're correct.

What's the right way to do this then? Do we need to use
schedule_timeout and wake up every 100s or so? Using TASK_INTERRUPTIBLE
to work around the watchdog seems wrong but I guess we can live with
that in the short term if it's the only way.

Long-term, it would probably make sense to convert this (and other
service threads like this) over to workqueue-based services. I
still need to chase down where the latency comes from before that
patchset is ready for merge though.

> > Reported-by: "J. Bruce Fields" <bfields@fieldses.org>
> > Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> > ---
> >  fs/nfs/callback.c | 5 +++--
> >  1 file changed, 3 insertions(+), 2 deletions(-)
> >
> > diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> > index b8fb3a4ef649..ebba958e084c 100644
> > --- a/fs/nfs/callback.c
> > +++ b/fs/nfs/callback.c
> > @@ -128,13 +128,14 @@ nfs41_callback_svc(void *vrqstp)
> >                 if (try_to_freeze())
> >                         continue;
> >
> > -               prepare_to_wait(&serv->sv_cb_waitq, &wq,
> > TASK_INTERRUPTIBLE);
> > +               prepare_to_wait(&serv->sv_cb_waitq, &wq,
> > TASK_UNINTERRUPTIBLE); spin_lock_bh(&serv->sv_cb_lock);
> >                 if (!list_empty(&serv->sv_cb_list)) {
> >                         req = list_first_entry(&serv->sv_cb_list,
> >                                         struct rpc_rqst,
> > rq_bc_list); list_del(&req->rq_bc_list);
> >                         spin_unlock_bh(&serv->sv_cb_lock);
> > +                       finish_wait(&serv->sv_cb_waitq, &wq);
> >                         dprintk("Invoking bc_svc_process()\n");
> >                         error = bc_svc_process(serv, req, rqstp);
> >                         dprintk("bc_svc_process() returned w/ error
> > code= %d\n", @@ -142,8 +143,8 @@ nfs41_callback_svc(void *vrqstp)
> >                 } else {
> >                         spin_unlock_bh(&serv->sv_cb_lock);
> >                         schedule();
> > +                       finish_wait(&serv->sv_cb_waitq, &wq);
> >                 }
> > -               finish_wait(&serv->sv_cb_waitq, &wq);
> >         }
> >         return 0;
> >  }
> > --
> > 2.1.0
> >
> 
> 
> 


-- 
Jeff Layton <jlayton@primarydata.com>
