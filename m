Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:38442 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932566AbcCHKhz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Mar 2016 05:37:55 -0500
Received: by mail-wm0-f53.google.com with SMTP id l68so21426945wml.1
        for <linux-nfs@vger.kernel.org>; Tue, 08 Mar 2016 02:37:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.OSX.2.19.9992.1603080525480.66950@dhcp0201.cthon.org>
References: <CAADnVQKwfQ7Z087WJyNR_-4dxk8LrzbKjk+XPZVvBnDVuQ1dSA@mail.gmail.com>
 <alpine.OSX.2.19.9992.1603080525480.66950@dhcp0201.cthon.org>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 8 Mar 2016 11:37:33 +0100
Message-ID: <CACT4Y+bzHXfPaT=GTTxuot7GoL6VX7EHju5WDST23_aBkOxMbw@mail.gmail.com>
Subject: Re: slab-out-of-bounds in rpc/nfs
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 8, 2016 at 11:27 AM, Benjamin Coddington
<bcodding@redhat.com> wrote:
> Adding linux-nfs@vger.kernel.org ..
>
> On Mon, 7 Mar 2016, Alexei Starovoitov wrote:
>
>> seeing on ton of these errors on net-next with kasan on.
>> Likely old bug though.
>>
>> [  373.705691] BUG: KASAN: slab-out-of-bounds in memcpy+0x28/0x40 at
>> addr ffff8811ada62cb0
>> [  373.707137] Write of size 28 by task bash/7059
>> [  373.708177] =============================================================================
>> [  373.709711] BUG kmalloc-4096 (Tainted: G        W      ): kasan:
>> bad access detected
>> [  373.711185] -----------------------------------------------------------------------------
>> [  373.711185]
>> [  373.721461] INFO: Allocated in rpc_malloc+0x58/0xd0 age=21 cpu=5 pid=7059
>> [  373.727158]     ___slab_alloc+0x4e2/0x500
>> [  373.728469]     __slab_alloc+0x43/0x70
>> [  373.729222]     __kmalloc+0x286/0x350
>> [  373.729978]     rpc_malloc+0x58/0xd0
>> [  373.730590]     call_allocate+0x333/0x690
>> [  373.731428]     __rpc_execute+0x187/0xad0
>> [  373.734395]     rpc_execute+0xe1/0x2c0
>> [  373.735020]     rpc_run_task+0x1ce/0x250
>> [  373.735706]     rpc_call_sync+0x93/0x150
>> [  373.736387]     nfs3_rpc_wrapper.constprop.12+0x9b/0x240
>> [  373.742818]     nfs3_proc_readdir+0x230/0x390
>> [  373.750157]     nfs_readdir_xdr_to_array+0x501/0x9b0
>> [  373.753520]     nfs_readdir_filler+0x68/0x160
>> [  373.758455]     do_read_cache_page+0x8c/0x3c0
>> [  373.761745]     read_cache_page+0x46/0x70
>> [  373.763269]     nfs_readdir+0x420/0x1380
>> [  373.764078] INFO: Freed in rpc_free+0x41/0x70 age=64 cpu=5 pid=7059
>> [  373.765335]     __slab_free+0x175/0x280
>> [  373.766106]     kfree+0x25c/0x2a0
>> [  373.766809]     rpc_free+0x41/0x70
>> [  373.767629]     xprt_release+0x2c5/0x8f0
>> [  373.768430]     rpc_release_resources_task+0x14/0x80
>> [  373.769403]     __rpc_execute+0x547/0xad0
>> [  373.770249]     rpc_execute+0xe1/0x2c0
>> [  373.770995]     rpc_run_task+0x1ce/0x250
>> [  373.771786]     rpc_call_sync+0x93/0x150
>> [  373.772672]     nfs3_rpc_wrapper.constprop.12+0x9b/0x240
>> [  373.773704]     nfs3_proc_access+0x1f1/0x330
>> [  373.774544]     nfs_do_access+0x94f/0x12d0
>> [  373.775572]     nfs_permission+0x469/0x580
>> [  373.776465]     __inode_permission+0x151/0x230
>> [  373.780764]     inode_permission+0x21/0xf0
>> [  373.791392]     may_open+0x14b/0x260
>>

The report misses the most interesting part -- the out-of-bounds
access stack. It should be at the bottom of the report. If you still
have the full report, please post it.
