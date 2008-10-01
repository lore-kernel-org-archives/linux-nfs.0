From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 06/10] lockd: Add helper to sanity check incoming NOTIFY requests
Date: Wed, 1 Oct 2008 12:01:30 -0400
Message-ID: <3DC9A32F-878A-4BA5-A1E5-7EDE6D1083EF@oracle.com>
References: <20080917161337.4963.74674.stgit@ellison.1015granger.net> <20080917161757.4963.82230.stgit@ellison.1015granger.net> <20080926224316.GH7138@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:59255 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760AbYJAQBr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Oct 2008 12:01:47 -0400
In-Reply-To: <20080926224316.GH7138@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep 26, 2008, at Sep 26, 2008, 6:43 PM, J. Bruce Fields wrote:
> On Wed, Sep 17, 2008 at 11:17:57AM -0500, Chuck Lever wrote:
>> The NLM performs a silly test to see that incoming NOTIFY requests  
>> are
>> relatively secure.  Make sure the test works for both AF_INET and  
>> AF_INET6
>> addresses.
>
> Makes sense.  (Why's the test silly?  If it prevents local users from
> telling lockd to drop a client's locks, that seems good.)

I was referring to the port range part of the test.  Anyone who wants  
real security will not rely on the port value, but will use SSL or  
third-party authentication like Kerberos.

>
>
> --b.
>
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> fs/lockd/svc4proc.c         |    6 ++----
>> fs/lockd/svcproc.c          |    6 ++----
>> include/linux/lockd/lockd.h |   41 +++++++++++++++++++++++++++++++++ 
>> ++++++++
>> 3 files changed, 45 insertions(+), 8 deletions(-)
>>
>> diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
>> index 9e1c751..6a5ef9f 100644
>> --- a/fs/lockd/svc4proc.c
>> +++ b/fs/lockd/svc4proc.c
>> @@ -432,11 +432,9 @@ nlm4svc_proc_sm_notify(struct svc_rqst *rqstp,  
>> struct nlm_reboot *argp,
>> {
>> 	struct sockaddr_in	saddr;
>>
>> -	memcpy(&saddr, svc_addr_in(rqstp), sizeof(saddr));
>> -
>> 	dprintk("lockd: SM_NOTIFY     called\n");
>> -	if (saddr.sin_addr.s_addr != htonl(INADDR_LOOPBACK)
>> -	 || ntohs(saddr.sin_port) >= 1024) {
>> +
>> +	if (!nlm_privileged_requester(rqstp)) {
>> 		char buf[RPC_MAX_ADDRBUFLEN];
>> 		printk(KERN_WARNING "lockd: rejected NSM callback from %s\n",
>> 				svc_print_addr(rqstp, buf, sizeof(buf)));
>> diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
>> index fcb7998..62fcfdb 100644
>> --- a/fs/lockd/svcproc.c
>> +++ b/fs/lockd/svcproc.c
>> @@ -464,11 +464,9 @@ nlmsvc_proc_sm_notify(struct svc_rqst *rqstp,  
>> struct nlm_reboot *argp,
>> {
>> 	struct sockaddr_in	saddr;
>>
>> -	memcpy(&saddr, svc_addr_in(rqstp), sizeof(saddr));
>> -
>> 	dprintk("lockd: SM_NOTIFY     called\n");
>> -	if (saddr.sin_addr.s_addr != htonl(INADDR_LOOPBACK)
>> -	 || ntohs(saddr.sin_port) >= 1024) {
>> +
>> +	if (!nlm_privileged_requester(rqstp)) {
>> 		char buf[RPC_MAX_ADDRBUFLEN];
>> 		printk(KERN_WARNING "lockd: rejected NSM callback from %s\n",
>> 				svc_print_addr(rqstp, buf, sizeof(buf)));
>> diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/ 
>> lockd.h
>> index 075095f..409eab4 100644
>> --- a/include/linux/lockd/lockd.h
>> +++ b/include/linux/lockd/lockd.h
>> @@ -280,6 +280,47 @@ static inline struct inode  
>> *nlmsvc_file_inode(struct nlm_file *file)
>> 	return file->f_file->f_path.dentry->d_inode;
>> }
>>
>> +static inline int __nlm_privileged_request4(const struct sockaddr  
>> *sap)
>> +{
>> +	const struct sockaddr_in *sin = (struct sockaddr_in *)sap;
>> +	return (sin->sin_addr.s_addr == htonl(INADDR_LOOPBACK)) &&
>> +			(ntohs(sin->sin_port) < 1024);
>> +}
>> +
>> +#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
>> +static inline int __nlm_privileged_request6(const struct sockaddr  
>> *sap)
>> +{
>> +	const struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
>> +	return (ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LOOPBACK) &&
>> +			(ntohs(sin6->sin6_port) < 1024);
>> +}
>> +#else	/* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
>> +static inline int __nlm_privileged_request6(const struct sockaddr  
>> *sap)
>> +{
>> +	return 0;
>> +}
>> +#endif	/* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
>> +
>> +/*
>> + * Ensure incoming requests are suitably "secure"
>> + *
>> + * Return TRUE if sender is local and is connecting via a  
>> privileged port;
>> + * otherwise return FALSE.
>> + */
>> +static inline int nlm_privileged_requester(const struct svc_rqst  
>> *rqstp)
>> +{
>> +	const struct sockaddr *sap = svc_addr(rqstp);
>> +
>> +	switch (sap->sa_family) {
>> +	case AF_INET:
>> +		return __nlm_privileged_request4(sap);
>> +	case AF_INET6:
>> +		return __nlm_privileged_request6(sap);
>> +	default:
>> +		return 0;
>> +	}
>> +}
>> +
>> static inline int __nlm_cmp_addr4(const struct sockaddr *sap1,
>> 				  const struct sockaddr *sap2)
>> {
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




