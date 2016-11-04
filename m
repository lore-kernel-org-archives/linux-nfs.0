Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48186 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935059AbcKDQC6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 4 Nov 2016 12:02:58 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trond.myklebust@primarydata.com>
Cc: anna.schumaker@netapp.com, linux-nfs@vger.kernel.org,
        "Oleg Drokin" <green@linuxhacker.ru>
Subject: Re: [PATCH v7 13/31] NFSv4.1: Ensure we always run TEST/FREE_STATEID
 on locks
Date: Fri, 04 Nov 2016 12:02:55 -0400
Message-ID: <599EE56B-46DD-411B-805D-11C2FB5E30A4@redhat.com>
In-Reply-To: <1474565961-21303-14-git-send-email-trond.myklebust@primarydata.com>
References: <1474565961-21303-1-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-2-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-3-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-4-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-5-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-6-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-7-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-8-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-9-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-10-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-11-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-12-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-13-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-14-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

On 22 Sep 2016, at 13:39, Trond Myklebust wrote:

> Right now, we're only running TEST/FREE_STATEID on the locks if
> the open stateid recovery succeeds. The protocol requires us to
> always do so.
> The fix would be to move the call to TEST/FREE_STATEID and do it
> before we attempt open recovery.
>
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/nfs4proc.c | 92 
> +++++++++++++++++++++++++++++++------------------------
>  1 file changed, 52 insertions(+), 40 deletions(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 3c1b8cb7dd95..33ca6d768bd2 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2486,6 +2486,45 @@ static void 
> nfs41_check_delegation_stateid(struct nfs4_state *state)
>  }
>
>  /**
> + * nfs41_check_expired_locks - possibly free a lock stateid
> + *
> + * @state: NFSv4 state for an inode
> + *
> + * Returns NFS_OK if recovery for this stateid is now finished.
> + * Otherwise a negative NFS4ERR value is returned.
> + */
> +static int nfs41_check_expired_locks(struct nfs4_state *state)
> +{
> +	int status, ret = NFS_OK;
> +	struct nfs4_lock_state *lsp;
> +	struct nfs_server *server = NFS_SERVER(state->inode);
> +
> +	if (!test_bit(LK_STATE_IN_USE, &state->flags))
> +		goto out;
> +	list_for_each_entry(lsp, &state->lock_states, ls_locks) {
> +		if (test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags)) {

I bisected a crash to this patch (commit 
c5896fc8622d57b31e1e98545d67d7089019e478).
I thought the problem was that this patch moved this path out from under 
the
nfsi->rwsem in nfs4_reclaim_locks() so it ends up with a freed
nfs4_lock_state here.  So I tried the following fixup, but it doesn't 
help:

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b5290fd..2f51200 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2559,9 +2559,13 @@ static int nfs41_check_open_stateid(struct 
nfs4_state *state)
  static int nfs41_open_expired(struct nfs4_state_owner *sp, struct 
nfs4_state *state)
  {
         int status;
+       struct inode *inode = state->inode;
+       struct nfs_inode *nfsi = NFS_I(inode);

         nfs41_check_delegation_stateid(state);
+       down_write(&nfsi->rwsem);
         status = nfs41_check_expired_locks(state);
+       up_write(&nfsi->rwsem);
         if (status != NFS_OK)
                 return status;
         status = nfs41_check_open_stateid(state);

I can reproduce this with generic/089.  Any ideas?

[ 1113.492603] BUG: unable to handle kernel NULL pointer dereference at 
0000000000000018
[ 1113.493553] IP: [<ffffffffa02d1987>] nfs41_open_expired+0xb7/0x380 
[nfsv4]
[ 1113.494355] PGD 132363067 PUD 1387b7067 PMD 0
[ 1113.494908] Oops: 0000 [#1] SMP
[ 1113.495274] Modules linked in: nfsv4 dns_resolver nfs ip6t_rpfilter 
ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_broute 
bridge stp llc ebtable_nat ip6table_security ip6table_mangle 
ip6table_raw ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 
iptable_security iptable_mangle iptable_raw iptable_nat 
nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack 
ebtable_filter ebtables ip6table_filter ip6_tables nfsd auth_rpcgss 
nfs_acl lockd grace sunrpc virtio_balloon virtio_net virtio_console 
virtio_blk ppdev crct10dif_pclmul crc32_pclmul crc32c_intel 
ghash_clmulni_intel parport_pc parport serio_raw acpi_cpufreq tpm_tis 
virtio_pci tpm_tis_core ata_generic virtio_ring pata_acpi virtio 
i2c_piix4 tpm
[ 1113.503438] CPU: 3 PID: 3008 Comm: ::1-manager Not tainted 
4.8.0-rc7-00073-gf746650 #31
[ 1113.504329] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), 
BIOS 1.8.1-20150318_183358- 04/01/2014
[ 1113.505476] task: ffff88013a469d40 task.stack: ffff8801386cc000
[ 1113.506140] RIP: 0010:[<ffffffffa02d1987>]  [<ffffffffa02d1987>] 
nfs41_open_expired+0xb7/0x380 [nfsv4]
[ 1113.507202] RSP: 0018:ffff8801386cfd98  EFLAGS: 00010203
[ 1113.507794] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 
0000000000000000
[ 1113.508586] RDX: 00000000003ce306 RSI: ffff88013fd9c940 RDI: 
ffff880138e5ca00
[ 1113.509385] RBP: ffff8801386cfde8 R08: 000000000001c940 R09: 
ffff88013537e300
[ 1113.510182] R10: ffff88013537e338 R11: ffff88013fd99d88 R12: 
ffff8801384820c0
[ 1113.510977] R13: 0000000000000000 R14: ffff8801384820e0 R15: 
ffff880138496650
[ 1113.511770] FS:  0000000000000000(0000) GS:ffff88013fd80000(0000) 
knlGS:0000000000000000
[ 1113.512672] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1113.513318] CR2: 0000000000000018 CR3: 0000000132600000 CR4: 
00000000000406e0
[ 1113.514116] Stack:
[ 1113.514352]  ffff880131839000 ffff880139fab000 ffff8801386cfda8 
ffff8801386cfda8
[ 1113.515244]  00000000530c0386 ffff8801384820c0 ffffffffa03012a0 
ffff880138496650
[ 1113.516139]  ffffffffa03012a0 ffff880138496650 ffff8801386cfe80 
ffffffffa02e615f
[ 1113.517030] Call Trace:
[ 1113.517330]  [<ffffffffa02e615f>] nfs4_do_reclaim+0x1af/0x610 [nfsv4]
[ 1113.518067]  [<ffffffffa02e6ad0>] nfs4_run_state_manager+0x510/0x7d0 
[nfsv4]
[ 1113.518854]  [<ffffffffa02e65c0>] ? nfs4_do_reclaim+0x610/0x610 
[nfsv4]
[ 1113.519606]  [<ffffffffa02e65c0>] ? nfs4_do_reclaim+0x610/0x610 
[nfsv4]
[ 1113.520366]  [<ffffffff810c62c8>] kthread+0xd8/0xf0
[ 1113.520930]  [<ffffffff8180653f>] ret_from_fork+0x1f/0x40
[ 1113.521542]  [<ffffffff810c61f0>] ? kthread_worker_fn+0x170/0x170
[ 1113.522227] Code: 44 24 40 a8 01 0f 84 ee 00 00 00 49 8b 5c 24 20 4d 
8d 74 24 20 49 39 de 75 11 e9 da 00 00 00 48 8b 1b 4c 39 f3 0f 84 ba 00 
00 00 <48> 8b 43 18 a8 01 74 ec 48 8b 43 10 48 8b 3c 24 48 8d b3 08 01
[ 1113.525343] RIP  [<ffffffffa02d1987>] nfs41_open_expired+0xb7/0x380 
[nfsv4]
[ 1113.526149]  RSP <ffff8801386cfd98>
[ 1113.526545] CR2: 0000000000000018
[ 1113.527301] ---[ end trace 10e07174c7bf56ff ]---

Ben


> +			struct rpc_cred *cred = lsp->ls_state->owner->so_cred;
> +
> +			status = nfs41_test_and_free_expired_stateid(server,
> +					&lsp->ls_stateid,
> +					cred);
> +			trace_nfs4_test_lock_stateid(state, lsp, status);
> +			if (status == -NFS4ERR_EXPIRED ||
> +			    status == -NFS4ERR_BAD_STATEID) {
> +				clear_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags);
> +				if (!recover_lost_locks)
> +					set_bit(NFS_LOCK_LOST, &lsp->ls_flags);
> +			} else if (status != NFS_OK) {
> +				ret = status;
> +				break;
> +			}
> +		}
> +	};
> +out:
> +	return ret;
> +}
> +
> +/**
>   * nfs41_check_open_stateid - possibly free an open stateid
>   *
>   * @state: NFSv4 state for an inode
> @@ -2522,6 +2561,9 @@ static int nfs41_open_expired(struct 
> nfs4_state_owner *sp, struct nfs4_state *st
>  	int status;
>
>  	nfs41_check_delegation_stateid(state);
> +	status = nfs41_check_expired_locks(state);
> +	if (status != NFS_OK)
> +		return status;
>  	status = nfs41_check_open_stateid(state);
>  	if (status != NFS_OK)
>  		status = nfs4_open_expired(sp, state);
> @@ -6125,49 +6167,19 @@ out:
>  }
>
>  #if defined(CONFIG_NFS_V4_1)
> -/**
> - * nfs41_check_expired_locks - possibly free a lock stateid
> - *
> - * @state: NFSv4 state for an inode
> - *
> - * Returns NFS_OK if recovery for this stateid is now finished.
> - * Otherwise a negative NFS4ERR value is returned.
> - */
> -static int nfs41_check_expired_locks(struct nfs4_state *state)
> -{
> -	int status, ret = NFS_OK;
> -	struct nfs4_lock_state *lsp;
> -	struct nfs_server *server = NFS_SERVER(state->inode);
> -
> -	list_for_each_entry(lsp, &state->lock_states, ls_locks) {
> -		if (test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags)) {
> -			struct rpc_cred *cred = lsp->ls_state->owner->so_cred;
> -
> -			status = nfs41_test_and_free_expired_stateid(server,
> -					&lsp->ls_stateid,
> -					cred);
> -			trace_nfs4_test_lock_stateid(state, lsp, status);
> -			if (status == -NFS4ERR_EXPIRED ||
> -			    status == -NFS4ERR_BAD_STATEID)
> -				clear_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags);
> -			else if (status != NFS_OK) {
> -				ret = status;
> -				break;
> -			}
> -		}
> -	};
> -
> -	return ret;
> -}
> -
>  static int nfs41_lock_expired(struct nfs4_state *state, struct 
> file_lock *request)
>  {
> -	int status = NFS_OK;
> +	struct nfs4_lock_state *lsp;
> +	int status;
>
> -	if (test_bit(LK_STATE_IN_USE, &state->flags))
> -		status = nfs41_check_expired_locks(state);
> -	if (status != NFS_OK)
> -		status = nfs4_lock_expired(state, request);
> +	status = nfs4_set_lock_state(state, request);
> +	if (status != 0)
> +		return status;
> +	lsp = request->fl_u.nfs4_fl.owner;
> +	if (test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags) ||
> +	    test_bit(NFS_LOCK_LOST, &lsp->ls_flags))
> +		return 0;
> +	status = nfs4_lock_expired(state, request);
>  	return status;
>  }
>  #endif
> -- 
> 2.7.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" 
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
