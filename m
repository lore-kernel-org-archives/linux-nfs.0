From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: timeo & retrans, smaller max timeout than 60 seconds?
Date: Wed, 29 Mar 2006 15:52:49 -0500
Message-ID: <1143665569.7957.24.camel@lade.trondhjem.org>
References: <Pine.LNX.4.64.0603290921500.2597@maggie.lkpg.cendio.se>
	 <1143641272.7928.13.camel@lade.trondhjem.org>
	 <Pine.LNX.4.64.0603291625370.7796@maggie.lkpg.cendio.se>
	 <1143644879.7928.44.camel@lade.trondhjem.org>
	 <Pine.LNX.4.64.0603292058050.15464@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FOhf7-0000sW-S6
	for nfs@lists.sourceforge.net; Wed, 29 Mar 2006 12:53:05 -0800
Received: from pat.uio.no ([129.240.10.6] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FOhf6-0006tM-0I
	for nfs@lists.sourceforge.net; Wed, 29 Mar 2006 12:53:06 -0800
To: Peter =?ISO-8859-1?Q?=C5strand?= <astrand@cendio.se>
In-Reply-To: <Pine.LNX.4.64.0603292058050.15464@maggie.lkpg.cendio.se>
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

On Wed, 2006-03-29 at 22:24 +0200, Peter =C3=85strand wrote:
> On Wed, 29 Mar 2006, Trond Myklebust wrote:
>=20
> >>> The maximum timeout for TCP is 600 seconds, i.e. 10 minutes.
> >>
> >> Does this mean that the manpage statement "The maximum timeout is alwa=
ys
> >> 60 seconds." is incorrect?
> >
> > Yes.
>=20
> Let's fix this, then. What about this patch, against=20
> util-linux-2.13-pre7 ?:
>=20
> --- ./mount/nfs.5.org   2006-03-29 20:54:59.000000000 +0200
> +++ ./mount/nfs.5       2006-03-29 20:57:35.000000000 +0200
> @@ -43,12 +43,12 @@
>   first retransmission after an RPC timeout.
>   The default value is 7 tenths of a second.  After the first timeout,
>   the timeout is doubled after each successive timeout until a maximum
> -timeout of 60 seconds is reached or the enough retransmissions
> +timeout is reached or the enough retransmissions
>   have occured to cause a major timeout.  Then, if the filesystem
>   is hard mounted, each new timeout cascade restarts at twice the
>   initial value of the previous cascade, again doubling at each
> -retransmission.  The maximum timeout is always 60 seconds.
> -Better overall performance may be achieved by increasing the
> +retransmission.  The maximum timeout is 60 seconds for UDP and 600
> +seconds for TCP. Better overall performance may be achieved by increasin=
g=20
> the
>   timeout when mounting on a busy network, to a slow server, or through
>   several routers or gateways.
>   .TP 1.5i

Yeah... Except I'm not sure we should keep the stuff about 'better
overall performance...'. There are sections in the NFS-HOWTO that do a
better job of describing the effect of these options.

> >>>>    If we start using, say, retrans=3D1, does this mean that applicat=
ions can
> >>>>    recieve EIO after as little as 1 second?
> >>>
> >>> No. "timeo" controls the timeout value. "retrans" controls the number=
 of
> >>> retransmissions before a major timeout is declared.
> >>
> >> Yes, but the manpage states that EIO is reported when a major timeout
> >> occurs. So, the time until EIO must be influenced by "retrans", right?
> >
> > It is influenced by _both_. timeo sets the timeout value for a single
> > retransmission. retrans sets the number of retransmissions in a major
> > timeout.
>=20
> Ok, so with the default values of timeo=3D7 and retrans=3D3, the first ma=
jor=20
> timeout will occur after 0.7 + 1.4 + 2.8 =3D 4.9 seconds? And with soft=20
> mounts, this should return EIO to the application?
>=20
> In that case, how is it possible that I experience timeouts of 180=20
> seconds?!?

...because default retransmission timeout value for tcp is timeo=3D60.
Unlike UDP, TCP offers reliable transport, so the only times we should
need to time out and retransmit is if the server is seriously out of
resources and has to drop the request (in which case, we are better off
delaying for a longer period in order to allow the server to recover).

> >>>> * About "intr": The man page says "If an NFS file operation has a ma=
jor
> >>>>    timeout and it is hard mounted". Does "intr" affect soft mounts i=
n any
> >>>>    way, or is it better to remove it?
> >>>
> >>> Intr changes the set of signals that are able to interrupt an RPC cal=
l.
> >>> It has nothing to do with "soft".
> >>
> >> That is - it has no effect when "soft" is used?
> >
> > No. I mean that it has the same effect whether you use "soft" or "hard"=
.
> > Intr controls signals, not timeouts.
>=20
> Then again the man page wording is strange:
>=20
> "If an NFS file operation has a major timeout and it is hard mounted,"
>=20
> Shouldn't this read:
>=20
> "If an NFS file operation has a major timeout,"

It shouldn't mention major timeouts at all. The Solaris manpage
documents 'intr' as

           intr | nointr
                 Allow (do not allow) keyboard interrupts to kill
                 a  process  that  is  hung  while  waiting for a
                 response on  a  hard-mounted  file  system.  The
                 default  is  intr,  which  makes it possible for
                 clients to interrupt applications  that  may  be
                 waiting for a remote mount.

which is pretty much what we aim to do too.

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
