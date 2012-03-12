Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38400 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754812Ab2CLTbR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Mar 2012 15:31:17 -0400
Date: Mon, 12 Mar 2012 15:31:16 -0400
To: Nikolaus Rath <Nikolaus@rath.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS4 over VPN hangs when connecting > 2 clients
Message-ID: <20120312193115.GA7203@fieldses.org>
References: <878vj7x6mj.fsf@vostro.rath.org>
 <87pqchn64e.fsf@inspiron.ap.columbia.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87pqchn64e.fsf@inspiron.ap.columbia.edu>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 12, 2012 at 12:20:17PM -0400, Nikolaus Rath wrote:
> Nikolaus Rath <Nikolaus-BTH8mxji4b0@public.gmane.org> writes:
> > The problem is that as soon as more than three clients are accessing the
> > NFS shares, any operations on the NFS mountpoints by the clients hang.
> > At the same time, CPU usage of the VPN processes becomes very high. If I
> > run the VPN in debug mode, all I can see is that it is busy forwarding
> > lots of packets. I also ran a packet sniffer which showed me that 90% of
> > the packets were NFS related, but I am not familiar enough with NFS to
> > be able to tell anything from the packets themselves. I can provide an
> > example of the dump if that helps.
> 
> I have put a screenshot of the dump on
> http://www.rath.org/res/wireshark.png (the full dump is 18 MB, and I'm
> not sure which parts are important).

Looks like they're doing SETCLIENTID, SETCLIENTID_CONFIRM, OPEN,
OPEN_CONFIRM repeatedly.

> Any suggestions how I could further debug this?

Could the clients be stepping on each others' state if they all think
they have the same IP address (because of something to do with the VPN
networking?)

It'd be interesting to know the fields of the setclientid call, and the
errors that the server is responding with to these calls.  If you look
at the packet details you'll probably see the same thing happening
over and over again.

Filtering to look at traffic between server and one client at a time
might help to see the pattern.

--b.
