Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36816 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752560AbbIPTIs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Sep 2015 15:08:48 -0400
Subject: Re: [PATCH] mountd: fix mount issue due to comparison with
 uninitialized uuid
To: Vivek Trivedi <t.vivek@samsung.com>, linux-nfs@vger.kernel.org
References: <1438949454-12216-1-git-send-email-t.vivek@samsung.com>
Cc: a.sahrawat@samsung.com, pankaj.m@samsung.com
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <55F9BE37.8070400@RedHat.com>
Date: Wed, 16 Sep 2015 15:08:39 -0400
MIME-Version: 1.0
In-Reply-To: <1438949454-12216-1-git-send-email-t.vivek@samsung.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/07/2015 08:10 AM, Vivek Trivedi wrote:
> fix mount issue due to comparison of uninitialized variable
> u(uuid) with parsed->fhuuid when uuid_by_path return 0.
> 
> /tmp/usb            192.168.1.0/16(ro,no_root_squash,no_subtree_check,fsid=0)
> /tmp/usb/sda1       192.168.1.0/16(ro,no_root_squash,no_subtree_check)
> /tmp/usb/sdb1       192.168.1.0/16(ro,no_root_squash,no_subtree_check)
> 
> mount -t nfs -o nolock,nfsvers=3 192.168.1.2:/tmp/usb/sda1 /tmp/sda1
> mount -t nfs -o nolock,nfsvers=3 192.168.1.2:/tmp/usb/sdb1 /tmp/sdb1
> 
> results in below mountd error:
> mountd: /tmp/usb and /tmp/usb/sdb1 have same filehandle for 192.168.1.0/16, using first
> 
> when uuid_by_path returned 0, by chance, garbage value of u was same as
> parsed->fhuuid(of sdb1), and comparison of these resulted in above error.
> 
> Signed-off-by: Vivek Trivedi <t.vivek@samsung.com>
> Reviewed-by: Amit Sahrawat <a.sahrawat@samsung.com>
Committed... 

steved.

> ---
>  utils/mountd/cache.c |    9 ++++-----
>  1 file changed, 4 insertions(+), 5 deletions(-)
> 
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index 7d250f9..7847446 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -638,18 +638,17 @@ static bool match_fsid(struct parsed_fsid *parsed, nfs_export *exp, char *path)
>  		if (!is_mountpoint(path))
>  			return false;
>  	check_uuid:
> -		if (exp->m_export.e_uuid)
> +		if (exp->m_export.e_uuid) {
>  			get_uuid(exp->m_export.e_uuid, parsed->uuidlen, u);
> +			if (memcmp(u, parsed->fhuuid, parsed->uuidlen) == 0)
> +				return true;
> +		}
>  		else
>  			for (type = 0;
>  			     uuid_by_path(path, type, parsed->uuidlen, u);
>  			     type++)
>  				if (memcmp(u, parsed->fhuuid, parsed->uuidlen) == 0)
>  					return true;
> -
> -		if (memcmp(u, parsed->fhuuid, parsed->uuidlen) != 0)
> -			return false;
> -		return true;
>  	}
>  	/* Well, unreachable, actually: */
>  	return false;
> 
