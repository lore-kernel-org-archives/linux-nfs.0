From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Re: Linux 2.4.25, nfs client hangs when talking to a MacOS nfs server.
Date: Wed, 17 Mar 2004 11:56:34 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C61130435DD8A@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: <csc@cadence.com>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B3hYk-0000yA-LJ
	for nfs@lists.sourceforge.net; Wed, 17 Mar 2004 12:22:38 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1B3hYj-0001ql-T2
	for nfs@lists.sourceforge.net; Wed, 17 Mar 2004 12:22:37 -0800
To: "Charles-Edouard Ruault" <ce@idtect.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

charles-

> >It's very simple: if you using UDP as the transport mechanism, then=20
> >packets can (and *will*) be lost.
> > =20
> >
> yep, that's why i tried switching to TCP ... but with no=20
> better result.
>=20
> >This is particularly true if you are working across a net=20
> which mixes=20
> >network speeds, since the switches have to queue data when=20
> going from=20
> >the fast to the slower net: once this queue has built up to=20
> the point=20
> >where the switch runs out of memory, it will start dropping incoming=20
> >packets.
> >
> >IOW: this is not an NFS client bug, it is a network design bug.
> >
> > =20
> >
> We'll see if this disappears after we've finished migrating=20
> the network=20
> to 1Gbps
>=20
> >In these environments you *must* use TCP, since that has congestion=20
> >control capabilities baked into the protocol...

what matters here is flow control.  UDP simply doesn't have it.

for gigabit Ethernet, you need flow control at the link level and
at the transport level.  so once you have gigabit infrastructure,
be sure you have enabled full gigabit flow control on your servers
and on your switches.  then you should use TCP and not UDP so you
have transport layer flow control.


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
