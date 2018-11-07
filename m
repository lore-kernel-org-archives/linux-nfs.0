Return-Path: <SRS0=4cvb=NS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 931ADC0044C
	for <linux-nfs@archiver.kernel.org>; Wed,  7 Nov 2018 21:48:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2D3A22086C
	for <linux-nfs@archiver.kernel.org>; Wed,  7 Nov 2018 21:48:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D3A22086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726770AbeKHHVJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 8 Nov 2018 02:21:09 -0500
Received: from fieldses.org ([173.255.197.46]:37364 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726751AbeKHHVJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Nov 2018 02:21:09 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 0953F1E31; Wed,  7 Nov 2018 16:48:50 -0500 (EST)
Date:   Wed, 7 Nov 2018 16:48:50 -0500
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 13/13] NFSD add nfs4 inter ssc to nfsd4_copy
Message-ID: <20181107214850.GC19588@fieldses.org>
References: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
 <20181019152905.32418-14-olga.kornievskaia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181019152905.32418-14-olga.kornievskaia@gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Oct 19, 2018 at 11:29:05AM -0400, Olga Kornievskaia wrote:
> From: Olga Kornievskaia <kolga@netapp.com>
> 
> Given a universal address, mount the source server from the destination
> server.  Use an internal mount. Call the NFS client nfs42_ssc_open to
> obtain the NFS struct file suitable for nfsd_copy_range.
> 
> Ability to do "inter" server-to-server depends on the an nfsd kernel
> parameter "inter_copy_offload_enabled".
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfsd/nfs4proc.c   | 298 ++++++++++++++++++++++++++++++++++++++++++++++++---
>  fs/nfsd/nfssvc.c     |   6 ++
>  fs/nfsd/xdr4.h       |   5 +
>  include/linux/nfs4.h |   1 +
>  4 files changed, 293 insertions(+), 17 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 59e9d0c..6dcd80c 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1153,6 +1153,229 @@ void nfsd4_shutdown_copy(struct nfs4_client *clp)
>  	while ((copy = nfsd4_get_copy(clp)) != NULL)
>  		nfsd4_stop_copy(copy);
>  }
> +#ifdef CONFIG_NFSD_V4_2_INTER_SSC
> +
> +extern struct file *nfs42_ssc_open(struct vfsmount *ss_mnt,
> +				   struct nfs_fh *src_fh,
> +				   nfs4_stateid *stateid);
> +extern void nfs42_ssc_close(struct file *filep);
> +
> +extern void nfs_sb_deactive(struct super_block *sb);
> +
> +#define NFSD42_INTERSSC_MOUNTOPS "minorversion=2,vers=4,addr=%s,clientaddr=%s"

The nfs man page says "clientaddr=" has no effect on 4.2 mounts.

Also, what's the "addr=" option for, isn't the server address already
given in the mount string?  (Honest question, I may be wrong here.)

> +
> +/**
> + * Support one copy source server for now.
> + */
> +static struct vfsmount *
> +nfsd4_interssc_connect(struct nl4_server *nss, struct svc_rqst *rqstp)
> +{
> +	struct file_system_type *type;
> +	struct vfsmount *ss_mnt;
> +	struct nfs42_netaddr *naddr;
> +	struct sockaddr_storage tmp_addr;
> +	size_t tmp_addrlen, match_netid_len = 3;
> +	char *startsep = "", *endsep = "", *match_netid = "tcp";
> +	char *ipaddr, *ipaddr2, *raw_data;
> +	int len, raw_len, status = -EINVAL;
> +
> +	/* Currently support only NL4_NETADDR source server */
> +	if (nss->nl4_type != NL4_NETADDR) {
> +		WARN(nss->nl4_type != NL4_NETADDR,
> +			"nfsd4_copy src server not NL4_NETADDR\n");

Won't nfsd4_decode_nl4_server actually let through NL4_NAME and NL4_URL?
That would make this WARN() triggerable by a client--that's bad.

> +		goto out_err;
> +	}
> +
> +	naddr = &nss->u.nl4_addr;
> +
> +	tmp_addrlen = rpc_uaddr2sockaddr(SVC_NET(rqstp), naddr->addr,
> +					 naddr->addr_len,
> +					 (struct sockaddr *)&tmp_addr,
> +					 sizeof(tmp_addr));
> +	if (tmp_addrlen == 0)
> +		goto out_err;
> +
> +	if (tmp_addr.ss_family == AF_INET6) {
> +		startsep = "[";
> +		endsep = "]";
> +		match_netid = "tcp6";
> +		match_netid_len = 4;
> +	}
> +
> +	if (naddr->netid_len != match_netid_len ||
> +		strncmp(naddr->netid, match_netid, naddr->netid_len))

Just strcmp(naddr->netid, match_netid) would do the job.

> +		goto out_err;
> +
> +	/* Construct the raw data for the vfs_kern_mount call */
> +	len = RPC_MAX_ADDRBUFLEN + 1;
> +	ipaddr = kzalloc(len, GFP_KERNEL);
> +	if (!ipaddr)
> +		goto out_err;
> +
> +	rpc_ntop((struct sockaddr *)&tmp_addr, ipaddr, len);
> +
> +	/* 2 for ipv6 endsep and startsep. 3 for ":/" and trailing '/0'*/
> +	ipaddr2 = kzalloc(len + 5, GFP_KERNEL);
> +	if (!ipaddr2)
> +		goto out_free_ipaddr;
> +
> +	rpc_ntop((struct sockaddr *)&rqstp->rq_daddr, ipaddr2, len + 5);

Replace the above by two calls to a function that does kmalloc+rpcntop?
(Though actually I don't think we need ipaddr.)

> +
> +	raw_len = strlen(NFSD42_INTERSSC_MOUNTOPS) + strlen(ipaddr) +
> +			strlen(ipaddr2);
> +	raw_data = kzalloc(raw_len, GFP_KERNEL);
> +	if (!raw_data)
> +		goto out_free_ipaddr2;
> +
> +	snprintf(raw_data, raw_len, NFSD42_INTERSSC_MOUNTOPS, ipaddr,
> +		 ipaddr2);
> +
> +	status = -ENODEV;
> +	type = get_fs_type("nfs");
> +	if (!type)
> +		goto out_free_rawdata;

I believe you also need a put_filesystem after this.  (e.g. see
kernel/trace/trace.c:trace_automount().)

> +
> +	/* Set the server:<export> for the vfs_kerne_mount call */
> +	memset(ipaddr2, 0, len + 5);
> +	snprintf(ipaddr2, len + 5, "%s%s%s:/", startsep, ipaddr, endsep);
> +
> +	dprintk("%s  Raw mount data:  %s server:export %s\n", __func__,
> +		raw_data, ipaddr2);
> +
> +	/* Use an 'internal' mount: MS_KERNMOUNT -> MNT_INTERNAL */
> +	ss_mnt = vfs_kern_mount(type, MS_KERNMOUNT, ipaddr2, raw_data);
> +	if (IS_ERR(ss_mnt)) {
> +		status = PTR_ERR(ss_mnt);
> +		goto out_free_rawdata;
> +	}
> +

Let's combine the successful and failure cases, so the below should be
something like:

	out_free_rawdata:
		kfree(raw_data);
	out_free_ipaddr2:
		kfree(ipaddr2);
	out_free_ipaddr:
		kfree(ipaddr);
	out_err:
		if (IS_ERR(ret))
			dprintk("--> %s ERROR %d\n", __func__, status);
		return ret;


> +	kfree(raw_data);
> +	kfree(ipaddr2);
> +	kfree(ipaddr);
> +
> +	return ss_mnt;
> +
> +out_free_rawdata:
> +	kfree(raw_data);
> +out_free_ipaddr2:
> +	kfree(ipaddr2);
> +out_free_ipaddr:
> +	kfree(ipaddr);
> +out_err:
> +	dprintk("--> %s ERROR %d\n", __func__, status);
> +	return ERR_PTR(status);
> +}
> +
> +static void
> +nfsd4_interssc_disconnect(struct vfsmount *ss_mnt)
> +{
> +	nfs_sb_deactive(ss_mnt->mnt_sb);
> +	mntput(ss_mnt);
> +}
> +
> +/**
> + * nfsd4_setup_inter_ssc
> + *
> + * Verify COPY destination stateid.
> + * Connect to the source server with NFSv4.1.
> + * Create the source struct file for nfsd_copy_range.
> + * Called with COPY cstate:
> + *    SAVED_FH: source filehandle
> + *    CURRENT_FH: destination filehandle
> + *
> + * Returns errno (not nfserrxxx)
> + */
> +static struct vfsmount *
> +nfsd4_setup_inter_ssc(struct svc_rqst *rqstp,
> +		      struct nfsd4_compound_state *cstate,
> +		      struct nfsd4_copy *copy)
> +{
> +	struct svc_fh *s_fh = NULL;
> +	stateid_t *s_stid = &copy->cp_src_stateid;
> +	struct vfsmount *ss_mnt;
> +	__be32 status;
> +
> +	/* Verify the destination stateid and set dst struct file*/
> +	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
> +					    &copy->cp_dst_stateid,
> +					    WR_STATE, &copy->file_dst, NULL,
> +					    NULL);
> +	if (status) {
> +		ss_mnt = ERR_PTR(be32_to_cpu(status));

That looks wrong.  I don't think IS_ERR() is going to be true for that
value.

If we need to return either an nfserr or a pointer, best is probably to
have the function return __be32 and have the pointer returned in an
argument.

(Thought I notice the only caller ignores the error value, I wonder if
that's right.)

> +		goto out;
> +	}
> +
> +	ss_mnt = nfsd4_interssc_connect(copy->cp_src, rqstp);
> +	if (IS_ERR(ss_mnt))
> +		goto out;

So this function can return -ERRNO, or nfserr_*, or a pointer?  That
won't work.

> +	s_fh = &cstate->save_fh;
> +
> +	copy->c_fh.size = s_fh->fh_handle.fh_size;
> +	memcpy(copy->c_fh.data, &s_fh->fh_handle.fh_base, copy->c_fh.size);
> +	copy->stateid.seqid = s_stid->si_generation;
> +	memcpy(copy->stateid.other, (void *)&s_stid->si_opaque,
> +	       sizeof(stateid_opaque_t));
> +
> +out:
> +	return ss_mnt;
> +}
> +
> +static void
> +nfsd4_cleanup_inter_ssc(struct vfsmount *ss_mnt, struct file *src,
> +			struct file *dst)
> +{
> +	nfs42_ssc_close(src);
> +	fput(src);
> +	fput(dst);
> +	mntput(ss_mnt);
> +}
> +
> +#else /* CONFIG_NFSD_V4_2_INTER_SSC */
> +
> +static struct vfsmount *
> +nfsd4_setup_inter_ssc(struct svc_rqst *rqstp,
> +		      struct nfsd4_compound_state *cstate,
> +		      struct nfsd4_copy *copy)
> +{
> +	return ERR_PTR(-EINVAL);

I wonder if that's really the right error for the
server-to-server-copy-unsupported case.

> +}
> +
> +static void
> +nfsd4_cleanup_inter_ssc(struct vfsmount *ss_mnt, struct file *src,
> +			struct file *dst)
> +{
> +}
> +
> +static void
> +nfsd4_interssc_disconnect(struct vfsmount *ss_mnt)
> +{
> +}
> +
> +static struct file *nfs42_ssc_open(struct vfsmount *ss_mnt,
> +				   struct nfs_fh *src_fh,
> +				   nfs4_stateid *stateid)
> +{
> +	return NULL;
> +}
> +#endif /* CONFIG_NFSD_V4_2_INTER_SSC */
> +
> +static __be32
> +nfsd4_setup_intra_ssc(struct svc_rqst *rqstp,
> +		      struct nfsd4_compound_state *cstate,
> +		      struct nfsd4_copy *copy)
> +{
> +	return nfsd4_verify_copy(rqstp, cstate, &copy->cp_src_stateid,
> +				 &copy->file_src, &copy->cp_dst_stateid,
> +				 &copy->file_dst, NULL);
> +}
> +
> +static void
> +nfsd4_cleanup_intra_ssc(struct file *src, struct file *dst)
> +{
> +	fput(src);
> +	fput(dst);
> +}
>  
>  static void nfsd4_cb_offload_release(struct nfsd4_callback *cb)
>  {
> @@ -1217,12 +1440,16 @@ static __be32 nfsd4_do_copy(struct nfsd4_copy *copy, bool sync)
>  		status = nfs_ok;
>  	}
>  
> -	fput(copy->file_src);
> -	fput(copy->file_dst);
> +	if (copy->cp_src) /* Inter server SSC */
> +		nfsd4_cleanup_inter_ssc(copy->ss_mnt, copy->file_src,
> +					copy->file_dst);
> +	else
> +		nfsd4_cleanup_intra_ssc(copy->file_src, copy->file_dst);
> +
>  	return status;
>  }
>  
> -static void dup_copy_fields(struct nfsd4_copy *src, struct nfsd4_copy *dst)
> +static int dup_copy_fields(struct nfsd4_copy *src, struct nfsd4_copy *dst)
>  {
>  	dst->cp_src_pos = src->cp_src_pos;
>  	dst->cp_dst_pos = src->cp_dst_pos;
> @@ -1232,8 +1459,21 @@ static void dup_copy_fields(struct nfsd4_copy *src, struct nfsd4_copy *dst)
>  	memcpy(&dst->fh, &src->fh, sizeof(src->fh));
>  	dst->cp_clp = src->cp_clp;
>  	dst->file_dst = get_file(src->file_dst);
> -	dst->file_src = get_file(src->file_src);
> +	if (!src->cp_src) /* for inter, file_src doesnt exist yet */
> +		dst->file_src = get_file(src->file_src);
>  	memcpy(&dst->cp_stateid, &src->cp_stateid, sizeof(src->cp_stateid));
> +	if (src->cp_src) {
> +		dst->cp_src = kmalloc(sizeof(struct nl4_server), GFP_KERNEL);
> +		if (!dst->cp_src)
> +			return -ENOMEM;
> +		memcpy(dst->cp_src, src->cp_src, sizeof(struct nl4_server));
> +	}
> +	memcpy(&dst->stateid, &src->stateid, sizeof(src->stateid));
> +	memcpy(&dst->c_fh, &src->c_fh, sizeof(src->c_fh));
> +	dst->ss_mnt = src->ss_mnt;
> +
> +	return 0;
> +
>  }
>  
>  static void cleanup_async_copy(struct nfsd4_copy *copy)
> @@ -1244,6 +1484,7 @@ static void cleanup_async_copy(struct nfsd4_copy *copy)
>  	spin_lock(&copy->cp_clp->async_lock);
>  	list_del(&copy->copies);
>  	spin_unlock(&copy->cp_clp->async_lock);
> +	kfree(copy->cp_src);
>  	nfs4_put_copy(copy);
>  }
>  
> @@ -1252,7 +1493,18 @@ static int nfsd4_do_async_copy(void *data)
>  	struct nfsd4_copy *copy = (struct nfsd4_copy *)data;
>  	struct nfsd4_copy *cb_copy;
>  
> +	if (copy->cp_src) { /* Inter server SSC */
> +		copy->file_src = nfs42_ssc_open(copy->ss_mnt, &copy->c_fh,
> +					      &copy->stateid);
> +		if (IS_ERR(copy->file_src)) {
> +			copy->nfserr = nfserr_offload_denied;
> +			nfsd4_interssc_disconnect(copy->ss_mnt);
> +			goto do_callback;
> +		}
> +	}
> +
>  	copy->nfserr = nfsd4_do_copy(copy, 0);
> +do_callback:
>  	cb_copy = kzalloc(sizeof(struct nfsd4_copy), GFP_KERNEL);
>  	if (!cb_copy)
>  		goto out;
> @@ -1276,11 +1528,19 @@ static int nfsd4_do_async_copy(void *data)
>  	__be32 status;
>  	struct nfsd4_copy *async_copy = NULL;
>  
> -	status = nfsd4_verify_copy(rqstp, cstate, &copy->cp_src_stateid,
> -				   &copy->file_src, &copy->cp_dst_stateid,
> -				   &copy->file_dst, NULL);
> -	if (status)
> -		goto out;
> +	if (copy->cp_src) { /* Inter server SSC */
> +		if (!inter_copy_offload_enable || copy->cp_synchronous) {
> +			status = nfserr_notsupp;
> +			goto out;
> +		}
> +		copy->ss_mnt = nfsd4_setup_inter_ssc(rqstp, cstate, copy);
> +		if (IS_ERR(copy->ss_mnt))
> +			return nfserr_offload_denied;

We should check that this is the right error to return in all those
failure cases.

That's all I have for now.

--b.

> +	} else {
> +		status = nfsd4_setup_intra_ssc(rqstp, cstate, copy);
> +		if (status)
> +			return status;
> +	}
>  
>  	copy->cp_clp = cstate->clp;
>  	memcpy(&copy->fh, &cstate->current_fh.fh_handle,
> @@ -1291,15 +1551,15 @@ static int nfsd4_do_async_copy(void *data)
>  		status = nfserrno(-ENOMEM);
>  		async_copy = kzalloc(sizeof(struct nfsd4_copy), GFP_KERNEL);
>  		if (!async_copy)
> -			goto out;
> -		if (!nfs4_init_cp_state(nn, copy)) {
> -			kfree(async_copy);
> -			goto out;
> -		}
> +			goto out_err;
> +		if (!nfs4_init_cp_state(nn, copy))
> +			goto out_err;
>  		refcount_set(&async_copy->refcount, 1);
>  		memcpy(&copy->cp_res.cb_stateid, &copy->cp_stateid,
>  			sizeof(copy->cp_stateid));
> -		dup_copy_fields(copy, async_copy);
> +		status = dup_copy_fields(copy, async_copy);
> +		if (status)
> +			goto out_err;
>  		async_copy->copy_task = kthread_create(nfsd4_do_async_copy,
>  				async_copy, "%s", "copy thread");
>  		if (IS_ERR(async_copy->copy_task))
> @@ -1310,13 +1570,17 @@ static int nfsd4_do_async_copy(void *data)
>  		spin_unlock(&async_copy->cp_clp->async_lock);
>  		wake_up_process(async_copy->copy_task);
>  		status = nfs_ok;
> -	} else
> +	} else {
>  		status = nfsd4_do_copy(copy, 1);
> +	}
>  out:
>  	return status;
>  out_err:
>  	cleanup_async_copy(async_copy);
> -	goto out;
> +	status = nfserrno(-ENOMEM);
> +	if (copy->cp_src)
> +		nfsd4_interssc_disconnect(copy->ss_mnt);
> +	goto out_err;
>  }
>  
>  struct nfsd4_copy *
> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> index 89cb484..9d254e7 100644
> --- a/fs/nfsd/nfssvc.c
> +++ b/fs/nfsd/nfssvc.c
> @@ -30,6 +30,12 @@
>  
>  #define NFSDDBG_FACILITY	NFSDDBG_SVC
>  
> +bool inter_copy_offload_enable;
> +EXPORT_SYMBOL_GPL(inter_copy_offload_enable);
> +module_param(inter_copy_offload_enable, bool, 0644);
> +MODULE_PARM_DESC(inter_copy_offload_enable,
> +		 "Enable inter server to server copy offload. Default: false");
> +
>  extern struct svc_program	nfsd_program;
>  static int			nfsd(void *vrqstp);
>  
> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> index c98ef64..c7e3df1 100644
> --- a/fs/nfsd/xdr4.h
> +++ b/fs/nfsd/xdr4.h
> @@ -546,7 +546,12 @@ struct nfsd4_copy {
>  	struct task_struct	*copy_task;
>  	refcount_t		refcount;
>  	bool			stopped;
> +
> +	struct vfsmount		*ss_mnt;
> +	struct nfs_fh		c_fh;
> +	nfs4_stateid		stateid;
>  };
> +extern bool inter_copy_offload_enable;
>  
>  struct nfsd4_seek {
>  	/* request */
> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> index 4d76f87..e53a261 100644
> --- a/include/linux/nfs4.h
> +++ b/include/linux/nfs4.h
> @@ -17,6 +17,7 @@
>  #include <linux/uidgid.h>
>  #include <uapi/linux/nfs4.h>
>  #include <linux/sunrpc/msg_prot.h>
> +#include <linux/nfs.h>
>  
>  enum nfs4_acl_whotype {
>  	NFS4_ACL_WHO_NAMED = 0,
> -- 
> 1.8.3.1
