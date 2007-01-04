From: "Brian J. Murrell" <brian@interlinx.bc.ca>
Subject: trying to unload nfsd
Date: Thu, 04 Jan 2007 15:06:48 -0500
Message-ID: <1167941208.18576.28.camel@pc.ilinx>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0836225447=="
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H2YrY-0006do-BI
	for nfs@lists.sourceforge.net; Thu, 04 Jan 2007 12:06:56 -0800
Received: from linux.interlinx.bc.ca ([66.11.173.224])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H2YrY-0007cD-M7
	for nfs@lists.sourceforge.net; Thu, 04 Jan 2007 12:06:58 -0800
Received: from [10.75.22.1] (pc.ilinx [10.75.22.1])
	(using TLSv1 with cipher RC4-MD5 (128/128 bits))
	(No client certificate requested)
	by linux.interlinx.bc.ca (Postfix) with ESMTP id B1D94F678D
	for <nfs@lists.sourceforge.net>; Thu,  4 Jan 2007 15:06:49 -0500 (EST)
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


--===============0836225447==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="=-202ZMeCXhi49rCURbB8Y"


--=-202ZMeCXhi49rCURbB8Y
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

I have umounted all of my nfs filesystems and stopped the nfs services.
I still can't unload the nfsd module:

$ sudo /sbin/lsmod | grep nfsd
nfsd                  277152  4=20
exportfs                7680  1 nfsd
lockd                  77616  1 nfsd
nfs_acl                 5120  1 nfsd
sunrpc                174840  7 nfsd,lockd,nfs_acl

The only thing I can see that could be pinning it still is:

$ grep nfs /proc/mounts
sunrpc /var/lib/nfs/rpc_pipefs rpc_pipefs rw 0 0

But I can't seem to umount that:

$ sudo umount /var/lib/nfs/rpc_pipefs
umount: /var/lib/nfs/rpc_pipefs: device is busy
umount: /var/lib/nfs/rpc_pipefs: device is busy

What could be pinning that fs/mount-point?

b.

--=20
My other computer is your Microsoft Windows server.

Brian J. Murrell

--=-202ZMeCXhi49rCURbB8Y
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBFnV5Yl3EQlGLyuXARApVXAJ0UfvYK/qJowGfa1WSqd8j7iAmWXwCfe4cO
5MUNtWim5K7uWvUi7cSkbhY=
=2d2G
-----END PGP SIGNATURE-----

--=-202ZMeCXhi49rCURbB8Y--



--===============0836225447==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============0836225447==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0836225447==--
