From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: [autofs] [PATCH/RFC 0/2] Userspace RPC proxying
Date: Tue, 8 Mar 2005 12:27:34 -0800
Message-ID: <482A3FA0050D21419C269D13989C611307CF4C14@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "linux-nfs" <nfs@lists.sourceforge.net>,
	"autofs mailing list" <autofs@linux.kernel.org>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8lIu-0002Qb-Rv
	for nfs@lists.sourceforge.net; Tue, 08 Mar 2005 12:27:44 -0800
Received: from mx1.netapp.com ([216.240.18.38])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D8lIu-0005uJ-Fm
	for nfs@lists.sourceforge.net; Tue, 08 Mar 2005 12:27:44 -0800
To: <mike@waychison.com>
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

> It's less unsafe than SO_REUSEADDR, however it completely ignores
> TIME_WAIT,  which has two purposes (according to W.R. Stevens):
>=20
> - If the client performs the active close, it allows the socket to
> remember to resend the final ACK in response to the server's FIN.=20
> Otherwise the client would respond with a RST.
>=20
> - It ensures that no re-incarnations of the same four-tuple=20
> occur within 2
> * MSL, ensuring that no packets that were lost on the network from the
> first incarnation get used as part of the new incarnation.
>=20
> Avoiding TIME_WAIT altogether keeps TCP from doing a proper=20
> full-duplex
> close and also allows old packets to screw up TCP state.

right, there are cases where proper connection close processing is
required.  and you don't need to worry much about duplicate request
caching for the services we're talking about here, so it's probably not
as critical for rpcproxyd.

> Which timeout is 5 minutes? (sparing me the trouble of finding it
myself).

the RPC client side idle timeout is 5 minutes in the reference
implementation (Solaris).

> I figured 30 for caching un-used tcp connections sounded like a good
> number as it means that if TIME_WAIT period is 2 minutes,=20
> that the most
> TIME_WAIT connections that you can have to a given remote=20
> service at any time is 4.
>=20
> A bit more thought could be had for timeouts (wishlist):
> - TCP connect()s aren't timedout. (uses EINPROGRESS, but will wait
> indefinitely, which I think is bounded by the kernel anyway).

there is a SYN retry limit controllable via sysctl for all sockets on
the system.  by default the active end tries sending SYN 6 times with
exponential backoff.  eventually the connection attempt will time out if
the remote peer doesn't respond with SYN,ACK after the last SYN is sent.
i think it's on the order of a couple of minutes.

> - UDP retransmission occurs in the proxy itself, which is currently
> hardcoded to retry 5 times, once every two seconds.  I can=20
> trivially set it up so that it gets the actual timeout values from the

> client though and use those parameters.

that should probably have exponential backoff, but it probably isn't
critical.

> > you will also need a unique connection for each=20
> program/version number
> > combination to a given server; ie you can't share a single=20
> socket among
> > different program/version numbers (even though some=20
> implementations try
> > to do this, it is a bad practice, in my opinion).
> >
>=20
> So, I know I discussed this with you last week, however I was=20
> under the
> impression that that was needed for the case where you=20
> support re-binding
> of the transport.  I'm not up to speed of who are the users of such a
> thing (I'm assuming NFSv4).

if you expect to cache these associations for a long time, you will need
to rebind every so often in case the server decides to move the service
to another port.  with UDP, anyway.

you also can't assume that all the services you need to talk to
(PORTMAP, NFS, MOUNTD, etc) will live on the same port.  for a truly
general implementation you will need to use a separate connection for
each service.

but you said "assuming NFSv4," so maybe none of this matters.  i would
hope that a connection cache would be good for any application using
RPC.

> > to support IPv6 you will need support for rpcbind versions=20
> 3 and 4; but
> > that may be an issue outside of rpcproxyd.
> >
>=20
> Okay.  I'm not so familiar with RPCB, but it is just a PMAP=20
> on steroids, right?

the later versions of the rpcbind protocol support additional operations
that allow IPv6-style information to be returned.  version 2 does not
support IPv6, as far as i know, but i'm no expert.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
