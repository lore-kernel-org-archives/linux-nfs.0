Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:58961 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750751AbcFQRg7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Jun 2016 13:36:59 -0400
Date: Fri, 17 Jun 2016 13:36:44 -0400
From: Calvin Owens <calvinowens@fb.com>
To: Benjamin Coddington <bcodding@redhat.com>
CC: Dmitry Vyukov <dvyukov@google.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>
Subject: Re: slab-out-of-bounds in rpc/nfs
Message-ID: <20160617173644.GB72696@calvinowens-mba.dhcp.thefacebook.com>
References: <CAADnVQKwfQ7Z087WJyNR_-4dxk8LrzbKjk+XPZVvBnDVuQ1dSA@mail.gmail.com>
 <alpine.OSX.2.19.9992.1603080525480.66950@dhcp0201.cthon.org>
 <CACT4Y+bzHXfPaT=GTTxuot7GoL6VX7EHju5WDST23_aBkOxMbw@mail.gmail.com>
 <20160616175201.GA62982@calvinowens-mba.dhcp.thefacebook.com>
 <CFBEB74A-DDD4-4689-824D-FCCE39C44F42@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
In-Reply-To: <CFBEB74A-DDD4-4689-824D-FCCE39C44F42@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Friday 06/17 at 09:38 -0400, Benjamin Coddington wrote:
> On 16 Jun 2016, at 13:52, Calvin Owens wrote:
> 
> > On Tuesday 03/08 at 11:37 +0100, Dmitry Vyukov wrote:
> > > On Tue, Mar 8, 2016 at 11:27 AM, Benjamin Coddington
> > > <bcodding@redhat.com> wrote:
> > > > Adding linux-nfs@vger.kernel.org ..
> > > > 
> > > > On Mon, 7 Mar 2016, Alexei Starovoitov wrote:
> > > > 
> > > > > seeing on ton of these errors on net-next with kasan on.
> > > > > Likely old bug though.
> > > > > 
> > > > > [  373.705691] BUG: KASAN: slab-out-of-bounds in
> > > > > memcpy+0x28/0x40 at
> > > > > addr ffff8811ada62cb0
> > > > > [  373.707137] Write of size 28 by task bash/7059
> > > > > [  373.708177] =============================================================================
> > > > > [  373.709711] BUG kmalloc-4096 (Tainted: G        W      ): kasan:
> > > > > bad access detected
> > > > > [  373.711185] -----------------------------------------------------------------------------
> > > > > [  373.711185]
> > > > > [  373.721461] INFO: Allocated in rpc_malloc+0x58/0xd0
> > > > > age=21 cpu=5 pid=7059
> > > > > [  373.727158]     ___slab_alloc+0x4e2/0x500
> > > > > [  373.728469]     __slab_alloc+0x43/0x70
> > > > > [  373.729222]     __kmalloc+0x286/0x350
> > > > > [  373.729978]     rpc_malloc+0x58/0xd0
> > > > > [  373.730590]     call_allocate+0x333/0x690
> > > > > [  373.731428]     __rpc_execute+0x187/0xad0
> > > > > [  373.734395]     rpc_execute+0xe1/0x2c0
> > > > > [  373.735020]     rpc_run_task+0x1ce/0x250
> > > > > [  373.735706]     rpc_call_sync+0x93/0x150
> > > > > [  373.736387]     nfs3_rpc_wrapper.constprop.12+0x9b/0x240
> > > > > [  373.742818]     nfs3_proc_readdir+0x230/0x390
> > > > > [  373.750157]     nfs_readdir_xdr_to_array+0x501/0x9b0
> > > > > [  373.753520]     nfs_readdir_filler+0x68/0x160
> > > > > [  373.758455]     do_read_cache_page+0x8c/0x3c0
> > > > > [  373.761745]     read_cache_page+0x46/0x70
> > > > > [  373.763269]     nfs_readdir+0x420/0x1380
> > > > > [  373.764078] INFO: Freed in rpc_free+0x41/0x70 age=64
> > > > > cpu=5 pid=7059
> > > > > [  373.765335]     __slab_free+0x175/0x280
> > > > > [  373.766106]     kfree+0x25c/0x2a0
> > > > > [  373.766809]     rpc_free+0x41/0x70
> > > > > [  373.767629]     xprt_release+0x2c5/0x8f0
> > > > > [  373.768430]     rpc_release_resources_task+0x14/0x80
> > > > > [  373.769403]     __rpc_execute+0x547/0xad0
> > > > > [  373.770249]     rpc_execute+0xe1/0x2c0
> > > > > [  373.770995]     rpc_run_task+0x1ce/0x250
> > > > > [  373.771786]     rpc_call_sync+0x93/0x150
> > > > > [  373.772672]     nfs3_rpc_wrapper.constprop.12+0x9b/0x240
> > > > > [  373.773704]     nfs3_proc_access+0x1f1/0x330
> > > > > [  373.774544]     nfs_do_access+0x94f/0x12d0
> > > > > [  373.775572]     nfs_permission+0x469/0x580
> > > > > [  373.776465]     __inode_permission+0x151/0x230
> > > > > [  373.780764]     inode_permission+0x21/0xf0
> > > > > [  373.791392]     may_open+0x14b/0x260
> > > > > 
> > > 
> > > The report misses the most interesting part -- the out-of-bounds
> > > access stack. It should be at the bottom of the report. If you still
> > > have the full report, please post it.
> > 
> > I'm triggering this as well on 4.7-rc3. I can reproduce it as far back
> > as 4.0,
> > can't easily test any further back because that's when KASAN was merged.
> > 
> > Logs and Kconfig follow. I can trigger this 100% of the time.
> 
> Hi Calvin, how are you triggering this?  I would guess this is getdents or a
> readdir that's been signaled before the server replies..

Unfortunately my current repro is "boot a specific server type at Facebook", I'll
drill down and see if I can get a minimal repro to send along.

Thanks,
Calvin
