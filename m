From: Cajus Pollmeier <c.pollmeier@gmx.net>
Subject: Re: NFS problems, UMON, missing directories, wrong permissions
Date: Tue, 6 May 2003 15:36:42 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200305061536.45140.c.pollmeier@gmx.net>
References: <200305061042.02405.c.pollmeier@gmx.net> <shsr87c70t3.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dns-2.dinet.de ([212.8.6.1] helo=mail-2.dinet.de)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19D2co-0002nD-00
	for <nfs@lists.sourceforge.net>; Tue, 06 May 2003 06:36:54 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shsr87c70t3.fsf@charged.uio.no>
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

=2D----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Am Dienstag, 6. Mai 2003 13:48 schrieb Trond Myklebust:
> >>>>> " " =3D=3D Cajus Pollmeier <c.pollmeier@gmx.net> writes:
>      > * Randomly missing directories / shredded permissions
>      >   Either users don't see shared directories contents or have no
>      >   permissions to access them. In fact they have, "id" shows up
>      >   with the correct group membership and "ls -la" shows the
>      >   directory group writable. After logging out and in again,
>      >   everything's fine.
>
> Please note that NFS doesn't support more than 16 groups. If the
> permissions depend on the 17th group as listed by 'id', then it
> probably won't work.

Hi Trond,

thanks for the quick response...
I didn't know that group membership is limited to 16 when using
nfs. Just checked one user affected by this, he's in 18 groups...

> However that may not be the cause of your problem:
>      >   May 6 07:12:59 terminalserver kernel: nsm:
>      >   xdr_encode_mon(0a010002, -1249509120, 67108864, 268435456)
>
> That's interesting. Looks like a pretty nasty stack corruption to
> me. Are you running an Nvidia-tainted kernel by any chance?

Beware. Its a server :-)

=2D --<some merging>--

> Duh. Forget that... For some reason or another xdr_encode_mon() has
> been set up to print its arguments using network-order (and in
> decimal). That's almost worth a bugfix in itself...
>=20
> OK. The bug appears to be in userland then, since the UNMON request is
> correct, and the /var/lib/nfs/sm does contain the 10.0.0.2 address.

So if the above is not the only problem, I can compile a newer set of=20
nfs-utils to check if I run in problems with them.

Again - thanks,
Cajus
=2D----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQE+t7pqtyibJ/7Y+CYRAk9dAJsH4lm5I2/GEpITvVgS+Uao1Uw7/gCgkj/S
x/9g/Rhlyogh3NA+p7EN7b0=3D
=3DLcxb
=2D----END PGP SIGNATURE-----



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
