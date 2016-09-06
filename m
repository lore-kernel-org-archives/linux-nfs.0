Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:47730 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934248AbcIFUmj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Sep 2016 16:42:39 -0400
Date: Tue, 6 Sep 2016 16:42:38 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org, bcodding@redhat.com
Subject: Re: [PATCH] svcauth_gss: Revert 64c59a3726f2 ("Remove unnecessary
 allocation")
Message-ID: <20160906204238.GA30260@fieldses.org>
References: <20160901144839.6035.63068.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160901144839.6035.63068.stgit@klimt.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 01, 2016 at 10:50:38AM -0400, Chuck Lever wrote:
> On occasion I see this on my server:
> 
> kernel: kernel BUG at /home/cel/src/linux/linux-2.6/mm/slub.c:3851!
> kernel: invalid opcode: 0000 [#1] SMP
> kernel: Modules linked in: cts rpcsec_gss_krb5 sb_edac edac_core x86_pkg_temp_thermal intel_powerclamp coretemp kvm_intel kvm irqbypass crct10dif_pclmul crc32_pclmul ghash_clmulni_intel aesni_intel lrw gf128mul glue_helper ablk_helper cryptd btrfs xor iTCO_wdt iTCO_vendor_support raid6_pq pcspkr i2c_i801 i2c_smbus lpc_ich mfd_core mei_me sg mei shpchp wmi ioatdma ipmi_si ipmi_msghandler acpi_pad acpi_power_meter rpcrdma ib_ipoib rdma_ucm ib_ucm ib_uverbs ib_umad rdma_cm ib_cm iw_cm nfsd nfs_acl lockd grace auth_rpcgss sunrpc ip_tables xfs libcrc32c mlx4_ib mlx4_en ib_core sr_mod cdrom sd_mod ast drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm drm crc32c_intel igb mlx4_core ahci libahci libata ptp pps_core dca i2c_algo_bit i2c_core dm_mirror dm_region_hash dm_log dm_mod
> kernel: CPU: 7 PID: 145 Comm: kworker/7:2 Not tainted 4.8.0-rc4-00006-g9d06b0b #15
> kernel: Hardware name: Supermicro Super Server/X10SRL-F, BIOS 1.0c 09/09/2015
> kernel: Workqueue: events do_cache_clean [sunrpc]
> kernel: task: ffff8808541d8000 task.stack: ffff880854344000
> kernel: RIP: 0010:[<ffffffff811e7075>]  [<ffffffff811e7075>] kfree+0x155/0x180
> kernel: RSP: 0018:ffff880854347d70  EFLAGS: 00010246
> kernel: RAX: ffffea0020fe7660 RBX: ffff88083f9db064 RCX: 146ff0f9d5ec5600
> kernel: RDX: 000077ff80000000 RSI: ffff880853f01500 RDI: ffff88083f9db064
> kernel: RBP: ffff880854347d88 R08: ffff8808594ee000 R09: ffff88087fdd8780
> kernel: R10: 0000000000000000 R11: ffffea0020fe76c0 R12: ffff880853f01500
> kernel: R13: ffffffffa013cf76 R14: ffffffffa013cff0 R15: ffffffffa04253a0
> kernel: FS:  0000000000000000(0000) GS:ffff88087fdc0000(0000) knlGS:0000000000000000
> kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> kernel: CR2: 00007fed60b020c3 CR3: 0000000001c06000 CR4: 00000000001406e0
> kernel: Stack:
> kernel: ffff8808589f2f00 ffff880853f01500 0000000000000001 ffff880854347da0
> kernel: ffffffffa013cf76 ffff8808589f2f00 ffff880854347db8 ffffffffa013d006
> kernel: ffff8808589f2f20 ffff880854347e00 ffffffffa0406f60 0000000057c7044f
> kernel: Call Trace:
> kernel: [<ffffffffa013cf76>] rsc_free+0x16/0x90 [auth_rpcgss]
> kernel: [<ffffffffa013d006>] rsc_put+0x16/0x30 [auth_rpcgss]
> kernel: [<ffffffffa0406f60>] cache_clean+0x2e0/0x300 [sunrpc]
> kernel: [<ffffffffa04073ee>] do_cache_clean+0xe/0x70 [sunrpc]
> kernel: [<ffffffff8109a70f>] process_one_work+0x1ff/0x3b0
> kernel: [<ffffffff8109b15c>] worker_thread+0x2bc/0x4a0
> kernel: [<ffffffff8109aea0>] ? rescuer_thread+0x3a0/0x3a0
> kernel: [<ffffffff810a0ba4>] kthread+0xe4/0xf0
> kernel: [<ffffffff8169c47f>] ret_from_fork+0x1f/0x40
> kernel: [<ffffffff810a0ac0>] ? kthread_stop+0x110/0x110
> kernel: Code: f7 ff ff eb 3b 65 8b 05 da 30 e2 7e 89 c0 48 0f a3 05 a0 38 b8 00 0f 92 c0 84 c0 0f 85 d1 fe ff ff 0f 1f 44 00 00 e9 f5 fe ff ff <0f> 0b 49 8b 03 31 f6 f6 c4 40 0f 85 62 ff ff ff e9 61 ff ff ff
> kernel: RIP  [<ffffffff811e7075>] kfree+0x155/0x180
> kernel: RSP <ffff880854347d70>
> kernel: ---[ end trace 3fdec044969def26 ]---
> 
> It seems to be most common after a server reboot where a client has been
> using a Kerberos mount, and reconnects to continue its workload.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> Hi Bruce-
> 
> I've hit this off-and-on oops since 64c59a3726f2 was merged.
> Reverting it seems to make the problem go away. I haven't dug
> into why.
> 
> Thoughts?

Apologies, I wasn't thinking when I wrote that patch.  The problem is
probably that rsc_lookup steals the passed-in memory to avoid doing an
allocation of its own, so we can't just pass in a pointer to memory that
someone else is using....

If we really want to avoid allocation there then maybe we should
preallocate somwhere, or reference count these handles.

For now reverting sounds like the right thing to do.

Ben, did you ever confirm whether this helped with the problem you were
seeing?  (If I remember correctly, unnpredictable delays here could
cause the request to be dropped if later requests push the rpcsec_gss
sequence window too far.)  If so then we could look into reference
counting.

--b.

> 
> 
>  net/sunrpc/auth_gss/svcauth_gss.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
> index 1d28181..d858202 100644
> --- a/net/sunrpc/auth_gss/svcauth_gss.c
> +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> @@ -569,9 +569,10 @@ gss_svc_searchbyctx(struct cache_detail *cd, struct xdr_netobj *handle)
>  	struct rsc *found;
>  
>  	memset(&rsci, 0, sizeof(rsci));
> -	rsci.handle.data = handle->data;
> -	rsci.handle.len = handle->len;
> +	if (dup_to_netobj(&rsci.handle, handle->data, handle->len))
> +		return NULL;
>  	found = rsc_lookup(cd, &rsci);
> +	rsc_free(&rsci);
>  	if (!found)
>  		return NULL;
>  	if (cache_check(cd, &found->h, NULL))
