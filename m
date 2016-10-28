Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:31333 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935453AbcJ1BUz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Oct 2016 21:20:55 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: upstream server crash
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <3F1E6818-8E19-44FC-A434-39BE67FE8170@oracle.com>
Date: Thu, 27 Oct 2016 21:20:41 -0400
Cc: Eryu Guan <guaneryu@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <A6DF0462-6DE5-4D60-9B55-FFBEDFD99102@oracle.com>
References: <20161023182115.GA14481@fieldses.org> <20161024031519.GN2462@eguan.usersys.redhat.com> <1477315868.2625.37.camel@redhat.com> <7B3F94BF-CAA1-4001-BEBC-C93965A81DE4@oracle.com> <1477322377.14828.4.camel@redhat.com> <1477322680.14828.6.camel@redhat.com> <20161024180858.GA27359@fieldses.org> <1477336654.21854.9.camel@redhat.com> <20161024204022.GB27359@fieldses.org> <58FE664A-94BE-4589-A3D1-D734284272A0@oracle.com> <1477357020.23530.5.camel@redhat.com> <368D37F5-FEF7-43EB-BD7F-BFDAA6C53EDF@oracle.com> <1477359964.23530.11.camel@redhat.com> <3F1E6818-8E19-44FC-A434-39BE67FE8170@oracle.com>
To: Jeff Layton <jlayton@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Oct 24, 2016, at 10:02 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> 
>> On Oct 24, 2016, at 9:46 PM, Jeff Layton <jlayton@redhat.com> wrote:
>> 
>> On Mon, 2016-10-24 at 21:00 -0400, Chuck Lever wrote:
>>>> 
>>>> On Oct 24, 2016, at 8:57 PM, Jeff Layton <jlayton@redhat.com> wrote:
>>>> 
>>>> On Mon, 2016-10-24 at 17:38 -0400, Chuck Lever wrote:
>>>>> 
>>>>>> 
>>>>>> 
>>>>>> On Oct 24, 2016, at 4:40 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>>>>>> 
>>>>>> On Mon, Oct 24, 2016 at 03:17:34PM -0400, Jeff Layton wrote:
>>>>>>> 
>>>>>>> 
>>>>>>> On Mon, 2016-10-24 at 14:08 -0400, J. Bruce Fields wrote:
>>>>>>>> 
>>>>>>>> 
>>>>>>>> On Mon, Oct 24, 2016 at 11:24:40AM -0400, Jeff Layton wrote:
>>>>>>>>> 
>>>>>>>>> 
>>>>>>>>> 
>>>>>>>>> On Mon, 2016-10-24 at 11:19 -0400, Jeff Layton wrote:
>>>>>>>>>> 
>>>>>>>>>> 
>>>>>>>>>> 
>>>>>>>>>> On Mon, 2016-10-24 at 09:51 -0400, Chuck Lever wrote:
>>>>>>>>>>> 
>>>>>>>>>>> 
>>>>>>>>>>> 
>>>>>>>>>>> 
>>>>>>>>>>>> 
>>>>>>>>>>>> 
>>>>>>>>>>>> 
>>>>>>>>>>>> 
>>>>>>>>>>>> 
>>>>>>>>>>>> On Oct 24, 2016, at 9:31 AM, Jeff Layton <jlayton@redhat.com> wrote:
>>>>>>>>>>>> 
>>>>>>>>>>>> On Mon, 2016-10-24 at 11:15 +0800, Eryu Guan wrote:
>>>>>>>>>>>>> 
>>>>>>>>>>>>> 
>>>>>>>>>>>>> 
>>>>>>>>>>>>> 
>>>>>>>>>>>>> 
>>>>>>>>>>>>> On Sun, Oct 23, 2016 at 02:21:15PM -0400, J. Bruce Fields wrote:
>>>>>>>>>>>>>> 
>>>>>>>>>>>>>> 
>>>>>>>>>>>>>> 
>>>>>>>>>>>>>> 
>>>>>>>>>>>>>> 
>>>>>>>>>>>>>> 
>>>>>>>>>>>>>> I'm getting an intermittent crash in the nfs server as of
>>>>>>>>>>>>>> 68778945e46f143ed7974b427a8065f69a4ce944 "SUNRPC: Separate buffer
>>>>>>>>>>>>>> pointers for RPC Call and Reply messages".
>>>>>>>>>>>>>> 
>>>>>>>>>>>>>> I haven't tried to understand that commit or why it would be a problem yet, I
>>>>>>>>>>>>>> don't see an obvious connection--I can take a closer look Monday.
>>>>>>>>>>>>>> 
>>>>>>>>>>>>>> Could even be that I just landed on this commit by chance, the problem is a
>>>>>>>>>>>>>> little hard to reproduce so I don't completely trust my testing.
>>>>>>>>>>>>> 
>>>>>>>>>>>>> I've hit the same crash on 4.9-rc1 kernel, and it's reproduced for me
>>>>>>>>>>>>> reliably by running xfstests generic/013 case, on a loopback mounted
>>>>>>>>>>>>> NFSv4.1 (or NFSv4.2), XFS is the underlying exported fs. More details
>>>>>>>>>>>>> please see
>>>>>>>>>>>>> 
>>>>>>>>>>>>> http://marc.info/?l=linux-nfs&m=147714320129362&w=2
>>>>>>>>>>>>> 
>>>>>>>>>>>> 
>>>>>>>>>>>> Looks like you landed at the same commit as Bruce, so that's probably
>>>>>>>>>>>> legit. That commit is very small though. The only real change that
>>>>>>>>>>>> doesn't affect the new field is this:
>>>>>>>>>>>> 
>>>>>>>>>>>> 
>>>>>>>>>>>> @@ -1766,7 +1766,7 @@ rpc_xdr_encode(struct rpc_task *task)
>>>>>>>>>>>>                  req->rq_buffer,
>>>>>>>>>>>>                  req->rq_callsize);
>>>>>>>>>>>>     xdr_buf_init(&req->rq_rcv_buf,
>>>>>>>>>>>> -                    (char *)req->rq_buffer + req->rq_callsize,
>>>>>>>>>>>> +                    req->rq_rbuffer,
>>>>>>>>>>>>                  req->rq_rcvsize);
>>>>>>>>>>>> 
>>>>>>>>>>>> 
>>>>>>>>>>>> So I'm guessing this is breaking the callback channel somehow?
>>>>>>>>>>> 
>>>>>>>>>>> Could be the TCP backchannel code is using rq_buffer in a different
>>>>>>>>>>> way than RDMA backchannel or the forward channel code.
>>>>>>>>>>> 
>>>>>>>>>> 
>>>>>>>>>> Well, it basically allocates a page per rpc_rqst and then maps that.
>>>>>>>>>> 
>>>>>>>>>> One thing I notice is that this patch ensures that rq_rbuffer gets set
>>>>>>>>>> up in rpc_malloc and xprt_rdma_allocate, but it looks like
>>>>>>>>>> xprt_alloc_bc_req didn't get the same treatment.
>>>>>>>>>> 
>>>>>>>>>> I suspect that that may be the problem...
>>>>>>>>>> 
>>>>>>>>> In fact, maybe we just need this here? (untested and probably
>>>>>>>>> whitespace damaged):
>>>>>>>> 
>>>>>>>> No change in results for me.
>>>>>>>> 
>>>>>>>> --b.
>>>>>>>>> 
>>>>>>>>> 
>>>>>>>>> 
>>>>>>>>> 
>>>>>>>>> diff --git a/net/sunrpc/backchannel_rqst.c b/net/sunrpc/backchannel_rqst.c
>>>>>>>>> index ac701c28f44f..c561aa8ce05b 100644
>>>>>>>>> --- a/net/sunrpc/backchannel_rqst.c
>>>>>>>>> +++ b/net/sunrpc/backchannel_rqst.c
>>>>>>>>> @@ -100,6 +100,7 @@ struct rpc_rqst *xprt_alloc_bc_req(struct rpc_xprt *xprt, gfp_t gfp_flags)
>>>>>>>>>             goto out_free;
>>>>>>>>>     }
>>>>>>>>>     req->rq_rcv_buf.len = PAGE_SIZE;
>>>>>>>>> +       req->rq_rbuffer = req->rq_rcv_buf.head[0].iov_base;
>>>>>>>>> 
>>>>>>>>>     /* Preallocate one XDR send buffer */
>>>>>>>>>     if (xprt_alloc_xdr_buf(&req->rq_snd_buf, gfp_flags) < 0) {
>>>>>>> 
>>>>>>> Ahh ok, I think I see.
>>>>>>> 
>>>>>>> We probably also need to set rq_rbuffer in bc_malloc and and
>>>>>>> xprt_rdma_bc_allocate.
>>>>>>> 
>>>>>>> My guess is that we're ending up in rpc_xdr_encode with a NULL
>>>>>>> rq_rbuffer pointer, so the right fix would seem to be to ensure that it
>>>>>>> is properly set whenever rq_buffer is set.
>>>>>>> 
>>>>>>> So I think this may be what we want, actually. I'll plan to test it out
>>>>>>> but may not get to it before tomorrow.
>>>>>> 
>>>>>> It passes here.
>>>>> 
>>>>> Without Jeff's patch, my server locks up during generic/013 with NFS/RDMA
>>>>> and NFSv4.1. With it, I get all the way to generic/089, and then encounter
>>>>> this:
>>>>> 
>>>> 
>>>> Thanks for testing. I just sent an "official" patch submission with the
>>>> same patch.
>>>> 
>>>> 
>>>>> 
>>>>> Oct 24 17:31:11 klimt kernel: general protection fault: 0000 [#1] SMP
>>>>> Oct 24 17:31:11 klimt kernel: Modules linked in: cts rpcsec_gss_krb5 sb_edac edac_core x86_pkg_temp_thermal intel_powerclamp coretemp kvm_intel kvm btrfs irqbypass crct10dif_pclmul crc32_pclmul ghash_clmulni_intel iTCO_wdt iTCO_vendor_support aesni_intel lrw gf128mul glue_helper ablk_helper cryptd xor raid6_pq rpcrdma pcspkr i2c_i801 lpc_ich ib_ipoib i2c_smbus mfd_core mei_me sg mei rdma_ucm shpchp ioatdma wmi ib_ucm ipmi_si ipmi_msghandler ib_uverbs ib_umad rdma_cm ib_cm iw_cm acpi_pad acpi_power_meter nfsd auth_rpcgss nfs_acl lockd grace sunrpc ip_tables xfs libcrc32c mlx4_ib ib_core mlx4_en sd_mod sr_mod cdrom ast drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm drm mlx4_core ahci libahci igb crc32c_intel ptp libata pps_core dca i2c_algo_bit i2c_core dm_mirror dm_region_hash dm_log dm_mod
>>>>> Oct 24 17:31:11 klimt kernel: CPU: 3 PID: 1681 Comm: nfsd Not tainted 4.9.0-rc2-00006-g0e8f985 #2
>>>>> Oct 24 17:31:11 klimt kernel: Hardware name: Supermicro Super Server/X10SRL-F, BIOS 1.0c 09/09/2015
>>>>> Oct 24 17:31:11 klimt kernel: task: ffff88083feb15c0 task.stack: ffffc900058a0000
>>>>> Oct 24 17:31:11 klimt kernel: RIP: 0010:[<ffffffff811ed1f0>]  [<ffffffff811ed1f0>] __kmalloc_track_caller+0x1b0/0x220
>>>>> Oct 24 17:31:11 klimt kernel: RSP: 0018:ffffc900058a3b88  EFLAGS: 00010286
>>>>> Oct 24 17:31:11 klimt kernel: RAX: 0000000000000000 RBX: 00000000024000c0 RCX: 0000000000293b6b
>>>>> Oct 24 17:31:11 klimt kernel: RDX: 0000000000293b6a RSI: 0000000000000000 RDI: 0000000000000002
>>>>> Oct 24 17:31:11 klimt kernel: RBP: ffffc900058a3bc8 R08: 000000000001c560 R09: ffff88085f003a40
>>>>> Oct 24 17:31:11 klimt kernel: R10: ffff88085f003a40 R11: ffff88083fc9b3c0 R12: 00000000024000c0
>>>>> Oct 24 17:31:11 klimt kernel: R13: 0000000000000018 R14: ffff88081993d600 R15: c0d435750e5f8620
>>>>> Oct 24 17:31:11 klimt kernel: FS:  0000000000000000(0000) GS:ffff88087fcc0000(0000) knlGS:0000000000000000
>>>>> Oct 24 17:31:11 klimt kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>>>>> Oct 24 17:31:11 klimt kernel: CR2: 00007fca9725a298 CR3: 0000000001c06000 CR4: 00000000001406e0
>>>>> Oct 24 17:31:11 klimt kernel: Stack:
>>>>> Oct 24 17:31:11 klimt kernel: ffff88085f003a40 ffff88085f003a40 ffffffff812c227b 0000000000000018
>>>>> Oct 24 17:31:11 klimt kernel: ffff880852ee6b00 ffff88085583a000 ffff88081993d600 ffff880839a95840
>>>>> Oct 24 17:31:11 klimt kernel: ffffc900058a3be8 ffffffff811a65d0 ffff88081993d600 00000000024000c0
>>>>> Oct 24 17:31:11 klimt kernel: Call Trace:
>>>>> Oct 24 17:31:11 klimt kernel: [<ffffffff812c227b>] ? selinux_cred_prepare+0x1b/0x30
>>>>> Oct 24 17:31:11 klimt kernel: [<ffffffff811a65d0>] kmemdup+0x20/0x50
>>>>> Oct 24 17:31:11 klimt kernel: [<ffffffff812c227b>] selinux_cred_prepare+0x1b/0x30
>>>>> Oct 24 17:31:11 klimt kernel: [<ffffffff812bd3f9>] security_prepare_creds+0x39/0x60
>>>>> Oct 24 17:31:11 klimt kernel: [<ffffffff810a486f>] prepare_creds+0x12f/0x150
>>>>> Oct 24 17:31:11 klimt kernel: [<ffffffffa043ee6c>] nfsd_setuser+0x8c/0x250 [nfsd]
>>>>> Oct 24 17:31:11 klimt kernel: [<ffffffffa0438077>] nfsd_setuser_and_check_port+0x77/0xa0 [nfsd]
>>>>> Oct 24 17:31:11 klimt kernel: [<ffffffff812bd3f9>] ? security_prepare_creds+0x39/0x60
>>>>> Oct 24 17:31:11 klimt kernel: [<ffffffffa04a33f6>] ? write_bytes_to_xdr_buf+0xa6/0xd0 [sunrpc]
>>>>> Oct 24 17:31:11 klimt kernel: [<ffffffffa0438dcc>] fh_verify+0x5cc/0x610 [nfsd]
>>>>> Oct 24 17:31:11 klimt kernel: [<ffffffffa044659b>] nfsd4_getattr+0x1b/0x80 [nfsd]
>>>>> Oct 24 17:31:11 klimt kernel: [<ffffffffa04481fd>] nfsd4_proc_compound+0x40d/0x690 [nfsd]
>>>>> Oct 24 17:31:11 klimt kernel: [<ffffffffa04352b4>] nfsd_dispatch+0xd4/0x1d0 [nfsd]
>>>>> Oct 24 17:31:11 klimt kernel: [<ffffffffa049b249>] svc_process_common+0x3d9/0x700 [sunrpc]
>>>>> Oct 24 17:31:11 klimt kernel: [<ffffffffa049c0c1>] svc_process+0xf1/0x1d0 [sunrpc]
>>>>> Oct 24 17:31:11 klimt kernel: [<ffffffffa0434d4f>] nfsd+0xff/0x160 [nfsd]
>>>>> Oct 24 17:31:11 klimt kernel: [<ffffffffa0434c50>] ? nfsd_destroy+0x60/0x60 [nfsd]
>>>>> Oct 24 17:31:11 klimt kernel: [<ffffffff810a2235>] kthread+0xe5/0xf0
>>>>> Oct 24 17:31:11 klimt kernel: [<ffffffff810a2150>] ? kthread_stop+0x120/0x120
>>>>> Oct 24 17:31:11 klimt kernel: [<ffffffff816aa795>] ret_from_fork+0x25/0x30
>>>>> Oct 24 17:31:11 klimt kernel: Code: 85 d2 75 dd eb d3 48 89 c3 66 90 eb 6e 81 e3 00 00 10 00 0f 84 e4 fe ff ff 66 90 e9 e7 fe ff ff 49 63 42 20 48 8d 4a 01 4d 8b 02 <49> 8b 1c 07 4c 89 f8 65 49 0f c7 08 0f 94 c0 84 c0 0f 85 3b ff 
>>>>> Oct 24 17:31:11 klimt kernel: RIP  [<ffffffff811ed1f0>] __kmalloc_track_caller+0x1b0/0x220
>>>>> Oct 24 17:31:11 klimt kernel: RSP <ffffc900058a3b88>
>>>>> Oct 24 17:31:11 klimt kernel: ---[ end trace af2b44f9db7f5a36 ]---
>>>>> 
>>>>> This appears to be unrelated. Maybe.
>>>>> 
>>>>> Bruce, do you have CONFIG_VMAP_STACK set? I took the default, just
>>>>> wondering if that was an especially safe thing to try.
>>>>> 
>>>>> 
>>>> 
>>>> Yeah, looks unrelated to me too. It died down in the kmalloc code, so
>>>> I'd have to wonder if there is some slab corruption or something?
>>>> 
>>>> Chuck, can you do something like this on the kernel where you saw this
>>>> panic?
>>>> 
>>>>   $ gdb vmlinux
>>>>   gdb> list *(__kmalloc_track_caller+0x1b0)
>>>> 
>>>> It'd be good to see where this crashed.
>>> 
>>> [cel@manet 4.9.0-rc2-00012-gf3e49aa]$ gdb vmlinux
>>> GNU gdb (GDB) Red Hat Enterprise Linux 7.6.1-80.el7
>>> Copyright (C) 2013 Free Software Foundation, Inc.
>>> License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
>>> This is free software: you are free to change and redistribute it.
>>> There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
>>> and "show warranty" for details.
>>> This GDB was configured as "x86_64-redhat-linux-gnu".
>>> For bug reporting instructions, please see:
>>> <http://www.gnu.org/software/gdb/bugs/>...
>>> Reading symbols from /usr/lib/modules/4.9.0-rc2-00012-gf3e49aa/vmlinux...done.
>>> (gdb) list *(__kmalloc_track_caller+0x1b0)
>>> 0xffffffff811ecee0 is in __kmalloc_track_caller (/home/cel/src/linux/linux-2.6/mm/slub.c:241).
>>> 236	 * 			Core slab cache functions
>>> 237	 *******************************************************************/
>>> 238	
>>> 239	static inline void *get_freepointer(struct kmem_cache *s, void *object)
>>> 240	{
>>> 241		return *(void **)(object + s->offset);
>>> 242	}
>>> 243	
>>> 244	static void prefetch_freepointer(const struct kmem_cache *s, void *object)
>>> 245	{
>>> (gdb) 
>>> 
>>> --
>>> Chuck Lever
>>> 
>>> 
>>> 
>> 
>> Thanks -- I'm guessing that means that "s" is bogus there, so
>> yeah...slab corruption.
>> 
>> I hit some panics in the same function about a year or so ago when I
>> was developing some fsnotify patches, and it turned out to be double-
>> free. Wonder what's sharing that slab?
> 
> Could be anything: that's called from kmemdup(), so it's going to be
> one of the generic slabs.
> 
> I've disabled CONFIG_VMAP_STACK and SELinux, and so far everything is
> stable with NFSv4.1 on RDMA and v4.9-rc2.

Just hit this on the server while running xfstests generic/089 on
NFSv4.0 / RDMA. Still v4.9-rc2 with a few NFS/RDMA patches, but
no kernel debugging enabled yet.

Oct 27 21:08:42 klimt kernel: general protection fault: 0000 [#1] SMP
Oct 27 21:08:42 klimt kernel: Modules linked in: cts rpcsec_gss_krb5 sb_edac edac_core x86_pkg_temp_thermal intel_powerclamp coretemp btrfs kvm_intel kvm irqbypass crct10dif_pclmul crc32_pclmul ghash_clmulni_intel aesni_intel xor lrw gf128mul glue_helper ablk_helper cryptd iTCO_wdt iTCO_vendor_support raid6_pq pcspkr lpc_ich i2c_i801 mfd_core i2c_smbus mei_me mei rpcrdma sg ipmi_si shpchp ioatdma wmi ipmi_msghandler ib_ipoib acpi_pad acpi_power_meter rdma_ucm ib_ucm ib_uverbs ib_umad rdma_cm ib_cm iw_cm nfsd auth_rpcgss nfs_acl lockd grace sunrpc ip_tables xfs libcrc32c mlx4_ib ib_core mlx4_en sr_mod cdrom sd_mod ast drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm ahci drm igb libahci libata mlx4_core ptp crc32c_intel pps_core dca i2c_algo_bit i2c_core dm_mirror dm_region_hash dm_log dm_mod
Oct 27 21:08:42 klimt kernel: CPU: 3 PID: 1649 Comm: nfsd Not tainted 4.9.0-rc2-00004-ga75a35c #3
Oct 27 21:08:42 klimt kernel: Hardware name: Supermicro Super Server/X10SRL-F, BIOS 1.0c 09/09/2015
Oct 27 21:08:42 klimt kernel: task: ffff880841474140 task.stack: ffff880841798000
Oct 27 21:08:42 klimt kernel: RIP: 0010:[<ffffffff811e9a99>]  [<ffffffff811e9a99>] kmem_cache_alloc+0x149/0x1b0
Oct 27 21:08:42 klimt kernel: RSP: 0018:ffff88084179bc98  EFLAGS: 00010282
Oct 27 21:08:42 klimt kernel: RAX: 0000000000000000 RBX: 00000000024000c0 RCX: 00000000095755fa
Oct 27 21:08:42 klimt kernel: RDX: 00000000095755f9 RSI: 00000000024000c0 RDI: ffff88085f007400
Oct 27 21:08:42 klimt kernel: RBP: ffff88084179bcc8 R08: 000000000001ce30 R09: ffff8808416a1070
Oct 27 21:08:42 klimt kernel: R10: 0000000000000003 R11: ffff8808416a0220 R12: 00000000024000c0
Oct 27 21:08:42 klimt kernel: R13: e748f37c723b66c0 R14: ffff88085f007400 R15: ffff88085f007400
Oct 27 21:08:42 klimt kernel: FS:  0000000000000000(0000) GS:ffff88087fcc0000(0000) knlGS:0000000000000000
Oct 27 21:08:42 klimt kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Oct 27 21:08:42 klimt kernel: CR2: 00007f6822890000 CR3: 0000000001c06000 CR4: 00000000001406e0
Oct 27 21:08:42 klimt kernel: Stack:
Oct 27 21:08:42 klimt kernel: ffffffff810a4456 0000000011270000 ffff880841474140 ffff880841484000
Oct 27 21:08:42 klimt kernel: 0000000000000000 ffff88084cbc4a00 ffff88084179bce8 ffffffff810a4456
Oct 27 21:08:42 klimt kernel: 0000000011270000 ffff8808416a1068 ffff88084179bd58 ffffffffa04c09ed
Oct 27 21:08:42 klimt kernel: Call Trace:
Oct 27 21:08:42 klimt kernel: [<ffffffff810a4456>] ? prepare_creds+0x26/0x150
Oct 27 21:08:42 klimt kernel: [<ffffffff810a4456>] prepare_creds+0x26/0x150
Oct 27 21:08:42 klimt kernel: [<ffffffffa04c09ed>] fh_verify+0x1ed/0x610 [nfsd]
Oct 27 21:08:42 klimt kernel: [<ffffffffa04ce6f9>] nfsd4_putfh+0x49/0x50 [nfsd]
Oct 27 21:08:42 klimt kernel: [<ffffffffa04d01fd>] nfsd4_proc_compound+0x40d/0x690 [nfsd]
Oct 27 21:08:42 klimt kernel: [<ffffffffa04bd2b4>] nfsd_dispatch+0xd4/0x1d0 [nfsd]
Oct 27 21:08:42 klimt kernel: [<ffffffffa0430249>] svc_process_common+0x3d9/0x700 [sunrpc]
Oct 27 21:08:42 klimt kernel: [<ffffffffa04310c1>] svc_process+0xf1/0x1d0 [sunrpc]
Oct 27 21:08:42 klimt kernel: [<ffffffffa04bcd4f>] nfsd+0xff/0x160 [nfsd]
Oct 27 21:08:42 klimt kernel: [<ffffffffa04bcc50>] ? nfsd_destroy+0x60/0x60 [nfsd]
Oct 27 21:08:42 klimt kernel: [<ffffffff810a1f25>] kthread+0xe5/0xf0
Oct 27 21:08:42 klimt kernel: [<ffffffff810a1e40>] ? kthread_stop+0x120/0x120
Oct 27 21:08:42 klimt kernel: [<ffffffff816aa795>] ret_from_fork+0x25/0x30
Oct 27 21:08:42 klimt kernel: Code: d0 41 ff d2 4d 8b 55 00 4d 85 d2 75 dc eb d1 81 e3 00 00 10 00 0f 84 0a ff ff ff e9 0f ff ff ff 49 63 47 20 48 8d 4a 01 4d 8b 07 <49> 8b 5c 05 00 4c 89 e8 65 49 0f c7 08 0f 94 c0 84 c0 0f 85 45 
Oct 27 21:08:42 klimt kernel: RIP  [<ffffffff811e9a99>] kmem_cache_alloc+0x149/0x1b0
Oct 27 21:08:42 klimt kernel: RSP <ffff88084179bc98>
Oct 27 21:08:42 klimt kernel: ---[ end trace 0bf398a5b035df79 ]---

Looks rather similar:

(gdb) list *(kmem_cache_alloc+0x149)
0xffffffff811e9a99 is in kmem_cache_alloc (/home/cel/src/linux/linux-2.6/mm/slub.c:241).
236	 * 			Core slab cache functions
237	 *******************************************************************/
238	
239	static inline void *get_freepointer(struct kmem_cache *s, void *object)
240	{
241		return *(void **)(object + s->offset);
242	}
243	
244	static void prefetch_freepointer(const struct kmem_cache *s, void *object)
245	{
(gdb) 


--
Chuck Lever



