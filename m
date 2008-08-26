From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 5/5] lockd: Add address family-agnostic helper for zeroing the port number
Date: Tue, 26 Aug 2008 15:49:33 -0400
Message-ID: <7AD6FAE8-B6E1-432B-A34B-C15100232998@oracle.com>
References: <20080822163939.20488.92983.stgit@manray.1015granger.net> <20080822164232.20488.11685.stgit@manray.1015granger.net> <20080826190319.GF4380@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:49153 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753279AbYHZTvH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Aug 2008 15:51:07 -0400
In-Reply-To: <20080826190319.GF4380@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug 26, 2008, at Aug 26, 2008, 3:03 PM, J. Bruce Fields wrote:
> It would be nice if not necessary just to move nfs_set_port()  
> somewhere
> common and use that (maybe with a more generic name).

I agree.  However...

As we round out to a full IPv6 implementation for NFS, it will become  
clear what additional helper functions can be shared.  This might  
include not only a port setting helper, but also one that can  
construct presentation format addresses, and so on.

At that point, we can consolidate as needed.

Until then, I would like to wait until everything is reviewed and  
integrated so we are sure to include changes and updates related to  
the review process, if that's OK with you.

> On Fri, Aug 22, 2008 at 12:42:33PM -0400, Chuck Lever wrote:
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> fs/lockd/host.c |   14 +++++++++++++-
>> 1 files changed, 13 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/lockd/host.c b/fs/lockd/host.c
>> index 55ef751..3f0c1a8 100644
>> --- a/fs/lockd/host.c
>> +++ b/fs/lockd/host.c
>> @@ -39,6 +39,18 @@ static struct nsm_handle *	nsm_find(const struct  
>> sockaddr_in *sin,
>> 					 const char *hostname,
>> 					 unsigned int hostname_len);
>>
>> +static void nlm_clear_port(struct sockaddr *sap)
>> +{
>> +	switch (sap->sa_family) {
>> +	case AF_INET:
>> +		((struct sockaddr_in *)sap)->sin_port = 0;
>> +		break;
>> +	case AF_INET6:
>> +		((struct sockaddr_in6 *)sap)->sin6_port = 0;
>> +		break;
>> +	}
>> +}
>> +
>> static void nlm_display_address(const struct sockaddr *sap,
>> 				char *buf, const size_t len)
>> {
>> @@ -149,7 +161,7 @@ static struct nlm_host *nlm_lookup_host(int  
>> server,
>> 	}
>> 	host->h_name	   = nsm->sm_name;
>> 	host->h_addr       = *sin;
>> -	host->h_addr.sin_port = 0;	/* ouch! */
>> +	nlm_clear_port((struct sockaddr *)&host->h_addr);
>> 	host->h_saddr	   = *ssin;
>> 	host->h_version    = version;
>> 	host->h_proto      = proto;
>>

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




