From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: Linux 2.4.25, nfs client hangs when talking to a
	MacOS nfs server.
Date: Wed, 17 Mar 2004 13:16:04 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1079547364.3047.27.camel@lade.trondhjem.org>
References: <117F2C39-7800-11D8-93C6-000A95CFFC9C@idtect.com>
	 <1079542707.3047.12.camel@lade.trondhjem.org>
	 <4825B7F5-783A-11D8-97E9-000A95CFFC9C@idtect.com>
	 <1079546462.3769.249.camel@d158140025182.Cadence.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Charles-Edouard Ruault <ce@idtect.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B3faQ-0002Ke-6Q
	for nfs@lists.sourceforge.net; Wed, 17 Mar 2004 10:16:14 -0800
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1B3faN-0007dH-Ni
	for nfs@lists.sourceforge.net; Wed, 17 Mar 2004 10:16:11 -0800
To: csc@cadence.com
In-Reply-To: <1079546462.3769.249.camel@d158140025182.Cadence.COM>
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

P=E5 on , 17/03/2004 klokka 13:01, skreiv Chris Croswhite:
> I have seen similar issues, but with slowlaris NFS server to linux.=20
> Never was able to resolve the issue and so moved to linux NFS server. =20
>=20
> I am willing to spend sometime on this issue if Trond can give me some
> assistance?  I can detail the issue if you have you are available.

It's very simple: if you using UDP as the transport mechanism, then
packets can (and *will*) be lost.
This is particularly true if you are working across a net which mixes
network speeds, since the switches have to queue data when going from
the fast to the slower net: once this queue has built up to the point
where the switch runs out of memory, it will start dropping incoming
packets.

IOW: this is not an NFS client bug, it is a network design bug.

In these environments you *must* use TCP, since that has congestion
control capabilities baked into the protocol...

For more detailed info on how to deal with this sort of problem, I
suggest the NFS FAQ and HOWTO: see http://nfs.sourceforge.net/

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
