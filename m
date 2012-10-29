Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1050.oracle.com ([141.146.126.70]:26437 "EHLO
	aserp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753308Ab2J2SQC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2012 14:16:02 -0400
Received: from aserp1040.oracle.com (aserp1040.oracle.com [141.146.126.69])
	by aserp1050.oracle.com (Sentrion-MTA-4.2.2/Sentrion-MTA-4.2.2) with ESMTP id q9THmuHd008054
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 29 Oct 2012 17:48:56 GMT
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: Legacy NFS client DNS resolver fails since 2.6.37
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20121029125914.506eb0fc@notabene.brown>
Date: Mon, 29 Oct 2012 13:47:27 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <6ECAAFE6-6EE4-4399-9B79-594E3F9A0B2C@oracle.com>
References: <6F448C67-E729-41E7-A09C-A49D15B50D5E@oracle.com> <20121029125914.506eb0fc@notabene.brown>
To: NeilBrown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 28, 2012, at 9:59 PM, NeilBrown <neilb@suse.de> wrote:

> On Sun, 28 Oct 2012 21:03:45 -0400 Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> Hi Neil-
>> 
>> To use the legacy DNS resolver for resolving hostnames in NFSv4 referrals, I've installed the /sbin/nfs_cache_getent script on my NFS client "degas."  I've confirmed it works with a 2.6.36 kernel.
>> 
>> However, since 2.6.37 commit c5b29f885afe890f953f7f23424045cdad31d3e4 "sunrpc: use seconds since boot in expiry cache" the legacy DNS resolver appears not to work.  When attempting to follow a referral that uses a server hostname, the client fails 100% of the time to mount the referred to server with an error such as:
>> 
>>  [cel@degas example.net]$ ls home
>>  ls: cannot open directory home: No such file or directory
>> 
>> The contents of the dns_resolve cache appear to indicate that there are resolution results in the cache, but the CACHE_VALID flag is not set for that entry:
>> 
>>  [root@degas dns_resolve]# cat content 
>>  # ip address      hostname        ttl
>>  #               , klimt.example.net 48
>> 
>> klimt.example.net is the hostname that is contained in the referral.
>> 
>> I have a second referral called "ip-address" in the same directory (domainroot), with the same content except the IP address of klimt is used instead of its hostname.  Following that second referral always works.
>> 
>> I've tried every stable.0 release up to 3.6.0, and the behavior is roughly the same for each, which suggests that there is no upstream fix for this issue thus far.
>> 
>> Since I've never seen a problem like this reported, I'm wondering if anyone else can confirm this issue.
>> 
>> I have a narrow interest in fixing the legacy DNS server in stable kernels, but there may also be a latent problem with the RPC cache implementation that could spell trouble for other consumers, even post-3.6.
>> 
>> A rough outline of how you might reproduce this:
>> 
>>  + Build and install a 2.6.37 or later kernel for your NFS client with CONFIG_NFS_USE_LEGACY_DNS=y.
>> 
>>  + Set up an NFS server with "refer=" exports.  man exports(5)
>> 
>>  + On your client, mount the server directory that contains the exports, then try to "cd" through one of the referrals.
>> 
>> If you don't feel up to replicating the above arrangement, can you suggest cache debugging instrumentation that can be added to my client to help nail this?  Thanks for any advice!
>> 
> 
> 
> Hi Chuck,
> looks like I messed up.
> Every other cache uses absolute timestamps for expiry time.  The dns resolver
> differs from this and uses relative time stamps (ttl).  I obviously didn't
> understand this properly when I wrote the patch that broke things.
> In particular, using get_expiry() is inappropriate in this context.
> 
> Something like this should fix it.

I built a 3.7-rc2 kernel with CONFIG_NFS_USE_LEGACY_DNS=y.

Without your patch, following a referral containing a hostname does not work on this kernel. After applying your patch, following the same referral works as expected.

Tested-by: Chuck Lever <chuck.lever@oracle.com>

IMO, this fix should go to all stable kernels => 2.6.37, and to 3.7-rc.

Good news is that this problem does not affect other RPC cache consumers.  Thanks for the quick response!

> NeilBrown
> 
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
> 
> 

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




