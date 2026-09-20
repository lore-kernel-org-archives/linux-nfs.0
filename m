Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 33FC547043E;
	Sun, 20 Sep 2026 17:08:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789924133; cv=none; b=aWT1KqYAJ5F1qiqreVWkfODw8eOS8mo0M7WrWnzVXEV5YSry/NK/7YTPu0eL1PpVi6GhDRCdxlBpDNZHeE6G16E1qVTUQPAbkVx47BQo8CQPB0TRpesTQHbipMLeAonin+pbtz9rrArDJiggme+d3Dciurnez/cA4x/I2XvqGfQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789924133; c=relaxed/simple;
	bh=Ktr8iveArGKXM+AJMuKZDd1u7kF+3hA4fMnIriSPTmY=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:Subject:Content-Type; b=SbtXM3QRB8X8u0SgE8IP9yj8pnepr33bFb1BCAX2y27DgmNyzdKx5BHtZ8qD8w8vWWizKGAEbl2jxA9LlhgowozcORt/rPAZQtlac0USwTxufRNlZgcJlZear5doxh5r8ATiUYcTa6FIO90DYtAzUfCNneQz7w8/DEQPIjWPvPI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Ka3WP5WS; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Ka3WP5WS"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5F3B31F00893;
	Sun, 20 Sep 2026 17:08:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789924131;
	bh=WkaNo7HN5kCJFTD9bMLAl3NMY+GmFyJQa6e7ryXKOvY=;
	h=Date:From:To:Cc:Subject;
	b=Ka3WP5WSWuKUQKQlJikqagiOZ0sBmYJIbYi8LYQKu/XE8DEtWkSL7G64MWwFzmThq
	 xz4Eb5CUXx18C/vBbrqVAeNixKZMX+HIdKcAxSxUvcIzCy9dX5ELwmCKdJ5nxPIHt3
	 jrx0Ys9xFjzb0tamRFBGPhmHyDH6EzLjc36mVyaWrYEjWK3kUikTDiFJdHfbktfQkU
	 lCU2zMowadhYHfWDd9wjWBCIz/4zLgWEn1i7A7DTptpswElcWG164NeHrEslB+aFm0
	 YATrq8ZXY/G+A96Z8qhWDLZ27YOQcNzw0updwBT7NNU24RIR3PIjbRaT2LjiOGI/nV
	 L/hX8PDKHqeQg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 8ADABF40068;
	Sun, 20 Sep 2026 13:08:50 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sun, 20 Sep 2026 13:08:50 -0400
X-ME-Sender: <xms:IhOwatVw7y_oXB4hre0DQ6FjuKng2OxMRlBEEWmR1bDMh8Wpvi4gxA>
    <xme:IhOwaoY8PR6Pvr2yo4MUFf7g1_1i3xxdOtFNJcF6zOlS0UJaQ7rsKhohZK5SQadXA
    _UjGl9JVUdjJlIEQNu18Pu4pET3EFcu4X13A_UjP9bUzwzvxvvprV8>
X-ME-Proxy-Cause: dmFkZTFtnh3vtJTxG35JYOX56IuAoeta1S5dY0VEJNuEAtCuAg1+k8Ljrc+94tdjLFv3eW
    JF+4J+3neWbDQkb6ROgC8yzOA8y6Q0EoMIx5UdrVM4BeUQaAw6BlQcUWyQiZ7q1Qqi4HBZ
    3m4Ro/h6bJxOpwq8Jm1XMjaNIUmdTXhL6sCocJISWpc8F32z9O5g59svM+YQ5Q0R+2XQH3
    pG0bWAxnklQ4UlSzE5/DdN8KH8cghnwzEk7hQOKyONWhLvkyoSsJD2u47tP/r81/gBjQKR
    kir8tL4m9X7xdca55GP7xX6xXf49muhRrZa8W3pvjYb73JjoFxTCMsq+hWqe3alIdyPdC/
    JXRsId3L5zq0wAtSa3X79u5SLUU2U/ZC+mdJknPfwYzKY0sBh4SzWeSMw3PVPfcJCom3RY
    DspuONvoEfMrbESUG1FQqfjmdUpSBwKHYjGFefzLZd/mAO8oftgxtobXECgt2bqBVVDkk6
    0+E8P5u/m9mGh31ixkRJDGy+Gn76JkRfAfBBRagIUZdsfSigK3Bj6lQ4J8ZWV1dc9pmlBd
    /24V7sY0nmGgvip9CICVOjVSUIVvhJ+Tk3lGO0NILifnzHS2Rnqjnn5OS/ekcWhgkktrQu
    9N0c26pd3JfqCPH2Z25Ff2AQXPjiXgNfBtaPbaJNo2Q3BR/5VRRUTDvROIlg
X-ME-Proxy: <xmx:IhOwap7eVBK_lZY1-JGlHt6IDc-M2W4D5s0A05JiZZLjILUH7rZppQ>
    <xmx:IhOwaoNunukBcZaU_HOEVGSKXq-_Jzx9Qu-w8ZgLBPgiyjWS3NYQOw>
    <xmx:IhOwalHEseXyUSAC8u-88hBqSxNjpEpOZOKrFYuoUACg0GVNcdXd_g>
    <xmx:IhOwak0EeWaSssEAqVGm12SCB0wygX5RwbR6_gKL_252kIS7_BjBnQ>
    <xmx:IhOwakGghV4NCa0ZpVRK5HnxEeIXyude15oB84eWbZKZgkjZsSeReP_v>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 5955D780070; Sun, 20 Sep 2026 13:08:50 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: Ao5V-aygA_bs
Date: Sun, 20 Sep 2026 13:08:21 -0400
From: "Chuck Lever" <cel@kernel.org>
To: neilb@ownmail.net
Cc: viro@zeniv.linux.org.uk, brauner@kernel.org, jlayton@kernel.org,
 jkoolstra@xs4all.nl, mjguzik@gmail.com, dorjoychy111@gmail.com,
 trondmy@kernel.org, anna@kernel.org, agruenba@redhat.com,
 gfs2@lists.linux.dev, idryomov@gmail.com, amarkuze@redhat.com,
 slava@dubeyko.com, ceph-devel@vger.kernel.org, pc@manguebit.org,
 linkinjeon@kernel.org, linux-cifs@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Message-Id: <c3dfb897-c18c-426e-ba4c-10d957085e7e@slotpi15m67>
Subject: Re: [PATCH v2 11/14] nfsd: check for mountpoints after non-creating open.
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On 9/18/26 9:26 PM, NeilBrown wrote:
> From: NeilBrown <neil@brown.name>
> 
> A file can be a mountpoint for nfsd purposes when it isn't in the
> dcache.  This happens when it is a junction (nfsd4_is_junction()).
> So when we open a file and find that it already existed though
> not in the dcache, we have to check if it is a mountpoint (or junction)
> and potentially follow the junction.
> 
> So move the mountpoint crossing code in nfsd4_create_file() to a new
> label at the end of the function and goto there both when an in-dcache
> lookup finds an existing file, and when vfs_lookup_open() finds an
> existing file.
> 
> Signed-off-by: NeilBrown <neil@brown.name>

At this point in the series, nfsd4_create_file() still calls the local
do_lookup_open() helper. Nothing under fs/nfsd calls vfs_lookup_open()
until 12/14. Can the last sentence name do_lookup_open() instead?


> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 6e443503d0b7..3d37754f787b 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c

[ ... ]

> @@ -339,21 +340,8 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  						    open->op_fnamelen),
>  					  parent.dentry);
>  		if (child && !IS_ERR(child) && d_is_reg(child) &&
> -		    unlikely(nfsd_mountpoint(child, fhp->fh_export))) {

[ ... ]

> +		    unlikely(nfsd_mountpoint(child, fhp->fh_export)))
> +			goto do_cross_mnt;
>  		if (!IS_ERR(child))
>  			dput(child);
>  	}
> @@ -466,6 +454,14 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  			status = nfserr_exist;
>  			goto out;
>  		}
> +		/* We opened an existing file, it might be a junction. */
> +		if (unlikely(nfsd_mountpoint(child, fhp->fh_export) == 1)) {
> +			dget(child);
> +			nfsd_filp_close(open->op_filp);
> +			open->op_filp = NULL;
> +			goto do_cross_mnt;
> +		}

Can this leak the dentry and export references held in resfhp? By the
time this branch runs, resfhp has already been composed, just above:

	status = fh_compose(resfhp, fhp->fh_export, child, fhp);
	if (status != nfs_ok)
		goto out;

and do_cross_mnt then calls fh_compose(resfhp, ...) a second time.
fh_compose() releases its target only when ref_fh == fhp, which is not
the case here, so it complains and then overwrites both pointers:

fs/nfsd/nfsfh.c:fh_compose() {
    ...
	if (fhp->fh_dentry) {
		printk(KERN_ERR "fh_compose: fh %pd2 not initialized!\n",
		       dentry);
	}
    ...
	fhp->fh_dentry = dget(dentry); /* our internal copy */
	fhp->fh_export = exp_get(exp);
    ...
}

The goto from the try_lookup_noperm() check is fine, since it is taken
before resfhp is composed. Calling fh_put(resfhp) before this goto might
be enough.

Nit: The dcache check above tests nfsd_mountpoint() for nonzero while
this one tests for == 1. I think that works because a d_managed()
dentry (return value 2) is pinned in the dcache, so the earlier check
always catches it. Is that the reasoning? If so, could the comment say
that? nfsd_mountpoint() also returns 1 for NFSEXP_V4ROOT exports, so
it isn't only junctions that arrive here.


> +
>  		/* NFSv4 protocol requires change attributes
>  		 * even though no change happened.
>  		 */
> @@ -511,6 +507,21 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  out:
>  	nfsd_attrs_free(&attrs);
>  	return status;
> +
> +do_cross_mnt:
> +	exp = exp_get(fhp->fh_export);
> +
> +	status = nfsd_cross_mnt(rqstp, &child, &exp);
> +	if (status == nfs_ok)
> +		status = fh_compose(resfhp, exp,
> +				    child, fhp);
> +	fh_fill_post_noop(fhp);
> +	open->op_truncate =
> +		(iap->ia_valid & ATTR_SIZE) &&
> +		!iap->ia_size;

Nit: The non-crossing path includes d_is_reg(child) in this expression:

	open->op_truncate = (d_is_reg(child) &&
			     (iap->ia_valid & ATTR_SIZE) &&
			     !iap->ia_size);

After nfsd_cross_mnt(), child might no longer be a regular file.
do_open_lookup() rejects that via nfsd_check_obj_isreg() before
op_truncate is used, so nothing breaks. Perhaps the two expressions
should match?


> +	dput(child);
> +	exp_put(exp);
> +	goto out;
>  }


-- 
Chuck Lever (Come to NFS Bake-a-thon! https://nfsv4bat.org)
