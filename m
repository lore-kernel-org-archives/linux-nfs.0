From: =?UTF-8?Q?Peter_=C3=85strand?= <astrand@cendio.se>
Subject: Re: A new NFSv4 server...
Date: Fri, 4 Jan 2008 21:03:01 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0801042030380.18738@maggie.lkpg.cendio.se>
References: <477CD231.30603@garzik.org> <20080103163200.GB30029@fieldses.org>
	<477DC501.3060104@garzik.org> <477DD11B.40909@melbourne.sgi.com>
	<477DDA86.6020100@garzik.org>
	<Pine.LNX.4.64.0801040954070.5004@maggie.lkpg.cendio.se>
	<477E61D3.4030408@garzik.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-59745507-1199475791=:18738"
Cc: NFS list <linux-nfs@vger.kernel.org>, nfsv4@linux-nfs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <477E61D3.4030408@garzik.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--789237761-59745507-1199475791=:18738
Content-Type: TEXT/PLAIN; CHARSET=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Content-ID: <Pine.LNX.4.64.0801042058241.18738@maggie.lkpg.cendio.se>


> > think v3 is a fairly good protocol, if you use it correctly. For exampl=
e,
> > many people don't realize that you don't need the portmapper, that you =
can
> > use a single well-known TCP port, that you can use RPCSEC_GSS and so fo=
rth,
> > even with v3.=20
>=20
> Absolutely...  But still, I think integrated mount protocol (aka pseudo
> filesystem namespace) and integrated locking were big steps forward. You
> really shouldn't need more than one protocol.

I don't think the mount protocol is a big problem. Either you can continue=
=20
to use the mount protocol and just have one export (/) and export all file=
=20
systems below it ("nohide"). Modern clients (such as modern Linux kernels)=
=20
will automatically create "sub mounts" when traversing and discovering new=
=20
fsids.

Or, you can get rid of the mount protocol by using WebNFS and the public=20
filehandle.=20


File locking support is harder, though.=20


> Authentication and security should be simple, tough to screw up.  I would=
 tend
> to prefer an ASCII-based authentication/security negotiation at the start=
 of a
> [SCTP|TCP] stream.
>=20
> Use TLS to give most people what they want:  AUTH_SYS with encryption. GS=
SAPI
> is fine as a "required option" but you shouldn't need GSSAPI to do simple=
 wire
> encryption between IP-authenticated hosts.

SSH is another option if you just want encryption, but my impression is=20
that AUTH_SYS is a very big problem as well.=20


> heh, tell me about it.  First I started out using rpcgen, then rewrote
> everything to do raw XDR decoding.  OPEN is huge.
>=20
> IMO, OPEN should be split into multiple operations, probably one for each
> "OPEN arm".  It's not like new opcode numbers are expensive.
>=20
> Or, hope of hopes, simplify OPEN in some other manner, like delegating ta=
sks
> to other operations.

Or perhaps aiming for something less than perfect. Remember, the perfect=20
is the enemy of the good.=20

Regards,=20
---
Peter =C3=85strand=09=09ThinLinc Chief Developer
Cendio AB=09=09http://www.cendio.se
Wallenbergs gata 4
583 30 Link=C3=B6ping=09Phone: +46-13-21 46 00
--789237761-59745507-1199475791=:18738
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
--789237761-59745507-1199475791=:18738--
