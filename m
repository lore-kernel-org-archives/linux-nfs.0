Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:47576 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1732321AbeGKOzz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 11 Jul 2018 10:55:55 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Scott Mayhew" <smayhew@redhat.com>
Cc: trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        dhowells@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: add minor version to nfs_server_key for fscache
Date: Wed, 11 Jul 2018 10:51:11 -0400
Message-ID: <1F59764C-4E7C-4D15-BE35-490D61F0349F@redhat.com>
In-Reply-To: <20180711122219.20808-1-smayhew@redhat.com>
References: <20180711122219.20808-1-smayhew@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

So there's two changes here, the first is that we don't call
nfs_fscache_get_client_cookie() if rpc_ops->init_client fails, which 
makes
sense.  The second is that we create separate fscache indexes for minor
versions.  Why do we need separate caches if the nfs_client is the same? 
  I
thought that the nfs_client is just there to have something to hang the
superblock caches from..

Is the problem that we can take down one nfs_client and then initialize 
a
new one, but the nfs_server_key is exactly the same, so now we start to 
add
new objects before fscache has cleaned up old references?

Ben

On 11 Jul 2018, at 8:22, Scott Mayhew wrote:

> If the same NFS filesystem is mounted multiple times with "-o fsc" and
> different NFS versions, the following oops can occur.
>
> Fix it by adding the minor version to the struct nfs_server_key.
>
> Note this requires waiting to call nfs_fscache_get_client_cookie()
> until after the nfs_client has been initialized.
>
> kernel BUG at fs/cachefiles/namei.c:194!
> invalid opcode: 0000 [#1] SMP PTI
> Modules linked in: ...
> CPU: 1 PID: 6 Comm: kworker/u4:0 Kdump: loaded Not tainted 
> 4.17.3-200.fc28.x86_64 #1
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 
> 1.10.2-2.fc27 04/01/2014
> Workqueue: fscache_object fscache_object_work_func [fscache]
> RIP: 0010:cachefiles_walk_to_object.cold.16+0x124/0x18c [cachefiles]
> RSP: 0000:ffffa37f40347d50 EFLAGS: 00010246
> RAX: 0000000000000001 RBX: ffff9327f3e94300 RCX: 0000000000000006
> RDX: 0000000000000000 RSI: 0000000000000092 RDI: ffff9327ffd16930
> RBP: ffff9327f3e94000 R08: 0000000000000000 R09: 000000000000026f
> R10: 0000000000000000 R11: 0000000000000001 R12: ffff9327faa59840
> R13: ffff9327faa59840 R14: ffff9327f3e94440 R15: ffff9327f3e94ec0
> FS:  0000000000000000(0000) GS:ffff9327ffd00000(0000) 
> knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00007f63f1db28a0 CR3: 000000002020a001 CR4: 00000000003606e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> Call Trace:
>  ? __queue_work+0x103/0x3e0
>  ? __switch_to_asm+0x34/0x70
>  cachefiles_lookup_object+0x4b/0xa0 [cachefiles]
>  fscache_look_up_object+0x9c/0x110 [fscache]
>  ? fscache_parent_ready+0x2a/0x50 [fscache]
>  fscache_object_work_func+0x74/0x2b0 [fscache]
>  process_one_work+0x187/0x340
>  worker_thread+0x2e/0x380
>  ? pwq_unbound_release_workfn+0xd0/0xd0
>  kthread+0x112/0x130
>  ? kthread_create_worker_on_cpu+0x70/0x70
>  ret_from_fork+0x35/0x40
> Code: ...
> RIP: cachefiles_walk_to_object.cold.16+0x124/0x18c [cachefiles] RSP: 
> ffffa37f40347d50
>
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> ---
>  fs/nfs/client.c  | 8 +++++---
>  fs/nfs/fscache.c | 2 ++
>  2 files changed, 7 insertions(+), 3 deletions(-)
>
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 377a61654a88..bfd1b4e2852b 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -185,7 +185,6 @@ struct nfs_client *nfs_alloc_client(const struct 
> nfs_client_initdata *cl_init)
>  	cred = rpc_lookup_machine_cred("*");
>  	if (!IS_ERR(cred))
>  		clp->cl_machine_cred = cred;
> -	nfs_fscache_get_client_cookie(clp);
>
>  	return clp;
>
> @@ -397,7 +396,7 @@ nfs_found_client(const struct nfs_client_initdata 
> *cl_init,
>   */
>  struct nfs_client *nfs_get_client(const struct nfs_client_initdata 
> *cl_init)
>  {
> -	struct nfs_client *clp, *new = NULL;
> +	struct nfs_client *clp, *ret, *new = NULL;
>  	struct nfs_net *nn = net_generic(cl_init->net, nfs_net_id);
>  	const struct nfs_rpc_ops *rpc_ops = cl_init->nfs_mod->rpc_ops;
>
> @@ -422,7 +421,10 @@ struct nfs_client *nfs_get_client(const struct 
> nfs_client_initdata *cl_init)
>  					&nn->nfs_client_list);
>  			spin_unlock(&nn->nfs_client_lock);
>  			new->cl_flags = cl_init->init_flags;
> -			return rpc_ops->init_client(new, cl_init);
> +			ret = rpc_ops->init_client(new, cl_init);
> +			if (!IS_ERR(ret))
> +				nfs_fscache_get_client_cookie(new);
> +			return ret;
>  		}
>
>  		spin_unlock(&nn->nfs_client_lock);
> diff --git a/fs/nfs/fscache.c b/fs/nfs/fscache.c
> index 4dc887813c71..c32146319944 100644
> --- a/fs/nfs/fscache.c
> +++ b/fs/nfs/fscache.c
> @@ -35,6 +35,7 @@ static DEFINE_SPINLOCK(nfs_fscache_keys_lock);
>  struct nfs_server_key {
>  	struct {
>  		uint16_t	nfsversion;		/* NFS protocol version */
> +		uint16_t	minorversion;		/* NFSv4 minor version */
>  		uint16_t	family;			/* address family */
>  		__be16		port;			/* IP port */
>  	} hdr;
> @@ -59,6 +60,7 @@ void nfs_fscache_get_client_cookie(struct nfs_client 
> *clp)
>
>  	memset(&key, 0, sizeof(key));
>  	key.hdr.nfsversion = clp->rpc_ops->version;
> +	key.hdr.minorversion = clp->cl_minorversion;
>  	key.hdr.family = clp->cl_addr.ss_family;
>
>  	switch (clp->cl_addr.ss_family) {
> -- 
> 2.14.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" 
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
