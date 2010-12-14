Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47061 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757825Ab0LNTPR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Dec 2010 14:15:17 -0500
Date: Tue, 14 Dec 2010 14:15:14 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: DENIEL Philippe <philippe.deniel@cea.fr>
Cc: Thomas Haynes <thomas@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: Side effects of having NFSv4 mounted over udp
Message-ID: <20101214191514.GC24828@fieldses.org>
References: <4D05CF50.1010305@cea.fr>
 <A9F12BB4-8571-4C58-AC6A-8094FA912B27@netapp.com>
 <20101213191634.GB2230@fieldses.org>
 <4D071E32.905@cea.fr>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D071E32.905@cea.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Dec 14, 2010 at 08:35:14AM +0100, DENIEL Philippe wrote:
> Hi
> >The Linux server allows it, but I've been considering that a
> >(low-priority) bug, so it wouldn't be safe to assume it will continue
> >working.
> I am mostly thinking at the client side using as well udp and tcp.
> Would the "NFSv4 client over UDP" behaves differently then the same
> client over TCP ?
> 
> >That aside, if you have a perfect network,
> I can trust my network. It's not a WAN, it's located into a very
> massive cluster (it's kind of "internal LAN"). It's a very high
> throughput network (IB based) so I believe there are less "hardware
> based reason" to loose packets.
> 
> >NFSv4.0 at least will
> >probably work.
> OK.
> >(Not 4.1 since backchannel setup will fail?)
> What is erroneous in using UDP for NFSv4.1 backchannels ?

I assumed it would require some stronger notion of a "connection" than
UDP could provide.  But maybe it could be made to work somehow.

> >Are you really sure that you can't make tcp scale to thousands of
> >clients?
> I am a bit afraid of a "No more file descriptors" effect. If I have
> one TCP socket per client and thousands of clients, I have less
> remaining fds for other purposes. Another point : UDP is a "cheap"
> protocol. I can have bunches of clients without overloading the
> server (a new client will almost cost nothing to the server, just
> the cost of a new clientid negotiation) .

Is the tcp state all that much more?

> I was wondering if it
> could be reliable to use it for NFSv4 inside a large cluster.

Well, it'd require some spec changes in any case.

--b.
