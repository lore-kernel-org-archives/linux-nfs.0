Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52266 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750818AbcLUVlz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 21 Dec 2016 16:41:55 -0500
Date: Wed, 21 Dec 2016 16:41:53 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: NeilBrown <neilb@suse.com>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSD: correctly range-check v4.x minor version when
 setting versions.
Message-ID: <20161221214153.GK17617@parsley.fieldses.org>
References: <87bmw6rm7w.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87bmw6rm7w.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Makes sense to me, queueing up for 4.11 (none of this seems urgent).

--b.

On Wed, Dec 21, 2016 at 02:32:19PM +1100, NeilBrown wrote:
> 
> Writing to /proc/fs/nfsd/versions allows individual major versions
> and NFSv4 minor versions to be enabled or disabled.
> 
> However NFSv4.0 cannot currently be disabled, thought there is no good reason.
> Also the minor number is parsed as a 'long' but used as an 'int'
> so '4294967297' will be incorrectly treated as '1'.
> 
> This patch removes the test on 'minor == 0' and switches to kstrtouint()
> to get correct range checking.
> 
> When reading from /proc/fs/nfsd/versions, 4.0 is current not reported.
> To allow the disabling for v4.0 to be visible, while maintaining
> backward compatibility, change code to report "-4.0" if appropriate, but
> not "+4.0".
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  fs/nfsd/nfsctl.c | 10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index f3b2f34b10a3..d54fb0e3f30e 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -569,8 +569,7 @@ static ssize_t __write_versions(struct file *file, char *buf, size_t size)
>  			if (*minorp == '.') {
>  				if (num != 4)
>  					return -EINVAL;
> -				minor = simple_strtoul(minorp+1, NULL, 0);
> -				if (minor == 0)
> +				if (kstrtouint(minorp+1, 0, &minor) < 0)
>  					return -EINVAL;
>  				if (nfsd_minorversion(minor, sign == '-' ?
>  						     NFSD_CLEAR : NFSD_SET) < 0)
> @@ -613,8 +612,13 @@ static ssize_t __write_versions(struct file *file, char *buf, size_t size)
>  			tlen += len;
>  		}
>  	if (nfsd_vers(4, NFSD_AVAIL))
> -		for (minor = 1; minor <= NFSD_SUPPORTED_MINOR_VERSION;
> +		for (minor = 0; minor <= NFSD_SUPPORTED_MINOR_VERSION;
>  		     minor++) {
> +			if (minor == 0 && nfsd_minorversion(minor, NFSD_TEST))
> +				/* for backward compatibility, don't report
> +				 * +4.0
> +				 */
> +				continue;
>  			len = snprintf(buf, remaining, " %c4.%u",
>  					(nfsd_vers(4, NFSD_TEST) &&
>  					 nfsd_minorversion(minor, NFSD_TEST)) ?
> -- 
> 2.11.0
> 


