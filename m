From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: timeo & retrans, smaller max timeout than 60 seconds?
Date: Wed, 29 Mar 2006 10:07:59 -0500
Message-ID: <1143644879.7928.44.camel@lade.trondhjem.org>
References: <Pine.LNX.4.64.0603290921500.2597@maggie.lkpg.cendio.se>
	 <1143641272.7928.13.camel@lade.trondhjem.org>
	 <Pine.LNX.4.64.0603291625370.7796@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FOcHW-0001uE-Db
	for nfs@lists.sourceforge.net; Wed, 29 Mar 2006 07:08:22 -0800
Received: from pat.uio.no ([129.240.10.6] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FOcHU-0003e3-Lx
	for nfs@lists.sourceforge.net; Wed, 29 Mar 2006 07:08:22 -0800
To: Peter =?ISO-8859-1?Q?=C5strand?= <astrand@cendio.se>
In-Reply-To: <Pine.LNX.4.64.0603291625370.7796@maggie.lkpg.cendio.se>
Sender: nfs-admin@lists.sourceforge.net
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

On Wed, 2006-03-29 at 16:33 +0200, Peter =C3=85strand wrote:

> > The maximum timeout for TCP is 600 seconds, i.e. 10 minutes.
>=20
> Does this mean that the manpage statement "The maximum timeout is always=20
> 60 seconds." is incorrect?

Yes.

> >>    If we start using, say, retrans=3D1, does this mean that applicatio=
ns can
> >>    recieve EIO after as little as 1 second?
> >
> > No. "timeo" controls the timeout value. "retrans" controls the number o=
f
> > retransmissions before a major timeout is declared.
>=20
> Yes, but the manpage states that EIO is reported when a major timeout=20
> occurs. So, the time until EIO must be influenced by "retrans", right?

It is influenced by _both_. timeo sets the timeout value for a single
retransmission. retrans sets the number of retransmissions in a major
timeout.

> >> * Is it true that all the "-f" option to umount does is skip trying
> >>    MOUNTPROC_UMNT?
> >
> > No. '-f' causes all pending RPC calls to be cancelled (and return -EIO)=
.
>=20
> Is MOUNTPROC_UMNT tried even when -f is specified?

I believe so.

> >> * About "intr": The man page says "If an NFS file operation has a majo=
r
> >>    timeout and it is hard mounted". Does "intr" affect soft mounts in =
any
> >>    way, or is it better to remove it?
> >
> > Intr changes the set of signals that are able to interrupt an RPC call.
> > It has nothing to do with "soft".
>=20
> That is - it has no effect when "soft" is used?

No. I mean that it has the same effect whether you use "soft" or "hard".
Intr controls signals, not timeouts.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
