From: =?iso-8859-1?Q?Peter_=C5strand?= <astrand@lysator.liu.se>
Subject: NFS configuration question
Date: Wed, 7 May 2003 08:48:13 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0305070846120.6092-100000@aristocat.lysator.liu.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from aristocat.lysator.liu.se ([130.236.254.84])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19DIiw-0003FO-00
	for <nfs@lists.sourceforge.net>; Tue, 06 May 2003 23:48:18 -0700
Received: from localhost (astrand@localhost)
	by aristocat.lysator.liu.se (8.11.6/8.11.6) with ESMTP id h476mEj06119
	for <nfs@lists.sourceforge.net>; Wed, 7 May 2003 08:48:14 +0200
To: nfs@lists.sourceforge.net
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



>The issue is processes on machines B and C do not get a complete file
>from the shared directory on A.

>As an example, tail -f file X on B or C.  Cat data to file X on A.
>The process tail does not catch the change.

You might want to try "tail --follow=3Dname".=20

--=20
/Peter =C5strand <altic@lysator.liu.se>




-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
