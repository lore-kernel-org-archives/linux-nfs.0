From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH] nfs: Fix misparsing of nfsv4 fs_locations attribute
Date: Fri, 09 May 2008 17:15:47 -0700
Message-ID: <4824E933.1000108@panasas.com>
References: <20080509011918.GK12690@fieldses.org> <1210309839.8657.0.camel@localhost> <20080509152750.GA325@fieldses.org> <20080509165204.GB1907@fieldses.org> <20080509171208.GC1907@fieldses.org> <20080509235930.GM1907@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Trond Myklebust <trond@netapp.com>, linux-nfs@vger.kernel.org,
	Manoj Naik <manoj@almaden.ibm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-colo-pa.panasas.com ([66.238.117.130]:3436 "EHLO
	cassoulet.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753483AbYEJAT3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 May 2008 20:19:29 -0400
In-Reply-To: <20080509235930.GM1907@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May. 09, 2008, 16:59 -0700, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> From: J. Bruce Fields <bfields@citi.umich.edu>
> 
> The code incorrectly assumes here that the server name (or ip address)
> is null-terminated.  This can cause referrals to fail in some cases.
> 
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  fs/nfs/nfs4namespace.c |   12 +++++++++---
>  1 files changed, 9 insertions(+), 3 deletions(-)
> 
> I think this was the bug causing the referral failures.  There must be a
> less ugly solution, though.
> 
> --b.
> 
> diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
> index 5f9ba41..2684c65 100644
> --- a/fs/nfs/nfs4namespace.c
> +++ b/fs/nfs/nfs4namespace.c
> @@ -96,11 +96,17 @@ static int nfs4_validate_fspath(const struct vfsmount *mnt_parent,
>  /*
>   * Check if the string represents a "valid" IPv4 address
>   */
> -static inline int valid_ipaddr4(const char *buf)
> +static inline int valid_ipaddr4(const struct nfs4_string *buf)
>  {
>  	int rc, count, in[4];
>  
> -	rc = sscanf(buf, "%d.%d.%d.%d", &in[0], &in[1], &in[2], &in[3]);
> +	/*
> +	 * XXX: Depending on the knowledge that the following byte is
> +	 * either xdr padding or an xdr length that has already been
> +	 * copied:
> +	 */
> +	buf->data[buf->len] = '\0';

Hmm, can't that overflow if buf->len is word aligned?

Benny

> +	rc = sscanf(buf->data, "%d.%d.%d.%d", &in[0], &in[1], &in[2], &in[3]);
>  	if (rc != 4)
>  		return -EINVAL;
>  	for (count = 0; count < 4; count++) {
> @@ -178,7 +184,7 @@ static struct vfsmount *nfs_follow_referral(const struct vfsmount *mnt_parent,
>  			};
>  
>  			if (location->servers[s].len <= 0 ||
> -			    valid_ipaddr4(location->servers[s].data) < 0) {
> +			    valid_ipaddr4(&location->servers[s]) < 0) {
>  				s++;
>  				continue;
>  			}


-- 
Benny Halevy
Software Architect
Tel/Fax: +972-3-647-8340
Mobile: +972-54-802-8340
US:      +1-412-203-3187
bhalevy@panasas.com
 
Panasas, Inc.
Leader in Parallel Storage
www.panasas.com
