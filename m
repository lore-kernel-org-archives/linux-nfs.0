From: Vincent ROQUETA <vincent.roqueta@ext.bull.net>
Subject: Re: Wrong file size (large file problem)
Date: Fri, 13 Feb 2004 17:17:34 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200402131717.34182.vincent.roqueta@ext.bull.net>
References: <Pine.LNX.4.44.0402131420000.13346-100000@kakadu.cosy.sbg.ac.at>
Reply-To: vincent.roqueta@ext.bull.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Arg0P-0000V2-0Q
	for nfs@lists.sourceforge.net; Fri, 13 Feb 2004 08:17:29 -0800
Received: from ecbull20.frec.bull.fr ([129.183.4.3])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1ArfvZ-0005FK-SE
	for nfs@lists.sourceforge.net; Fri, 13 Feb 2004 08:12:30 -0800
To: Gerald Stieglbauer <gstiegl@cosy.sbg.ac.at>
In-Reply-To: <Pine.LNX.4.44.0402131420000.13346-100000@kakadu.cosy.sbg.ac.at>
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

Le Vendredi 13 F=E9vrier 2004 14:21, Gerald Stieglbauer a =E9crit :
> Hello,
>
> I have some strange problems with large files on Client side. In the
> concrete case, a file with a size of 4504526848 Bytes lies on my server
> (kernel 2.4.24). If I mount the directory with this file via nfs, the
> client (kernel 2.4.24) informs me that the file size is only 209559552
> Bytes. For "debugging" I copied the file and watch the grow of the file
> size during the copy job on both machines. Nothing suspicious happens unt=
il
> the file size reached a level of about 4300000000 Bytes. The the client
> began counting from 0 Bytes up to the 209559552; some form of overflow. On
> the server side, nothing went wrong.
> On a previous posting (http://sourceforge.net/mailarchive/
> forum.php?thread_id=3D3874012&forum_id=3D4930) Vincent ROQUETA reports
> problems with files that exceeds 4294967294 Bytes. Is there may be the sa=
me
> underlying problem? BTW: 4294967294 + 209559552 =3D 4504526846 -> this is
> very, very close to 4504526848; so can this be only luck?
>
> Thanks!
>
> cu,
> Gerald.


Well... In my bug, the size of the big file is not  4294967294, that is the=
=20
=2E.. user name and group name (Really stranges too... !!! )
I don't rember the size of my file, I know it was a little more than 2Go.

Vincent



-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
