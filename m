From: "Lever, Charles" <cel@netapp.com>
Subject: RE: [autofs] umount fails with NFS mounts
Date: Tue, 14 Sep 2004 07:11:51 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C611302B07E14@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <autofs@linux.kernel.org>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C7E2Q-0001vV-W4
	for nfs@lists.sourceforge.net; Tue, 14 Sep 2004 07:12:06 -0700
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C7E2Q-00018O-H6
	for nfs@lists.sourceforge.net; Tue, 14 Sep 2004 07:12:06 -0700
To: "Peter Astrand" <peter@cendio.se>
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

> We are using autofs for mounting home directories, but are=20
> experiencing two major problems wrt unmounting NFS mounts:
>=20
> 1) The umount command indicates that the umount succeeded,=20
> but even so,=20
> the NFS export is still mounted. This can be confirmed by looking in=20
> /etc/mtab and /proc/mounts.=20

in other words, you are able to replicate this problem without autofs
(ie, using only static mount points)?

> Any ideas? This is a major problem for us, since it's not=20
> possible to have=20
> more than 800 NFS mounts or so.=20

is there an error message in the kernel log?  you might try a few umount
commands while NFS or RPC trace debugging messages are enabled on your
client.

  sudo sysctl -w sunrpc.rpc_debug=3D32767


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM. 
Deadline: Sept. 13. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
