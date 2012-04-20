Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:45656 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753220Ab2DTVMF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Apr 2012 17:12:05 -0400
Subject: Re: [PATCH] NFS4: fix referrals with IPv6 mounts
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1334949705-33393-1-git-send-email-dros@netapp.com>
Date: Fri, 20 Apr 2012 15:30:59 -0400
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Message-Id: <B1E9AAB3-6739-46D5-999A-130494131031@oracle.com>
References: <1334949705-33393-1-git-send-email-dros@netapp.com>
To: Weston Andros Adamson <dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 20, 2012, at 3:21 PM, Weston Andros Adamson wrote:

> nfs4_path() was parsing the path component by splitting on the first colon.
> This is wrong when an IPv6 address is used to mount a server.
> 
> For example, having mounted 'fc00::10:/export', nfs4_path() returned
> ':10:/export'.  This causes referrals (using IPv4 or IPv6 addresses) to fail
> in nfs4_validate_fspath().
> 
> Parsing the path component by using the *last* colon works with
> IPv6 as well as IPv4 addrs.

These ad hoc fixes give me the willies.

During a referral, how is the server name and export path getting recombined?  In fs_locations data, these are separate.  In the forward mount path, IPv6 addresses are escaped via square brackets.

(Having not looked at this code in years), is there some way we can keep the server name and path separate here so we don't have to reparse?

> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> ---
> fs/nfs/nfs4namespace.c |    2 +-
> 1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
> index 9c8eca3..dd3dd30 100644
> --- a/fs/nfs/nfs4namespace.c
> +++ b/fs/nfs/nfs4namespace.c
> @@ -59,7 +59,7 @@ static char *nfs4_path(struct dentry *dentry, char *buffer, ssize_t buflen)
> 	char *limit;
> 	char *path = nfs_path(&limit, dentry, buffer, buflen);
> 	if (!IS_ERR(path)) {
> -		char *colon = strchr(path, ':');
> +		char *colon = strrchr(path, ':');
> 		if (colon && colon < limit)
> 			path = colon + 1;
> 	}
> -- 
> 1.7.4.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




