From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 6/6] nfs: Fix misparsing of nfsv4 fs_locations attribute
Date: Mon, 09 Jun 2008 17:08:16 -0400
Message-ID: <1213045696.19130.7.camel@localhost>
References: <1213044696-32741-1-git-send-email-bfields@citi.umich.edu>
	 <1213044696-32741-2-git-send-email-bfields@citi.umich.edu>
	 <1213044696-32741-3-git-send-email-bfields@citi.umich.edu>
	 <1213044696-32741-4-git-send-email-bfields@citi.umich.edu>
	 <1213044696-32741-5-git-send-email-bfields@citi.umich.edu>
	 <1213044696-32741-6-git-send-email-bfields@citi.umich.edu>
	 <1213044696-32741-7-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32166 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750981AbYFIVIT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Jun 2008 17:08:19 -0400
In-Reply-To: <1213044696-32741-7-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2008-06-09 at 16:51 -0400, J. Bruce Fields wrote:
> The code incorrectly assumes here that the server name (or ip address)
> is null-terminated.  This can cause referrals to fail in some cases.
> 
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  fs/nfs/nfs4namespace.c |   34 ++++++++++------------------------
>  1 files changed, 10 insertions(+), 24 deletions(-)
> 
> diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
> index b112857..2f3eabe 100644
> --- a/fs/nfs/nfs4namespace.c
> +++ b/fs/nfs/nfs4namespace.c
> @@ -93,23 +93,6 @@ static int nfs4_validate_fspath(const struct vfsmount *mnt_parent,
>  	return 0;
>  }
>  
> -/*
> - * Check if the string represents a "valid" IPv4 address
> - */
> -static inline int valid_ipaddr4(const char *buf)
> -{
> -	int rc, count, in[4];
> -
> -	rc = sscanf(buf, "%d.%d.%d.%d", &in[0], &in[1], &in[2], &in[3]);
> -	if (rc != 4)
> -		return -EINVAL;
> -	for (count = 0; count < 4; count++) {
> -		if (in[count] > 255)
> -			return -EINVAL;
> -	}
> -	return 0;
> -}
> -
>  /**
>   * nfs_follow_referral - set up mountpoint when hitting a referral on moved error
>   * @mnt_parent - mountpoint of parent directory
> @@ -172,19 +155,20 @@ static struct vfsmount *nfs_follow_referral(const struct vfsmount *mnt_parent,
>  
>  		s = 0;
>  		while (s < location->nservers) {
> +			const struct nfs4_string *buf = &location->servers[s];
>  			struct sockaddr_in addr = {
>  				.sin_family	= AF_INET,
>  				.sin_port	= htons(NFS_PORT),
>  			};
> +			u8 *ip = (u8 *)addr.sin_addr.s_addr;
>  
> -			if (location->servers[s].len <= 0 ||
> -			    valid_ipaddr4(location->servers[s].data) < 0) {
> -				s++;
> -				continue;
> -			}
> +			if (buf->len <= 0 || buf->len >= PAGE_SIZE)
> +				goto next;
> +			if (!in4_pton(buf->data, buf->len, ip, '\0', NULL))
> +				goto next;

What if it is an IPv6 address? As I've said before, could we please just
adapt nfs_parse_server_address to deal with all these cases?

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
