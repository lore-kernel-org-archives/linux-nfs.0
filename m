From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: NFS regression? Odd delays and lockups accessing an NFS export.
Date: Wed, 27 Aug 2008 09:43:01 -0500
Message-ID: <48B567F5.2090605@opengridcomputing.com>
References: <1219435207.27921.51.camel@localhost.localdomain> <1219440202.9097.14.camel@localhost> <1219441041.27921.57.camel@localhost.localdomain> <1219442213.9097.25.camel@localhost> <1219603981.27921.145.camel@localhost.localdomain> <1219605422.14389.2.camel@localhost> <1219605596.14389.5.camel@localhost> <1219615789.27921.152.camel@localhost.localdomain> <1219616136.14389.12.camel@localhost> <48B2D7F8.5020206@opengridcomputing.com> <20080826192711.GJ4380@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Ian Campbell <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	John Ronciak <john.ronciak@gmail.com>,
	Grant Coady <gcoady.lk@gmail.com>,
	linux-kernel@vger.kernel.org, neilb@suse.de,
	linux-nfs@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:39295 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752675AbYH0OnD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Aug 2008 10:43:03 -0400
In-Reply-To: <20080826192711.GJ4380@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Mon, Aug 25, 2008 at 11:04:08AM -0500, Tom Tucker wrote:
>> Trond Myklebust wrote:
>>> On Sun, 2008-08-24 at 23:09 +0100, Ian Campbell wrote:
>>>> (added some quoting from previous mail to save replying twice)
>>>>
>>>> On Sun, 2008-08-24 at 15:19 -0400, Trond Myklebust wrote:
>>>>> On Sun, 2008-08-24 at 15:17 -0400, Trond Myklebust wrote:
>>>>>> >From the tcpdump, it looks as if the NFS server is failing to close the
>>>>>> socket, when the client closes its side. You therefore end up getting
>>>>>> stuck in the FIN_WAIT2 state (as netstat clearly shows above).
>>>>>>
>>>>>> Is the server keeping the client in this state for a very long
>>>>>> period?
>>>> Well, it had been around an hour and a half on this occasion. Next time
>>>> it happens I can wait longer but I'm pretty sure I've come back from
>>>> time away and it's been wedged for at least a day. How long would you
>>>> expect it to remain in this state for?
>>> The server should ideally start to close the socket as soon as it
>>> receives the FIN from the client. I'll have a look at the code.
>>>
>> I don't think it should matter how long the connection stays in FIN WAIT,
>> the client should reconnect anyway.
>>
>> Since the client seems to be the variable, I would think it might be an
>> issue with the client reconnect logic?
>>
>> That said, 2.6.25 is when the server side transport switch logic went in.
> 
> Any chance you could help Trond figure out why the server might be doing
> this?
> 
> If not, I'll get to it, but not as soon as I should.
> 

Sure. I've actually tried to reproduce it here unsuccessfully.

As a starter, I would suggest turning on transport debugging:

# echo 256 > /proc/sys/sunrpc/rpc_debug

Here are my thoughts on how it is supposed to work. Trond if this doesn't match
your understanding, please let me know.

For the case where the client closes the connection first
because it's timeout is shorter (5min vs. 6), the sequence of events should be:


client					server

close
sends FIN goes to FIN-WAIT-1
					receives FIN replies with ACK
					and goes to CLOSE-WAIT
receives ACK goes to FIN-WAIT-2
					calls tcp_state_change callback on socket
					svc_tcp_state_change sets XPT_CLOSE on
					the transport and enqueues transport for
					servicing by svc thread.

					thread gets dequeued, calls svc_recv
					svc_recv sees XPT_CLOSE and calls
					svc_xprt_destroy that closes the socket

					TCP sends FIN/ACK after close
receives FIN/ACK goes to TIME-WAIT

since state is TIME-WAIT and
reuse port is set, we can re-connect

There's a couple places we could be getting stuck:

- The state-change callback never gets called.
- The state-change callback gets called but svsk is null and it ignores the event
- svc_tcp_state_change enqueues the transport, but due to a race bug, the transport
   doesn't actually get queued and since there is no activity it never closes
- something else

The message log with RPCDBG_SVCXPRT (256) enabled as shown above would help figure
out where it's happening.

If Ian is willing to create the log (or already has one), I'm certainly willing to
look at it.

Tom


> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

