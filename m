Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:64267 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751400Ab1KKWjJ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Nov 2011 17:39:09 -0500
Message-ID: <1321051132.4810.16.camel@lade.trondhjem.org>
Subject: Re: unexpected NFS timeouts, related to sync/async soft mounts over
 TCP
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Andrew Cooper <andrew.cooper3@citrix.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Date: Fri, 11 Nov 2011 17:38:52 -0500
In-Reply-To: <4EBCF98E.6050101@citrix.com>
References: <4EBAC88D.40902@citrix.com>
		 <BEF32B02-0D19-4D97-8E93-C1797DF02CFE@oracle.com>
		 <4EBBB247.40805@citrix.com>
		 <2E3D3F87-479E-4096-B086-C8F83A0147B5@oracle.com>
		 <4EBBF35B.5000606@citrix.com>
	 <1320957784.11956.16.camel@lade.trondhjem.org>
	 <4EBCF98E.6050101@citrix.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2011-11-11 at 10:31 +0000, Andrew Cooper wrote: 
> On 10/11/11 20:43, Trond Myklebust wrote:
> > On Thu, 2011-11-10 at 15:52 +0000, Andrew Cooper wrote: 
> >> On 10/11/11 15:29, Chuck Lever wrote:
> >>> On Nov 10, 2011, at 6:15 AM, Andrew Cooper wrote:
> >>>
> >>>> On 09/11/11 22:36, Chuck Lever wrote:
> >>>>> On Nov 9, 2011, at 1:38 PM, Andrew Cooper wrote:
> >> Sorry.  I am not sure I was clear.  An EIO does not present itself with
> >> a hard mount, but a TCP FIN is still injected into the stream by the
> >> client, causing 15 seconds of deadlock, eventually fixed by sending a
> >> RST and restarting with a new TCP stream.  At this point, softmounts
> >> throw an EIO while hardmounts restart and continue successfully.
> >>
> >> My problem is not the EIO on softmount or lack of EIO for hardmout, but
> >> the fact that the client sees fit to try and close the TCP stream while
> >> an apparently otherwise healthy NFS session is ongoing.
> > The client will attempt to close the TCP connection on any RPC level
> > error. That can happen, e.g., if the server sends a faulty RPC/TCP
> > record fragment header or some other garbage data.
> >
> > I'm assuming that you've checked that the TCP parameters are set to sane
> > values for a 10GigE connection (i.e. tcp_timestamps is on) so that there
> > is no corruption happening at that level?
> >
> > Cheers
> >   Trond
> 
> I have a TCPdump/wireshark analysis of the entire packet stream (4GiB). 
> I cant see any RPC level errors (rpc.replystat != 0 yields no matches). 
> What specifically would I be looking for?  Wireshark seems not to have
> any problem decoding any of the RPC packets, so I hope that indicates no
> RPC level corruption.
> 
> There is one case where the server sends a double write reply for the
> same write, with different length fields.  However, this is a good 20
> seconds before the FIN is sent, so I was hoping that it was unrelated.
> Might it not be?

Can you send us just that portion of the trace so that we can have a look?

> As for TCP timestamps; I have a Timestamp option in each TCP packet. 
> Nothing appears corrupted.  What would I be looking for with corrupted
> timestamps?

I just meant that you should check that you've enabled tcp window
scaling and timestamps in order to avoid problems with wrapped sequence
numbers (See  http://tools.ietf.org/html/rfc1323 for details).

On Linux this means that you need to check

	sysctl net.ipv4.tcp_timestamps
and
	sysctl net.ipv4.tcp_window_scaling

They should both be set to the value '1'.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

