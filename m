From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 30/32] NFS: Add a dns resolver for use with NFSv4 referrals and migration
Date: Thu, 20 Aug 2009 12:54:48 -0400
Message-ID: <F9C66E65-D885-4F14-88AD-16DCC5E5B563@oracle.com>
References: <1250725135-14632-1-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-2-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-3-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-4-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-5-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-6-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-7-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-8-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-9-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-10-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-11-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-12-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-13-git-send
 -email-Trond.Myklebust@netapp.com> <1250725135-14632-14-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-15-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-16-git-s!
 ! end-email-Trond.Myklebust@netapp.com> <1250725135-14632-17-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-18-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-19-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-20-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-21-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-22-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-23-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-24-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-25-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-26-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-27-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-28-git-send-email-Trond.Myklebust@net
 app.com> <1250725135-14632-29-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-30-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-31-git-send-email-Trond.Myklebust@!
 ne! tapp.com> <74466E40-D037-4DCD-9129-0EE7B987C843@oracle.com!
 > <1250785542.19156.12.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:18098 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754602AbZHTQy4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Aug 2009 12:54:56 -0400
In-Reply-To: <1250785542.19156.12.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug 20, 2009, at 12:25 PM, Trond Myklebust wrote:
> On Thu, 2009-08-20 at 11:34 -0400, Chuck Lever wrote:
>>> +A basic sample /sbin/nfs_cache_getent
>>> +=====================================
>>> +
>>> +#!/bin/bash
>>> +#
>>> +ttl=600
>>> +#
>>> +cut=/usr/bin/cut
>>> +getent=/usr/bin/getent
>>> +rpc_pipefs=/var/lib/nfs/rpc_pipefs
>>> +#
>>> +die()
>>> +{
>>> +	echo "Usage: $0 cache_name entry_name"
>>> +	exit 1
>>> +}
>>> +
>>> +[ $# -lt 2 ] && die
>>> +cachename="$1"
>>> +cache_path=${rpc_pipefs}/cache/${cachename}/channel
>>> +
>>> +case "${cachename}" in
>>> +	dns_resolve)
>>> +		name="$2"
>>> +		result="$(${getent} hosts ${name} | ${cut} -f1 -d\ )"
>>> +		[ -z "${result}" ] && result="0"
>>> +		;;
>>> +	*)
>>> +		die
>>> +		;;
>>> +esac
>>> +echo "${result} ${name} ${ttl}" >${cache_path}
>>> +
>>
>> Instead of having a single script with a big case statement in it,  
>> why
>> not have a directory containing a bunch of smaller, more specific,
>> scripts?  Common code can be "sourced" from a separate file.  Some of
>> these scripts may want to do more (or less) than writing into an
>> rpc_pipefs file.
>
> I'm not too concerned. As it says above, this is a sample that
> illustrates how you could do it. It does work, though, so people can
> definitely use it to test the functionality.

I'm thinking of when we want to add new upcalls, since you went to  
some length to generalize this facility.  It would be easier to manage  
adding a new script than it would to update an existing one, and an  
admin or distributor could control what scripts are present, or  
provide their own.

The act of editing a single script is easy enough, but then you have  
to worry about updates from the distributor possibly overwriting the  
local modifications, and so on, and so on.

A model like /etc/init.d might be easier to manage in the long run.

>>> +	 * Disable the upcall mechanism if we're getting an ENOENT or
>>> +	 * EACCES error. The admin can re-enable it on the fly by using
>>> +	 * sysfs to set the 'cache_getent' parameter once the problem
>>> +	 * has been fixed.
>>> +	 */
>>> +	if (ret == -ENOENT || ret == -EACCES)
>>> +		nfs_cache_getent_prog[0] = '\0';
>>
>> What's the risk of continuing to invoke the upcall script if it
>> doesn't exist?  If it's happening frequently I would expect that the
>> lack of the file would be cached, so it would still be a quick  
>> failure.
>
> Yes, but if the upcall script fails, we want to fall back to trying  
> the
> pipe upcall mechanism.

Makes sense, but that important detail is not clear from the  
documenting comment.

>>> +#define NFS_DNS_HASHBITS 4
>>> +#define NFS_DNS_HASHTBL_SIZE (1 << NFS_DNS_HASHBITS)
>>
>> So the hash table is only 16 buckets.  Is it really worth the trouble
>> of keeping a small cache of hostname lookups in the kernel?  I  
>> guess I
>> don't have a clear idea of how often you need to handle DNS  
>> resolution
>> for FS_LOCATIONS.
>
> At the moment, the number of referrals out there are few, but we're
> expecting that to grow when the whole federated fs management
> infrastructure develops.

OK.  Can you give some sense of quantity?

>>> +static unsigned int nfs_dns_hash(const struct nfs_dns_ent *key)
>>> +{
>>> +	return hash_str(key->hostname, NFS_DNS_HASHBITS);
>>> +}
>>
>> Any idea how well this hash function works for hostnames?
>
> No, but it is the same one nfsd uses for its version of the same  
> cache,
> so I assume that it is appropriate.

A brief scan shows that it's hashing for username@host for idmapping,  
but not for hostnames only (which might be missing randomness of the  
username@ part).  A detail, for sure, but it would be reasonable to  
verify at some point as the size of the cache increases.

>>> +#define NFS_DNS_HOSTNAME_MAXLEN	(128)
>>
>> It looks like you are using this to size the target buffer for a
>> presentation address, not a hostname.  Perhaps you should use
>> INET6_ADDRSTRLEN+IPV6_SCOPEID_LEN+1 here instead, and/or change the
>> name of the macro.
>
> No. I'm using it primarily to store the hostname. See nfs_dns_parse().

OK, you store the presentation address in buf1 first, and now I see  
that farther down you are storing the hostname too.  But note that the  
maximum size of a hostname is 1024 (see the definition of NI_MAXHOST  
in user space).

If there is a protocol specified limit on the hostname string returned  
via FS_LOCATION, perhaps that should be noted here.  Otherwise, 128 is  
too small, I think.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



