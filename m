From: seth vidal <skvidal@phy.duke.edu>
Subject: Re: Journaling FileSystems w/ NFS
Date: 20 Sep 2002 12:40:45 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1032540045.10301.8.camel@opus>
References: <Pine.LNX.4.33.0209201145290.16674-100000@node1.nacs.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature";
	boundary="=-cpMY4qeb/uvIYrGx5woA"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.phy.duke.edu ([152.3.182.2])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17sQpm-0004K7-00
	for <nfs@lists.sourceforge.net>; Fri, 20 Sep 2002 09:40:50 -0700
To: Greg Boehnlein <damin@nacs.net>
In-Reply-To: <Pine.LNX.4.33.0209201145290.16674-100000@node1.nacs.net>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>


--=-cpMY4qeb/uvIYrGx5woA
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2002-09-20 at 11:48, Greg Boehnlein wrote:
> Hello,
> 	Can someone point me to a FAQ on which is the best solution for
> running a Journalized Filesystem with NFS support under Linux? We've trie=
d
> deploying JFS with RedHat 7.3 and NFS and have run into problems. From my
> investigation, it appears that XFS is our best option for running NFS wit=
h
> +2gig file size support.
>=20

ext3 works fine and it works w/o patching your 2.4 kernel.



-sv


--=-cpMY4qeb/uvIYrGx5woA
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQA9i0+N1Aj3x2mIbMcRAvX1AKCSM5RNlWBaGjx/S26XRWaaJzzzowCgjl8A
10ojEhzhF5Uce3mBy0OLAZE=
=zzhI
-----END PGP SIGNATURE-----

--=-cpMY4qeb/uvIYrGx5woA--



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
