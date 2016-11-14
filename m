Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46634 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936435AbcKNUTA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 14 Nov 2016 15:19:00 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trond.myklebust@primarydata.com>,
        "Anna Schumaker" <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSv4.1: Don't allow a lock_state to be freed while
 checking
Date: Mon, 14 Nov 2016 15:18:57 -0500
Message-ID: <00FD5260-0053-45B0-B0FB-2B2F53947E39@redhat.com>
In-Reply-To: <0e6e9dac991cd93e2ae3e6a4b4b41bd974a040cb.1479142099.git.bcodding@redhat.com>
References: <0e6e9dac991cd93e2ae3e6a4b4b41bd974a040cb.1479142099.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 14 Nov 2016, at 11:50, Benjamin Coddington wrote:

> While walking the list of lock_states, keep the current 
> nfs4_lock_state
> referenced so that it isn't freed while checking.
>
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
>  fs/nfs/nfs4proc.c | 12 +++++++++---
>  1 file changed, 9 insertions(+), 3 deletions(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 7897826d7c51..9a1cb9e8c4fc 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2564,12 +2564,15 @@ static void 
> nfs41_check_delegation_stateid(struct nfs4_state *state)
>  static int nfs41_check_expired_locks(struct nfs4_state *state)
>  {
>  	int status, ret = NFS_OK;
> -	struct nfs4_lock_state *lsp;
> +	struct nfs4_lock_state *lsp, *tmp;
>  	struct nfs_server *server = NFS_SERVER(state->inode);
>
>  	if (!test_bit(LK_STATE_IN_USE, &state->flags))
>  		goto out;
> -	list_for_each_entry(lsp, &state->lock_states, ls_locks) {
> +	spin_lock(&state->state_lock);
> +	list_for_each_entry_safe(lsp, tmp, &state->lock_states, ls_locks) {
> +		atomic_inc(&lsp->ls_count);
> +		spin_unlock(&state->state_lock);
>  		if (test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags)) {
>  			struct rpc_cred *cred = lsp->ls_state->owner->so_cred;
>
> @@ -2588,7 +2591,10 @@ static int nfs41_check_expired_locks(struct 
> nfs4_state *state)
>  				break;
>  			}
>  		}
> -	};
> +		nfs4_put_lock_state(lsp);
> +		spin_lock(&state->state_lock);
> +	}
> +	spin_unlock(&state->state_lock);
>  out:
>  	return ret;
>  }

Actually, something else may be wrong here.. after several more hours of
testing with this and Trond's two fixes for CLOSE races this popped up:

[ 8102.015071] BUG: unable to handle kernel NULL pointer dereference at 
0000000000000048
[ 8102.015985] IP: [<ffffffff8182717c>] _raw_spin_lock+0xc/0x30
[ 8102.016622] PGD 0
[ 8102.016829]
[ 8102.017014] Oops: 0002 [#1] SMP
[ 8102.017357] Modules linked in: nfsv4 dns_resolver nfs ip6t_rpfilter 
ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat 
ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 
nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw 
ip6table_security iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 
nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw 
iptable_security ebtable_filter ebtables ip6table_filter ip6_tables nfsd 
auth_rpcgss nfs_acl lockd grace sunrpc virtio_balloon virtio_console 
virtio_net virtio_blk crct10dif_pclmul ppdev crc32_pclmul crc32c_intel 
ghash_clmulni_intel virtio_pci serio_raw i2c_piix4 virtio_ring virtio 
ata_generic parport_pc pata_acpi parport acpi_cpufreq tpm_tis 
tpm_tis_core tpm
[ 8102.025180] CPU: 3 PID: 4475 Comm: ::1-manager Not tainted 
4.9.0-rc5-00268-gbb3ec452d27c #45
[ 8102.026093] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), 
BIOS 1.8.1-20150318_183358- 04/01/2014
[ 8102.027122] task: ffff880132b93a80 task.stack: ffffc90003200000
[ 8102.027769] RIP: 0010:[<ffffffff8182717c>]  [<ffffffff8182717c>] 
_raw_spin_lock+0xc/0x30
[ 8102.028657] RSP: 0018:ffffc90003203d40  EFLAGS: 00010246
[ 8102.029227] RAX: 0000000000000000 RBX: ffff880132d9c31c RCX: 
0000000000000001
[ 8102.029996] RDX: 0000000000000001 RSI: 0000000000000048 RDI: 
0000000000000048
[ 8102.030771] RBP: ffffc90003203d58 R08: 0000000032b45601 R09: 
000000018010000e
[ 8102.031532] R10: 000000008010000e R11: 0000000000100000 R12: 
0000000000000048
[ 8102.032291] R13: 0000000000000000 R14: 0000000000000000 R15: 
ffff880139fc2050
[ 8102.033064] FS:  0000000000000000(0000) GS:ffff88013fd80000(0000) 
knlGS:0000000000000000
[ 8102.033930] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 8102.034546] CR2: 0000000000000048 CR3: 0000000139678000 CR4: 
00000000000406e0
[ 8102.035312] Stack:
[ 8102.035542]  ffffffff81489818 ffff880132d9c200 0000000000000000 
ffffc90003203d78
[ 8102.036400]  ffffffffa02f9289 ffff8801314f29c0 0000000000000000 
ffffc90003203de8
[ 8102.037259]  ffffffffa02e3dd2 ffff88013393f000 ffff8801314f29e0 
ffff8801314f2a08
[ 8102.038120] Call Trace:
[ 8102.038392]  [<ffffffff81489818>] ? _atomic_dec_and_lock+0x48/0x5b
[ 8102.039073]  [<ffffffffa02f9289>] nfs4_put_lock_state+0x29/0x90 
[nfsv4]
[ 8102.039797]  [<ffffffffa02e3dd2>] nfs41_open_expired+0x192/0x410 
[nfsv4]
[ 8102.040523]  [<ffffffffa02f859f>] nfs4_do_reclaim+0x1af/0x630 [nfsv4]
[ 8102.041227]  [<ffffffffa02f8f30>] nfs4_run_state_manager+0x510/0x7d0 
[nfsv4]
[ 8102.041995]  [<ffffffffa02f8a20>] ? nfs4_do_reclaim+0x630/0x630 
[nfsv4]
[ 8102.042719]  [<ffffffffa02f8a20>] ? nfs4_do_reclaim+0x630/0x630 
[nfsv4]
[ 8102.043434]  [<ffffffff810c96a9>] kthread+0xd9/0xf0
[ 8102.043968]  [<ffffffff810c95d0>] ? kthread_park+0x60/0x60
[ 8102.044559]  [<ffffffff81827615>] ret_from_fork+0x25/0x30
[ 8102.045150] Code: c0 ba 01 00 00 00 f0 0f b1 17 85 c0 75 02 5d c3 89 
c6 e8 18 db 8c ff 5d c3 66 0f 1f 44 00 00 66 66 66 66 90 31 c0 ba 01 00 
00 00 <f0> 0f b1 17 85 c0 75 01 c3 55 89 c6 48 89 e5 e8 f0 da 8c ff 5d
[ 8102.048136] RIP  [<ffffffff8182717c>] _raw_spin_lock+0xc/0x30
[ 8102.048775]  RSP <ffffc90003203d40>
[ 8102.049153] CR2: 0000000000000048
[ 8102.049893] ---[ end trace 8dc47952e274960a ]---
[ 8102.050391] Kernel panic - not syncing: Fatal exception
[ 8102.051090] Kernel Offset: disabled
[ 8102.051475] ---[ end Kernel panic - not syncing: Fatal exception

OK, it now looks like the nfs4_state has been freed while walking the 
list of
lock_states.  I'll have to look at this a bit more tomorrow.  I have to 
ferry
the kids around now.

Ben
