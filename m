Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58536 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752008AbdJESp5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 5 Oct 2017 14:45:57 -0400
Date: Thu, 5 Oct 2017 14:45:57 -0400
To: Eryu Guan <eguan@redhat.com>
Cc: linux-nfs@vger.kernel.org, "J . Bruce Fields" <bfields@redhat.com>
Subject: Re: [PATCH] nfsd4: define nfsd4_secinfo_no_name_release()
Message-ID: <20171005184557.GB19093@fieldses.org>
References: <20170929070110.13442-1-eguan@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170929070110.13442-1-eguan@redhat.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applying for 4.14.--b.

On Fri, Sep 29, 2017 at 03:01:10PM +0800, Eryu Guan wrote:
> Commit 34b1744c91cc ("nfsd4: define ->op_release for compound ops")
> defined a couple ->op_release functions and run them if necessary.
> 
> But there's a problem with that is that it reused
> nfsd4_secinfo_release() as the op_release of OP_SECINFO_NO_NAME, and
> caused a leak on struct nfsd4_secinfo_no_name in
> nfsd4_encode_secinfo_no_name(), because there's no .si_exp field in
> struct nfsd4_secinfo_no_name.
> 
> I found this because I was unable to umount an ext4 partition after
> exporting it via NFS & run fsstress on the nfs mount. A simplified
> reproducer would be:
> 
>  # mount a local-fs device at /mnt/test, and export it via NFS with
>  # fsid=0 export option (this is required)
>  mount /dev/sda5 /mnt/test
>  echo "/mnt/test *(rw,no_root_squash,fsid=0)" >> /etc/exports
>  service nfs restart
> 
>  # locally mount the nfs export with all default, note that I have
>  # nfsv4.1 configured as the default nfs version, because of the
>  # fsid export option, v4 mount would fail and fall back to v3
>  mount localhost:/mnt/test /mnt/nfs
> 
>  # try to umount the underlying device, but got EBUSY
>  umount /mnt/nfs
>  service nfs stop
>  umount /mnt/test <=== EBUSY here
> 
> Fixed it by defining a separate nfsd4_secinfo_no_name_release()
> function as the op_release method of OP_SECINFO_NO_NAME that
> releases the correct nfsd4_secinfo_no_name structure.
> 
> Fixes: 34b1744c91cc ("nfsd4: define ->op_release for compound ops")
> Signed-off-by: Eryu Guan <eguan@redhat.com>
> ---
>  fs/nfsd/nfs4proc.c | 9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 3c69db7d4905..8487486ec496 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -927,6 +927,13 @@ nfsd4_secinfo_release(union nfsd4_op_u *u)
>  		exp_put(u->secinfo.si_exp);
>  }
>  
> +static void
> +nfsd4_secinfo_no_name_release(union nfsd4_op_u *u)
> +{
> +	if (u->secinfo_no_name.sin_exp)
> +		exp_put(u->secinfo_no_name.sin_exp);
> +}
> +
>  static __be32
>  nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	      union nfsd4_op_u *u)
> @@ -2375,7 +2382,7 @@ static const struct nfsd4_operation nfsd4_ops[] = {
>  	},
>  	[OP_SECINFO_NO_NAME] = {
>  		.op_func = nfsd4_secinfo_no_name,
> -		.op_release = nfsd4_secinfo_release,
> +		.op_release = nfsd4_secinfo_no_name_release,
>  		.op_flags = OP_HANDLES_WRONGSEC,
>  		.op_name = "OP_SECINFO_NO_NAME",
>  		.op_rsize_bop = nfsd4_secinfo_rsize,
> -- 
> 2.13.6
