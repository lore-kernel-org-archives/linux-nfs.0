Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f51.google.com ([209.85.192.51]:42675 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751691AbbATMYG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jan 2015 07:24:06 -0500
Received: by mail-qg0-f51.google.com with SMTP id z107so7516454qgd.10
        for <linux-nfs@vger.kernel.org>; Tue, 20 Jan 2015 04:24:04 -0800 (PST)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 20 Jan 2015 07:23:59 -0500
To: Junxiao Bi <junxiao.bi@oracle.com>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Bruce Fields <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd: fix memory corruption due to uninitialized
 variable
Message-ID: <20150120072359.70053ddf@tlielax.poochiereds.net>
In-Reply-To: <54BE40DB.4070801@oracle.com>
References: <1421584142-12505-1-git-send-email-junxiao.bi@oracle.com>
	<CAHQdGtTs6B93fi4TAL86f02cD7OE5zzWgk8tCa6ZOyKQ9Bd7Eg@mail.gmail.com>
	<54BC5B3F.9080004@oracle.com>
	<20150119092953.2584b496@tlielax.poochiereds.net>
	<54BE40DB.4070801@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 20 Jan 2015 19:49:47 +0800
Junxiao Bi <junxiao.bi@oracle.com> wrote:

> On 01/19/2015 10:29 PM, Jeff Layton wrote:
> > On Mon, 19 Jan 2015 09:17:51 +0800
> > Junxiao Bi <junxiao.bi@oracle.com> wrote:
> >
> >> On 01/18/2015 10:43 PM, Trond Myklebust wrote:
> >>> On Sun, Jan 18, 2015 at 7:29 AM, Junxiao Bi <junxiao.bi@oracle.com> wrote:
> >>>> nfsd4_decode_open() doesn't initialize variable open->op_file and
> >>>> open->op_stp, they are initialized in nfsd4_process_open1(), but if
> >>>> any error happens before initializing them, nfsd4_open() will call
> >>>> into nfsd4_cleanup_open_state() and corrupt the memory.
> >>>>
> >>>> Since nfsd4_process_open1() will initialize these two variables and
> >>>> open->op_openowner, make them default to null at the beginning.
> >>>>
> >>>> Signed-off-by: Junxiao Bi <junxiao.bi@oracle.com>
> >>>> ---
> >>>>   fs/nfsd/nfs4state.c |    4 ++++
> >>>>   1 file changed, 4 insertions(+)
> >>>>
> >>>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> >>>> index c06a1ba..6e74a91 100644
> >>>> --- a/fs/nfsd/nfs4state.c
> >>>> +++ b/fs/nfsd/nfs4state.c
> >>>> @@ -3547,6 +3547,10 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
> >>>>          struct nfs4_openowner *oo = NULL;
> >>>>          __be32 status;
> >>>>
> >>>> +       open->op_file = NULL;
> >>>> +       open->op_openowner = NULL;
> >>>> +       open->op_stp = NULL;
> >>>> +
> >>>>          if (STALE_CLIENTID(&open->op_clientid, nn))
> >>>>                  return nfserr_stale_clientid;
> >>>>          /*
> >>> Have you ever seen an instance of this corruption? I would have
> >>> thought that the kzalloc() in nfsd4_decode_compound() and/or the
> >>> earlier memset() in svc_process_common() would ensure that these
> >>> fields are always initialised to NULL.
> >> Yes, we got the following panic from 3.8.13. The bad pointer
> >> open->op_stp was freed into kmem_cache array_cache, and was allocated to
> >> next "op_stp" allocation request which triggered the panic.
> >>
> >>
> >> @ PID: 21663  TASK: ffff8809fe6103c0  CPU: 0   COMMAND: "nfsd"
> >> @ #0 [ffff8809fe613980] machine_kexec at ffffffff810421d9
> >> @ #1 [ffff8809fe6139f0] crash_kexec at ffffffff810c9d39
> >> @ #2 [ffff8809fe613ac0] oops_end at ffffffff81599298
> >> @ #3 [ffff8809fe613af0] die at ffffffff8101870b
> >> @ #4 [ffff8809fe613b20] do_general_protection at ffffffff8159906c
> >> @ #5 [ffff8809fe613b50] general_protection at ffffffff81598668
> >> @    [exception RIP: init_stid+14]
> >> @    RIP: ffffffffa058247e  RSP: ffff8809fe613c08  RFLAGS: 00010292
> >> @    RAX: 0000000000000000  RBX: 736e61727465722c  RCX: 0000000000000000
> >> @    RDX: 0000000000000001  RSI: ffff8808e433a800  RDI: 736e61727465722c
> >> @    RBP: ffff8809fe613c28   R8: ffff880a01469000   R9: 0000000000000000
> >> @    R10: 0000000000000000  R11: 0000000000000000  R12: ffff8808e19821a0
> >> @    R13: ffff8809aa40f3a8  R14: ffff8809fd781040  R15: ffff8809aafc9c98
> >> @    ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
> >> @ #6 [ffff8809fe613c30] nfsd4_process_open2 at ffffffffa0588123 [nfsd]
> >> @ #7 [ffff8809fe613d00] nfsd4_open at ffffffffa0577e82 [nfsd]
> >> @ #8 [ffff8809fe613d50] nfsd4_proc_compound at ffffffffa0575de8 [nfsd]
> >> @ #9 [ffff8809fe613db0] nfsd_dispatch at ffffffffa056429b [nfsd]
> >> @ #10 [ffff8809fe613df0] svc_process_common at ffffffffa04afd14 [sunrpc]
> >> @ #11 [ffff8809fe613e70] svc_process at ffffffffa04b034f [sunrpc]
> >> @ #12 [ffff8809fe613e90] nfsd at ffffffffa05649ff [nfsd]
> >> @ #13 [ffff8809fe613ec0] kthread at ffffffff81082f4e
> >> @ #14 [ffff8809fe613f50] ret_from_fork at ffffffff815a09ac
> >>
> >> Thanks,
> >> Junxiao.
> >>
> >>> Cheers
> >>>    Trond
> >>>
> > I agree with Trond. This patch doesn't make much sense.
> >
> > Why isn't that memset in svc_process_common() zeroing this out? If this
> > is a bug in the open codepath, then it's almost certainly a bug for
> > other compound ops. I'd suggest doing a bit more investigative work and
> > see if you can figure out why that isn't working as expected...
> Found the cause, this issue should have been fix by the following 
> commit. This fix is not merged in 3.8.13. Thanks for you and Trond 
> review it.
> 
> commit 5d6031ca742f9f07b9c9d9322538619f3bd155ac
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Thu Jul 17 16:20:39 2014 -0400
> 
>      nfsd4: zero op arguments beyond the 8th compound op
> 
>      The first 8 ops of the compound are zeroed since they're a part of the
>      argument that's zeroed by the
> 
>          memset(rqstp->rq_argp, 0, procp->pc_argsize);
> 
>      in svc_process_common().  But we handle larger compounds by allocating
>      the memory on the fly in nfsd4_decode_compound().  Other than code
>      recently fixed by 01529e3f8179 "NFSD: Fix memory leak in encoding 
> denied
>      lock", I don't know of any examples of code depending on this
>      initialization. But it definitely seems possible, and I'd rather be
>      safe.
> 
>      Compounds this long are unusual so I'm much more worried about failure
>      in this poorly tested cases than about an insignificant performance 
> hit.
> 
>      Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 01023a5..628b430 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1635,7 +1635,7 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
>                  goto xdr_error;
> 
>          if (argp->opcnt > ARRAY_SIZE(argp->iops)) {
> -               argp->ops = kmalloc(argp->opcnt * sizeof(*argp->ops), 
> GFP_KERNEL);
> +               argp->ops = kzalloc(argp->opcnt * sizeof(*argp->ops), 
> GFP_KERNEL);
>                  if (!argp->ops) {
>                          argp->ops = argp->iops;
>                          dprintk("nfsd: couldn't allocate room for 
> COMPOUND\n");
> 
> Thanks,
> Junxiao.
> >
> 

Yes, that patch looks fine, and I'm pretty sure it'd be ok for stable.
I don't think v3.8 is being maintained anymore though, is it?

-- 
Jeff Layton <jlayton@primarydata.com>
