Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:40364 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934676AbdBVVQi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 22 Feb 2017 16:16:38 -0500
Date: Wed, 22 Feb 2017 15:50:47 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: Allow enabling NFSv4.x without also requiring
 NFSv4.0
Message-ID: <20170222205047.GA18508@fieldses.org>
References: <20170222184822.4658-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170222184822.4658-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 22, 2017 at 01:48:22PM -0500, Trond Myklebust wrote:
> For some setups, we may want to allow clients to fall back to NFSv3, or
> even to fail, if a specific minor version of NFSv4 is not enabled.
> For instance, an application that relies on NFSv4.2 CLONE functionality
> is simply not going to work when it falls back to NFSv4.1 or NFSv4.

I have a patch of Neil's queued up for 4.11 that claims to accomplish
the same thing:

	http://git.linux-nfs.org/?p=bfields/linux.git;a=commit;h=e35659f1b03c03946cae8abb6b0a9e170b574f1c

If it's deficient in some way, could you make an incremental patch?

--b.

> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfsd/nfsctl.c | 16 ++++++++--------
>  fs/nfsd/nfssvc.c | 14 ++++++++++++++
>  2 files changed, 22 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index f3b2f34b10a3..81b6a0aa4b92 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -561,6 +561,7 @@ static ssize_t __write_versions(struct file *file, char *buf, size_t size)
>  		len = qword_get(&mesg, vers, size);
>  		if (len <= 0) return -EINVAL;
>  		do {
> +			enum vers_op cmd;
>  			sign = *vers;
>  			if (sign == '+' || sign == '-')
>  				num = simple_strtol((vers+1), &minorp, 0);
> @@ -572,21 +573,20 @@ static ssize_t __write_versions(struct file *file, char *buf, size_t size)
>  				minor = simple_strtoul(minorp+1, NULL, 0);
>  				if (minor == 0)
>  					return -EINVAL;
> -				if (nfsd_minorversion(minor, sign == '-' ?
> -						     NFSD_CLEAR : NFSD_SET) < 0)
> -					return -EINVAL;
> -				goto next;
> -			}
> +			} else
> +				minor = 0;
> +			cmd = sign == '-' ? NFSD_CLEAR : NFSD_SET;
>  			switch(num) {
>  			case 2:
>  			case 3:
> -			case 4:
> -				nfsd_vers(num, sign == '-' ? NFSD_CLEAR : NFSD_SET);
> +				nfsd_vers(num, cmd);
>  				break;
> +			case 4:
> +				if (nfsd_minorversion(minor, cmd) >= 0)
> +					break;
>  			default:
>  				return -EINVAL;
>  			}
> -		next:
>  			vers += len + 1;
>  		} while ((len = qword_get(&mesg, vers, size)) > 0);
>  		/* If all get turned off, turn them back on, as
> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> index e6bfd96734c0..07bf3bd9687b 100644
> --- a/fs/nfsd/nfssvc.c
> +++ b/fs/nfsd/nfssvc.c
> @@ -153,6 +153,18 @@ int nfsd_vers(int vers, enum vers_op change)
>  	return 0;
>  }
>  
> +static void
> +nfsd_adjust_nfsd_versions4(void)
> +{
> +	unsigned i;
> +
> +	for (i = 0; i <= NFSD_SUPPORTED_MINOR_VERSION; i++) {
> +		if (nfsd_supported_minorversions[i])
> +			return;
> +	}
> +	nfsd_vers(4, NFSD_CLEAR);
> +}
> +
>  int nfsd_minorversion(u32 minorversion, enum vers_op change)
>  {
>  	if (minorversion > NFSD_SUPPORTED_MINOR_VERSION)
> @@ -160,9 +172,11 @@ int nfsd_minorversion(u32 minorversion, enum vers_op change)
>  	switch(change) {
>  	case NFSD_SET:
>  		nfsd_supported_minorversions[minorversion] = true;
> +		nfsd_vers(4, NFSD_SET);
>  		break;
>  	case NFSD_CLEAR:
>  		nfsd_supported_minorversions[minorversion] = false;
> +		nfsd_adjust_nfsd_versions4();
>  		break;
>  	case NFSD_TEST:
>  		return nfsd_supported_minorversions[minorversion];
> -- 
> 2.9.3
