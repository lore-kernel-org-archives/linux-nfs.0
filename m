From: Tobias Diedrich <ranma@gmx.at>
Subject: Re: RPC timeout errors
Date: Mon, 11 Nov 2002 11:42:10 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021111104210.GA2248@melchior.ranmachan.dyndns.org>
References: <02111100215404.06294@192.168.0.254> <200211110040.03963.avatar@dcr.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="M9NhX3UHpAaciwkO"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx.stud.uni-hannover.de ([130.75.176.3] helo=studserv.stud.uni-hannover.de)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18BCEg-00061C-00
	for <nfs@lists.sourceforge.net>; Mon, 11 Nov 2002 02:56:06 -0800
Received: from melchior.ranmachan.dyndns.org (a118.home.uni-hannover.de [130.75.232.118])
	by studserv.stud.uni-hannover.de (8.12.6/8.12.6/MX/check_local5.5) with ESMTP id gABAqIa2008276
	for <nfs@lists.sourceforge.net>; Mon, 11 Nov 2002 11:55:55 +0100 (MET)
Received: from ranma by melchior.ranmachan.dyndns.org with local (Exim 3.35 #1 (Debian))
	id 18BC1D-0000ci-00
	for <nfs@lists.sourceforge.net>; Mon, 11 Nov 2002 11:42:11 +0100
To: nfs@lists.sourceforge.net
In-Reply-To: <200211110040.03963.avatar@dcr.net>
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


--M9NhX3UHpAaciwkO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Donavan Pantke wrote:

> I've run into this before, and the problem is that the mount
> daemon is trying to reverse and forward resolve that IP address.
> If you dumped the client and server either in a DNS server or in
> the /etc/hosts file you should see an instanteanous mount.

Interesting.
We have ~80 nfs clients and since adding the last 30 we got the problem
that when a lot of users are using the system we often get "RPC: timed
out" on a lot of machines, but in the server lot nothing looks wrong.
Maybe I should try setting up an additional nameserver on the nfs server
because the machine currently running the nameserver is an old sun
ultra1 enterprise...
We also experienced a weird problem where after everything was running
fine for a few days the server would refuse mounts to some clients with
"getfh failed" and you'd have to exportfs -rav to get it working
again...

--=20
Tobias								PGP: 0x9AC7E0BC
This mail is made of 100% recycled bits

--M9NhX3UHpAaciwkO
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQE9z4mC5q/seprH4LwRAg+bAJ91xIsDgk4IC2rW3anYN+qPTPXHWwCgh86q
YDVX8o4h6OD+JCmjlydtUgk=
=wi6q
-----END PGP SIGNATURE-----

--M9NhX3UHpAaciwkO--


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
