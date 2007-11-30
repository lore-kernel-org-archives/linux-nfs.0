From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,PATCH 09/38] svc: Add a transport function that checks for write space
Date: Fri, 30 Nov 2007 17:43:34 -0500
Message-ID: <84F74F37-5C1D-4B71-B144-37486C55D9E1@oracle.com>
References: <20071129223917.14563.77633.stgit@dell3.ogc.int> <20071129224012.14563.23130.stgit@dell3.ogc.int> <2F76C3FF-923D-4C36-ADBE-E3F9F645F20E@oracle.com> <1196458764.5432.52.camel@trinity.ogc.int>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:57542 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754965AbXK3WoP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Nov 2007 17:44:15 -0500
In-Reply-To: <1196458764.5432.52.camel-SMNkleLxa3ZimH42XvhXlA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov 30, 2007, at 4:39 PM, Tom Tucker wrote:
> On Fri, 2007-11-30 at 15:46 -0500, Chuck Lever wrote:
>> On Nov 29, 2007, at 5:40 PM, Tom Tucker wrote:
>>> +static int svc_udp_has_wspace(struct svc_xprt *xprt)
>>> +{
>>> +	struct svc_sock *svsk = container_of(xprt, struct svc_sock,
>>> sk_xprt);
>>> +	struct svc_serv	*serv = svsk->sk_server;
>>> +	int required;
>>> +
>>> +	/*
>>> +	 * Set the SOCK_NOSPACE flag before checking the available
>>> +	 * sock space.
>>> +	 */
>>> +	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
>>> +	required = atomic_read(&svsk->sk_reserved) + serv->sv_max_mesg;
>>
>> The result of the sum is unsigned, but then we stuff it into a signed
>> integer...
>>
>>> +	if (required*2 > sock_wspace(svsk->sk_sk))
>>> +		return 0;
>>
>> ...and then this introduces a mixed sign comparison (harmless
>> AFAICT).  Perhaps "required" should be an unsigned long.
>>
>
> So for svc_udp_has_wspace, it makes sense for required to
> be unsigned, and then demote to signed on return. Yes?
>
>>
>> Also, some may prefer "<< 1" to "* 2".  I'm not sure it makes much
>> difference here.  Arguably, it might be slightly better documentation
>> to double "required" before the if statement.
>>
>>> +	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
>>> +	return 1;
>>> +}

As far as I can tell you never return "required."  The result of  
svc_udp_has_wspace() is really a boolean, right?  Or did I miss your  
point?

>>> +
>>>  static struct svc_xprt_ops svc_udp_ops = {
>>>  	.xpo_recvfrom = svc_udp_recvfrom,
>>>  	.xpo_sendto = svc_udp_sendto,
>>> @@ -904,6 +924,7 @@ static struct svc_xprt_ops svc_udp_ops = {
>>>  	.xpo_detach = svc_sock_detach,
>>>  	.xpo_free = svc_sock_free,
>>>  	.xpo_prep_reply_hdr = svc_udp_prep_reply_hdr,
>>> +	.xpo_has_wspace = svc_udp_has_wspace,
>>>  };
>>>
>>>  static struct svc_xprt_class svc_udp_class = {
>>> @@ -1366,6 +1387,24 @@ static void svc_tcp_prep_reply_hdr(struct
>>> svc_rqst *rqstp)
>>>  	svc_putnl(resv, 0);
>>>  }
>>>
>>> +static int svc_tcp_has_wspace(struct svc_xprt *xprt)
>>> +{
>>> +	struct svc_sock *svsk = container_of(xprt, struct svc_sock,
>>> sk_xprt);
>>> +	struct svc_serv	*serv = svsk->sk_server;
>>> +	int required;
>>> +
>>> +	/*
>>> +	 * Set the SOCK_NOSPACE flag before checking the available
>>> +	 * sock space.
>>> +	 */
>>> +	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
>>> +	required = atomic_read(&svsk->sk_reserved) + serv->sv_max_mesg;
>>
>> Ibid.
>>
>>> +	if (required*2 > sk_stream_wspace(svsk->sk_sk))
>>> +		return 0;
>>
>> Oddly sk_stream_wspace() returns an int, but sock_space() returns an
>> unsigned long.  Sigh...
>
> For this one, let's leave required signed and add an explicit cast to
> serv->sv_max_mesg. Sound ok?

If sk_reserved goes negative, it will be converted to unsigned, and  
become a very large positive number.  The result of the sum will be  
recast back to an int when it's assigned to "required," and we  
probably get a reasonable result.  I doubt an explicit cast will  
change things at all.

Instead, perhaps we should add an explicit check to ensure  
sk_reserved is a reasonable positive value before doing any other  
checks.  (Likewise in the UDP case as well).

I wonder if this is really the correct write space check to use for  
TCP, though.  I remember fixing a similar issue in the RPC client a  
long time ago -- both UDP and TCP used the same wspace check.  It  
resulted in the sk_write_space callback hammering on the RPC client,  
and forward progress on TCP socket writes would slow to a crawl.

You probably want something like this instead:

	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);

	required = atomic_read(&svsk->sk_reserved) + serv->sv_max_mesg;
	wspace = sk_stream_wspace(svsk->sk_sk);

	if (wspace < sk_stream_min_wspace(svsk->sk_sk))
		return 0;
	if (required * 2 > wspace)
		return 0;

	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
	return 1;

The first test mimics sk_stream_write_space() and xs_tcp_write_space 
().  I'm still unsure what to do about the possibility of one of  
these signed integers going negative on us.

Bruce?  Neil?  What sayest thou?

>>> +	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
>>> +	return 1;
>>> +}
>>> +
>>>  static struct svc_xprt_ops svc_tcp_ops = {
>>>  	.xpo_recvfrom = svc_tcp_recvfrom,
>>>  	.xpo_sendto = svc_tcp_sendto,
>>> @@ -1373,6 +1412,7 @@ static struct svc_xprt_ops svc_tcp_ops = {
>>>  	.xpo_detach = svc_sock_detach,
>>>  	.xpo_free = svc_sock_free,
>>>  	.xpo_prep_reply_hdr = svc_tcp_prep_reply_hdr,
>>> +	.xpo_has_wspace = svc_tcp_has_wspace,
>>>  };
>>>
>>>  static struct svc_xprt_class svc_tcp_class = {

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
