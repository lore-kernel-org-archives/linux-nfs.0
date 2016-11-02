Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33140 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755919AbcKBPtg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 2 Nov 2016 11:49:36 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: NeilBrown <neilb@suse.com>
Cc: "Trond Myklebust" <trond.myklebust@primarydata.com>,
        "Anna Schumaker" <anna.schumaker@netapp.com>,
        "Jeff Layton" <jlayton@redhat.com>,
        "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/6] NFSv4: change nfs4_do_setattr to take an open_context
 instead of a nfs4_state.
Date: Wed, 02 Nov 2016 11:49:33 -0400
Message-ID: <0773ADA2-C1DE-4D01-8B3C-5883A6A62C2E@redhat.com>
In-Reply-To: <147633280745.766.9047567139865023402.stgit@noble>
References: <147633263771.766.17853370901003798934.stgit@noble>
 <147633280745.766.9047567139865023402.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 13 Oct 2016, at 0:26, NeilBrown wrote:

> The open_context can always lead directly to the state, and is always 
> easily
> available, so this is a straightforward change.
> Doing this makes more information available to _nfs4_do_setattr() for 
> use
> in the next patch.
>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  fs/nfs/nfs4proc.c |   28 +++++++++++++---------------
>  1 file changed, 13 insertions(+), 15 deletions(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 3d85ab7b56bf..950b25413bb4 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -94,7 +94,7 @@ static int nfs4_proc_getattr(struct nfs_server *, 
> struct nfs_fh *, struct nfs_fa
>  static int _nfs4_proc_getattr(struct nfs_server *server, struct 
> nfs_fh *fhandle, struct nfs_fattr *fattr, struct nfs4_label *label);
>  static int nfs4_do_setattr(struct inode *inode, struct rpc_cred 
> *cred,
>  			    struct nfs_fattr *fattr, struct iattr *sattr,
> -			    struct nfs4_state *state, struct nfs4_label *ilabel,
> +			    struct nfs_open_context *ctx, struct nfs4_label *ilabel,
>  			    struct nfs4_label *olabel);
>  #ifdef CONFIG_NFS_V4_1
>  static int nfs41_test_stateid(struct nfs_server *, nfs4_stateid *,
> @@ -2807,7 +2807,7 @@ static int _nfs4_do_open(struct inode *dir,
>  			nfs_fattr_init(opendata->o_res.f_attr);
>  			status = nfs4_do_setattr(state->inode, cred,
>  					opendata->o_res.f_attr, sattr,
> -					state, label, olabel);
> +					ctx, label, olabel);
>  			if (status == 0) {
>  				nfs_setattr_update_inode(state->inode, sattr,
>  						opendata->o_res.f_attr);
> @@ -2902,7 +2902,7 @@ static int _nfs4_do_setattr(struct inode *inode,
>  			    struct nfs_setattrargs *arg,
>  			    struct nfs_setattrres *res,
>  			    struct rpc_cred *cred,
> -			    struct nfs4_state *state)
> +			    struct nfs_open_context *ctx)
>  {
>  	struct nfs_server *server = NFS_SERVER(inode);
>          struct rpc_message msg = {
> @@ -2925,13 +2925,13 @@ static int _nfs4_do_setattr(struct inode 
> *inode,
>
>  	if (nfs4_copy_delegation_stateid(inode, fmode, &arg->stateid, 
> &delegation_cred)) {
>  		/* Use that stateid */
> -	} else if (truncate && state != NULL) {
> +	} else if (truncate && ctx != NULL) {
>  		struct nfs_lockowner lockowner = {
>  			.l_owner = current->files,
>  		};
> -		if (!nfs4_valid_open_stateid(state))
> +		if (!nfs4_valid_open_stateid(ctx->state))
>  			return -EBADF;
> -		if (nfs4_select_rw_stateid(state, FMODE_WRITE, &lockowner,
> +		if (nfs4_select_rw_stateid(ctx->state, FMODE_WRITE, &lockowner,
>  				&arg->stateid, &delegation_cred) == -EIO)
>  			return -EBADF;
>  	} else
> @@ -2942,7 +2942,7 @@ static int _nfs4_do_setattr(struct inode *inode,
>  	status = nfs4_call_sync(server->client, server, &msg, 
> &arg->seq_args, &res->seq_res, 1);
>
>  	put_rpccred(delegation_cred);
> -	if (status == 0 && state != NULL)
> +	if (status == 0 && ctx != NULL)
>  		renew_lease(server, timestamp);
>  	trace_nfs4_setattr(inode, &arg->stateid, status);
>  	return status;
> @@ -2950,10 +2950,11 @@ static int _nfs4_do_setattr(struct inode 
> *inode,
>
>  static int nfs4_do_setattr(struct inode *inode, struct rpc_cred 
> *cred,
>  			   struct nfs_fattr *fattr, struct iattr *sattr,
> -			   struct nfs4_state *state, struct nfs4_label *ilabel,
> +			   struct nfs_open_context *ctx, struct nfs4_label *ilabel,
>  			   struct nfs4_label *olabel)
>  {
>  	struct nfs_server *server = NFS_SERVER(inode);
> +	struct nfs4_state *state = ctx ? ctx->state : NULL;
>          struct nfs_setattrargs  arg = {
>                  .fh             = NFS_FH(inode),
>                  .iap            = sattr,
> @@ -2978,7 +2979,7 @@ static int nfs4_do_setattr(struct inode *inode, 
> struct rpc_cred *cred,
>  		arg.bitmask = nfs4_bitmask(server, olabel);
>
>  	do {
> -		err = _nfs4_do_setattr(inode, &arg, &res, cred, state);
> +		err = _nfs4_do_setattr(inode, &arg, &res, cred, ctx);
>  		switch (err) {
>  		case -NFS4ERR_OPENMODE:
>  			if (!(sattr->ia_valid & ATTR_SIZE)) {
> @@ -3673,7 +3674,7 @@ nfs4_proc_setattr(struct dentry *dentry, struct 
> nfs_fattr *fattr,
>  {
>  	struct inode *inode = d_inode(dentry);
>  	struct rpc_cred *cred = NULL;
> -	struct nfs4_state *state = NULL;
> +	struct nfs_open_context *ctx = NULL;
>  	struct nfs4_label *label = NULL;
>  	int status;
>
> @@ -3694,20 +3695,17 @@ nfs4_proc_setattr(struct dentry *dentry, 
> struct nfs_fattr *fattr,
>
>  	/* Search for an existing open(O_WRITE) file */
>  	if (sattr->ia_valid & ATTR_FILE) {
> -		struct nfs_open_context *ctx;
>
>  		ctx = nfs_file_open_context(sattr->ia_file);
> -		if (ctx) {
> +		if (ctx)
>  			cred = ctx->cred;
> -			state = ctx->state;
> -		}
>  	}


Does this need a get_nfs_open_context() there to make sure the open 
context
doesn't drop away?  I'm getting this on generic/089:

[  651.855291] run fstests generic/089 at 2016-11-01 11:15:57
[  652.645828] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
[  653.166259] NFSD: client ::1 testing state ID with incorrect client 
ID
[  653.167218] BUG: unable to handle kernel NULL pointer dereference at 
0000000000000018
[  653.168142] IP: [<ffffffffa02dbca4>] nfs41_open_expired+0xb4/0x3c0 
[nfsv4]
[  653.168938] PGD 13470c067
[  653.169236] PUD 132ac1067
[  653.169557] PMD 0
[  653.169628]
[  653.169819] Oops: 0000 [#1] SMP
[  653.170181] Modules linked in: nfsv4 dns_resolver nfs ip6t_rpfilter 
ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat 
ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 
nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_security 
ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 
nf_nat nf_conntrack iptable_mangle iptable_security iptable_raw 
ebtable_filter ebtables ip6table_filter ip6_tables nfsd auth_rpcgss 
nfs_acl lockd grace sunrpc virtio_net virtio_console virtio_blk 
virtio_balloon ppdev crct10dif_pclmul crc32_pclmul crc32c_intel 
ghash_clmulni_intel serio_raw virtio_pci parport_pc virtio_ring parport 
virtio ata_generic acpi_cpufreq pata_acpi tpm_tis i2c_piix4 tpm_tis_core 
tpm
[  653.178176] CPU: 0 PID: 7508 Comm: ::1-manager Not tainted 
4.9.0-rc1-00008-g9b7fe7e #17
[  653.179068] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), 
BIOS 1.8.1-20150318_183358- 04/01/2014
[  653.180125] task: ffff880139598000 task.stack: ffffc90008b18000
[  653.180777] RIP: 0010:[<ffffffffa02dbca4>]  [<ffffffffa02dbca4>] 
nfs41_open_expired+0xb4/0x3c0 [nfsv4]
[  653.181829] RSP: 0018:ffffc90008b1bd98  EFLAGS: 00010203
[  653.182420] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 
0000000000000000
[  653.183212] RDX: 0000000000000035 RSI: ffff88013fc1c9c0 RDI: 
ffff880138f2bc00
[  653.183998] RBP: ffffc90008b1bde8 R08: 000000000001c9c0 R09: 
ffff8801319a0300
[  653.184788] R10: ffff8801319a0338 R11: 0000000000000001 R12: 
00000000ffffd8d7
[  653.185577] R13: ffff88013aaeb6c0 R14: ffff88013aaeb6e0 R15: 
ffff88013946f850
[  653.186458] FS:  0000000000000000(0000) GS:ffff88013fc00000(0000) 
knlGS:0000000000000000
[  653.187329] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  653.187950] CR2: 0000000000000018 CR3: 000000013308c000 CR4: 
00000000000406f0
[  653.188723] Stack:
[  653.188951]  ffff8801319a7800 ffff8801315b9800 ffffc90008b1bda8 
ffffc90008b1bda8
[  653.189807]  000000002f556716 ffff88013aaeb6c0 ffffffffa030b460 
ffff88013946f850
[  653.190666]  ffffffffa030b460 ffff88013946f850 ffffc90008b1be80 
ffffffffa02f051f
[  653.191524] Call Trace:
[  653.191808]  [<ffffffffa02f051f>] nfs4_do_reclaim+0x1af/0x660 [nfsv4]
[  653.192522]  [<ffffffffa02f0ee0>] nfs4_run_state_manager+0x510/0x7d0 
[nfsv4]
[  653.193297]  [<ffffffffa02f09d0>] ? nfs4_do_reclaim+0x660/0x660 
[nfsv4]
[  653.194016]  [<ffffffffa02f09d0>] ? nfs4_do_reclaim+0x660/0x660 
[nfsv4]
[  653.194739]  [<ffffffff810c95d9>] kthread+0xd9/0xf0
[  653.195274]  [<ffffffff810c9500>] ? kthread_park+0x60/0x60
[  653.195875]  [<ffffffff818264d5>] ret_from_fork+0x25/0x30
[  653.196466] Code: 24 49 8b 45 40 a8 01 0f 84 f5 00 00 00 49 8b 5d 20 
4d 8d 75 20 49 39 de 75 11 e9 e3 00 00 00 48 8b 1b 4c 39 f3 0f 84 c4 00 
00 00 <48> 8b 43 18 a8 01 74 ec 48 8b 43 10 48 8b 3c 24 48 8d b3 08 01
[  653.199416] RIP  [<ffffffffa02dbca4>] nfs41_open_expired+0xb4/0x3c0 
[nfsv4]
[  653.200196]  RSP <ffffc90008b1bd98>
[  653.200578] CR2: 0000000000000018
[  653.201291] ---[ end trace ad4f1849f777932d ]---
[  653.201792] Kernel panic - not syncing: Fatal exception
[  653.202492] Kernel Offset: disabled
[  653.202876] ---[ end Kernel panic - not syncing: Fatal exception


Something else is also wrong there.. wrapping that with
get_nfs_open_context() makes the crash go away, but there are still 
several
"NFS: nfs4_reclaim_open_state: Lock reclaim failed!" in the log.   Why 
would
we be doing reclaim at all?  I'll look at a network capture next.

Ben

>
>  	label = nfs4_label_alloc(NFS_SERVER(inode), GFP_KERNEL);
>  	if (IS_ERR(label))
>  		return PTR_ERR(label);
>
> -	status = nfs4_do_setattr(inode, cred, fattr, sattr, state, NULL, 
> label);
> +	status = nfs4_do_setattr(inode, cred, fattr, sattr, ctx, NULL, 
> label);
>  	if (status == 0) {
>  		nfs_setattr_update_inode(inode, sattr, fattr);
>  		nfs_setsecurity(inode, fattr, label);
>
