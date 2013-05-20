Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:13268 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752710Ab3ETTlZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 May 2013 15:41:25 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Steve Dickson <SteveD@redhat.com>
CC: "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 11/13] NFS: Client implementation of Labeled-NFS
Date: Mon, 20 May 2013 19:40:55 +0000
Message-ID: <1369078846.6115.39.camel@leira.trondhjem.org>
References: <1368719808-14584-1-git-send-email-SteveD@redhat.com>
	 <1368719808-14584-12-git-send-email-SteveD@redhat.com>
In-Reply-To: <1368719808-14584-12-git-send-email-SteveD@redhat.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-05-16 at 11:56 -0400, Steve Dickson wrote:
> From: Steve Dickson <steved@redhat.com>
> 
> This patch implements the client transport and handling support for labeled
> NFS. The patch adds two functions to encode and decode the security label
> recommended attribute which makes use of the LSM hooks added earlier. It also
> adds code to grab the label from the file attribute structures and encode the
> label to be sent back to the server.
> 
> Acked-by: James Morris <james.l.morris@oracle.com>
> Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
> Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
> Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
> Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---

<snip>

>  
> +static int decode_attr_security_label(struct xdr_stream *xdr, uint32_t *bitmap,
> +					struct nfs4_label *label)
> +{
> +	uint32_t pi = 0;
> +	uint32_t lfs = 0;
> +	__u32 len;
> +	__be32 *p;
> +	int status = 0;
> +
> +	if (unlikely(bitmap[2] & (FATTR4_WORD2_SECURITY_LABEL - 1U)))
> +		return -EIO;
> +	if (likely(bitmap[2] & FATTR4_WORD2_SECURITY_LABEL)) {
> +		p = xdr_inline_decode(xdr, 4);
> +		if (unlikely(!p))
> +			goto out_overflow;
> +		lfs = be32_to_cpup(p++);
> +		p = xdr_inline_decode(xdr, 4);
> +		if (unlikely(!p))
> +			goto out_overflow;
> +		pi = be32_to_cpup(p++);
> +		p = xdr_inline_decode(xdr, 4);
> +		if (unlikely(!p))
> +			goto out_overflow;
> +		len = be32_to_cpup(p++);
> +		p = xdr_inline_decode(xdr, len);
> +		if (unlikely(!p))
> +			goto out_overflow;
> +		if (len < NFS4_MAXLABELLEN) {
> +			if (label) {
> +				memcpy(label->label, p, len);
> +				label->len = len;
> +				label->pi = pi;
> +				label->lfs = lfs;
> +				status = NFS_ATTR_FATTR_V4_SECURITY_LABEL;
> +			}
> +			bitmap[2] &= ~FATTR4_WORD2_SECURITY_LABEL;
> +		} else
> +			printk(KERN_WARNING "%s: label too long (%u)!\n",
> +					__func__, len);
> +	}
> +	if (label && label->label)
> +		dprintk("%s: label=%s, len=%d, PI=%d, LFS=%d\n", __func__,
> +			(char *)label->label, label->len, label->pi, label->lfs);
> +	return status;
> +
> +out_overflow:
> +	print_overflow_msg(__func__, xdr);
> +	return -EIO;
> +}
> +
>  static int decode_attr_time_modify(struct xdr_stream *xdr, uint32_t *bitmap, struct timespec *time)
>  {
>  	int status = 0;
> @@ -4384,7 +4465,7 @@ out_overflow:
>  
>  static int decode_getfattr_attrs(struct xdr_stream *xdr, uint32_t *bitmap,
>  		struct nfs_fattr *fattr, struct nfs_fh *fh,
> -		struct nfs4_fs_locations *fs_loc,
> +		struct nfs4_fs_locations *fs_loc, struct nfs4_label *label,
>  		const struct nfs_server *server)
>  {
>  	int status;
> @@ -4492,6 +4573,13 @@ static int decode_getfattr_attrs(struct xdr_stream *xdr, uint32_t *bitmap,
>  	if (status < 0)
>  		goto xdr_error;
>  
> +	if (label) {
> +		status = decode_attr_security_label(xdr, bitmap, label);
> +		if (status < 0)
> +			goto xdr_error;
> +		fattr->valid |= status;
> +	}
> +
>  xdr_error:
>  	dprintk("%s: xdr returned %d\n", __func__, -status);
>  	return status;
> @@ -4499,7 +4587,7 @@ xdr_error:
>  
>  static int decode_getfattr_generic(struct xdr_stream *xdr, struct nfs_fattr *fattr,
>  		struct nfs_fh *fh, struct nfs4_fs_locations *fs_loc,
> -		const struct nfs_server *server)
> +		struct nfs4_label *label, const struct nfs_server *server)
>  {
>  	unsigned int savep;
>  	uint32_t attrlen,
> @@ -4518,7 +4606,8 @@ static int decode_getfattr_generic(struct xdr_stream *xdr, struct nfs_fattr *fat
>  	if (status < 0)
>  		goto xdr_error;
>  
> -	status = decode_getfattr_attrs(xdr, bitmap, fattr, fh, fs_loc, server);
> +	status = decode_getfattr_attrs(xdr, bitmap, fattr, fh, fs_loc,
> +					label, server);
>  	if (status < 0)
>  		goto xdr_error;
>  
> @@ -4529,9 +4618,9 @@ xdr_error:
>  }
>  
>  static int decode_getfattr(struct xdr_stream *xdr, struct nfs_fattr *fattr,
> -		const struct nfs_server *server)
> +		struct nfs4_label *label, const struct nfs_server *server)


Can we please just add a 'decode_getfattr_labeled()' so that we don't
have to go through all this extra churn with adding NULL arguments to
all the decode_getfattr() users?


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
