From: "chen jian" <chenj@nju.edu.cn>
Subject: a serious problem about using NFS as FTP SERVER
Date: Sun, 9 Jan 2005 13:06:55 +0800
Message-ID: <200501090506.j0956tMx021492@mail2.nju.edu.cn>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="gb2312"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CnVIE-0005Y9-ME
	for nfs@lists.sourceforge.net; Sat, 08 Jan 2005 21:07:10 -0800
Received: from mail2.nju.edu.cn ([202.119.32.137])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CnVIB-0005br-Kt
	for nfs@lists.sourceforge.net; Sat, 08 Jan 2005 21:07:10 -0800
Received: from nic76 (nic172.nju.edu.cn [202.119.32.172])
	by mail2.nju.edu.cn (8.13.2/8.13.2) with SMTP id j0956tMx021492
	for <nfs@lists.sourceforge.net>; Sun, 9 Jan 2005 13:06:55 +0800
To: "nfs" <nfs@lists.sourceforge.net>
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

I meet a serious problem about using NFS as FTP SERVER.
  I use Linux box as a FTP SERVER, the shared directory is a NFS mounted directory from a AIX NFS SERVER.
when the total number of ftp users above 20 or 30, ftp LIST become very slow, you must wait 30 seconds or 
even more to list the NFS mounted directory's content.
  Linux kernel is 2.6.9, NFS version is 3, AIX version is 5.2.0, I have tried many methods I could think 
about,such as tune wsize,rsize,using TCP instead of UDP, but have no improve.
  Does anyone can help me?



-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
