From: "Heflin, Roger A." <Roger.A.Heflin@conocophillips.com>
Subject: nfs_notify_change: revalidate_failed, error=-512
Date: Tue, 11 Mar 2003 10:40:03 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5CA6F03EF05E0046AC5594562398B916A32868@POEXMB3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from usamail2.conoco.com ([12.31.208.227])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18smoC-0001by-00
	for <nfs@lists.sourceforge.net>; Tue, 11 Mar 2003 08:40:56 -0800
To: <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>



	Hello,

	I am getting the following error on the client end.

	nfs_notify_change: revalidate_failed, error=3D-512

	The client is running 2.4.21pre3 NFSALL, the servers are
	2.4.19 NFSALL, and possibly one Solaris 8 server in the mix,
	I am not able to determine exactly who is producing the error,
	it is does not appear to happen repeatably, ie I have had at
	least 4 events in the last 2 weeks spread out over several
	days.

	Any ideas on how to further debug it?   I don't think tracing
	something is dooable is it does not happen enough.

	                        Roger


-------------------------------------------------------
This SF.net email is sponsored by:Crypto Challenge is now open! 
Get cracking and register here for some mind boggling fun and 
the chance of winning an Apple iPod:
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0031en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
