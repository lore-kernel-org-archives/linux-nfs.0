From: miyoshi@hpc.bs1.fc.nec.co.jp
Subject: Doubly mounting same directory
Date: Fri, 26 Jul 2002 18:27:29 +0900
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020726182729H.miyoshi@hpc.bs1.fc.nec.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tyo201.gate.nec.co.jp ([202.32.8.214])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Y1NA-0006S0-00
	for <nfs@lists.sourceforge.net>; Fri, 26 Jul 2002 02:26:56 -0700
Received: from mailgate4.nec.co.jp ([10.7.69.193])
	by TYO201.gate.nec.co.jp (8.11.6/3.7W01080315) with ESMTP id g6Q9QkK24628
	for <nfs@lists.sourceforge.net>; Fri, 26 Jul 2002 18:26:46 +0900 (JST)
Received: from mailsv4.nec.co.jp (mailgate51.nec.co.jp [10.7.69.196]) by mailgate4.nec.co.jp (8.11.6/3.7W-MAILGATE-NEC) with ESMTP
	id g6Q9QiZ17272 for <nfs@lists.sourceforge.net>; Fri, 26 Jul 2002 18:26:45 +0900 (JST)
Received: from mailsv.bs1.fc.nec.co.jp (venus.d2.bs1.fc.nec.co.jp [10.34.77.164]) by mailsv4.nec.co.jp (8.11.6/3.7W-MAILSV4-NEC) with ESMTP
	id g6Q9Qio15553 for <nfs@lists.sourceforge.net>; Fri, 26 Jul 2002 18:26:44 +0900 (JST)
Received: from localhost (pingu.hpc.bs1.fc.nec.co.jp [10.34.77.220])
	by mailsv.bs1.fc.nec.co.jp (8.12.0/3.7W-HPC5.2F(mailsv)01041614) with ESMTP id g6Q9IXLw015262
	for <nfs@lists.sourceforge.net>; Fri, 26 Jul 2002 18:18:33 +0900 (JST)
To: nfs@lists.sourceforge.net
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


Hi, all.

I am newbie to NFS, and I have a question about Linux NFS.

On most unix systems, mounting the same remote directory to
the same local mount point will cause mount error.

On linux boxes, we can do that without error.
It seems there are some semantic difference between
Linux NFS and other implementations,
but what is the difference?

Thanks,


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
