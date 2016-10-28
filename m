Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51806 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756755AbcJ1Uu5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 28 Oct 2016 16:50:57 -0400
Date: Fri, 28 Oct 2016 16:50:56 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Jeff Layton <jlayton@redhat.com>, Eryu Guan <guaneryu@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: upstream server crash
Message-ID: <20161028205056.GA11926@fieldses.org>
References: <1477322680.14828.6.camel@redhat.com>
 <20161024180858.GA27359@fieldses.org>
 <1477336654.21854.9.camel@redhat.com>
 <20161024204022.GB27359@fieldses.org>
 <58FE664A-94BE-4589-A3D1-D734284272A0@oracle.com>
 <1477357020.23530.5.camel@redhat.com>
 <368D37F5-FEF7-43EB-BD7F-BFDAA6C53EDF@oracle.com>
 <1477359964.23530.11.camel@redhat.com>
 <3F1E6818-8E19-44FC-A434-39BE67FE8170@oracle.com>
 <A6DF0462-6DE5-4D60-9B55-FFBEDFD99102@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <A6DF0462-6DE5-4D60-9B55-FFBEDFD99102@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 27, 2016 at 09:20:41PM -0400, Chuck Lever wrote:
> Just hit this on the server while running xfstests generic/089 on
> NFSv4.0 / RDMA. Still v4.9-rc2 with a few NFS/RDMA patches, but
> no kernel debugging enabled yet.

Weird, I wouldn't even know where to start.  It's not even obvious that
it's an NFS or RDMA bug at all.

--b.

> 
> Oct 27 21:08:42 klimt kernel: general protection fault: 0000 [#1] SMP
> Oct 27 21:08:42 klimt kernel: Modules linked in: cts rpcsec_gss_krb5 sb_edac edac_core x86_pkg_temp_thermal intel_powerclamp coretemp btrfs kvm_intel kvm irqbypass crct10dif_pclmul crc32_pclmul ghash_clmulni_intel aesni_intel xor lrw gf128mul glue_helper ablk_helper cryptd iTCO_wdt iTCO_vendor_support raid6_pq pcspkr lpc_ich i2c_i801 mfd_core i2c_smbus mei_me mei rpcrdma sg ipmi_si shpchp ioatdma wmi ipmi_msghandler ib_ipoib acpi_pad acpi_power_meter rdma_ucm ib_ucm ib_uverbs ib_umad rdma_cm ib_cm iw_cm nfsd auth_rpcgss nfs_acl lockd grace sunrpc ip_tables xfs libcrc32c mlx4_ib ib_core mlx4_en sr_mod cdrom sd_mod ast drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm ahci drm igb libahci libata mlx4_core ptp crc32c_intel pps_core dca i2c_algo_bit i2c_core dm_mirror dm_region_hash dm_log dm_mod
> Oct 27 21:08:42 klimt kernel: CPU: 3 PID: 1649 Comm: nfsd Not tainted 4.9.0-rc2-00004-ga75a35c #3
> Oct 27 21:08:42 klimt kernel: Hardware name: Supermicro Super Server/X10SRL-F, BIOS 1.0c 09/09/2015
> Oct 27 21:08:42 klimt kernel: task: ffff880841474140 task.stack: ffff880841798000
> Oct 27 21:08:42 klimt kernel: RIP: 0010:[<ffffffff811e9a99>]  [<ffffffff811e9a99>] kmem_cache_alloc+0x149/0x1b0
> Oct 27 21:08:42 klimt kernel: RSP: 0018:ffff88084179bc98  EFLAGS: 00010282
> Oct 27 21:08:42 klimt kernel: RAX: 0000000000000000 RBX: 00000000024000c0 RCX: 00000000095755fa
> Oct 27 21:08:42 klimt kernel: RDX: 00000000095755f9 RSI: 00000000024000c0 RDI: ffff88085f007400
> Oct 27 21:08:42 klimt kernel: RBP: ffff88084179bcc8 R08: 000000000001ce30 R09: ffff8808416a1070
> Oct 27 21:08:42 klimt kernel: R10: 0000000000000003 R11: ffff8808416a0220 R12: 00000000024000c0
> Oct 27 21:08:42 klimt kernel: R13: e748f37c723b66c0 R14: ffff88085f007400 R15: ffff88085f007400
> Oct 27 21:08:42 klimt kernel: FS:  0000000000000000(0000) GS:ffff88087fcc0000(0000) knlGS:0000000000000000
> Oct 27 21:08:42 klimt kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> Oct 27 21:08:42 klimt kernel: CR2: 00007f6822890000 CR3: 0000000001c06000 CR4: 00000000001406e0
> Oct 27 21:08:42 klimt kernel: Stack:
> Oct 27 21:08:42 klimt kernel: ffffffff810a4456 0000000011270000 ffff880841474140 ffff880841484000
> Oct 27 21:08:42 klimt kernel: 0000000000000000 ffff88084cbc4a00 ffff88084179bce8 ffffffff810a4456
> Oct 27 21:08:42 klimt kernel: 0000000011270000 ffff8808416a1068 ffff88084179bd58 ffffffffa04c09ed
> Oct 27 21:08:42 klimt kernel: Call Trace:
> Oct 27 21:08:42 klimt kernel: [<ffffffff810a4456>] ? prepare_creds+0x26/0x150
> Oct 27 21:08:42 klimt kernel: [<ffffffff810a4456>] prepare_creds+0x26/0x150
> Oct 27 21:08:42 klimt kernel: [<ffffffffa04c09ed>] fh_verify+0x1ed/0x610 [nfsd]
> Oct 27 21:08:42 klimt kernel: [<ffffffffa04ce6f9>] nfsd4_putfh+0x49/0x50 [nfsd]
> Oct 27 21:08:42 klimt kernel: [<ffffffffa04d01fd>] nfsd4_proc_compound+0x40d/0x690 [nfsd]
> Oct 27 21:08:42 klimt kernel: [<ffffffffa04bd2b4>] nfsd_dispatch+0xd4/0x1d0 [nfsd]
> Oct 27 21:08:42 klimt kernel: [<ffffffffa0430249>] svc_process_common+0x3d9/0x700 [sunrpc]
> Oct 27 21:08:42 klimt kernel: [<ffffffffa04310c1>] svc_process+0xf1/0x1d0 [sunrpc]
> Oct 27 21:08:42 klimt kernel: [<ffffffffa04bcd4f>] nfsd+0xff/0x160 [nfsd]
> Oct 27 21:08:42 klimt kernel: [<ffffffffa04bcc50>] ? nfsd_destroy+0x60/0x60 [nfsd]
> Oct 27 21:08:42 klimt kernel: [<ffffffff810a1f25>] kthread+0xe5/0xf0
> Oct 27 21:08:42 klimt kernel: [<ffffffff810a1e40>] ? kthread_stop+0x120/0x120
> Oct 27 21:08:42 klimt kernel: [<ffffffff816aa795>] ret_from_fork+0x25/0x30
> Oct 27 21:08:42 klimt kernel: Code: d0 41 ff d2 4d 8b 55 00 4d 85 d2 75 dc eb d1 81 e3 00 00 10 00 0f 84 0a ff ff ff e9 0f ff ff ff 49 63 47 20 48 8d 4a 01 4d 8b 07 <49> 8b 5c 05 00 4c 89 e8 65 49 0f c7 08 0f 94 c0 84 c0 0f 85 45 
> Oct 27 21:08:42 klimt kernel: RIP  [<ffffffff811e9a99>] kmem_cache_alloc+0x149/0x1b0
> Oct 27 21:08:42 klimt kernel: RSP <ffff88084179bc98>
> Oct 27 21:08:42 klimt kernel: ---[ end trace 0bf398a5b035df79 ]---
> 
> Looks rather similar:
> 
> (gdb) list *(kmem_cache_alloc+0x149)
> 0xffffffff811e9a99 is in kmem_cache_alloc (/home/cel/src/linux/linux-2.6/mm/slub.c:241).
> 236	 * 			Core slab cache functions
> 237	 *******************************************************************/
> 238	
> 239	static inline void *get_freepointer(struct kmem_cache *s, void *object)
> 240	{
> 241		return *(void **)(object + s->offset);
> 242	}
> 243	
> 244	static void prefetch_freepointer(const struct kmem_cache *s, void *object)
> 245	{
> (gdb) 
> 
> 
> --
> Chuck Lever
> 
> 
