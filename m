From: Robert Kellner <skyywalk@btcips73x1.cip.uni-bayreuth.de>
Subject: FreeBSD -> Linux locking problems
Date: Mon, 4 Nov 2002 17:36:26 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E188kDD-0006Uv-00@btcips73x6.cip.uni-bayreuth.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from btcips73x6.cip.uni-bayreuth.de ([132.180.237.6])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 188kDQ-0001EG-00
	for <nfs@lists.sourceforge.net>; Mon, 04 Nov 2002 08:36:40 -0800
Received: from localhost
	([127.0.0.1] helo=btcips73x6 ident=skyywalk)
	by btcips73x6.cip.uni-bayreuth.de with smtp (Exim 3.36 #1 (Debian))
	id 188kDD-0006Uv-00
	for <nfs@lists.sourceforge.net>; Mon, 04 Nov 2002 17:36:27 +0100
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hello,

I am using a FreeBSD System as server for nfs and nis for
linux clients.
Unfortunately nfs-file locking does not work although
nlockmgr and rpc.statd are running on both systems. 

The FAQ says nothing about troubles with FreeBSD and Linux
concerning locks.

Does anybody know about this Problem and/or how to solve it?

Greetings,

Robert


-------------------------------------------------------
This SF.net email is sponsored by: ApacheCon, November 18-21 in
Las Vegas (supported by COMDEX), the only Apache event to be
fully supported by the ASF. http://www.apachecon.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
