From: s o f i a <sofiavalera@yahoo.com>
Subject: RE: Linux client network performance
Date: Wed, 25 Jun 2003 11:09:28 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030625180928.84426.qmail@web41807.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from web41807.mail.yahoo.com ([66.218.93.141])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19VEi6-00046y-00
	for <nfs@lists.sourceforge.net>; Wed, 25 Jun 2003 11:09:34 -0700
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hello,

(pls cc me, a colleague just forwarded
this to me...)

I have seen this at a customer site.
And thank you so much for the clarification.

Can you please let me know:
- are there any identified workarounds?
- are there any papers or writeups on
various other symptoms of this issue?

At one site, the customer environment mentioned
about having issues with Linux clients; they
had to change NFS block size to 8k.... 

Wondering if one can comment about this one case, 
I noticed even with the Linux client side
mounted at 8k, at a certain point in time,
with a certain application that is write intensive,
to a Solaris NFS server, the client had to do
(2) writes, before the NFS server replied ...
(in looking at the snoop) ... i am not sure, but
i think the application had the capability to
write in even less the 8k blocksize, and it seems
like this eliminated the problem of NFS-writes
from the linux client... 

any thoughts on this issue?

thanks in advance,

sofia.


> Sent: Wednesday, June 25, 2003 10:40 AM
> To: Brasseur Valéry
> Cc: nfs@lists.sourceforge.net; Matthias Kittner
> Subject: RE: [NFS] Linux client network performance
> 
> 
> hi valery-
> 
> > what's the "IP fragmentation bug" ?
> 
> the Linux IP layer sends packet fragments on the
wire
> as it fragments each datagram.  it can run out of
socket
> buffer space in the middle of fragmenting a
datagram.
> the bug is that if it runs out of buffer space, it
> stops fragmenting and drops the packet.   
> 
> this leaves the receiving end with a bunch of
fragments
> it can't assemble into a whole datagram.  this
becomes
> a problem when the sending end is perpetually
running
> out of socket space.  this fills the receiving end's
> reassembly queue with fragments that can't be used,
> preventing all UDP traffic from getting to the
server.
> 
> the fix is to have it continue fragmenting this
datagram
> even though the socket buffer is "full."
> 
> > what are the symptoms of this bug ?
> 
> you're using NFS/UDP with largish r/wsize.  your
> network features links of different speed (100Mb
> mixed with GbE) between client and server, or is
> routed rather than only switched.
> 
> you see lots of IP fragments on your network from
> one or two NFS clients.  you have periods of very
slow
> server and network performance, followed by periods
of
> normal performance.  
> 
> > > -----Original Message-----
> > > From: Lever, Charles
[mailto:Charles.Lever@netapp.com]
> > > Sent: Wednesday, June 25, 2003 4:30 PM
> > > To: Matthias Kittner
> > > Cc: nfs@lists.sourceforge.net
> > > Subject: RE: [NFS] Linux client network
performance
> > > 
> > > 
> > > hi matthias-
> > > 
> > > it sounds like you've hit the IP fragmentation
bug.
> > > you should use NFS/TCP (the "tcp" mount option).
> > > 
> > > probably it's your 2.4.19-based client that is
> > > causing this problem.
> > > 
> > > > -----Original Message-----
> > > > From: Matthias Kittner
[mailto:kittner@vrcom.de]
> > > > Sent: Wednesday, June 25, 2003 4:57 AM
> > > > To: nfs@lists.sourceforge.net
> > > > Subject: [NFS] Linux client network
performance
> > > > 
> > > > 
> > > > [I am not a subscriber, please CC to my
eMail!]
> > > > 
> > > > Hello,
> > > > 
> > > > we have the following problem:
> > > > 
> > > > - 2 linux clients:
> > > > 	2.4.19-16mdk
> > > > 	2.4.20
> > > > - Solaris NFS-Server (nfs.server 1.21)
> > > > 	SunOS 5.7
> > > > 
> > > > If we compile on one of the linux machines
sometimes in
> > > this compile
> > > > process the whole network hangs resp. is so
slow that one
> > can wait
> > > > between 10s or 2min to finish a "ls".
> > > > 
> > > > "snoop" at the nfs-server machine show
very/very much "UDP
> > > > continuation" 
> > > > traffic between the linux client and the
solaris server. 
> > > Killing the
> > > > compile process stops this messages.
> > > > 
> > > > Can anyone help us? Is this a configuration
problem or a bug?
> > > > 
> > > > Regards,
> > > > Matthias
> > > > 
> > > > 
> > > > 
> > > >
-------------------------------------------------------
> > > > This SF.Net email is sponsored by: INetU
> > > > Attention Web Developers & Consultants: Become
An INetU
> > > > Hosting Partner.
> > > > Refer Dedicated Servers. We Manage Them. You
Get 10% Monthly 
> > > > Commission!
> > > > INetU Dedicated Managed Hosting 
> > http://www.inetu.net/partner/index.php
> > > _______________________________________________
> > > NFS maillist  -  NFS@lists.sourceforge.net 
> > > https://lists.sourceforge.net/lists/listinfo/nfs
> > > 
> > 
> > 
> >
-------------------------------------------------------
> > This SF.Net email is sponsored by: INetU
> > Attention Web Developers & Consultants: Become An
INetU
> > Hosting Partner.
> > Refer Dedicated Servers. We Manage Them. You Get
10% Monthly 
> > Commission!
> > INetU Dedicated Managed Hosting 
> http://www.inetu.net/partner/index.php


__________________________________
Do you Yahoo!?
SBC Yahoo! DSL - Now only $29.95 per month!
http://sbc.yahoo.com


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
