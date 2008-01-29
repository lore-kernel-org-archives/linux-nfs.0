From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/3] NLM per-ip grace period - core
Date: Tue, 29 Jan 2008 11:33:08 -0500
Message-ID: <514B944F-02FC-4164-BFDA-209361F4BD25@oracle.com>
References: <479970EA.2060900@redhat.com> <20080129025656.GH16785@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	NFS list <linux-nfs@vger.kernel.org>, cluster-devel@redhat.com
To: Wendy Cheng <wcheng@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:14775 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752565AbYA2QfJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jan 2008 11:35:09 -0500
In-Reply-To: <20080129025656.GH16785@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 28, 2008, at 9:56 PM, J. Bruce Fields wrote:
> On Fri, Jan 25, 2008 at 12:17:30AM -0500, Wendy Cheng wrote:
>> The logic is implemented on top of linux nfsd procfs with core  
>> functions
>> residing in lockd kernel module. Entry function is nlmsvc_resume_ip()
>> where it stores the requested ip interface into a linked-list
>> nlm_failover_list. The list entry count is nlm_failover_cnt and  
>> access
>> protection is done by nlm_failover_mutex. Entry in  
>> nlm_failover_ip_list
>> is a "nlm_failover_struct", defined in: include/linux/lockd/lockd.h.
>>
>> The list is kept in descending order (newer entry first) based on
>> g_expire jiffies. For per ip grace period checking, the search  
>> goes thru
>> the list. As soon as one match ip is found, the search stops. This
>> implies older entries will not be used and always expire before new
>> entry. This is to allow multiple entries (for the same ip) to be  
>> added
>> into the list. The maximum size of the list entries is  
>> NLM_FO_MAX_GP_CNT
>> (1024).
>>
>> -- Wendy
>
>> The logic is implemented on top of linux nfsd procfs with core  
>> functions
>> residing in lockd kernel module. Entry function is nlmsvc_resume_ip 
>> () where
>> it stores the requested ip interface into a linked-list  
>> nlm_failover_list.
>> The list entry count is nlm_failover_cnt and access protection is  
>> done by
>> nlm_failover_mutex. Entry in nlm_failover_ip_list is a  
>> "nlm_failover_struct",
>> defined in: include/linux/lockd/lockd.h.
>>
>> The list is kept in descending order (newer entry first) based on  
>> g_expire
>> jiffies. For per ip grace period checking, the search goes thru  
>> the list.
>> As soon as one match ip is found, the search stops. This implies  
>> older
>> entries will not be used and always expire before new entry. This  
>> is to allow
>> multiple entries (for the same ip) to be added into the list. The  
>> maximum size
>> of the list entries is NLM_FO_MAX_GP_CNT (1024).
>>
>> Signed-off-by: S. Wendy Cheng <wcheng@redhat.com>
>> Signed-off-by: Lon Hohberger  <lhh@redhat.com>
>>
>>  fs/lockd/svc.c              |    4 +
>>  fs/lockd/svcsubs.c          |  159 +++++++++++++++++++++++++++++++ 
>> ++++++++++++-
>>  include/linux/lockd/lockd.h |   14 +++
>>  3 files changed, 174 insertions(+), 3 deletions(-)
>>
>> --- linux-2/include/linux/lockd/lockd.h	2008-01-24  
>> 17:07:21.000000000 -0500
>> +++ linux-3/include/linux/lockd/lockd.h	2008-01-24  
>> 17:09:26.000000000 -0500
>> @@ -221,6 +221,20 @@ void		  nlmsvc_invalidate_all(void);
>>  int           nlmsvc_failover_path(struct nameidata *nd);
>>  int           nlmsvc_failover_ip(__be32 server_addr);
>>  int           nlmsvc_failover_setgrace(void *server_ip, int  
>> ip_size);
>> +void          nlmsvc_failover_reset(void);
>> +
>> +#define NLM_FO_MAX_GP_CNT	1024
>> +
>> +struct nlm_failover_struct {
>> +	struct list_head	g_list;		/* linked list */
>> +	unsigned long		g_expire;	/* grace period expire */
>> +	int			g_size;		/* g_key type: ipv4 or ipv6 */
>> +	union {
>> +		__be32		ipv4;		/* ip v4 address */
>> +		__be32		ipv6[4];	/* ip v6 address */
>> +	} g_key;
>> +#define g_ip			g_key.ipv6
>> +};
>
> Only the second member of that union is every used; could we just get
> rid of the union?
>
> Also, is that the right choice of types?  Maybe we should just use
> struct in6_addr?

I agree with Bruce -- just use in_addr, and leave out the unused IPv6  
stuff for now.

In some places, we just replace in_addr with in6_addr and simply map  
IPv4 to IPv6 addresses, rather than setting up a union.

If the address is used as a hash and never displayed, using a mapped  
IPv4 address is sufficient, and keeps things simple.

> +
>  int
>  nlmsvc_failover_setgrace(void *server_ip, int ip_size)

Should this be

   int nlmsvc_failover_setgrace(const struct in_addr *server_ip)

for now, and later we can change it to use in6_addr instead?

>  {
> -	/* implemented by resume_002.patch */
> -	return ENOSYS;



--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
