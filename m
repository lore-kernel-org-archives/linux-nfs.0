From: Cyril Bouthors <cyril@bouthors.org>
Subject: EXT3+NFS: random "operation not permitted" fatal errors with
 2.4.25.
Date: Wed, 31 Mar 2004 12:13:41 +0300
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <87oeqd9y62.fsf@wide.bouthors.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B8bnM-0003Kx-F8
	for nfs@lists.sourceforge.net; Wed, 31 Mar 2004 01:14:00 -0800
Received: from [62.173.237.194] (helo=wide.bouthors.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1B8bnK-0005RK-OM
	for nfs@lists.sourceforge.net; Wed, 31 Mar 2004 01:14:00 -0800
Received: from cyb by wide.bouthors.org with local (Exim 4.30)
	id 1B8bn3-0003tp-Sw
	for nfs@lists.sourceforge.net; Wed, 31 Mar 2004 12:13:41 +0300
To: nfs@lists.sourceforge.net
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

--=-=-=

Hi,

I'm getting random "Operation not permitted" fatal errors on file
operation with NFS+EXT3+DRBD+RAID0 running 2.4.25, for example:

chmod: failed to get attributes of `/home/lorenzo009/': Operation not permitted

The problem is still there when the partition is remounted using EXT2.
There's no such problem when directly accessing the partition from
localhost without NFS.

The failure can't be perfectly reproduced but it happens more often
when the NFS client and/or server have a load average of 5+.  SMP is
not used.

2.4.24 also had the same problem.

EXT3 mount options are "defaults, usrquota, noatime, noauto".

NFS mount options are "rw, nosuid, nodev, hard, intr, rsize=4096,
wsize=4096, retrans=16".

I've tried Remounting the partition soft but it's even worst.  Raising
retrans to 16 reduced the failures/access ratio.

I can't test with 2.6 (yet) because DRBD has not yet been fully
ported.

The partition has ~400GB and 7M inodes used. The NFS server is
transfering ~30Mb/s to clients on a local network.

Do you have any idea what should be done to fix those unwanted random
failure?

Please do not hesitate to ask me some more information about my setup
if needed.

Thanks.
-- 
Cyril Bouthors

--=-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBAaovFZ1SJHeqsYt8RAp9MAKCIFqXWoMOREH9+mfKtfNMUgZ7i9ACggNqQ
1DlrlByS9loH8W1OtIMj/iQ=
=7LOL
-----END PGP SIGNATURE-----
--=-=-=--


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
