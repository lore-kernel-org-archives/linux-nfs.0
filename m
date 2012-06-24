Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f178.google.com ([209.85.212.178]:51570 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779Ab2FXEoI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jun 2012 00:44:08 -0400
MIME-Version: 1.0
In-Reply-To: <FE90D2E0-C4C9-44BC-829F-ABE94801AB4C@netapp.com>
References: <1340448406-10161-1-git-send-email-linkinjeon@gmail.com>
	<02B16139-AFD6-4F06-99C0-C406B1A7E1DC@netapp.com>
	<FE90D2E0-C4C9-44BC-829F-ABE94801AB4C@netapp.com>
Date: Sun, 24 Jun 2012 13:44:05 +0900
Message-ID: <CAKYAXd8O7OjBDZE5jQjwmvch_Vr26dd_KoZYKfifGDHEcmyZ9g@mail.gmail.com>
Subject: Re: [RFC PATCH] nfs: Add NFS3PROC_UMOUNT procedure.
From: Namjae Jeon <linkinjeon@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Fields James <bfields@fieldses.org>,
        Morton Andrew <akpm@linux-foundation.org>,
        Harrosh Boaz <bharrosh@panasas.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        Namjae Jeon <namjae.jeon@samsung.com>,
        Vivek Trivedi <t.vivek@samsung.com>,
        Amit Sahrawat <a.sahrawat@samsung.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2012/6/24, Myklebust, Trond <Trond.Myklebust@netapp.com>:
> The other objection is that NFSv3 already has a way to do this via the MOUNT
> protocol. We already call MOUNTPROC3_UMNT/MOUNTPROC_UMNT on unmount of a
> filesystem.
I will check current MOUNTPROC3_UMNT/MOUNTPROC_UMNT.
>
> The problem with this approach is that if the NFS client crashes before it
> can call this function, then the server never gets notified. That is a
> problem that your patch has too...
You're right. Good point.. Acutally, I have been concerning about this.
Thanks.
>
>
> --
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>
> On Jun 23, 2012, at 11:07 AM, Myklebust, Trond wrote:
>
>> BIG NACK... We don't do embrace and extend in Linux...
>>
>>
>> The whole point of the NFS protocol is to be a standard. We can't just go
>> adding new functionality to one implementation of that standard without
>> breaking interoperability with other implementations...
>>
>> Trond
>>
>> --
>> Trond Myklebust
>> Linux NFS client maintainer
>>
>> NetApp
>> Trond.Myklebust@netapp.com
>> www.netapp.com
>>
>> On Jun 23, 2012, at 6:46 AM, Namjae Jeon wrote:
>>
>>> From: Namjae Jeon <namjae.jeon@samsung.com>
>>>
>>> Without this patch:
>>>
>>> On NFS Client:
>>> $ mount -t nfs <NFS_SERVER>:/mnt /mnt
>>> $ umount /mnt
>>>
>>> On NFS Server:
>>> $ umount /mnt
>>> umount: can't umount /mnt: Device or resource busy
>>>
>>> If user has to remove storage device user needs to unplug the
>>> device.
>>> This may result in file system corruption on attached media.
>>>
>>> This patch tries to add a NFS UMOUNT procedure for NFSv3 for safe
>>> removal of attached media at NFS Server.
>>>
>>> With this patch:
>>>
>>> On NFS Client:
>>> $ mount -t nfs <NFS_SERVER>:/mnt /mnt
>>> $ umount /mnt
>>>
>>> On NFS Server:
>>> $ umount /mnt --> umount successful
>>>
>>> Signed-off-by: Namjae Jeon <namjae.jeon@samsung.com>
>>> Signed-off-by: Vivek Trivedi <t.vivek@samsung.com>
>>> Signed-off-by: Amit Sahrawat <a.sahrawat@samsung.com>
>>> ---
>>> fs/nfs/nfs3proc.c       |   29 +++++++++++++++++++++++++++++
>>> fs/nfs/nfs3xdr.c        |   39 +++++++++++++++++++++++++++++++++++++++
>>> fs/nfs/super.c          |   10 ++++++++++
>>> fs/nfsd/nfs3proc.c      |   28 +++++++++++++++++++++++++++-
>>> fs/nfsd/nfs3xdr.c       |   19 +++++++++++++++++++
>>> fs/nfsd/nfsctl.c        |   22 ++++++++++++++++++++++
>>> fs/nfsd/nfsd.h          |    3 +++
>>> fs/nfsd/nfssvc.c        |    3 +++
>>> fs/nfsd/xdr3.h          |   14 +++++++++++++-
>>> include/linux/nfs3.h    |    1 +
>>> include/linux/nfs_xdr.h |    9 +++++++++
>>> 11 files changed, 175 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
>>> index 2292a0f..726227f 100644
>>> --- a/fs/nfs/nfs3proc.c
>>> +++ b/fs/nfs/nfs3proc.c
>>> @@ -877,6 +877,34 @@ nfs3_proc_lock(struct file *filp, int cmd, struct
>>> file_lock *fl)
>>> 	return nlmclnt_proc(NFS_SERVER(inode)->nlm_host, cmd, fl);
>>> }
>>>
>>> +static int nfs3_proc_umount(struct nfs_server *server)
>>> +{
>>> +	/*
>>> +	 * dummy argument and response are assigned to UMOUNT request
>>> +	 * to avoid BUG_ON(proc->p_arglen == 0); in net/sunrpc/clnt.c
>>> +	 */
>>> +	struct nfs3_umountargs  arg = {
>>> +		.dummy          = 0,
>>> +	};
>>> +	struct nfs3_umountres   res;
>>> +
>>> +	struct rpc_message msg = {
>>> +		.rpc_proc       = &nfs3_procedures[NFS3PROC_UMOUNT],
>>> +		.rpc_argp       = &arg,
>>> +		.rpc_resp       = &res,
>>> +
>>> +	};
>>> +	int err;
>>> +
>>> +	msg.rpc_cred = authnull_ops.lookup_cred(NULL, NULL, 0);
>>> +	dprintk("NFS call  umount\n");
>>> +	err = rpc_call_sync(server->client, &msg,
>>> +			RPC_TASK_SOFT | RPC_TASK_SOFTCONN);
>>> +	put_rpccred(msg.rpc_cred);
>>> +	dprintk("NFS reply umount: %d\n", err);
>>> +	return err;
>>> +}
>>> +
>>> const struct nfs_rpc_ops nfs_v3_clientops = {
>>> 	.version	= 3,			/* protocol version */
>>> 	.dentry_ops	= &nfs_dentry_operations,
>>> @@ -922,4 +950,5 @@ const struct nfs_rpc_ops nfs_v3_clientops = {
>>> 	.clear_acl_cache = nfs3_forget_cached_acls,
>>> 	.close_context	= nfs_close_context,
>>> 	.init_client	= nfs_init_client,
>>> +	.umount			= nfs3_proc_umount,
>>> };
>>> diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
>>> index 6cbe894..874b8b2 100644
>>> --- a/fs/nfs/nfs3xdr.c
>>> +++ b/fs/nfs/nfs3xdr.c
>>> @@ -61,6 +61,7 @@
>>> #define NFS3_readdirargs_sz	(NFS3_fh_sz+NFS3_cookieverf_sz+3)
>>> #define NFS3_readdirplusargs_sz	(NFS3_fh_sz+NFS3_cookieverf_sz+4)
>>> #define NFS3_commitargs_sz	(NFS3_fh_sz+3)
>>> +#define NFS3_umountargs_sz	(1)
>>>
>>> #define NFS3_getattrres_sz	(1+NFS3_fattr_sz)
>>> #define NFS3_setattrres_sz	(1+NFS3_wcc_data_sz)
>>> @@ -78,6 +79,7 @@
>>> #define NFS3_fsinfores_sz	(1+NFS3_post_op_attr_sz+12)
>>> #define NFS3_pathconfres_sz	(1+NFS3_post_op_attr_sz+6)
>>> #define NFS3_commitres_sz	(1+NFS3_wcc_data_sz+2)
>>> +#define NFS3_umountres_sz	(1 + 1)
>>>
>>> #define ACL3_getaclargs_sz	(NFS3_fh_sz+1)
>>> #define ACL3_setaclargs_sz	(NFS3_fh_sz+1+ \
>>> @@ -1306,6 +1308,22 @@ static void nfs3_xdr_enc_commit3args(struct
>>> rpc_rqst *req,
>>> 	encode_commit3args(xdr, args);
>>> }
>>>
>>> +/*
>>> + *   UMOUNT3args
>>> + */
>>> +static void encode_umount3args(struct xdr_stream *xdr,
>>> +		const struct nfs3_umountargs *args)
>>> +{
>>> +	encode_uint32(xdr, args->dummy);
>>> +}
>>> +
>>> +static void nfs3_xdr_enc_umount3args(struct rpc_rqst *req,
>>> +		struct xdr_stream *xdr,
>>> +		const struct nfs3_umountargs *args)
>>> +{
>>> +	encode_umount3args(xdr, args);
>>> +}
>>> +
>>> #ifdef CONFIG_NFS_V3_ACL
>>>
>>> static void nfs3_xdr_enc_getacl3args(struct rpc_rqst *req,
>>> @@ -1429,6 +1447,26 @@ out_status:
>>> }
>>>
>>> /*
>>> + *   UMOUNT3res
>>> + */
>>> +static int nfs3_xdr_dec_umount3res(struct rpc_rqst *req,
>>> +		struct xdr_stream *xdr,
>>> +		struct nfs3_umountres *result)
>>> +{
>>> +	enum nfs_stat status;
>>> +	int error;
>>> +
>>> +	error = decode_nfsstat3(xdr, &status);
>>> +	if (unlikely(error))
>>> +		goto out;
>>> +	if (status != NFS3_OK)
>>> +		return nfs3_stat_to_errno(status);
>>> +	error = decode_uint32(xdr, &result->dummy);
>>> +out:
>>> +	return error;
>>> +}
>>> +
>>> +/*
>>> * 3.3.3  LOOKUP3res
>>> *
>>> *	struct LOOKUP3resok {
>>> @@ -2508,6 +2546,7 @@ struct rpc_procinfo	nfs3_procedures[] = {
>>> 	PROC(FSINFO,		getattr,	fsinfo,		0),
>>> 	PROC(PATHCONF,		getattr,	pathconf,	0),
>>> 	PROC(COMMIT,		commit,		commit,		5),
>>> +	PROC(UMOUNT,		umount,		umount,		0),
>>> };
>>>
>>> const struct rpc_version nfs_version3 = {
>>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>>> index 906f09c..9fa295b 100644
>>> --- a/fs/nfs/super.c
>>> +++ b/fs/nfs/super.c
>>> @@ -2525,6 +2525,16 @@ static void nfs_kill_super(struct super_block *s)
>>> {
>>> 	struct nfs_server *server = NFS_SB(s);
>>>
>>> +	int err;
>>> +
>>> +	if (server->nfs_client->rpc_ops->umount) {
>>> +		err = server->nfs_client->rpc_ops->umount(server);
>>> +		if (err < 0) {
>>> +			printk(KERN_ERR "%s: nfs_proc3_umount() failed err = %d\n",
>>> +					__func__, err);
>>> +		}
>>> +	}
>>> +
>>> 	kill_anon_super(s);
>>> 	nfs_fscache_release_super_cookie(s);
>>> 	nfs_free_server(server);
>>> diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
>>> index 9095f3c..12ca821 100644
>>> --- a/fs/nfsd/nfs3proc.c
>>> +++ b/fs/nfsd/nfs3proc.c
>>> @@ -8,6 +8,7 @@
>>> #include <linux/ext2_fs.h>
>>> #include <linux/magic.h>
>>>
>>> +#include "nfsd.h"
>>> #include "cache.h"
>>> #include "xdr3.h"
>>> #include "vfs.h"
>>> @@ -63,6 +64,21 @@ nfsd3_proc_getattr(struct svc_rqst *rqstp, struct
>>> nfsd_fhandle  *argp,
>>> }
>>>
>>> /*
>>> + * UMOUNT call.
>>> + */
>>> +static __be32
>>> +nfsd3_proc_umount(struct svc_rqst *rqstp, struct nfsd3_umountargs
>>> *argp,
>>> +		struct nfsd3_umountres *resp)
>>> +{
>>> +	dprintk("nfsd: UMOUNT(3)\n");
>>> +
>>> +	if (nfs_umountd_workqueue)
>>> +		queue_work(nfs_umountd_workqueue, &nfs_umount_work);
>>> +
>>> +	return nfs_ok;
>>> +}
>>> +
>>> +/*
>>> * Set a file's attributes
>>> */
>>> static __be32
>>> @@ -671,7 +687,7 @@ struct nfsd3_voidargs { int dummy; };
>>> #define pAT (1+AT)	/* post attributes - conditional */
>>> #define WC (7+pAT)	/* WCC attributes */
>>>
>>> -static struct svc_procedure		nfsd_procedures3[22] = {
>>> +static struct svc_procedure		nfsd_procedures3[23] = {
>>> 	[NFS3PROC_NULL] = {
>>> 		.pc_func = (svc_procfunc) nfsd3_proc_null,
>>> 		.pc_encode = (kxdrproc_t) nfs3svc_encode_voidres,
>>> @@ -885,11 +901,21 @@ static struct svc_procedure		nfsd_procedures3[22] =
>>> {
>>> 		.pc_cachetype = RC_NOCACHE,
>>> 		.pc_xdrressize = ST+WC+2,
>>> 	},
>>> +	[NFS3PROC_UMOUNT] = {
>>> +		.pc_func = (svc_procfunc) nfsd3_proc_umount,
>>> +		.pc_decode = (kxdrproc_t) nfs3svc_decode_umountargs,
>>> +		.pc_encode = (kxdrproc_t) nfs3svc_encode_umountres,
>>> +		.pc_argsize = sizeof(struct nfsd3_umountargs),
>>> +		.pc_ressize = sizeof(struct nfsd3_umountres),
>>> +		.pc_cachetype = RC_NOCACHE,
>>> +		.pc_xdrressize = ST+1,
>>> +	},
>>> };
>>>
>>> struct svc_version	nfsd_version3 = {
>>> 		.vs_vers	= 3,
>>> 		.vs_nproc	= 22,
>>> +		.vs_nproc	= 23,
>>> 		.vs_proc	= nfsd_procedures3,
>>> 		.vs_dispatch	= nfsd_dispatch,
>>> 		.vs_xdrsize	= NFS3_SVC_XDRSIZE,
>>> diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
>>> index 43f46cd..8610282 100644
>>> --- a/fs/nfsd/nfs3xdr.c
>>> +++ b/fs/nfsd/nfs3xdr.c
>>> @@ -611,6 +611,15 @@ nfs3svc_decode_commitargs(struct svc_rqst *rqstp,
>>> __be32 *p,
>>> 	return xdr_argsize_check(rqstp, p);
>>> }
>>>
>>> +int
>>> +nfs3svc_decode_umountargs(struct svc_rqst *rqstp, __be32 *p,
>>> +		struct nfsd3_umountargs *args)
>>> +{
>>> +	args->dummy = ntohl(*p++);
>>> +
>>> +	return xdr_argsize_check(rqstp, p);
>>> +}
>>> +
>>> /*
>>> * XDR encode functions
>>> */
>>> @@ -1091,6 +1100,16 @@ nfs3svc_encode_commitres(struct svc_rqst *rqstp,
>>> __be32 *p,
>>> 	return xdr_ressize_check(rqstp, p);
>>> }
>>>
>>> +/* UMOUNT */
>>> +int
>>> +nfs3svc_encode_umountres(struct svc_rqst *rqstp, __be32 *p,
>>> +		struct nfsd3_umountres *resp)
>>> +{
>>> +	if (resp->status == 0)
>>> +		*p++ = htonl(resp->dummy);
>>> +	return xdr_ressize_check(rqstp, p);
>>> +}
>>> +
>>> /*
>>> * XDR release functions
>>> */
>>> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
>>> index c55298e..53748ac 100644
>>> --- a/fs/nfsd/nfsctl.c
>>> +++ b/fs/nfsd/nfsctl.c
>>> @@ -50,6 +50,9 @@ enum {
>>> #endif
>>> };
>>>
>>> +struct workqueue_struct *nfs_umountd_workqueue;
>>> +struct work_struct nfs_umount_work;
>>> +
>>> /*
>>> * write() for these nodes.
>>> */
>>> @@ -1175,6 +1178,17 @@ static struct pernet_operations nfsd_net_ops = {
>>> 	.size = sizeof(struct nfsd_net),
>>> };
>>>
>>> +static void nfs_umountd_fn(struct work_struct *unused)
>>> +{
>>> +	nfsd_export_flush(&init_net);
>>> +}
>>> +
>>> +static void nfsd_umount_destroy(void)
>>> +{
>>> +	if (nfs_umountd_workqueue)
>>> +		destroy_workqueue(nfs_umountd_workqueue);
>>> +}
>>> +
>>> static int __init init_nfsd(void)
>>> {
>>> 	int retval;
>>> @@ -1204,6 +1218,13 @@ static int __init init_nfsd(void)
>>> 	retval = register_filesystem(&nfsd_fs_type);
>>> 	if (retval)
>>> 		goto out_free_all;
>>> +
>>> +	nfs_umountd_workqueue = create_singlethread_workqueue("nfs.umountd");
>>> +	if (!nfs_umountd_workqueue)
>>> +		printk(KERN_ERR "nfsd: Failed to create nfs.umountd workqueue\n");
>>> +	else
>>> +		INIT_WORK(&nfs_umount_work, nfs_umountd_fn);
>>> +
>>> 	return 0;
>>> out_free_all:
>>> 	remove_proc_entry("fs/nfs/exports", NULL);
>>> @@ -1225,6 +1246,7 @@ out_unregister_notifier:
>>>
>>> static void __exit exit_nfsd(void)
>>> {
>>> +	nfsd_umount_destroy();
>>> 	nfsd_reply_cache_shutdown();
>>> 	remove_proc_entry("fs/nfs/exports", NULL);
>>> 	remove_proc_entry("fs/nfs", NULL);
>>> diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
>>> index 1671429..691450a 100644
>>> --- a/fs/nfsd/nfsd.h
>>> +++ b/fs/nfsd/nfsd.h
>>> @@ -20,6 +20,7 @@
>>> #include <linux/nfsd/debug.h>
>>> #include <linux/nfsd/export.h>
>>> #include <linux/nfsd/stats.h>
>>> +#include <linux/workqueue.h>
>>>
>>> /*
>>> * nfsd version
>>> @@ -61,6 +62,8 @@ extern unsigned int		nfsd_drc_max_mem;
>>> extern unsigned int		nfsd_drc_mem_used;
>>>
>>> extern const struct seq_operations nfs_exports_op;
>>> +extern struct workqueue_struct *nfs_umountd_workqueue;
>>> +extern struct work_struct nfs_umount_work;
>>>
>>> /*
>>> * Function prototypes.
>>> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
>>> index ee709fc..1fb3598 100644
>>> --- a/fs/nfsd/nfssvc.c
>>> +++ b/fs/nfsd/nfssvc.c
>>> @@ -256,6 +256,9 @@ static void nfsd_last_thread(struct svc_serv *serv,
>>> struct net *net)
>>> {
>>> 	/* When last nfsd thread exits we need to do some clean-up */
>>> 	nfsd_serv = NULL;
>>> +	if (nfs_umountd_workqueue)
>>> +		flush_workqueue(nfs_umountd_workqueue);
>>> +
>>> 	nfsd_shutdown();
>>>
>>> 	svc_rpcb_cleanup(serv, net);
>>> diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
>>> index 7df980e..b542c92 100644
>>> --- a/fs/nfsd/xdr3.h
>>> +++ b/fs/nfsd/xdr3.h
>>> @@ -106,6 +106,10 @@ struct nfsd3_commitargs {
>>> 	__u32			count;
>>> };
>>>
>>> +struct nfsd3_umountargs {
>>> +	__u32	dummy;
>>> +};
>>> +
>>> struct nfsd3_getaclargs {
>>> 	struct svc_fh		fh;
>>> 	int			mask;
>>> @@ -219,6 +223,11 @@ struct nfsd3_commitres {
>>> 	struct svc_fh		fh;
>>> };
>>>
>>> +struct nfsd3_umountres {
>>> +	__be32	status;
>>> +	__u32	dummy;
>>> +};
>>> +
>>> struct nfsd3_getaclres {
>>> 	__be32			status;
>>> 	struct svc_fh		fh;
>>> @@ -295,6 +304,8 @@ int nfs3svc_decode_readdirplusargs(struct svc_rqst *,
>>> __be32 *,
>>> 				struct nfsd3_readdirargs *);
>>> int nfs3svc_decode_commitargs(struct svc_rqst *, __be32 *,
>>> 				struct nfsd3_commitargs *);
>>> +int nfs3svc_decode_umountargs(struct svc_rqst *, __be32 *,
>>> +				struct nfsd3_umountargs *);
>>> int nfs3svc_encode_voidres(struct svc_rqst *, __be32 *, void *);
>>> int nfs3svc_encode_attrstat(struct svc_rqst *, __be32 *,
>>> 				struct nfsd3_attrstat *);
>>> @@ -324,7 +335,8 @@ int nfs3svc_encode_pathconfres(struct svc_rqst *,
>>> __be32 *,
>>> 				struct nfsd3_pathconfres *);
>>> int nfs3svc_encode_commitres(struct svc_rqst *, __be32 *,
>>> 				struct nfsd3_commitres *);
>>> -
>>> +int nfs3svc_encode_umountres(struct svc_rqst *, __be32 *,
>>> +				struct nfsd3_umountres *);
>>> int nfs3svc_release_fhandle(struct svc_rqst *, __be32 *,
>>> 				struct nfsd3_attrstat *);
>>> int nfs3svc_release_fhandle2(struct svc_rqst *, __be32 *,
>>> diff --git a/include/linux/nfs3.h b/include/linux/nfs3.h
>>> index 6ccfe3b..968e2e0 100644
>>> --- a/include/linux/nfs3.h
>>> +++ b/include/linux/nfs3.h
>>> @@ -90,6 +90,7 @@ struct nfs3_fh {
>>> #define NFS3PROC_FSINFO		19
>>> #define NFS3PROC_PATHCONF	20
>>> #define NFS3PROC_COMMIT		21
>>> +#define NFS3PROC_UMOUNT		22
>>>
>>> #define NFS_MNT3_VERSION	3
>>>
>>> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
>>> index 5c0014d..da53bd8 100644
>>> --- a/include/linux/nfs_xdr.h
>>> +++ b/include/linux/nfs_xdr.h
>>> @@ -786,6 +786,14 @@ struct nfs3_readdirargs {
>>> 	struct page **		pages;
>>> };
>>>
>>> +struct nfs3_umountargs {
>>> +	__u32			dummy;
>>> +};
>>> +
>>> +struct nfs3_umountres {
>>> +	__u32			dummy;
>>> +};
>>> +
>>> struct nfs3_diropres {
>>> 	struct nfs_fattr *	dir_attr;
>>> 	struct nfs_fh *		fh;
>>> @@ -1425,6 +1433,7 @@ struct nfs_rpc_ops {
>>> 	struct nfs_client *
>>> 		(*init_client) (struct nfs_client *, const struct rpc_timeout *,
>>> 				const char *, rpc_authflavor_t);
>>> +	int	(*umount)(struct nfs_server *);
>>> };
>>>
>>> /*
>>> --
>>> 1.7.9.5
>>>
>>
>
>
