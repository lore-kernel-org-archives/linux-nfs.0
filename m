Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:35582 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757101AbdIHU2N (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 8 Sep 2017 16:28:13 -0400
Date: Fri, 8 Sep 2017 16:28:13 -0400
To: Olga Kornievskaia <kolga@netapp.com>
Cc: Trond.Myklebust@primarydata.com, anna.schumaker@netapp.com,
        bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [RFC v3 28/42] NFSD add nfs4 inter ssc to nfsd4_copy
Message-ID: <20170908202813.GC18220@fieldses.org>
References: <20170711164416.1982-1-kolga@netapp.com>
 <20170711164416.1982-29-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170711164416.1982-29-kolga@netapp.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 11, 2017 at 12:44:02PM -0400, Olga Kornievskaia wrote:
> Given a universal address, mount the source server from the destination
> server.  Use an internal mount. Call the NFS client nfs42_ssc_open to
> obtain the NFS struct file suitable for nfsd_copy_range.
> 
> Add Kconfig dependencies for inter server to server copy
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfsd/Kconfig      |  10 ++
>  fs/nfsd/nfs4proc.c   | 262 +++++++++++++++++++++++++++++++++++++++++++++++++--
>  include/linux/nfs4.h |   1 +
>  3 files changed, 263 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
> index 20b1c17..37ff3d5 100644
> --- a/fs/nfsd/Kconfig
> +++ b/fs/nfsd/Kconfig
> @@ -131,6 +131,16 @@ config NFSD_FLEXFILELAYOUT
>  
>  	  If unsure, say N.
>  
> +config NFSD_V4_2_INTER_SSC
> +	bool "NFSv4.2 inter server to server COPY"
> +	depends on NFSD_V4 && NFS_V4_1 && NFS_V4_2
> +	help
> +	  This option enables support for NFSv4.2 inter server to
> +	  server copy where the destination server calls the NFSv4.2
> +	  client to read the data to copy from the source server.
> +
> +	  If unsure, say N.
> +
>  config NFSD_V4_SECURITY_LABEL
>  	bool "Provide Security Label support for NFSv4 server"
>  	depends on NFSD_V4 && SECURITY
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index ceee852..b1095e9 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1072,16 +1072,227 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
>  	return status;
>  }
>  
> +#ifdef CONFIG_NFSD_V4_2_INTER_SSC
> +
> +extern struct file *nfs42_ssc_open(struct vfsmount *ss_mnt,
> +				   struct nfs_fh *src_fh,
> +				   nfs4_stateid *stateid);
> +extern struct file *nfs42_ssc_close(struct file *filep);
> +
> +extern void nfs_sb_deactive(struct super_block *sb);
> +
> +#define NFSD42_INTERSSC_RAWDATA "minorversion=2,vers=4,addr=%s,clientaddr=%s"

INTERSCC_RAWDATA isn't the most helpful name.  Maybe MOUNTOPTS could be
in there?

> +
> +/**
> + * Support one copy source server for now.
> + */
> +static struct vfsmount *
> +nfsd4_interssc_connect(struct nl4_servers *nss, struct svc_rqst *rqstp)
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
> +	/* Currently support for one NL4_NETADDR source server */
> +	if (nss->nl_svr->nl4_type != NL4_NETADDR) {
> +		WARN(nss->nl_svr->nl4_type != NL4_NETADDR,
> +			"nfsd4_copy src server not NL4_NETADDR\n");
> +		goto out_err;
> +	}

We already checked this at xdr decoding time, didn't we?  Well, maybe
i'ts still worth a WARN.  Better, as mentioned before, maybe the data
structures just should assume only 1 NL4_NETADDR source server.

> +
> +	naddr = &nss->nl_svr->u.nl4_addr;
> +
> +	tmp_addrlen = rpc_uaddr2sockaddr(SVC_NET(rqstp), naddr->na_uaddr,
> +					naddr->na_uaddr_len,
> +					(struct sockaddr *)&tmp_addr,
> +					sizeof(tmp_addr));
> +	if (tmp_addrlen == 0)
> +		goto out_err;
> +
> +	if (tmp_addr.ss_family == AF_INET6) {
> +		startsep = "[";
> +		endsep = "]";
> +		match_netid = "tcp6";
> +		match_netid_len = 4;
> +	}

What about the tcp/ipv4 case?  Oh, I see, it's handled by the
initialization above.  That's a little confusing.

> +
> +	if (naddr->na_netid_len != match_netid_len ||
> +	    strncmp(naddr->na_netid, match_netid, naddr->na_netid_len))
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
> +
> +	raw_len = strlen(NFSD42_INTERSSC_RAWDATA) + strlen(ipaddr) +
> +			strlen(ipaddr2);
> +	raw_data = kzalloc(raw_len, GFP_KERNEL);
> +	if (!raw_data)
> +		goto out_free_ipaddr2;
> +
> +	snprintf(raw_data, raw_len, NFSD42_INTERSSC_RAWDATA, ipaddr,
> +		 ipaddr2);

Could "raw_data" be named more helpfully?

> +
> +	status = -ENODEV;
> +	type = get_fs_type("nfs");
> +	if (!type)
> +		goto out_free_rawdata;
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

I wonder if creating a mount (even a kernel internal one) has any
unexpected side effects.  Is it a problem that it could share caches
with any already-existing mounts of that export?

> +	if (IS_ERR(ss_mnt)) {
> +		status = PTR_ERR(ss_mnt);
> +		goto out_free_rawdata;
> +	}
> +
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
> +	mntput(ss_mnt);
> +	nfs_sb_deactive(ss_mnt->mnt_sb);

OK, I don't claim to understand that.

Are you sure it's still safe to dereference ss_mnt after calling
mntput() on it?

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
> +			struct nfsd4_compound_state *cstate,
> +			struct nfsd4_copy *copy, struct file **src,
> +			struct file **dst)
> +{
> +	struct svc_fh *s_fh = NULL;
> +	stateid_t *s_stid = &copy->cp_src_stateid;
> +	struct nfs_fh fh;
> +	nfs4_stateid stateid;
> +	struct file *filp;
> +	struct vfsmount *ss_mnt;
> +	__be32 status;
> +
> +	/* Verify the destination stateid and set dst struct file*/
> +	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
> +					&copy->cp_dst_stateid,
> +					WR_STATE, dst, NULL);
> +	if (status) {
> +		ss_mnt = ERR_PTR(be32_to_cpu(status));
> +		goto out;
> +	}
> +
> +	/* Inter copy source fh is always stale */

Not necessarily.

> +	CLEAR_CSTATE_FLAG(cstate, IS_STALE_FH);
> +
> +	ss_mnt = nfsd4_interssc_connect(&copy->cp_src, rqstp);
> +	if (IS_ERR(ss_mnt))
> +		goto out;
> +
> +	s_fh = &cstate->save_fh;
> +
> +	fh.size = s_fh->fh_handle.fh_size;
> +	memcpy(fh.data, &s_fh->fh_handle.fh_base, fh.size);
> +	stateid.seqid = s_stid->si_generation;
> +	memcpy(stateid.other, (void *)&s_stid->si_opaque,
> +		sizeof(stateid_opaque_t));
> +
> +	filp =  nfs42_ssc_open(ss_mnt, &fh, &stateid);

So that was defined in the client-side patches?

> +	if (IS_ERR(filp)) {
> +		nfsd4_interssc_disconnect(ss_mnt);
> +		return ERR_CAST(filp);
> +	}
> +	*src = filp;
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
> +
> +	nfsd4_interssc_disconnect(ss_mnt);
> +
> +}
> +
> +#else /* CONFIG_NFSD_V4_2_INTER_SSC */
> +
> +static struct vfsmount *
> +nfsd4_setup_inter_ssc(struct svc_rqst *rqstp,
> +			struct nfsd4_compound_state *cstate,
> +			struct nfsd4_copy *copy, struct file **src,
> +			struct file **dst)
> +{
> +	return ERR_PTR(-EINVAL);
> +}
> +
> +static void
> +nfsd4_cleanup_inter_ssc(struct vfsmount *ss_mnt, struct file *src,
> +			struct file *dst)
> +{
> +}
> +
> +#endif /* CONFIG_NFSD_V4_2_INTER_SSC */
> +
>  static __be32
> -nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> -		struct nfsd4_copy *copy)
> +nfsd4_setup_intra_ssc(struct svc_rqst *rqstp,
> +		      struct nfsd4_compound_state *cstate,
> +		      struct nfsd4_copy *copy, struct file **src,
> +		      struct file **dst)
>  {
> -	struct file *src, *dst;
>  	__be32 status;
> -	ssize_t bytes;
>  
> -	status = nfsd4_verify_copy(rqstp, cstate, &copy->cp_src_stateid, &src,
> -				   &copy->cp_dst_stateid, &dst);
> +	status = nfsd4_verify_copy(rqstp, cstate, &copy->cp_src_stateid, src,
> +				   &copy->cp_dst_stateid, dst);
>  	if (status)
>  		goto out;
>  
> @@ -1089,7 +1300,37 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
>  	if (HAS_CSTATE_FLAG(cstate, IS_STALE_FH)) {
>  		CLEAR_CSTATE_FLAG(cstate, IS_STALE_FH);
>  		cstate->status = nfserr_copy_stalefh;
> -		goto out_put;
> +	}
> +out:
> +	return status;
> +}
> +
> +static void
> +nfsd4_cleanup_intra_ssc(struct file *src, struct file *dst)
> +{
> +	fput(src);
> +	fput(dst);
> +}
> +
> +static __be32
> +nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> +	struct nfsd4_copy *copy)
> +{
> +	struct vfsmount *ss_mnt = NULL;
> +	struct file *src, *dst;
> +	__be32 status;
> +	ssize_t bytes;
> +
> +	if (copy->cp_src.nl_nsvr > 0) { /* Inter server SSC */
> +		ss_mnt = nfsd4_setup_inter_ssc(rqstp, cstate, copy, &src, &dst);
> +		if (IS_ERR(ss_mnt)) {
> +			status = nfserrno(PTR_ERR(ss_mnt));
> +			goto out;

Touched on before, I think: this could use some checking to make sure
that the error returned is useful to the client.  (I'm not sure exactly
what the most likely failures are, though.)

--b.

> +		}
> +	} else {
> +		status = nfsd4_setup_intra_ssc(rqstp, cstate, copy, &src, &dst);
> +		if (status)
> +			goto out;
>  	}
>  
>  	bytes = nfsd_copy_file_range(src, copy->cp_src_pos,
> @@ -1106,9 +1347,10 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
>  		status = nfs_ok;
>  	}
>  
> -out_put:
> -	fput(src);
> -	fput(dst);
> +	if (copy->cp_src.nl_nsvr > 0)   /* Inter server SSC */
> +		nfsd4_cleanup_inter_ssc(ss_mnt, src, dst);
> +	else
> +		nfsd4_cleanup_intra_ssc(src, dst);
>  out:
>  	return status;
>  }
> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> index 5aa36ac..843443b 100644
> --- a/include/linux/nfs4.h
> +++ b/include/linux/nfs4.h
> @@ -16,6 +16,7 @@
>  #include <linux/uidgid.h>
>  #include <uapi/linux/nfs4.h>
>  #include <linux/sunrpc/msg_prot.h>
> +#include <linux/nfs.h>
>  
>  enum nfs4_acl_whotype {
>  	NFS4_ACL_WHO_NAMED = 0,
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
