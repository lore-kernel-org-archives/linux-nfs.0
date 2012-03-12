Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54096 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757095Ab2CLUPF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Mar 2012 16:15:05 -0400
Date: Mon, 12 Mar 2012 16:15:05 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Nikolaus Rath <Nikolaus@rath.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS4 over VPN hangs when connecting > 2 clients
Message-ID: <20120312201505.GC7203@fieldses.org>
References: <878vj7x6mj.fsf@vostro.rath.org>
 <87pqchn64e.fsf@inspiron.ap.columbia.edu>
 <20120312193115.GA7203@fieldses.org>
 <4F5E5241.7070008@rath.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F5E5241.7070008@rath.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 12, 2012 at 03:45:05PM -0400, Nikolaus Rath wrote:
> On 03/12/2012 03:31 PM, J. Bruce Fields wrote:
> > On Mon, Mar 12, 2012 at 12:20:17PM -0400, Nikolaus Rath wrote:
> >> Nikolaus Rath <Nikolaus-BTH8mxji4b0@public.gmane.org> writes:
> >>> The problem is that as soon as more than three clients are accessing the
> >>> NFS shares, any operations on the NFS mountpoints by the clients hang.
> >>> At the same time, CPU usage of the VPN processes becomes very high. If I
> >>> run the VPN in debug mode, all I can see is that it is busy forwarding
> >>> lots of packets. I also ran a packet sniffer which showed me that 90% of
> >>> the packets were NFS related, but I am not familiar enough with NFS to
> >>> be able to tell anything from the packets themselves. I can provide an
> >>> example of the dump if that helps.
> >>
> >> I have put a screenshot of the dump on
> >> http://www.rath.org/res/wireshark.png (the full dump is 18 MB, and I'm
> >> not sure which parts are important).
> > 
> > Looks like they're doing SETCLIENTID, SETCLIENTID_CONFIRM, OPEN,
> > OPEN_CONFIRM repeatedly.
> > 
> >> Any suggestions how I could further debug this?
> > 
> > Could the clients be stepping on each others' state if they all think
> > they have the same IP address (because of something to do with the VPN
> > networking?)
> 
> That sounds like promising path of investigation. What determines the IP
> of a client as far as NFS is concerned?

I don't remember where it gets the ip it uses to construct clientid's
from....  But there is a mount option (clientaddr=) that will let you
change what it uses.  So it *might* be worth checking whether using a
clientaddr= option on each client (giving it a different ipaddr on each
client) would change the behavior.

> > It'd be interesting to know the fields of the setclientid call, and the
> > errors that the server is responding with to these calls.  If you look
> > at the packet details you'll probably see the same thing happening
> > over and over again.
> > 
> > Filtering to look at traffic between server and one client at a time
> > might help to see the pattern.
> 
> Hmm. I'm looking at the fields, but I just have no idea what any of
> those mean. Would you possibly be willing to take a look? I uploaded a
> pcap dump of a few packets to http://www.rath.org/res/sample.pcap.

Looking at the packet details, under the client id field, the clients
are all using:

	"0.0.0.0/192.168.1.2 tcp UNIX 0"

And the server is returning STALE_CLIENTID to some SETCLIENTID_CONFIRMs
(I wonder if that's a server bug, that doesn't sound like the right
error--though this is a weird case), and NFS4ERR_EXPIRED to some OPENs
(I think that's correct server behavior if it thinks another SETCLIENTID
purged the state).

--b.
