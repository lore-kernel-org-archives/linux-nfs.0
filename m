From: "Greg Bradner" <greg.bradner@gmail.com>
Subject: lockd and statd
Date: Wed, 4 Apr 2007 00:11:22 -0700
Message-ID: <57bc13580704040011u3058e6d9wd0d4fc0de63d4d93@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HYzeO-0001xO-HN
	for nfs@lists.sourceforge.net; Wed, 04 Apr 2007 00:11:24 -0700
Received: from ug-out-1314.google.com ([66.249.92.172])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HYzeP-0006iP-2U
	for nfs@lists.sourceforge.net; Wed, 04 Apr 2007 00:11:26 -0700
Received: by ug-out-1314.google.com with SMTP id z38so616993ugc
	for <nfs@lists.sourceforge.net>; Wed, 04 Apr 2007 00:11:24 -0700 (PDT)
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

I'm getting these errors in the syslog:
Apr  4 00:08:53 fbs2 kernel: statd: server localhost not responding, timed out
Apr  4 00:08:53 fbs2 kernel: lockd: cannot monitor fnas2
Apr  4 00:08:53 fbs2 kernel: lockd: failed to monitor fnas2


I'm using the 2.6.20.4 kernel.

I don't see any statd.c in the src tree.

Did I miss something Ideas?

Thanks,
Greg

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
