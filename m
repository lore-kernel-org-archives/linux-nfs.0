From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 20/27] NSM: Replace IP address as our nlm_reboot lookup key
Date: Thu, 11 Dec 2008 11:20:18 -0500
Message-ID: <FBB1D88B-C68F-49F4-A075-720058B80355@oracle.com>
References: <20081205235557.24075.12511.stgit@ingres.1015granger.net> <20081206000424.24075.72384.stgit@ingres.1015granger.net> <20081210234334.GQ1212@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:19887 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756364AbYLKQUh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Dec 2008 11:20:37 -0500
In-Reply-To: <20081210234334.GQ1212@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Dec 10, 2008, at Dec 10, 2008, 6:43 PM, J. Bruce Fields wrote:
> On Fri, Dec 05, 2008 at 07:04:24PM -0500, Chuck Lever wrote:
>> NLM provides file locking services for NFS files.  Part of this  
>> service
>> includes a second protocol, known as NSM, which is a reboot
>> notification service.  NLM uses this service to determine when to
>> reclaim locks or enter a grace period after a client or server  
>> reboots.
>>
>> The NLM service (implemented by lockd in the Linux kernel) contacts
>> the local NSM service (implemented by rpc.statd in Linux user space)
>> via NSM protocol upcalls to register a callback when a particular
>> remote peer reboots.
>>
>> To match the callback to the correct remote peer, the NLM service
>> constructs a cookie that it passes in the request.  The NSM service
>> passes that cookie back to the NLM service when it is notified that
>> the given remote peer has indeed rebooted.
>>
>> Currently on Linux, the cookie is the raw 32-bit IPv4 address of the
>> remote peer.  To support IPv6 addresses, which are larger, we could
>> use all 16 bytes of the cookie to represent a full IPv6 address,
>> although we still can't represent an IPv6 address with a scope ID in
>> just 16 bytes.
>>
>> Instead, to avoid the need for future changes to support additional
>> address types, we'll use a manufactured value for the cookie, and use
>> that to find the corresponding nsm_handle struct in the kernel during
>> the NLMPROC_SM_NOTIFY callback.
>>
>> This should provide complete support in the kernel's NSM
>> implementation for IPv6 hosts, while remaining backwards compatible
>> with older rpc.statd implementations.
>>
>> Note we also deal with another case where nsm_use_hostnames can  
>> change
>> while there are outstanding notifications, possibly resulting in the
>> loss of reboot notifications.  After this patch, the priv cookie is
>> always used to lookup rebooted hosts in the kernel.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> fs/lockd/mon.c |   39 ++++++++++++++++++++++++++++++---------
>> 1 files changed, 30 insertions(+), 9 deletions(-)
>>
>> diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
>> index a5f26f3..4113ed1 100644
>> --- a/fs/lockd/mon.c
>> +++ b/fs/lockd/mon.c
>> @@ -241,13 +241,38 @@ static struct nsm_handle  
>> *nsm_lookup_priv(const struct nsm_private *priv)
>>  * returned via NLMPROC_SM_NOTIFY, in the "priv" field of these
>>  * requests.
>>  *
>> - * Linux provides the raw IP address of the monitored host,
>> - * left in network byte order.
>> + * These cookies are not required to last across reboots, but they
>> + * must be unique for each nsm_handle during the same boot.
>> + * Uniqueness is guaranteed by using the memory address of the
>> + * nsm_handle data structure.  Such memory addresses are only reused
>> + * if the nsm_handle is destroyed by an nsm_release().
>> + *
>> + * A time stamp is added in case rpc.statd returns a stale cookie.
>> + * That would be a bug in rpc.statd, but it would result in some
>> + * client losing its locks inappropriately, which we would like to
>> + * avoid.
>
> I forget what the arguments were against using a simple counter here.

Using a simple counter would replay the cookies after every reboot,  
exposing us to bugs in user space which would cause the kernel to  
think the wrong host rebooted.

There is also a best practice for network protocols that advise  
against using a simple counter for anything.

Using the memory address and a timestamp is an efficient way to get a  
good guarantee of uniqueness without having to store any state across  
reboots.

>> + *
>> + * For safety, the cookie returned via NLM_SM_NOTIFY is treated as
>> + * an opaque -- the address is not used directly to access the
>> + * associated nsm_handle.  This also means it would be simple to
>> + * change the cookie generator again at some later point without
>> + * having to mess with the nsm_handle lookup code in
>> + * nsm_reboot_lookup().
>> + *
>> + * The cookies are exposed only to local user space via loopback.
>> + * They do not appear on the physical network.  If we want greater
>> + * security for some reason, nsm_init_private() could perform a
>> + * one-way hash to obscure the contents of the cookie.
>>  */
>> static void nsm_init_private(struct nsm_handle *nsm)
>> {
>> -	__be32 *p = (__be32 *)&nsm->sm_priv.data;
>> -	*p = nsm_addr_in(nsm)->sin_addr.s_addr;
>> +	u64 *p = (u64 *)&nsm->sm_priv.data;
>> +	struct timeval tv;
>> +
>> +	do_gettimeofday(&tv);
>
> I see there's a note on do_gettimeofday advising callers to use
> getnstimeofday instead.

Sorry, there are a number of architecture-specific do_gettimeofday()  
functions that don't have that note.  I must have missed the generic  
one.

> --b.
>
>> +
>> +	*p++ = (unsigned long)nsm;
>> +	*p = timeval_to_ns(&tv);
>> }
>>
>> static struct nsm_handle *nsm_create_handle(const struct sockaddr  
>> *sap,
>> @@ -351,11 +376,7 @@ struct nsm_handle *nsm_reboot_lookup(const  
>> struct nlm_reboot *info)
>>
>> 	spin_lock(&nsm_lock);
>>
>> -	if (nsm_use_hostnames && info->mon != NULL)
>> -		cached = nsm_lookup_hostname(info->mon, info->len);
>> -	else
>> -		cached = nsm_lookup_priv(&info->priv);
>> -
>> +	cached = nsm_lookup_priv(&info->priv);
>> 	if (unlikely(cached == NULL)) {
>> 		spin_unlock(&nsm_lock);
>> 		dprintk("lockd: never saw rebooted peer '%.*s' before\n",
>>

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




