Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:20202 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752719Ab3KGTZZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Nov 2013 14:25:25 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: [PATCH] Adding the nfs4_use_min_auth module parameter
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1383851364-8370-1-git-send-email-steved@redhat.com>
Date: Thu, 7 Nov 2013 11:25:19 -0800
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-Id: <A8E8F2C4-8CB7-434E-8520-B2B53F0582D9@oracle.com>
References: <1383851364-8370-1-git-send-email-steved@redhat.com>
To: Steve Dickson <steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

On Nov 7, 2013, at 11:09 AM, Steve Dickson <steved@redhat.com> wrote:

> This new module parameter makes the v4 client
> use the minimal authentication flavor (AUTH_UNIX)
> when establishing NFSV4 state and doing the
> pseudoroot lookup

The patch description doesn't say, but is this change to work around the 15 second GSSD upcall timeout? Have we completely given up on fixing the upcall?


> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
> fs/nfs/nfs4_fs.h    |    1 +
> fs/nfs/nfs4client.c |    8 ++++++--
> fs/nfs/nfs4proc.c   |    4 +++-
> fs/nfs/super.c      |    6 +++++-
> 4 files changed, 15 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index 28842ab..20bf925 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -438,6 +438,7 @@ extern bool nfs4_disable_idmapping;
> extern unsigned short max_session_slots;
> extern unsigned short send_implementation_id;
> extern bool recover_lost_locks;
> +extern bool nfs4_use_min_auth;
> 
> #define NFS4_CLIENT_ID_UNIQ_LEN		(64)
> extern char nfs4_client_id_uniquifier[NFS4_CLIENT_ID_UNIQ_LEN];
> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
> index a860ab5..ff85991 100644
> --- a/fs/nfs/nfs4client.c
> +++ b/fs/nfs/nfs4client.c
> @@ -355,6 +355,7 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
> 	char buf[INET6_ADDRSTRLEN + 1];
> 	struct nfs_client *old;
> 	int error;
> +	rpc_authflavor_t flavor = RPC_AUTH_GSS_KRB5I;
> 
> 	if (clp->cl_cons_state == NFS_CS_READY) {
> 		/* the client is initialised already */
> @@ -368,8 +369,11 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
> 	if (clp->cl_minorversion != 0)
> 		__set_bit(NFS_CS_INFINITE_SLOTS, &clp->cl_flags);
> 	__set_bit(NFS_CS_DISCRTRY, &clp->cl_flags);
> -	error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_GSS_KRB5I);
> -	if (error == -EINVAL)
> +
> +	if (nfs4_use_min_auth)
> +		flavor = RPC_AUTH_UNIX;
> +	error = nfs_create_rpc_client(clp, timeparms, flavor);
> +	if (error == -EINVAL && flavor != RPC_AUTH_UNIX)
> 		error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_UNIX);
> 	if (error < 0)
> 		goto error;
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index d53d678..00162cb 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2864,7 +2864,9 @@ static int nfs4_find_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
> 	int status = -EPERM;
> 	size_t i;
> 
> -	for (i = 0; i < ARRAY_SIZE(flav_array); i++) {
> +	if (nfs4_use_min_auth)
> +		status = nfs4_lookup_root_sec(server, fhandle, info, RPC_AUTH_UNIX);
> +	else for (i = 0; i < ARRAY_SIZE(flav_array); i++) {
> 		status = nfs4_lookup_root_sec(server, fhandle, info, flav_array[i]);
> 		if (status == -NFS4ERR_WRONGSEC || status == -EACCES)
> 			continue;
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index a03b9c6..42b4f9b 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -2791,6 +2791,7 @@ unsigned short max_session_slots = NFS4_DEF_SLOT_TABLE_SIZE;
> unsigned short send_implementation_id = 1;
> char nfs4_client_id_uniquifier[NFS4_CLIENT_ID_UNIQ_LEN] = "";
> bool recover_lost_locks = false;
> +bool nfs4_use_min_auth = false;
> 
> EXPORT_SYMBOL_GPL(nfs_callback_set_tcpport);
> EXPORT_SYMBOL_GPL(nfs_callback_tcpport);
> @@ -2800,6 +2801,7 @@ EXPORT_SYMBOL_GPL(max_session_slots);
> EXPORT_SYMBOL_GPL(send_implementation_id);
> EXPORT_SYMBOL_GPL(nfs4_client_id_uniquifier);
> EXPORT_SYMBOL_GPL(recover_lost_locks);
> +EXPORT_SYMBOL_GPL(nfs4_use_min_auth);
> 
> #define NFS_CALLBACK_MAXPORTNR (65535U)
> 
> @@ -2842,5 +2844,7 @@ MODULE_PARM_DESC(recover_lost_locks,
> 		 "If the server reports that a lock might be lost, "
> 		 "try to recover it risking data corruption.");
> 
> -
> +module_param(nfs4_use_min_auth, bool, 0644);
> +MODULE_PARM_DESC(nfs4_use_min_auth,
> +		"Use mimnal auth in SETCLIENTID operation");
> #endif /* CONFIG_NFS_V4 */
> -- 
> 1.7.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



