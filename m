From: przemyslaw_sowa@o2.pl
Subject: =?iso-8859-2?q?NFSv3_and_SYNC_option?=
Date: Mon, 17 Jul 2006 11:11:37 +0200
Message-ID: <20060717091137.62C9221400D@rekin14.go2.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G2P8g-0000rG-SU
	for nfs@lists.sourceforge.net; Mon, 17 Jul 2006 02:11:43 -0700
Received: from rekin14.go2.pl ([193.17.41.35])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G2P8e-0001Hj-Ul
	for nfs@lists.sourceforge.net; Mon, 17 Jul 2006 02:11:43 -0700
Received: from poczta.o2.pl (rekin [127.0.0.1])
	by rekin14.go2.pl (o2.pl Mailer 2.0.1) with ESMTP id 62C9221400D
	for <nfs@lists.sourceforge.net>; Mon, 17 Jul 2006 11:11:37 +0200 (CEST)
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

Hello,

I'd like to know if the "sync" option in /etc/exports makes NFSv3 works
like NFSv2? I mean if it then always waits for the data to be written to
the drive before sending reply?

If not, is there any way to guarantee stable storage on the server (v3)
side (ex. client can mount with the async option)?

Regards,
Przemyslaw Sowa



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
