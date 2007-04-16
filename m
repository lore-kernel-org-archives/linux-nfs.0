From: "Zhou Yingchao" <yingchao.zhou@gmail.com>
Subject: NFS livelock / starvation ?
Date: Mon, 16 Apr 2007 16:24:51 +0800
Message-ID: <67029b170704160124y7bfcb535h8dfbeb1530446469@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-kernel@vger.kernel.org
To: akpm@zip.com.au, trond.myklebust@fys.uio.no,
	neilb@cse.unsw.edu.au, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HdMW3-0007X3-AE
	for nfs@lists.sourceforge.net; Mon, 16 Apr 2007 01:24:51 -0700
Received: from wx-out-0506.google.com ([66.249.82.238])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HdMW5-00084l-09
	for nfs@lists.sourceforge.net; Mon, 16 Apr 2007 01:24:53 -0700
Received: by wx-out-0506.google.com with SMTP id i30so2627879wxd
	for <nfs@lists.sourceforge.net>; Mon, 16 Apr 2007 01:24:52 -0700 (PDT)
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

When we run a two nfs client and a nfs server in the following way, we
met a livelock / starvation condition.

MachineA        MachineB
 Client1             Client2
 Server

As shown in the figure, we run a client and server on one machine, and
run another client on another machine. When Client1 and Client2 make
many writes at the same time, the Client1's request is blocked until
Client2's writes finished.

We check the code, Client1 is blocked in generic_file_write-> ...
>balance_dirty_pages, balance_dirty_pages call writeback_inodes to
(only) flush data of the related fs.

In nfs, we found that the Server has enhanced its dirty_thresh. So in
the loop of writeback_inodes, Client1 has no data to write out, and
the condition "ns_reclaimable+wbs.nr_writeback<=dirty_thresh" will not
be true until Client2 finishes its write request to Server. So the
loop will only end after Client2 finished its write job.

The problem in this path is: why we write only pages of the related fs
in writeback_inodes but check the dirty thresh for total pages?

-- 
Yingchao Zhou
***********************************************
 Institute Of Computing Technology
 Chinese Academy of Sciences
***********************************************

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
