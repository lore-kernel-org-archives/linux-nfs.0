From: "Brian Taber" <btaber@diversecg.com>
Subject: NFSv4 client hang: setclientid: string in use by client
Date: Tue, 13 Mar 2007 01:48:02 -0400 (EDT)
Message-ID: <50600.71.162.89.56.1173764882.squirrel@mail.diversecg.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HSeJe-0007sw-OT
	for nfs@lists.sourceforge.net; Sat, 17 Mar 2007 12:11:47 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HSeJf-0005Op-Pe
	for nfs@lists.sourceforge.net; Sat, 17 Mar 2007 12:11:49 -0700
Received: from mail.diversecg.com ([66.151.188.102])
	by externalmx-1.sourceforge.net with esmtp (Exim 4.41)
	id 1HSeJd-00033n-9n
	for nfs@lists.sourceforge.net; Sat, 17 Mar 2007 11:11:46 -0800
Received: from mail.diversecg.com (localhost.localdomain [127.0.0.1])
	by mail.diversecg.com (Postfix) with ESMTP id E7D5C69EB4
	for <nfs@lists.sourceforge.net>; Tue, 13 Mar 2007 01:48:02 -0400 (EDT)
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

I have been unable to solve this problem.  I have a server running kernel 
2.6.16 (FC5) that is sharing the data.  The client connecting is kernel
2.6.17 (FC5).  The mount is a NFSv4 mount with read/write permissions. 
Initially everything works fine, I am able to work reading a writing info
no problem.  Then all of the sudden, the client will hang working with the
share.  If I look at the server logs I see this:

kernel: NFSD: setclientid: string in use by client(clientid
45f63261/00000005)

an I can not do anything except reboot the client to get it working again
(unmounting, stopping netfs, restarting nfs on the server, nothing works)

Can anyone help me out?  I decoded the client ip and it is an address that
is not even on my network...


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
