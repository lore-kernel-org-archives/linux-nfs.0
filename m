From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: how experimental is the seekdir patch
Date: Mon, 28 Apr 2003 18:34:33 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E07D55592@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19AK12-0006IR-00
	for <nfs@lists.sourceforge.net>; Mon, 28 Apr 2003 18:34:40 -0700
To: "Steve M. Robbins" <steven.robbins@videotron.ca>
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

hi steve-

> I was having problems with mounting a filesystem exported by=20
> an IRIX server that appear to be fixed by the "seekdir.dif"=20
> patch located at
>=20
>    http://www.fys.uio.no/~trondmy/src/2.4.21-pre6/
>
> According to the NFS FAQ, this problem has been known since
> 2.4.17. Yet the patch does not appear in the 2.4.21-rc1 kernel.
> Why not?

the seekdir patch is provided because the real cause of the
problem (a bug in glibc) has not been addressed.  the seekdir
patch will never appear in a stock Linux kernel, although the
patch is applied in Red Hat Linux, so it is well-tested.


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
