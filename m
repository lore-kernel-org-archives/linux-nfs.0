Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga09.intel.com ([134.134.136.24]:34109 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753942AbaCCGof (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Mar 2014 01:44:35 -0500
Message-ID: <531424D1.2020309@intel.com>
Date: Mon, 03 Mar 2014 14:44:33 +0800
From: "Yan, Zheng" <zheng.z.yan@intel.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [BUG] NULL pointer dereference in nfs4_match_stateid()
References: <5313E9F6.2020405@intel.com> <1393816686.6850.0.camel@leira.trondhjem.org>
In-Reply-To: <1393816686.6850.0.camel@leira.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/03/2014 11:18 AM, Trond Myklebust wrote:
> On Mon, 2014-03-03 at 10:33 +0800, Yan, Zheng wrote:
>> Hi,
>>
>> I got following Oops when running fsstress
>> ---
>> [ 2536.142216] BUG: unable to handle kernel NULL pointer dereference at 0000000000000020
>> [ 2536.143110] IP: [<ffffffff813391d9>] memcmp+0x9/0x50
>> [ 2536.143110] PGD 0
>> [ 2536.143110] Oops: 0000 [#1] SMP
>> [ 2536.143110] Modules linked in: rpcsec_gss_krb5(F) auth_rpcgss(F) nfsv4(F) dns_resolver(F) nfs(F) fscache(F) ceph(F) libceph(F) libcrc32c(F) netconsole(F) ip6table_filter(F) ip6_tables(F) ebtable_nat(F) ebtables(F) ipt_MASQUERADE(F) iptable_nat(F) nf_nat_ipv4(F) nf_nat(F) nf_conntrack_ipv4(F) nf_defrag_ipv4(F) xt_state(F) nf_conntrack(F) xt_CHECKSUM(F) iptable_mangle(F) bnep(F) bluetooth(F) 6lowpan_iphc(F) bridge(F) lockd(F) sunrpc(F) rfkill(F) be2iscsi(F) iscsi_boot_sysfs(F) stp(F) llc(F) bnx2i(F) cnic(F) uio(F) cxgb4i(F) cxgb4(F) cxgb3i(F) cxgb3(F) mdio(F) libcxgbi(F) ib_iser(F) rdma_cm(F) iw_cm(F) ib_cm(F) ib_sa(F) ib_mad(F) ib_core(F) ib_addr(F) iscsi_tcp(F) libiscsi_tcp(F) libiscsi(F) scsi_transport_iscsi(F) virtio_net(F) virtio_balloon(F) pcspkr(F) microcode(F) uinput(F) cirrus(F) drm_kms_helper(F) ttm(F) drm(F) i2c_core(F)
>> [ 2536.143110] CPU: 1 PID: 2925 Comm: nfsv4.0-svc Tainted: GF            3.14.0-rc4+ #50
>> [ 2536.143110] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
>> [ 2536.143110] task: ffff88003cd55aa0 ti: ffff88003c9a8000 task.ti: ffff88003c9a8000
>> [ 2536.143110] RIP: 0010:[<ffffffff813391d9>]  [<ffffffff813391d9>] memcmp+0x9/0x50
>> [ 2536.143110] RSP: 0018:ffff88003c9a9ca8  EFLAGS: 00010202
>> [ 2536.143110] RAX: ffffffffa04842c0 RBX: 0000000000000000 RCX: 0000000000000036
>> [ 2536.143110] RDX: 0000000000000010 RSI: ffff880035ee808a RDI: 0000000000000020
>> [ 2536.143110] RBP: ffff88003c9a9ca8 R08: 8020000000000000 R09: 00231b6840100000
>> [ 2536.143110] R10: ffbee4a086ca1004 R11: 0000000000000000 R12: ffff88003751e000
>> [ 2536.143110] R13: ffff880034afa000 R14: ffff880035ee808a R15: 0000000000000004
>> [ 2536.143110] FS:  0000000000000000(0000) GS:ffff88003fc80000(0000) knlGS:0000000000000000
>> [ 2536.143110] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>> [ 2536.143110] CR2: 0000000000000020 CR3: 0000000034bc0000 CR4: 00000000000006e0
>> [ 2536.143110] Stack:
>> [ 2536.143110]  ffff88003c9a9cb8 ffffffffa0455883 ffff88003c9a9cf0 ffffffffa0472b98
>> [ 2536.143110]  ffff880035ee8000 ffff880035ee8000 ffff8800231b6970 0000000011270000
>> [ 2536.143110]  0000000000000000 ffff88003c9a9d28 ffffffffa0475fc9 ffff88003c9a9d28
>> [ 2536.143110] Call Trace:
>> [ 2536.143110]  [<ffffffffa0455883>] nfs4_match_stateid+0x13/0x20 [nfsv4]
>> [ 2536.143110]  [<ffffffffa0472b98>] nfs_async_inode_return_delegation+0x48/0x90 [nfsv4]
>> [ 2536.143110]  [<ffffffffa0475fc9>] nfs4_callback_recall+0x59/0x130 [nfsv4]
>> [ 2536.143110]  [<ffffffffa0475005>] nfs4_callback_compound+0x465/0x6a0 [nfsv4]
>> [ 2536.143110]  [<ffffffffa0220c1a>] ? svcauth_unix_accept+0x14a/0x270 [sunrpc]
>> [ 2536.143110]  [<ffffffffa021c707>] svc_process_common+0x5e7/0x6e0 [sunrpc]
>> [ 2536.143110]  [<ffffffffa0473e80>] ? nfs_callback_authenticate+0x50/0x50 [nfsv4]
>> [ 2536.143110]  [<ffffffffa021c907>] svc_process+0x107/0x170 [sunrpc]
>> [ 2536.143110]  [<ffffffffa0473e80>] ? nfs_callback_authenticate+0x50/0x50 [nfsv4]
>> [ 2536.143110]  [<ffffffffa0473ec5>] nfs4_callback_svc+0x45/0x60 [nfsv4]
>> [ 2536.143110]  [<ffffffff810a4a52>] kthread+0xd2/0xf0
>> [ 2536.143110]  [<ffffffff810a4980>] ? insert_kthread_work+0x40/0x40
>> [ 2536.143110]  [<ffffffff816b567c>] ret_from_fork+0x7c/0xb0
>> [ 2536.143110]  [<ffffffff810a4980>] ? insert_kthread_work+0x40/0x40
>> [ 2536.143110] Code: 75 e9 31 c0 c6 06 01 5d c3 66 0f 1f 84 00 00 00 00 00 31 c0 c6 06 00 5d c3 66 0f 1f 84 00 00 00 00 00 55 48 85 d2 48 89 e5 74 3c <0f> b6 07 0f b6 0e 29 c8 75 27 48 83 ea 01 31 c9 eb 1a 0f 1f 44
>> [ 2536.143110] RIP  [<ffffffff813391d9>] memcmp+0x9/0x50
>> [ 2536.143110]  RSP <ffff88003c9a9ca8>
>> [ 2536.143110] CR2: 0000000000000020
>> [ 2536.143110] ---[ end trace 145a1eb5268045c7 ]---
> 
> Does the following patch help?
> 

I have run the same test for hours. It seems the patch works.

Regards
Yan, Zheng

> Cheers
>   Trond
> 8<---------------------------------------------------------------
> From 755a48a7a4eb05b9c8424e3017d947b2961a60e0 Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> Date: Sun, 2 Mar 2014 22:03:12 -0500
> Subject: [PATCH] NFS: Fix a delegation callback race
> 
> The clean-up in commit 36281caa839f ended up removing a NULL pointer check
> that is needed in order to prevent an Oops in
> nfs_async_inode_return_delegation().
> 
> Reported-by: "Yan, Zheng" <zheng.z.yan@intel.com>
> Link: http://lkml.kernel.org/r/5313E9F6.2020405@intel.com
> Fixes: 36281caa839f (NFSv4: Further clean-ups of delegation stateid validation)
> Cc: stable@vger.kernel.org # 3.4+
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/delegation.c | 11 +++++++----
>  1 file changed, 7 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
> index ef792f29f831..5d8ccecf5f5c 100644
> --- a/fs/nfs/delegation.c
> +++ b/fs/nfs/delegation.c
> @@ -659,16 +659,19 @@ int nfs_async_inode_return_delegation(struct inode *inode,
>  
>  	rcu_read_lock();
>  	delegation = rcu_dereference(NFS_I(inode)->delegation);
> +	if (delegation == NULL)
> +		goto out_enoent;
>  
> -	if (!clp->cl_mvops->match_stateid(&delegation->stateid, stateid)) {
> -		rcu_read_unlock();
> -		return -ENOENT;
> -	}
> +	if (!clp->cl_mvops->match_stateid(&delegation->stateid, stateid))
> +		goto out_enoent;
>  	nfs_mark_return_delegation(server, delegation);
>  	rcu_read_unlock();
>  
>  	nfs_delegation_run_state_manager(clp);
>  	return 0;
> +out_enoent:
> +	rcu_read_unlock();
> +	return -ENOENT;
>  }
>  
>  static struct inode *
> 

