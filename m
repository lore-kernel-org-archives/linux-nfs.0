From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: df hangs on down nfs server mounted with hard,intr,
	can't kill
Date: Wed, 10 Mar 2004 14:18:46 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1078946326.1940.35.camel@nidelv.trondhjem.org>
References: <482A3FA0050D21419C269D13989C61130435DD25@lavender-fe.eng.netapp.com>
	 <20040310080910.GA21031@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Charles Lever <Charles.Lever@netapp.com>, Wade Hampton <wade.hampton@nsc1.net>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B19Nq-00053r-0N
	for nfs@lists.sourceforge.net; Wed, 10 Mar 2004 11:28:50 -0800
Received: from dh197.citi.umich.edu
	([141.211.133.197] helo=nidelv.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1B18pN-00066u-Bp
	for nfs@lists.sourceforge.net; Wed, 10 Mar 2004 10:53:13 -0800
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040310080910.GA21031@suse.de>
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

P=E5 on , 10/03/2004 klokka 03:09, skreiv Olaf Kirch:
> On Tue, Mar 09, 2004 at 11:51:10AM -0800, Lever, Charles wrote:
> > the fact that "intr" doesn't work as expected is a bug, and
> > folks are attempting to address this at least partially in 2.6.
>=20
> FWIW, attached you'll find the patch I'm currently using.
> I thought I had posted it to this list already.
>=20
> BTW what is the "right" way to get stuff like this into the mainline
> kernel? Trond, are you collecting stuff and pushing it to Andrew, or
> should I be sending patches to him directly?

I've got your patch queued in the latest NFS4_ALL, and I believe I
already pushed it to Andrew (so it should already be in the latest
2.6.3-mm). I'm aiming to push it into 2.6.5-preX as soon as Linus
releases the final version of 2.6.4...

You are of course free to send stuff directly to Andrew/Linus, but I
personally would prefer if you attempt to queue it through me, since
that allows for a more ordered development process. Fixing up a set of
30 patches in order to accomodate some minor change that went directly
into the main kernel can be very time consuming, so it makes it easier
for me if we just append stuff to the NFS4_ALL patches (unless, of
course, we are talking *critical* fixes).

FYI: you can for the moment assume that *all* patches that are in the
http://www.fys.uio.no/~trondmy/src/Linux-2.6.x subdirectories are being
queued for inclusion in Linus' kernel. Only if a patch shows serious
problems under testing will it be dropped.

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
