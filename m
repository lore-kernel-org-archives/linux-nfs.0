From: James Pearson <james-p@moving-picture.com>
Subject: Help in using tcpdump/etherreal in gathering NFS stats
Date: Thu, 27 Jul 2006 10:53:15 +0100
Message-ID: <44C88D0B.9080602@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G6Doe-0007KL-UO
	for nfs@lists.sourceforge.net; Thu, 27 Jul 2006 14:54:48 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G63gz-0007n9-SA
	for nfs@lists.sourceforge.net; Thu, 27 Jul 2006 04:06:15 -0700
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by externalmx-1.sourceforge.net with esmtp (Exim 4.41)
	id 1G62YS-0007lE-Do
	for nfs@lists.sourceforge.net; Thu, 27 Jul 2006 02:53:21 -0700
Received: from minion.mpc.local ([172.16.11.112] helo=moving-picture.com)
	by moving-picture.com with esmtp (Exim 4.43) id 1G62YN-0003fk-2z
	for nfs@lists.sourceforge.net; Thu, 27 Jul 2006 10:53:15 +0100
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

I'm trying to work out which files on an NFS NAS (non-linux) box are 
being accessed most frequently in an effort to get a better 
understanding of some performance issues.

I'm mirroring the port that the NAS box is plugged into on a switch - so 
I can use tcpdump on a Linux box to grab the traffic to/from the NAS box.

However, my knowledge of using tcpdump and (t)ethereal is a bit limited 
- so can anyone give me some pointers to what options I should be using 
to capture information on what files are being accessed (stats and 
reads/writes)? - I'm not even sure this is possible with these tools ...

Thanks

James Pearson

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
