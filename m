From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: disable caching in NFS
Date: Wed, 4 Jun 2003 14:10:19 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C6113127590@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19NfWr-0000yn-00
	for <nfs@lists.sourceforge.net>; Wed, 04 Jun 2003 14:10:41 -0700
To: "David Myer" <davidmyer800@yahoo.com>, <nfs@lists.sourceforge.net>
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

use fcntl to lock and unlock the file.
or unmount and remount.

> -----Original Message-----
> From: David Myer [mailto:davidmyer800@yahoo.com]
> Sent: Wednesday, June 04, 2003 3:06 PM
> To: nfs@lists.sourceforge.net
> Subject: [NFS] disable caching in NFS
>=20
>=20
> I am testing linux NFS client functionality. I have a
> script that vi a large file repeatively after
> mounting, how do I make sure that each time it is
> getting file from the server and not the cached
> version ?
>=20
> Thanks
> Dave
>=20
> __________________________________
> Do you Yahoo!?
> Yahoo! Calendar - Free online calendar with sync to Outlook(TM).
> http://calendar.yahoo.com
>=20
>=20
> -------------------------------------------------------
> This SF.net email is sponsored by:  Etnus, makers of=20
> TotalView, The best
> thread debugger on the planet. Designed with thread debugging features
> you've never dreamed of, try TotalView 6 free at www.etnus.com.
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20


-------------------------------------------------------
This SF.net email is sponsored by:  Etnus, makers of TotalView, The best
thread debugger on the planet. Designed with thread debugging features
you've never dreamed of, try TotalView 6 free at www.etnus.com.
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
