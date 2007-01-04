From: "Ingmar" <i2a@gmx.net>
Subject: NFS file .lock problem?
Date: Thu, 4 Jan 2007 19:25:01 +0100
Message-ID: <20070104181136.M28899@quicknet.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H2XH9-0002g8-77
	for nfs@lists.sourceforge.net; Thu, 04 Jan 2007 10:25:15 -0800
Received: from mx102.multikabel.net ([212.127.254.140])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H2XH9-00010l-Hm
	for nfs@lists.sourceforge.net; Thu, 04 Jan 2007 10:25:16 -0800
Received: from vmx60.multikabel.net ([212.127.254.141])
	by mx102.multikabel.net with esmtp (Exim 4.54) id 1H2XH1-0007db-Ib
	for nfs@lists.sourceforge.net; Thu, 04 Jan 2007 19:25:07 +0100
Received: from www.malloc.nl (84-104-186-89.cable.quicknet.nl [84.104.186.89])
	by vmx60.multikabel.net (8.13.7/8.13.3) with ESMTP id l04IP0JX021620
	for <nfs@lists.sourceforge.net>; Thu, 4 Jan 2007 19:25:07 +0100
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

Hi All,

I am having a problem with the Openoffice.org suite and am guessing it has something to do
with NFS.

I am using NFS to mount my home dir, and Writer it will hang as soon as you (for example)
remove the ruler check from the document interface.

When using another account with an local/"on disk" home dir there is no problem.

Something similar occurs with aMule, it is unable to write a lock file.

Are there any special options needed by NFS to export or mount the directory.

My current export and mount lines are:

/* /etc/exports */
/home/i2a          192.168.0.21(rw,sync)

/* /etc/fstab */
192.168.0.254:/home/i2a  /home/i2a  nfs  rw,retrans=3,intr,noac


Thanks and regards,
  Ingmar

-------------------------------------------------------------------------------
unfair competition, n.:
	Selling cheaper than we do.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
