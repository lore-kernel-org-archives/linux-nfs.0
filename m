Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:24407 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423087Ab2JaPJf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Oct 2012 11:09:35 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: [PATCH] NFS: fix bug in legacy DNS resolver.
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20121031121601.5de16a5b@notabene.brown>
Date: Wed, 31 Oct 2012 11:09:27 -0400
Cc: NFS <linux-nfs@vger.kernel.org>
Message-Id: <06657F3E-5812-4680-929E-DE0FAED5601E@oracle.com>
References: <20121031121601.5de16a5b@notabene.brown>
To: NeilBrown <neilb@suse.de>, Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, Neil!

On Oct 30, 2012, at 9:16 PM, NeilBrown <neilb@suse.de> wrote:

> 
> The DNS resolver's use of the sunrpc cache involves a 'ttl' number
> (relative) rather that a timeout (absolute).  This confused me when
> I wrote
>  commit c5b29f885afe890f953f7f23424045cdad31d3e4
>     "sunrpc: use seconds since boot in expiry cache"
> 
> and I managed to break it.  The effect is that any TTL is interpreted
> as 0, and nothing useful gets into the cache.
> 
> This patch removes the use of get_expiry() - which really expects an
> expiry time - and uses get_uint() instead, treating the int correctly
> as a ttl.

Nit: The description says "get_uint()" but the patch uses "get_int()."  Should we change the patch?

> This fixes a regression that has been present since 2.6.37, causing
> certain NFS accesses in certain environments to incorrectly fail.

In particular, when the legacy DNS resolver is in use, this regression prevents the NFS client from following any NFSv4 referral which contains a DNS hostname.

> Reported-by: Chuck Lever <chuck.lever@oracle.com>
> Tested-by: Chuck Lever <chuck.lever@oracle.com>
> Cc: stable@vger.kernel.org
> Signed-off-by: NeilBrown <neilb@suse.de>
> 
> diff --git a/fs/nfs/dns_resolve.c b/fs/nfs/dns_resolve.c
> index 31c26c4..d9415a2 100644
> --- a/fs/nfs/dns_resolve.c
> +++ b/fs/nfs/dns_resolve.c
> @@ -217,7 +217,7 @@ static int nfs_dns_parse(struct cache_detail *cd, char *buf, int buflen)
> {
> 	char buf1[NFS_DNS_HOSTNAME_MAXLEN+1];
> 	struct nfs_dns_ent key, *item;
> -	unsigned long ttl;
> +	unsigned int ttl;
> 	ssize_t len;
> 	int ret = -EINVAL;
> 
> @@ -240,7 +240,8 @@ static int nfs_dns_parse(struct cache_detail *cd, char *buf, int buflen)
> 	key.namelen = len;
> 	memset(&key.h, 0, sizeof(key.h));
> 
> -	ttl = get_expiry(&buf);
> +	if (get_int(&buf, &ttl) < 0)
> +		goto out;
> 	if (ttl == 0)
> 		goto out;
> 	key.h.expiry_time = ttl + seconds_since_boot();

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




