From: "Heflin, Roger A." <Roger.A.Heflin@conocophillips.com>
Subject: RE: NFS configuration question
Date: Wed, 7 May 2003 08:57:54 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5CA6F03EF05E0046AC5594562398B916A3291C@POEXMB3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mailman1.ppco.com ([138.32.33.10])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19DPRU-0003KT-00
	for <nfs@lists.sourceforge.net>; Wed, 07 May 2003 06:58:44 -0700
Received: from bvltrendl.conoco.net ([172.19.28.43])
	by mailman1.ppco.com (8.12.8/8.12.8) with SMTP id h47DweI7023448
	for <nfs@lists.sourceforge.net>; Wed, 7 May 2003 08:58:40 -0500
Received: from hoexbh1.conoco.net (HOEXBH1.conoco.net [144.46.83.11])
	by mail1.ppco.com (8.11.6+Sun/8.11.6) with ESMTP id h47Dwcu07769
	for <nfs@lists.sourceforge.net>; Wed, 7 May 2003 08:58:39 -0500 (CDT)
To: <nfs@lists.sourceforge.net>
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




> Message: 3
> Date: Tue, 06 May 2003 18:53:20 -0400
> From: Tim Pickard <tpickard@crossref.org>
> To: nfs@lists.sourceforge.net
> Subject: [NFS] NFS configuration question
>=20
> I have 3 RedHat8 machines that share a common directory via NFS.
>=20
> The issue is processes on machines B and C do not get a complete file =
from
> the shared directory on A.
>=20
> As an example, tail -f file X on B or C.  Cat data to file X on A.  =
The
> process tail does not catch the change.
>=20
> Directory is exported with following options:
> (rw,insecure,sync,no_root_squash)
>=20
> What am I missing or misconfigured?
>=20
> Tim Pickard
> Systems Support Analyst and Administrator
> 40 Salem Street
> Lynnfield, MA  01940
> p.781-295-0072
> f.781-295-0077
> tpickard@crossref.org
>=20
>=20
	which are you using?

	cat > X           <-- If you are using this the file inode will change, =
and tail will
	still be following the old file's inode.  There is an option on tail to =
make
	it follow the filename on a inode change.

	or=20

	cat >> X

	Typically I do see tail -f working on one node when another puts the =
stuff
	in the file, it just takes a while (some number of seconds) before the =
second
	node sees it, so long as the one node is always the same node, and =
assuming
	that the file additions are not happening too fast.

	You will get in the least trouble if neither of the reading nodes are =
writing
	to the file, if node A writes to the file (every other block), and node =
B writes
	to the blocks that A did not, A will think the B blocks are blank and B =
will
	think the A blocks are blank, because they have in their cache what =
they
	think they wrote, this also requires A & B to be doing the writing at =
the
	same time, and to stop writing within <1second of each other, if the =
file
	attributes change (date, time, size) and the file is reopened then the
	cache will be invalidated because the attributes it has cached don't
	match so someone must have changed the file.

	You will get in trouble if your are expecting several nodes to be able =
to add
	stuff to that file and get it all, some nodes will overwrite other =
nodes and=20
	there is no easy way with nfs to prevent this, it all depends on the =
above
	timing, and is mostly a linux cache and file attribute resolution =
issue, it
	would be much more difficult to happen if the attribute times had =
higher
	resolution, since it would be much harder for two nodes to stop at the
	same time when you are timing in milli or micro seconds.  It is pretty=20
	easy to stop at the same time when you are using seconds.


	                                  Roger




-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
