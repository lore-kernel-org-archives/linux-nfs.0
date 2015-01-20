Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55794 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751996AbbATOgr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Jan 2015 09:36:47 -0500
Date: Tue, 20 Jan 2015 09:36:45 -0500
From: Bruce Fields <bfields@fieldses.org>
To: Junxiao Bi <junxiao.bi@oracle.com>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: fix memory corruption due to uninitialized variable
Message-ID: <20150120143645.GB7899@fieldses.org>
References: <1421584142-12505-1-git-send-email-junxiao.bi@oracle.com>
 <CAHQdGtTs6B93fi4TAL86f02cD7OE5zzWgk8tCa6ZOyKQ9Bd7Eg@mail.gmail.com>
 <54BC5B3F.9080004@oracle.com>
 <20150119092953.2584b496@tlielax.poochiereds.net>
 <54BE40DB.4070801@oracle.com>
 <20150120072359.70053ddf@tlielax.poochiereds.net>
 <54BE4992.4060805@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <54BE4992.4060805@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 20, 2015 at 08:26:58PM +0800, Junxiao Bi wrote:
> On 01/20/2015 08:23 PM, Jeff Layton wrote:
> >On Tue, 20 Jan 2015 19:49:47 +0800
> >Junxiao Bi <junxiao.bi@oracle.com> wrote:
> >
> >>On 01/19/2015 10:29 PM, Jeff Layton wrote:
> >>>On Mon, 19 Jan 2015 09:17:51 +0800
> >>>Junxiao Bi <junxiao.bi@oracle.com> wrote:
> >>>>Yes, we got the following panic from 3.8.13. The bad pointer
> >>>>open->op_stp was freed into kmem_cache array_cache, and was allocated to
> >>>>next "op_stp" allocation request which triggered the panic.
> >>>>
> >>>>
> >>>>@ PID: 21663  TASK: ffff8809fe6103c0  CPU: 0   COMMAND: "nfsd"
> >>>>@ #0 [ffff8809fe613980] machine_kexec at ffffffff810421d9
> >>>>@ #1 [ffff8809fe6139f0] crash_kexec at ffffffff810c9d39
> >>>>@ #2 [ffff8809fe613ac0] oops_end at ffffffff81599298
> >>>>@ #3 [ffff8809fe613af0] die at ffffffff8101870b
> >>>>@ #4 [ffff8809fe613b20] do_general_protection at ffffffff8159906c
> >>>>@ #5 [ffff8809fe613b50] general_protection at ffffffff81598668
> >>>>@    [exception RIP: init_stid+14]
> >>>>@    RIP: ffffffffa058247e  RSP: ffff8809fe613c08  RFLAGS: 00010292
> >>>>@    RAX: 0000000000000000  RBX: 736e61727465722c  RCX: 0000000000000000
> >>>>@    RDX: 0000000000000001  RSI: ffff8808e433a800  RDI: 736e61727465722c
> >>>>@    RBP: ffff8809fe613c28   R8: ffff880a01469000   R9: 0000000000000000
> >>>>@    R10: 0000000000000000  R11: 0000000000000000  R12: ffff8808e19821a0
> >>>>@    R13: ffff8809aa40f3a8  R14: ffff8809fd781040  R15: ffff8809aafc9c98
> >>>>@    ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
> >>>>@ #6 [ffff8809fe613c30] nfsd4_process_open2 at ffffffffa0588123 [nfsd]
> >>>>@ #7 [ffff8809fe613d00] nfsd4_open at ffffffffa0577e82 [nfsd]
> >>>>@ #8 [ffff8809fe613d50] nfsd4_proc_compound at ffffffffa0575de8 [nfsd]
> >>>>@ #9 [ffff8809fe613db0] nfsd_dispatch at ffffffffa056429b [nfsd]
> >>>>@ #10 [ffff8809fe613df0] svc_process_common at ffffffffa04afd14 [sunrpc]
> >>>>@ #11 [ffff8809fe613e70] svc_process at ffffffffa04b034f [sunrpc]
> >>>>@ #12 [ffff8809fe613e90] nfsd at ffffffffa05649ff [nfsd]
> >>>>@ #13 [ffff8809fe613ec0] kthread at ffffffff81082f4e
> >>>>@ #14 [ffff8809fe613f50] ret_from_fork at ffffffff815a09ac
...
> >>Found the cause, this issue should have been fix by the following
> >>commit. This fix is not merged in 3.8.13. Thanks for you and Trond
> >>review it.

Oh, sorry for not thinking of that one....

I wonder how you hit this case--which client were you using?

--b.

> >>
> >>commit 5d6031ca742f9f07b9c9d9322538619f3bd155ac
> >>Author: J. Bruce Fields <bfields@redhat.com>
> >>Date:   Thu Jul 17 16:20:39 2014 -0400
> >>
> >>      nfsd4: zero op arguments beyond the 8th compound op
> >>
> >>      The first 8 ops of the compound are zeroed since they're a part of the
> >>      argument that's zeroed by the
> >>
> >>          memset(rqstp->rq_argp, 0, procp->pc_argsize);
> >>
> >>      in svc_process_common().  But we handle larger compounds by allocating
> >>      the memory on the fly in nfsd4_decode_compound().  Other than code
> >>      recently fixed by 01529e3f8179 "NFSD: Fix memory leak in encoding
> >>denied
> >>      lock", I don't know of any examples of code depending on this
> >>      initialization. But it definitely seems possible, and I'd rather be
> >>      safe.
> >>
> >>      Compounds this long are unusual so I'm much more worried about failure
> >>      in this poorly tested cases than about an insignificant performance
> >>hit.
> >>
> >>      Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> >>
> >>diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> >>index 01023a5..628b430 100644
> >>--- a/fs/nfsd/nfs4xdr.c
> >>+++ b/fs/nfsd/nfs4xdr.c
> >>@@ -1635,7 +1635,7 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
> >>                  goto xdr_error;
> >>
> >>          if (argp->opcnt > ARRAY_SIZE(argp->iops)) {
> >>-               argp->ops = kmalloc(argp->opcnt * sizeof(*argp->ops),
> >>GFP_KERNEL);
> >>+               argp->ops = kzalloc(argp->opcnt * sizeof(*argp->ops),
> >>GFP_KERNEL);
> >>                  if (!argp->ops) {
> >>                          argp->ops = argp->iops;
> >>                          dprintk("nfsd: couldn't allocate room for
> >>COMPOUND\n");
> >>
> >>Thanks,
> >>Junxiao.
> >Yes, that patch looks fine, and I'm pretty sure it'd be ok for stable.
> yes.
> >I don't think v3.8 is being maintained anymore though, is it?
> Used by us internal.
> 
> Thanks,
> Junxiao.
> >
> 
