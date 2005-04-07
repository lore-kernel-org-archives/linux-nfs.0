From: Vasiliy Boulytchev <vasiliy@lohankin.com>
Subject: NFS experince story, questions.
Date: Thu, 07 Apr 2005 11:14:41 -0600
Message-ID: <1112894081.6230.9.camel@vasiliy.coinfotech.com>
Reply-To: vasiliy@lohankin.com
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DJaad-0007Dg-Lh
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 10:14:47 -0700
Received: from mail.mailsvc.com ([63.247.192.101] helo=mailsvc.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DJaad-00037e-1x
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 10:14:47 -0700
Received: from [63.247.192.30] (HELO [10.0.0.137])
  by mailsvc.com (CommuniGate Pro SMTP 4.2)
  with ESMTP id 184207671 for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 11:14:41 -0600
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


Ladies and Gents,
	In my previous experience, I have never had good luck with NFS.  We
used NFS to balance mail server queues (for spam and virus filtering)
between scanning nodes, and we ran into tons of problems, probably due
to lack of complete understanding and proper configuration on my part.
The performance was great, however, we kept getting stale mounts, and to
get things back, both sides needed to be rebooted, I could not just
unmount.  Maybe we were not mounting properly, but who knows.  Anyways,
as an alternative we looked into samba, and that solved all our issues.
We still run samba as the networking protocol, and are happy with it.

	A new task has come up, and we are looking back at NFS, since samba
really does not allow us to have proper user arrangements.  I really am
afraid of having stale mounts again.  Is this a common newbie problem,
or is this the nature of NFS?  When either of the nodes becomes
unstable, has to reboot, (or a failover occurs), does this mean the
other node will have a stale mount point and will need a reboot?

	Please assure me that this is not the case, and I can safely go on
experimenting.  What is the latest material I should get?  Any good
O'reilly books come to mind?

	Thanks for paying attention.

-- 
-------------
Vasiliy Boulytchev
Colorado Information Technologies Inc.
http://www.coinfotech.com



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
