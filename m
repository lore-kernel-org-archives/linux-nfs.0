From: Ming Zhang <blackmagic02881@gmail.com>
Subject: question about fh_copy
Date: Sat, 27 Jan 2007 10:20:08 -0500
Message-ID: <1169911208.2767.15.camel@localhost.localdomain>
Reply-To: blackmagic02881@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HApLh-0001pl-2E
	for nfs@lists.sourceforge.net; Sat, 27 Jan 2007 07:20:13 -0800
Received: from wx-out-0506.google.com ([66.249.82.237])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HApLh-0000Ur-MG
	for nfs@lists.sourceforge.net; Sat, 27 Jan 2007 07:20:14 -0800
Received: by wx-out-0506.google.com with SMTP id i30so1817317wxd
	for <nfs@lists.sourceforge.net>; Sat, 27 Jan 2007 07:20:09 -0800 (PST)
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

Hi All

A question about fh_copy(). This function is called many times on
argument passed directly from nfs clients. If a malicious nfs client
forge a fh, then fh_copy can invoke oops quite easily. shall we always
call fh_verify before call fh_copy? Thanks!

Ming

-- 
http://blackmagic02881.wordpress.com/


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
