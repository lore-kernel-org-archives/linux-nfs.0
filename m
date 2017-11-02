Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:37131 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933542AbdKBO4q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Nov 2017 10:56:46 -0400
Subject: Re: [PATCH] lockd: lost rollback of set_grace_period() in
 lockd_down_net()
To: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>
References: <fb8ccaec-e163-0b47-6fa0-e85de7abd6a8@virtuozzo.com>
From: Vasily Averin <vvs@virtuozzo.com>
Message-ID: <57cf271b-2b98-7f64-d706-59d757997bcf@virtuozzo.com>
Date: Thu, 2 Nov 2017 17:56:35 +0300
MIME-Version: 1.0
In-Reply-To: <fb8ccaec-e163-0b47-6fa0-e85de7abd6a8@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Without this patch kernel crashes after:

1) start new netns
# unshare -m -n

2) start nfsd inside
# mount -t nfsd nfsd /proc/fs/nfsd
# echo 1 > /proc/fs/nfsd/threads

3) stop nfsd
# echo 0 > /proc/fs/nfsd/threads

4) destroy netns
# logout (exit fromshell executed by unshare)

[103026.179908] NFSD: starting 90-second grace period (net ffff8eeeb07949c0) <<< start nfsd
[103029.839058] nfsd: last server has exited, flushing export cache          <<< stop nfsd
[103034.305184] ------------[ cut here ]------------                         <<< destroy netns
[103034.305835] kernel BUG at fs/nfs_common/grace.c:111!
[103034.306132] invalid opcode: 0000 [#1] SMP
[103034.306392] Modules linked in: binfmt_misc nfsd auth_rpcgss nfs_acl lockd grace ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw ip6table_security iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw iptable_security ebtable_filter ebtables ip6table_filter ip6_tables sunrpc crct10dif_pclmul crc32_pclmul ghash_clmulni_intel joydev i2c_piix4 ppdev parport_pc pvpanic virtio_balloon parport pcspkr xfs libcrc32c virtio_console virtio_net virtio_scsi bochs_drm drm_kms_helper crc32c_intel ttm drm serio_raw virtio_pci virtio_ring virtio ata_generic pata_acpi floppy
[103034.307115] CPU: 3 PID: 3441 Comm: kworker/u16:2 Tainted: G        W       4.14.0-rc6+ #2
[103034.307115] Hardware name: Virtuozzo KVM, BIOS 1.9.1-5.3.2.vz7.7 04/01/2014
[103034.307115] Workqueue: netns cleanup_net
[103034.307115] task: ffff8eeefcb9d040 task.stack: ffff9cf8816c4000
[103034.307115] RIP: 0010:grace_exit_net+0x24/0x30 [grace]
[103034.307115] RSP: 0018:ffff9cf8816c7de0 EFLAGS: 00010283
[103034.307115] RAX: ffff8eeeca139768 RBX: ffff8eeeb07949c0 RCX: fffff997000c6500
[103034.307115] RDX: ffff8eeee282cad0 RSI: ffffffffc07b9020 RDI: ffff8eeeb07949c0
[103034.307115] RBP: ffff9cf8816c7de0 R08: ffff8eee83195038 R09: 00000001001b0019
[103034.307115] R10: ffff9cf8816c7d60 R11: 0000000000000000 R12: ffff9cf8816c7e38
[103034.307115] R13: ffffffffc07b9018 R14: ffffffffc07b9020 R15: 00000000ffffffff
[103034.307115] FS:  0000000000000000(0000) GS:ffff8eeeffcc0000(0000) knlGS:0000000000000000
[103034.307115] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[103034.307115] CR2: 00005632ccdcaa98 CR3: 000000000be09002 CR4: 00000000001606e0
[103034.307115] Call Trace:
[103034.307115]  ops_exit_list.isra.6+0x38/0x60
[103034.307115]  cleanup_net+0x1e2/0x2e0
[103034.307115]  process_one_work+0x193/0x3c0
[103034.307115]  worker_thread+0x35/0x3b0
[103034.307115]  kthread+0x125/0x140
[103034.307115]  ? process_one_work+0x3c0/0x3c0
[103034.307115]  ? kthread_park+0x60/0x60
[103034.307115]  ? kthread_park+0x60/0x60
[103034.307115]  ret_from_fork+0x25/0x30
[103034.307115] Code: 1f 84 00 00 00 00 00 0f 1f 44 00 00 8b 15 c9 22 00 00 48 8b 87 78 12 00 00 48 8b 04 d0 48 8b 10 48 39 d0 75 02 f3 c3 55 48 89 e5 <0f> 0b 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 55 8b 15 98 
[103034.307115] RIP: grace_exit_net+0x24/0x30 [grace] RSP: ffff9cf8816c7de0

On 2017-11-02 13:03, Vasily Averin wrote:
> Commit efda760fe95ea ("lockd: fix lockd shutdown race") is incorrect,
> it removes lockd_manager and disarm grace_period_end for init_net only. 
> 
> If nfsd was started from another net namespace lockd_up_net() calls 
> set_grace_period() that adds lockd_manager into per-netns list
> and queues grace_period_end delayed work.
> 
> These action should be reverted in lockd_down_net().
> Otherwise it can lead to double list_add on after restart nfsd in netns,
> and to use-after-free if non-disarmed delayed work will be executed after netns destroy.  
> 
> Fixes commit efda760fe95e ("lockd: fix lockd shutdown race")
> 
> Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
> ---
>  fs/lockd/svc.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
> index c1573860..809cbcc 100644
> --- a/fs/lockd/svc.c
> +++ b/fs/lockd/svc.c
> @@ -277,6 +277,8 @@ static void lockd_down_net(struct svc_serv *serv, struct net *net)
>  	if (ln->nlmsvc_users) {
>  		if (--ln->nlmsvc_users == 0) {
>  			nlm_shutdown_hosts_net(net);
> +			cancel_delayed_work_sync(&ln->grace_period_end);
> +			locks_end_grace(&ln->lockd_manager);
>  			svc_shutdown_net(serv, net);
>  			dprintk("lockd_down_net: per-net data destroyed; net=%p\n", net);
>  		}
> 
