From: "Phillip Huang" <phuang@plasmon.cn>
Subject: CentOS4.4 support NFSv4 Replication and Migration
Date: Thu, 12 Apr 2007 11:18:37 +0800
Message-ID: <003801c77cb1$42e77870$207ba8c0@barcelona>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1962546473=="
To: <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hbt7J-0006c9-Aj
	for nfs@lists.sourceforge.net; Wed, 11 Apr 2007 23:49:13 -0700
Received: from [211.97.48.10] (helo=zh.plasmon.cn)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hbt7I-0007ol-Pl
	for nfs@lists.sourceforge.net; Wed, 11 Apr 2007 23:49:15 -0700
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

--===============1962546473==
Content-Type: text/plain; format=flowed; charset="gb2312"; reply-type=original
Content-Transfer-Encoding: 7bit

Hi all,

I have rebuild CentOS4.4 kernel with 2.6.20,
and its original nfs-util is 1.0.6.

Does this support NFSv4/replication and migration?

If support, how could I configure it?

PS: I google for some entries, and I try the following.
/export 
*(rw,fsid=0,insecure,no_subtree_check,replica="/@192.168.123.63")
It failed in my OS.


Thansk and regards,
Phillip 



--===============1962546473==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============1962546473==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1962546473==--
