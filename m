From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: lockd / statd fun (sorry)
Date: Fri, 23 Apr 2004 13:32:00 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200404231332.07891.bernd-schubert@web.de>
References: <200404231137.29216.gdh@acentral.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Cc: Gavin Hamill <gdh@acentral.co.uk>,
 Chip Salzenberg <chip@debian.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BGyuh-0000Sg-Ru
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 04:32:11 -0700
Received: from smtp08.web.de ([217.72.192.226] helo=smtp.web.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BGyuh-0007SP-Id
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 04:32:11 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <200404231137.29216.gdh@acentral.co.uk>
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

=2D----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hello Gavin,

> I'm afraid I have to dredge up old ground here...
>
> I'm running about 30 diskless workstations PXE-booting to an NFS-root and
> NFS-homedir with NIS logins, and the workstations are regularly getting t=
he
> familiar
>
> Apr 23 11:17:18 10.0.0.13 kernel: nsm_mon_unmon: rpc failed, status=3D-13
> Apr 23 11:17:18 10.0.0.13 kernel: lockd: cannot monitor 10.0.0.253
> Apr 23 11:17:18 10.0.0.13 kernel: lockd: failed to monitor 10.0.0.253
> Apr 23 11:17:18 10.0.0.13 kernel: nsm_mon_unmon: rpc failed, status=3D-13
> Apr 23 11:17:18 10.0.0.13 kernel: lockd: cannot monitor 10.0.0.253
>

we also use a diskless environment and also see that problem. However, as I=
=20
posted a long time ago to this list, it only happens if the nfs-utils are=20
compiled with the '--secure-statd' confiure option.
So every time we perform a general debian (testing) -update and so when als=
o=20
the nfs-utils become updated, we see that problem. Everytime this happens, =
I=20
fetch the debian nfs-utils source and recompile them without the=20
'--secure-statd' option.

When I posted that workaround, Trond told me, that its not good, since fake=
d=20
packages can be send to the statd-daemon that way. However, for us its bett=
er=20
to have an unsecured statd running than non at all. Also, the rpc.statd=20
manpage says, that the statd can be protected by the 'tcp_wrapper library'.


Cheers,
	Bernd
=2D----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAiP6zC8BUnAF+ydYRAv6qAJ9XovApFhzLv1E7/EBUxUbstj6UbQCeKW2a
0BIpyiHKUmqYIGnvxIO0JmQ=3D
=3DDGzb
=2D----END PGP SIGNATURE-----


-------------------------------------------------------
This SF.net email is sponsored by: The Robotic Monkeys at ThinkGeek
For a limited time only, get FREE Ground shipping on all orders of $35
or more. Hurry up and shop folks, this offer expires April 30th!
http://www.thinkgeek.com/freeshipping/?cpg=12297
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
