From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: full mount options
Date: Sun, 30 May 2004 15:02:27 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C61130435E1A1@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BUYO9-0004wz-Sx
	for nfs@lists.sourceforge.net; Sun, 30 May 2004 15:02:41 -0700
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BUYO9-0002cl-K9
	for nfs@lists.sourceforge.net; Sun, 30 May 2004 15:02:41 -0700
To: "Phy Prabab" <phyprabab@yahoo.com>
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

cat /proc/mounts

usually shows a more complete listing of NFS mount options than the
mount command does.

> -----Original Message-----
> From: Phy Prabab [mailto:phyprabab@yahoo.com]=20
> Sent: Sunday, May 30, 2004 1:18 PM
> To: nfs@lists.sourceforge.net
> Subject: [NFS] full mount options
>=20
>=20
> Is there a way to show the complete mount options a
> particular mount is using.  The mount command just
> shows the options I chose to use, however, if I choose
> no option, then what did the kernel decide to use
> (i.e. nfsv3, rsize, wsize,etc).
>=20
> Thank you for your time.
> Phy
>=20
>=20
> =09
> 	=09
> __________________________________
> Do you Yahoo!?
> Friends.  Fun.  Try the all-new Yahoo! Messenger.=20
http://messenger.yahoo.com/=20


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g.

Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3D3149&alloc_id=3D8166&op=3Dclick
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
