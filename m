From: "Phy Prabab" <phyprabab@gmail.com>
Subject: Odd log message associated with NFS
Date: Tue, 27 Mar 2007 11:40:48 -0700
Message-ID: <2fe399760703271140l703c2791oa84e9e1832487dcb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HWGbA-0002MJ-V8
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 11:40:50 -0700
Received: from wr-out-0506.google.com ([64.233.184.230])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HWGbC-0000xb-45
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 11:40:51 -0700
Received: by wr-out-0506.google.com with SMTP id i20so2650788wra
	for <nfs@lists.sourceforge.net>; Tue, 27 Mar 2007 11:40:49 -0700 (PDT)
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

Hello,

I am currently running 2.6.21-rc5 and I am seeing quite a bit of this
message in my log files:
kernel: rpcsvc: received unknown control message:-2144992132/-1

This machine is an dual dual core opteron with 3Ware 9650 (14 disk
RAID10), 4G RAM, 64bit kernel, nfsutils-1.0.12 running knfsd.  This
machine is a  file server.

I checked google and found nothing that seemed related and I ran a
ethereal looking for anything  out of the ordinary to no avail.

Any help is greatly appreciated.
TIA!
Phy

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
