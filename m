From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NFS: fix nfs_parse_ip_address() corner case
Date: Tue, 26 Aug 2008 16:24:12 -0400
Message-ID: <4C1CDB1D-8EE6-4303-B8CE-814F059E5BAD@oracle.com>
References: <20080822182419.19572.34705.stgit@manray.1015granger.net> <20080826183942.GE4380@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:46313 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945AbYHZUZF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Aug 2008 16:25:05 -0400
In-Reply-To: <20080826183942.GE4380@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug 26, 2008, at Aug 26, 2008, 2:39 PM, J. Bruce Fields wrote:
> On Fri, Aug 22, 2008 at 02:24:22PM -0400, Chuck Lever wrote:
>> Bruce observed that nfs_parse_ip_address() will successfully parse  
>> an IPv6
>> address that looks like this:
>>
>>  "::1%"
>>
>> A scope delimiter is present, but there is no scope ID following it.
>> This is harmless, as it would simply set the scope ID to zero.   
>> However,
>> in some cases we would like to flag this as an improperly formed
>> address.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> fs/nfs/super.c |   24 +++++++++++++++---------
>> 1 files changed, 15 insertions(+), 9 deletions(-)
>>
>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>> index 5b2aa04..f73e068 100644
>> --- a/fs/nfs/super.c
>> +++ b/fs/nfs/super.c
>> @@ -727,19 +727,21 @@ static void nfs_parse_ipv4_address(char  
>> *string, size_t str_len,
>> #define IPV6_SCOPE_DELIMITER	'%'
>>
>> #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
>> -static void nfs_parse_ipv6_scope_id(const char *string, const  
>> size_t str_len,
>> -				    const char *delim,
>> -				    struct sockaddr_in6 *sin6)
>> +static int nfs_parse_ipv6_scope_id(const char *string, const  
>> size_t str_len,
>> +				   const char *delim,
>> +				   struct sockaddr_in6 *sin6)
>> {
>> 	char *p;
>> 	size_t len;
>>
>> 	if (!(ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL))
>> -		return ;
>> +		return 0;
>> 	if (*delim != IPV6_SCOPE_DELIMITER)
>> -		return;
>> -
>> +		return 0;
>
> What happens in the case where there's no scope delimiter?  In that  
> case
> can't *delim correctly point to something else here?

When we get to nfs_parse_ipv6_scope_id(), *delim points to the first  
character following the 128-bit IPv6 address string.  We should fail  
if *delim doesn't point to either '%' or '\0'.  So we need another  
check here -- succeed immediately if *delim points to '\0'.

Then, I think we should check if the address is link-local _after_ we  
know we have a valid scope delimiter.

> Arguably kstrndup() and dev_get_by_name() failures should also  
> result in
> parser failures.  It seems safer to me to reject bad addresses than to
> try to use them anyway (possibly resulting in mounting a different
> server from what was intended).

Well, if kstrndup() fails, that doesn't necessarily mean we have a bad  
address; simply that there wasn't memory to parse it.  But it's  
reasonable to return 0 in that case.

If dev_get_by_name() fails, then the next step is to check if we were  
passed a numeric value instead of a device name.  If the strtoul()  
call fails to find a real numeric there, then yes, address parsing  
should fail.

If you agree I will repost with corrections.

>
>
> --b.
>
>> 	len = (string + str_len) - delim - 1;
>> +	if (len == 0)
>> +		return 0;
>> +
>> 	p = kstrndup(delim + 1, len, GFP_KERNEL);
>> 	if (p) {
>> 		unsigned long scope_id = 0;
>> @@ -758,6 +760,8 @@ static void nfs_parse_ipv6_scope_id(const char  
>> *string, const size_t str_len,
>> 		sin6->sin6_scope_id = scope_id;
>> 		dfprintk(MOUNT, "NFS: IPv6 scope ID = %lu\n", scope_id);
>> 	}
>> +
>> +	return 1;
>> }
>>
>> static void nfs_parse_ipv6_address(char *string, size_t str_len,
>> @@ -773,9 +777,11 @@ static void nfs_parse_ipv6_address(char  
>> *string, size_t str_len,
>>
>> 		sin6->sin6_family = AF_INET6;
>> 		*addr_len = sizeof(*sin6);
>> -		if (in6_pton(string, str_len, addr, IPV6_SCOPE_DELIMITER,  
>> &delim)) {
>> -			nfs_parse_ipv6_scope_id(string, str_len, delim, sin6);
>> -			return;
>> +		if (in6_pton(string, str_len, addr,
>> +					IPV6_SCOPE_DELIMITER, &delim)) {
>> +			if (nfs_parse_ipv6_scope_id(string,
>> +							str_len, delim, sin6))
>> +				return;
>> 		}
>> 	}
>>
>>

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




