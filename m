From: trmcneal@comcast.net
Subject: RE: NFS sync write performance
Date: Tue, 24 Feb 2004 22:06:07 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <022420042206.18531.7c5a@comcast.net>
Cc: "Alex Wun" <alexwun@consensys.com>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Avkho-0008IH-U2
	for nfs@lists.sourceforge.net; Tue, 24 Feb 2004 14:07:08 -0800
Received: from rwcrmhc13.comcast.net ([204.127.198.39])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvkUW-0001i6-R5
	for nfs@lists.sourceforge.net; Tue, 24 Feb 2004 13:53:24 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
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

I haven't done any measurements in a long time, but I'd think the 
differential between sync and async V3 would be minor in general.
Well, with the buffer size limits, it *is* significant, and HPUX definitely
got a big boost when they (well, it was we at the time) went from 
8k to 32K buffer sizes, but its nowhere near the differential 
between sync and async V2.  Has anyone figured out some general numbers?

Regards -

Tom

--
Tom McNeal
(650)906-0761(cell)
(650)964-8459(fax)



-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
