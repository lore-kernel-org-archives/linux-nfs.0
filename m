From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH 09/38] svc: Add a transport function that checks
	for write space
Date: Mon, 10 Dec 2007 14:43:54 -0600
Message-ID: <1197319434.21931.31.camel@trinity.ogc.int>
References: <20071129223917.14563.77633.stgit@dell3.ogc.int>
	 <20071129224012.14563.23130.stgit@dell3.ogc.int>
	 <2F76C3FF-923D-4C36-ADBE-E3F9F645F20E@oracle.com>
	 <1196458764.5432.52.camel@trinity.ogc.int>
	 <84F74F37-5C1D-4B71-B144-37486C55D9E1@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:47535 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752670AbXLJUjF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2007 15:39:05 -0500
In-Reply-To: <84F74F37-5C1D-4B71-B144-37486C55D9E1@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 2007-11-30 at 17:43 -0500, Chuck Lever wrote:
> On Nov 30, 2007, at 4:39 PM, Tom Tucker wrote:

[...snip...]

> >
> > For this one, let's leave required signed and add an explicit cast to
> > serv->sv_max_mesg. Sound ok?
> 
> If sk_reserved goes negative, it will be converted to unsigned, and  
> become a very large positive number.  The result of the sum will be  
> recast back to an int when it's assigned to "required," and we  
> probably get a reasonable result.  I doubt an explicit cast will  
> change things at all.
> 
> Instead, perhaps we should add an explicit check to ensure  
> sk_reserved is a reasonable positive value before doing any other  
> checks.  (Likewise in the UDP case as well).
> 
> I wonder if this is really the correct write space check to use for  
> TCP, though.  I remember fixing a similar issue in the RPC client a  
> long time ago -- both UDP and TCP used the same wspace check.  It  
> resulted in the sk_write_space callback hammering on the RPC client,  
> and forward progress on TCP socket writes would slow to a crawl.

For the server, the callback function is svc_write_space. Does the
sk_stream_wspace() < sk_stream_min_wspace() check belong in there as
well? I think this callback gets invoked whenever productive acks are
received for the connection. In other words, I don't see how it avoids
"hammering" the callback, rather it avoids fruitlessly waking up (i.e.
calling svc_xprt_enqueue) a transport.

I'm going to optimistically add it. Please let me know if there are
objections.

> 
> You probably want something like this instead:
> 
> 	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> 
> 	required = atomic_read(&svsk->sk_reserved) + serv->sv_max_mesg;
> 	wspace = sk_stream_wspace(svsk->sk_sk);
> 
> 	if (wspace < sk_stream_min_wspace(svsk->sk_sk))
> 		return 0;
> 	if (required * 2 > wspace)
> 		return 0;
> 
> 	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> 	return 1;
> 

I think this is good stuff and will add it unless someone has an
objection.

> The first test mimics sk_stream_write_space() and xs_tcp_write_space 
> ().  I'm still unsure what to do about the possibility of one of  
> these signed integers going negative on us.
> 
> Bruce?  Neil?  What sayest thou?
> 
> >>> +	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> >>> +	return 1;
> >>> +}
> >>> +
> >>>  static struct svc_xprt_ops svc_tcp_ops = {
> >>>  	.xpo_recvfrom = svc_tcp_recvfrom,
> >>>  	.xpo_sendto = svc_tcp_sendto,
> >>> @@ -1373,6 +1412,7 @@ static struct svc_xprt_ops svc_tcp_ops = {
> >>>  	.xpo_detach = svc_sock_detach,
> >>>  	.xpo_free = svc_sock_free,
> >>>  	.xpo_prep_reply_hdr = svc_tcp_prep_reply_hdr,
> >>> +	.xpo_has_wspace = svc_tcp_has_wspace,
> >>>  };
> >>>
> >>>  static struct svc_xprt_class svc_tcp_class = {
> 
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> -
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

