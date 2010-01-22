From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 3/3] NFSD: Enable NFS server use of PF_INET6
Date: Fri, 22 Jan 2010 12:07:42 -0500
Message-ID: <55DDE4BD-9B79-43AA-A054-FF9CA302A37B@oracle.com>
References: <20100113210650.19409.38009.stgit@localhost.localdomain> <20100113211048.19409.86029.stgit@localhost.localdomain> <20100115224405.GH30624@fieldses.org> <FD469623-92A6-43E4-9D9B-999A5BCDC0BD@oracle.com> <20100121220726.GI23322@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:64724 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753807Ab0AVRH7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Jan 2010 12:07:59 -0500
In-Reply-To: <20100121220726.GI23322@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 21, 2010, at 5:07 PM, J. Bruce Fields wrote:

> On Fri, Jan 15, 2010 at 06:17:38PM -0500, Chuck Lever wrote:
>>
>> On Jan 15, 2010, at 5:44 PM, J. Bruce Fields wrote:
>>
>>> On Wed, Jan 13, 2010 at 04:10:48PM -0500, Chuck Lever wrote:
>>>> Try to use an PF_INET6 listener for NFSD if IPv6 is enabled in the
>>>> kernel.
>>>>
>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>> ---
>>>>
>>>> fs/nfsd/nfsctl.c |   36 +++++++++++++++++++++++++++++-------
>>>> fs/nfsd/nfssvc.c |   27 ++++++++++++++++++++++-----
>>>> 2 files changed, 51 insertions(+), 12 deletions(-)
>>>>
>>>> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
>>>> index 2604c3e..7ebb7a5 100644
>>>> --- a/fs/nfsd/nfsctl.c
>>>> +++ b/fs/nfsd/nfsctl.c
>>>> @@ -981,6 +981,26 @@ static ssize_t __write_ports_delfd(char *buf)
>>>> 	return len;
>>>> }
>>>>
>>>> +static ssize_t __write_ports_create_xprt(struct svc_serv *serv,
>>>> +					 const char *transport,
>>>> +					 const int family,
>>>> +					 const unsigned short port)
>>>> +{
>>>> +	int err;
>>>> +
>>>> +	err = svc_create_xprt(serv, transport, family, port,
>>>> +						SVC_SOCK_ANONYMOUS);
>>>> +
>>>> +	if (err < 0) {
>>>> +		/* Give a reasonable perror msg for bad transport string */
>>>> +		if (err == -ENOENT)
>>>> +			err = -EPROTONOSUPPORT;
>>>> +		return err;
>>>> +	}
>>>> +
>>>> +	return 0;
>>>> +}
>>>> +
>>>> /*
>>>> * A transport listener is added by writing it's transport name and
>>>> * a port number.
>>>> @@ -1000,14 +1020,16 @@ static ssize_t __write_ports_addxprt(char
>>>> *buf)
>>>> 	if (err != 0)
>>>> 		return err;
>>>>
>>>> -	err = svc_create_xprt(nfsd_serv, transport,
>>>> -				PF_INET, port, SVC_SOCK_ANONYMOUS);
>>>> -	if (err < 0) {
>>>> -		/* Give a reasonable perror msg for bad transport string */
>>>> -		if (err == -ENOENT)
>>>> -			err = -EPROTONOSUPPORT;
>>>> +	err = __write_ports_create_xprt(nfsd_serv, transport, PF_INET,
>>>> port);
>>>> +	if (err < 0)
>>>> 		return err;
>>>> -	}
>>>> +
>>>> +#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
>>>> +	err = __write_ports_create_xprt(nfsd_serv, transport, PF_INET6,
>>>> port);
>>>> +	if (err < 0 && err != -EAFNOSUPPORT)
>>>> +		return err;
>>>> +#endif	/* CONFIG_IPV6 || CONFIG_IPV6_MODULE */
>>>
>>> Does every caller of __write_ports_create_xprt() with PF_INET6 end  
>>> up
>>> being under this ifdef?  Could we instead just move the ifdef inside
>>> it
>>> (or inside __svc_xpo_create())?  (As usual I'd rather keep any
>>> necessary
>>> hidden away to the extent possible.)
>>
>> The only two call sites are right here:  one with PF_INET and one  
>> with
>> PF_INET6.
>
> OK, but svc_create_xprt has a few more.
>
>>
>> When IPv6 support is not enabled, we want only the first call (with
>> PF_INET).  When IPv6 support is enabled, we want two calls; one with
>> PF_INET and then one with PF_INET6.
>
> Right, I understand, but we could equally well do that by calling
> svc_create_xprt twice, and depending on it (or __svc_xpo_create(), or
> someone else there) to return -EAFNOSUPPORT in the ! 
> defined(CONFIG_IPV6)
> && !defined(CONFIG_IPV6_MODULE case.  Right?
>
> No change in behavior, I just want the #ifdef's buried a little  
> further
> if it's possible.

Yeah, OK.  That kind of change would effect other call sites, so I  
would need to break this into a couple of smaller patches.

>
> --b.
>
>>
>> This particular interface is for creating a named transport.  We  
>> don't
>> name our IPv6 transports separately from IPv4 transports, so this  
>> is a
>> simple way to get IPv6 enabled listeners.  It's actually been a while
>> since I sat down and thought through this.
>>
>>> --b.
>>>
>>>> +
>>>> 	return 0;
>>>> }
>>>>
>>>> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
>>>> index 171699e..7af14c1 100644
>>>> --- a/fs/nfsd/nfssvc.c
>>>> +++ b/fs/nfsd/nfssvc.c
>>>> @@ -275,14 +275,32 @@ int nfsd_create_serv(void)
>>>> 	return err;
>>>> }
>>>>
>>>> -static int nfsd_init_socks(int port)
>>>> +static int nfsd_create_xprt(const char *transport, const unsigned
>>>> short port)
>>>> +{
>>>> +	int ret;
>>>> +
>>>> +	ret = svc_create_xprt(nfsd_serv, transport, PF_INET, port,
>>>> +							SVC_SOCK_DEFAULTS);
>>>> +	if (ret < 0)
>>>> +		return ret;
>>>> +
>>>> +#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
>>>> +	ret = svc_create_xprt(nfsd_serv, transport, PF_INET6, port,
>>>> +							SVC_SOCK_DEFAULTS);
>>>> +	if (ret < 0 && ret != -EAFNOSUPPORT)
>>>> +		return ret;
>>>> +#endif	/* CONFIG_IPV6 || CONFIG_IPV6_MODULE */
>>>> +
>>>> +	return 0;
>>>> +}
>>>> +
>>>> +static int nfsd_init_socks(const unsigned short port)
>>>> {
>>>> 	int error;
>>>> 	if (!list_empty(&nfsd_serv->sv_permsocks))
>>>> 		return 0;
>>>>
>>>> -	error = svc_create_xprt(nfsd_serv, "udp", PF_INET, port,
>>>> -					SVC_SOCK_DEFAULTS);
>>>> +	error = nfsd_create_xprt("udp", port);
>>>> 	if (error < 0)
>>>> 		return error;
>>>>
>>>> @@ -290,8 +308,7 @@ static int nfsd_init_socks(int port)
>>>> 	if (error < 0)
>>>> 		return error;
>>>>
>>>> -	error = svc_create_xprt(nfsd_serv, "tcp", PF_INET, port,
>>>> -					SVC_SOCK_DEFAULTS);
>>>> +	error = nfsd_create_xprt("tcp", port);
>>>> 	if (error < 0)
>>>> 		return error;
>>>>
>>>>
>>
>> --
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>>
>>
>>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



