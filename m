From: Michael Buesch <fsdeveloper@yahoo.de>
Subject: Re: processes stuck in D state
Date: Tue, 6 May 2003 17:41:50 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200305061742.14032.fsdeveloper@yahoo.de>
References: <200305061652.13280.fsdeveloper@yahoo.de> <shsel3c85ks.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Cc: neilb@cse.unsw.edu.au,
 nfs@lists.sourceforge.net,
 "Lever, Charles" <Charles.Lever@netapp.com>,
 linux kernel mailing list <linux-kernel@vger.kernel.org>,
 Zeev Fisher <Zeev.Fisher@il.marvell.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smtp018.mail.yahoo.com ([216.136.174.115])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19D4ak-0005vh-00
	for <nfs@lists.sourceforge.net>; Tue, 06 May 2003 08:42:54 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shsel3c85ks.fsf@charged.uio.no>
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

On Tuesday 06 May 2003 17:20, Trond Myklebust wrote:
> >>>>> " " =3D=3D Michael Buesch <fsdeveloper@yahoo.de> writes:
>      > Hi!  Please take a look at this problem:
>      >
>      > [linux-kernel-mailing-list thread]
>      > http://marc.theaimsgroup.com/?t=3D98639966100003&r=3D1&w=3D2
>
> If I can hazard a guess: someone is firewalling the lockd port and/or
> the statd port.
>
> Either mount using the 'nolock' option, or fix the firewall (see the
> HOWTO and/or FAQ).

To reproduce the problem:
=2D - mount some nfs from a server in your lan.
=2D - Open an app, that uses the mounted fs. I've simply opened a
  konqueror-window for the directory where the nfs is mounted.
=2D - shut down or crash the server or just pull the network-cable.
=2D - Now the konqueror-process is nonkillable in D state. There's no
  chance to kill it.

I've tried it with all firewalls disabled, but the problem resists.

> Cheers,
>   Trond

@linux-kernel-mailing-list: I've posted a thread to nfs-mailing list with
the same topic as in lkml. IMHO this is the better list for this problem. :)

=2D --=20
Regards Michael B=FCsch
http://www.8ung.at/tuxsoft
 17:34:35 up  1:26,  5 users,  load average: 1.52, 1.32, 1.13
=2D----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQE+t9fWoxoigfggmSgRAvrcAJ4i+i3V+kcRd+kLHS7cb2WDZDHKsQCfWljd
rwtAFK4ONkJHzVck03t7F5U=3D
=3DgHuP
=2D----END PGP SIGNATURE-----



-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
