Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:38841 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753990Ab0CLNfX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Mar 2010 08:35:23 -0500
Subject: Re: [RFC] SUNRPC connect timeout case network request delay
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        NFSv3 list <linux-nfs@vger.kernel.org>
In-Reply-To: <4B9A0F8C.5030900@cn.fujitsu.com>
References: <4B8F87A2.5080509@cn.fujitsu.com> <4B8FE6C7.2090207@oracle.com>
	 <4B94CA73.90600@cn.fujitsu.com> <4B951A70.7080201@oracle.com>
	 <4B9A0F8C.5030900@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 12 Mar 2010 08:35:10 -0500
Message-ID: <1268400910.3156.6.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2010-03-12 at 17:55 +0800, Mi Jinlong wrote: 
> Hi,
> 
>   Thanks for your reply.
> 
> Chuck Lever 写道:
> > On 03/08/2010 04:59 AM, Mi Jinlong wrote:
> >> Hi chuck,
> >>
> >>   Thanks for your reply.
> >>
> >> Chuck Lever 写道:
> >>> On 03/04/2010 05:12 AM, Mi Jinlong wrote:
> >>>> Hi,
> >>>> Step4: [22:42:16] Write data to file
> >>>>          [22:42:16] Write data success
> >>>> Step5: [22:42:16] Unlock file
> >>>>          [22:46:30] Unlock file success.
> >>>> Step6: [22:46:30] Close file /mnt/nfs/file
> >>>>          [22:46:30] Close fiel /mnt/nfs/file success
> >>>>
> >>>> The problem is at step5, unlock file takes 4 min, it's a long time
> >>>> than expected.
> >>>> When traceing the kernel, I find SUNRPC call call_connect timeout many
> >>>> times,
> >>>> one timeout is 1min.
> >>>
> >>> The kernel's TCP reconnect logic will retry until it succeeds, without
> >>> letting the upper level make progress.  For some reason, it is having
> >>> difficulty reconnecting with your server.
> >>>
> >>>> I think it's a problem of kernel, but i don't know why, can someone
> >>>> help me ?
> >>>
> >>> # sudo rpcdebug -m rpc -s xprt trans
> >>
> >>   After running this command, I got some important messages that I think.
> >>
> >>   RPC:       xs_connect delayed xprt  for 3 seconds
> >>   ...
> >>   RPC:       xs_connect delayed xprt  for 6 seconds
> >>   ...
> >>   RPC:       xs_connect delayed xprt  for 12 seconds
> >>   ...
> >>   RPC:       xs_connect delayed xprt  for 24 seconds
> >>   ...
> >>   ...
> >>   RPC:       xs_connect delayed xprt  for 300 seconds
> >>
> >> This message is printed at xs_connect, and the delay time is double
> >> there.
> >> IMO, when some data translate over through a socket, the socket should
> >> be released.
> >> But, it seems the socket isn't released through those messages above.
> >> Is it wrong, or there are some other reasons ?
> > 
> > The code is trying to connect, but the ->connect call isn't working
> > somehow.  The code backs off by doubling the timeout each time, so that
> > the connect attempts don't overload the server.
> > 
> > This tells us that the code is attempting to connect, but not why the
> > connect attempt is failing.
> 
>   When reading the kernel codes, I find a problem at function xs_tcp_close.
>     ....
>     772 static void xs_tcp_close(struct rpc_xprt *xprt)
>     773 {
>     774         if (test_and_clear_bit(XPRT_CONNECTION_CLOSE, &xprt->state))
>     775                 xs_close(xprt);
>     776         else
>     777                 xs_tcp_shutdown(xprt);
>     778 }
>      ...
>   If a task call xs_tcp_close to close the xprt's sock, many times it only call 
>   xs_tcp_shutdown to using the next layer's close function to close the socket
>   connection.
>   But after close the socket connection, the socket also exist, so the socket may
>   be reused. Is it a problem ? I think after xs_tcp_shutdown, the socket should
>   be released.

No it shouldn't. The whole point of the current code is to allow the RPC
client to _reuse_ the same port without having to wait for a TIME_WAIT.

The reason why we want to do that is because a lot of servers key their
duplicate reply caches on the port number. See
    http://www.connectathon.org/talks96/werme1.html

Trond

