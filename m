From: =?ISO-8859-1?Q?Rainer_Sch=F6pf?= <rainer.schoepf@proteosys.com>
Subject: NFS client problem: reading from zero length file
Date: Tue, 6 Sep 2005 15:47:01 +0200 (CEST)
Message-ID: <Pine.LNX.4.63.0509061510040.29150@bk-ws-11.proteosys>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: =?ISO-8859-1?Q?Rainer_Sch=F6pf?= <rainer.schoepf@proteosys.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ECdnE-0003nL-6H
	for nfs@lists.sourceforge.net; Tue, 06 Sep 2005 06:47:20 -0700
Received: from mail.proteosys.com ([213.139.130.197])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ECdnC-0005B6-ME
	for nfs@lists.sourceforge.net; Tue, 06 Sep 2005 06:47:20 -0700
Received: by mail.proteosys.com (8.12.10/8.12.2) with ESMTP id j86Dl1Ia032700
	for <nfs@lists.sourceforge.net>; Tue, 6 Sep 2005 15:47:02 +0200
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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

Hello,

I've encountered a strange problem on an NFS client: after an open system=
=20
call like

32036 open("result/PI_002_exp_003_pH_4-5.tif.s", O_RDWR|O_CREAT|O_TRUNC, =
0666) =3D 29

an immediately following read returns=20

32036 read(29, "abcdefgh", 8)                   =3D 8

As far as I know, this shouldn't happen, because of the O_TRUNC flag in=20
the open call.

I'm afraid this is the only pattern I've been able to isolate. This=20
happens when we run a complicated image analysis software, but only=20
occasionally, every couple of days, not systematically. If it happens,=20
repeated runs exhibit the problem (most of the time). umount/mount makes=20
it disappear.

A simple program that repeatedly opens a file and reads from it failed to=
=20
show the problem.

This is a Suse 9.3 system with kernel 2.6.11.4-21.8 (in Suse's=20
versioning).

The behaviour described above looks like some race condition to me.=20
I looked through the list of patches to the nfs client code on=20
www.linux-nfs.org, but am not sure how to proceed.

I'd be happy to try a patch if someone would suggest which one.

Thanks in advance
  Rainer Sch=F6pf


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
