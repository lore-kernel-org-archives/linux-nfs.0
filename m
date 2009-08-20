From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 30/32] NFS: Add a dns resolver for use with NFSv4
 referrals and migration
Date: Thu, 20 Aug 2009 12:25:42 -0400
Message-ID: <1250785542.19156.12.camel@heimdal.trondhjem.org>
References: <1250725135-14632-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-3-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-4-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-5-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-6-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-7-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-8-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-9-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-10-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-11-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-12-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-13-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-14-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-15-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-16-git-s! end-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-17-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-18-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-19-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-20-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-21-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-22-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-23-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-24-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-25-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-26-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-27-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-28-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-29-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-30-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-31-git-send-email-Trond.Myklebust@ne! tapp.com>
	 <74466E40-D037-4DCD-9129-0EE7B987C843@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13441 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750815AbZHTQZp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Aug 2009 12:25:45 -0400
In-Reply-To: <74466E40-D037-4DCD-9129-0EE7B987C843@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-08-20 at 11:34 -0400, Chuck Lever wrote:
> > +A basic sample /sbin/nfs_cache_getent
> > +=====================================
> > +
> > +#!/bin/bash
> > +#
> > +ttl=600
> > +#
> > +cut=/usr/bin/cut
> > +getent=/usr/bin/getent
> > +rpc_pipefs=/var/lib/nfs/rpc_pipefs
> > +#
> > +die()
> > +{
> > +	echo "Usage: $0 cache_name entry_name"
> > +	exit 1
> > +}
> > +
> > +[ $# -lt 2 ] && die
> > +cachename="$1"
> > +cache_path=${rpc_pipefs}/cache/${cachename}/channel
> > +
> > +case "${cachename}" in
> > +	dns_resolve)
> > +		name="$2"
> > +		result="$(${getent} hosts ${name} | ${cut} -f1 -d\ )"
> > +		[ -z "${result}" ] && result="0"
> > +		;;
> > +	*)
> > +		die
> > +		;;
> > +esac
> > +echo "${result} ${name} ${ttl}" >${cache_path}
> > +
> 
> Instead of having a single script with a big case statement in it, why  
> not have a directory containing a bunch of smaller, more specific,  
> scripts?  Common code can be "sourced" from a separate file.  Some of  
> these scripts may want to do more (or less) than writing into an  
> rpc_pipefs file.

I'm not too concerned. As it says above, this is a sample that
illustrates how you could do it. It does work, though, so people can
definitely use it to test the functionality.


> > +	 * Disable the upcall mechanism if we're getting an ENOENT or
> > +	 * EACCES error. The admin can re-enable it on the fly by using
> > +	 * sysfs to set the 'cache_getent' parameter once the problem
> > +	 * has been fixed.
> > +	 */
> > +	if (ret == -ENOENT || ret == -EACCES)
> > +		nfs_cache_getent_prog[0] = '\0';
> 
> What's the risk of continuing to invoke the upcall script if it  
> doesn't exist?  If it's happening frequently I would expect that the  
> lack of the file would be cached, so it would still be a quick failure.

Yes, but if the upcall script fails, we want to fall back to trying the
pipe upcall mechanism.

> > +#define NFS_DNS_HASHBITS 4
> > +#define NFS_DNS_HASHTBL_SIZE (1 << NFS_DNS_HASHBITS)
> 
> So the hash table is only 16 buckets.  Is it really worth the trouble  
> of keeping a small cache of hostname lookups in the kernel?  I guess I  
> don't have a clear idea of how often you need to handle DNS resolution  
> for FS_LOCATIONS.

At the moment, the number of referrals out there are few, but we're
expecting that to grow when the whole federated fs management
infrastructure develops.

> The garbage collection mechanism for expired entries isn't obvious.   
> Without one I would expect this cache to grow enough that inserting  
> and looking up valid entries might become expensive.

It uses the same garbage collection mechanisms that the nfsd caches use.
Try it...

> > +static unsigned int nfs_dns_hash(const struct nfs_dns_ent *key)
> > +{
> > +	return hash_str(key->hostname, NFS_DNS_HASHBITS);
> > +}
> 
> Any idea how well this hash function works for hostnames?

No, but it is the same one nfsd uses for its version of the same cache,
so I assume that it is appropriate.


> > +#define NFS_DNS_HOSTNAME_MAXLEN	(128)
> 
> It looks like you are using this to size the target buffer for a  
> presentation address, not a hostname.  Perhaps you should use  
> INET6_ADDRSTRLEN+IPV6_SCOPEID_LEN+1 here instead, and/or change the  
> name of the macro.

No. I'm using it primarily to store the hostname. See nfs_dns_parse().

> > @@ -1506,6 +1507,10 @@ static int __init init_nfs_fs(void)
> > {
> > 	int err;
> >
> > +	err = nfs_dns_resolver_init();
> > +	if (err < 0)
> > +		goto out8;
> > +
> > 	err = nfs_fscache_register();
> > 	if (err < 0)
> > 		goto out7;
> > @@ -1564,6 +1569,8 @@ out5:
> > out6:
> > 	nfs_fscache_unregister();
> > out7:
> > +	nfs_dns_resolver_destroy();
> > +out8:
> 
> This init routine is getting cumbersome.  Eventually could we provide  
> an array of function pointers and call them in a loop?

The annoyance comes primarily from the need to call the *_destroy()
functions on error. It would be better to just call exit_nfs_fs().

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
