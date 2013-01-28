Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:39177 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751166Ab3A1USG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2013 15:18:06 -0500
MIME-Version: 1.0
Message-ID: <321A7110-AD03-49EB-A158-246FC8BD24E1@oracle.com>
Date: Mon, 28 Jan 2013 12:16:17 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 01/16] nfsd: fix IPv6 address handling in the DRC
References: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
 <1359402082-29195-2-git-send-email-jlayton@redhat.com>
 <5AD4F061-69A6-47F5-B20A-34B8DCC2EB5E@oracle.com>
 <20130128150502.4c5f497b@tlielax.poochiereds.net>
In-Reply-To: <20130128150502.4c5f497b@tlielax.poochiereds.net>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 28, 2013, at 3:05 PM, Jeff Layton <jlayton@redhat.com> wrote:

> On Mon, 28 Jan 2013 11:51:13 -0800 (PST)
> Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> 
>> On Jan 28, 2013, at 2:41 PM, Jeff Layton <jlayton@redhat.com> wrote:
>> 
>>> Currently, it only stores the first 16 bytes of any address. struct
>>> sockaddr_in6 is 28 bytes however, so we're currently ignoring the last
>>> 12 bytes of the address.
>>> 
>>> Expand the c_addr field to a sockaddr_in6,
>> 
>> What do you do about link-local addresses?
>> 
> 
> I use rpc_cmp_addr() which should handle the scope correctly for
> link-local addrs.  Now that you mention it though, I think we may have a
> bug in __rpc_copy_addr6. It doesn't touch the scope_id at all --
> shouldn't we be setting the scopeid in that function as well?

It looks like rpc_copy_addr() is invoked to copy only source addresses, so the scope ID probably doesn't apply.  The comment over rpc_copy_addr() says it explicitly ignores port and scope ID.

Sounds like we need another class of unit tests.

> 
> 
>>> and cast it to a sockaddr_in
>>> as necessary. Also fix the comparitor to use the existing RPC
>>> helpers for this.
>>> 
>>> Signed-off-by: Jeff Layton <jlayton@redhat.com>
>>> ---
>>> fs/nfsd/cache.h             | 6 +++++-
>>> fs/nfsd/nfscache.c          | 7 +++++--
>>> include/linux/sunrpc/clnt.h | 4 +++-
>>> 3 files changed, 13 insertions(+), 4 deletions(-)
>>> 
>>> diff --git a/fs/nfsd/cache.h b/fs/nfsd/cache.h
>>> index 93cc9d3..2cac76c 100644
>>> --- a/fs/nfsd/cache.h
>>> +++ b/fs/nfsd/cache.h
>>> @@ -12,6 +12,10 @@
>>> 
>>> /*
>>> * Representation of a reply cache entry.
>>> + *
>>> + * Note that we use a sockaddr_in6 to hold the address instead of the more
>>> + * typical sockaddr_storage. This is for space reasons, since sockaddr_storage
>>> + * is much larger than a sockaddr_in6.
>>> */
>>> struct svc_cacherep {
>>> 	struct hlist_node	c_hash;
>>> @@ -20,7 +24,7 @@ struct svc_cacherep {
>>> 	unsigned char		c_state,	/* unused, inprog, done */
>>> 				c_type,		/* status, buffer */
>>> 				c_secure : 1;	/* req came from port < 1024 */
>>> -	struct sockaddr_in	c_addr;
>>> +	struct sockaddr_in6	c_addr;
>>> 	__be32			c_xid;
>>> 	u32			c_prot;
>>> 	u32			c_proc;
>>> diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
>>> index 2cbac34..5dd9ec2 100644
>>> --- a/fs/nfsd/nfscache.c
>>> +++ b/fs/nfsd/nfscache.c
>>> @@ -9,6 +9,7 @@
>>> */
>>> 
>>> #include <linux/slab.h>
>>> +#include <linux/sunrpc/clnt.h>
>>> 
>>> #include "nfsd.h"
>>> #include "cache.h"
>>> @@ -146,7 +147,8 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
>>> 		    xid == rp->c_xid && proc == rp->c_proc &&
>>> 		    proto == rp->c_prot && vers == rp->c_vers &&
>>> 		    time_before(jiffies, rp->c_timestamp + 120*HZ) &&
>>> -		    memcmp((char*)&rqstp->rq_addr, (char*)&rp->c_addr, sizeof(rp->c_addr))==0) {
>>> +		    rpc_cmp_addr(svc_addr(rqstp), (struct sockaddr *)&rp->c_addr) &&
>>> +		    rpc_get_port(svc_addr(rqstp)) == rpc_get_port((struct sockaddr *)&rp->c_addr)) {
>>> 			nfsdstats.rchits++;
>>> 			goto found_entry;
>>> 		}
>>> @@ -183,7 +185,8 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
>>> 	rp->c_state = RC_INPROG;
>>> 	rp->c_xid = xid;
>>> 	rp->c_proc = proc;
>>> -	memcpy(&rp->c_addr, svc_addr_in(rqstp), sizeof(rp->c_addr));
>>> +	rpc_copy_addr((struct sockaddr *)&rp->c_addr, svc_addr(rqstp));
>>> +	rpc_set_port((struct sockaddr *)&rp->c_addr, rpc_get_port(svc_addr(rqstp)));
>>> 	rp->c_prot = proto;
>>> 	rp->c_vers = vers;
>>> 	rp->c_timestamp = jiffies;
>>> diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
>>> index 34206b8..47354a2 100644
>>> --- a/include/linux/sunrpc/clnt.h
>>> +++ b/include/linux/sunrpc/clnt.h
>>> @@ -263,7 +263,9 @@ static inline bool __rpc_copy_addr6(struct sockaddr *dst,
>>> * @sap1: first sockaddr
>>> * @sap2: second sockaddr
>>> *
>>> - * Just compares the family and address portion. Ignores port, scope, etc.
>>> + * Just compares the family and address portion. Ignores port, but
>>> + * compares the scope if it's a link-local address.
>>> + *
>>> * Returns true if the addrs are equal, false if they aren't.
>>> */
>>> static inline bool rpc_cmp_addr(const struct sockaddr *sap1,
>>> -- 
>>> 1.7.11.7
>>> 
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
> 
> 
> -- 
> Jeff Layton <jlayton@redhat.com>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




