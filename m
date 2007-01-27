From: Jan Engelhardt <jengelh@linux01.gwdg.de>
Subject: File monitoring
Date: Sat, 27 Jan 2007 21:31:42 +0100 (MET)
Message-ID: <Pine.LNX.4.61.0701272123470.22295@yvahk01.tjqt.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HAuD7-0002sL-1G
	for nfs@lists.sourceforge.net; Sat, 27 Jan 2007 12:31:41 -0800
Received: from tmailer.gwdg.de ([134.76.10.23])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HAuD8-00011X-L1
	for nfs@lists.sourceforge.net; Sat, 27 Jan 2007 12:31:43 -0800
Received: from linux01.gwdg.de ([134.76.13.21])
	by mailer.gwdg.de with esmtps (TLSv1:AES256-SHA:256) (Exim 4.63)
	(envelope-from <jengelh@linux01.gwdg.de>) id 1HAuD6-0003Qp-Vc
	for nfs@lists.sourceforge.net; Sat, 27 Jan 2007 21:31:41 +0100
Received: from linux01.gwdg.de (localhost [127.0.0.1])
	by linux01.gwdg.de (8.13.3/8.13.3/SuSE Linux 0.7) with ESMTP id
	l0RKVgoc029989
	for <nfs@lists.sourceforge.net>; Sat, 27 Jan 2007 21:31:44 +0100
Received: from localhost (jengelh@localhost)
	by linux01.gwdg.de (8.13.3/8.13.3/Submit) with ESMTP id l0RKVgk3029983
	for <nfs@lists.sourceforge.net>; Sat, 27 Jan 2007 21:31:42 +0100
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

Hello list,


as part of implementing a netboot solution, I observe that the client 
pulls about 128 MB of data (measured in iptraf, so it includes 
IPv4 headers too). You probably agree that this contributes to a boot 
that could possibly be sped up (even if the same distribution was to 
read from local disk). I wonder what files it actually accesses. Is 
there some utility to get a listing of all the files that were accessed? 
tcpdump provides a nice hint, e.g.

21:29:09.877364 IP 192.168.222.34.3204330825 > 192.168.222.1.2049: 116 
lookup fh 
Unknown/0100000100160005118A180EF8B50D0D000000000000001068616C2D6765742D  
"hal-get-property"

But at best I'd like to have the full pathname (to distinguish the 
fictional case /bin/cat vs /usr/bin/cat)


	-`J'
-- 

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
