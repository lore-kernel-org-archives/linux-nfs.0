From: =?iso-8859-1?Q?Brasseur_Val=E9ry?= <Valery.Brasseur@atosorigin.com>
Subject: linus 2.4.20 nfs performance problem
Date: Tue, 16 Mar 2004 12:35:15 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <8147E1B07201DD41B6B9F0D31E07B38401648904@srv-grp-s07.dev.atos.fr>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B3Cr2-0001TJ-RP
	for nfs@lists.sourceforge.net; Tue, 16 Mar 2004 03:35:28 -0800
Received: from srv-grp-s01.axime.com ([160.92.18.102])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1B3Cqz-0006Sw-7b
	for nfs@lists.sourceforge.net; Tue, 16 Mar 2004 03:35:25 -0800
To: <Charles.Lever@netapp.com>
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

I have a config where LInux machines (bi Xeon 2.4Ghz 2Gb memory, kernel =
2.4.20 + trond patch) are accessing a Netapp 810 (or 825)

there is a lot of process (#400) =20
when in load a lots of process are in D state, the filer are around 5000 =
nfsops and the network is near 50 mbit/s for each machine

the machine and the filer are connect by a switch, machines are at 100mb =
and filer is at 1Gb

the cpu on the machines are near &=E0% and load average is near 100 or =
more


I don't know where is the bottleneck...=20

is somebody can help me ?


thanks in advance
valery



-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
