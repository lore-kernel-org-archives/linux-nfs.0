From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Sunrpc transport reconnection...
Date: Mon, 29 Mar 2010 18:25:16 -0400
Message-ID: <4BB128CC.7060707@oracle.com>
References: <1269898987.15895.95.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:61427 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752034Ab0C2W1E (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Mar 2010 18:27:04 -0400
In-Reply-To: <1269898987.15895.95.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/29/2010 05:43 PM, Trond Myklebust wrote:
> Having looked more carefully at the code...
>
> Is there any reason to keep the xprt->connect_timeout? As far as I can
> see, it would appear to be completely redundant.
>
> For UDP there is no disconnect/reconnect. The socket is set up once and
> for all, so no need for connect_timeout.

I vaguely recall at least one case where UDP connect can hang.  The 
connect_timeout in that case is short, on the order of 5 seconds.

> In the case of a TCP reconnection, the xprt->reestablish_timeout will do
> exponential back-off to prevent reconnecting unnecessarily. The
> XPRT_CONNECTING lock then prevents anyone from trying to interfere with
> that connect request until it gets a reply, or the TCP layer decides
> that the socket has timed out. Again, it appears that
> xprt->connect_timeout is redundant.

It probably is redundant when the host is unreachable.  We already have 
the retransmit timeout, and the socket connect call is always 
nonblocking because we aren't supposed to sleep.

If the server refuses our connection, the connect_timeout timer appears 
to be discarded, which is probably the wrong thing to do.

> RDMA reconnection appears to follow the TCP model. Once again, there is
> exponential back-off, enforced by XPRT_CONNECTING.
>
> So why do we have xprt->connect_timeout? What is it enforcing?

It may be a vestige of the previous connect implementation, where 
call_connect actually could have slept in the RPC scheduler.

We eventually want to invoke call_timeout if the connection never 
completes.  It could be because the server keeps refusing or resetting 
our connection, or because there is no response from the server.  The 
retransmit timeout is probably appropriate for both of those cases.

-- 
chuck[dot]lever[at]oracle[dot]com
