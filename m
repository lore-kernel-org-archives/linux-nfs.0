From: Peter Niemayer <niemayer@isg.de>
Subject: exported filesystem on loop-device could be much faster if only nfs
 on the server side...
Date: Thu, 19 Feb 2004 21:33:24 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40351D94.8000405@isg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Atux2-0003rv-K4
	for nfs@lists.sourceforge.net; Thu, 19 Feb 2004 12:39:16 -0800
Received: from rzfoobar.is-asp.com ([217.11.194.155] helo=mail.isg.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1AtujL-0002r7-Ng
	for nfs@lists.sourceforge.net; Thu, 19 Feb 2004 12:25:07 -0800
Received: from isg.de (unknown [192.168.5.53])
	by mail.isg.de (Postfix) with ESMTP id D00D01503580
	for <nfs@lists.sourceforge.net>; Thu, 19 Feb 2004 21:33:24 +0100 (CET)
To: nfs@lists.sourceforge.net
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

... would do some more read-ahead. But first: Hi, I'm currently seeing a bizarre
effect with an filesystem on a loop device exported via nfs (v3, kernel 2.6.2):

Another computer, connected via Gigabit-EtherNet, reads a big file. The performance
is not that good, only about 6MB/s, while files that are exported the same way but
are not on a filesystem that resides on a loop device can be read at about 35MB/s.
The server machine has a lot of idle time left in this scenario.

Now comes the funny part: If I start both the copy job on the remote machine reading
the file AND a local "dd if=file_on_loop_fs of=/dev/zero" on the server machine,
the performance increases up to about 30MB/s!

So it seems that a little read-ahead on the server machine can do wonders to the
performance in this case.

Is there any way to configure read-ahead on the server side of NFS?

Any other tip you can give me to get the same performance boost without the
awkward manual start of the bogus "dd" (which certainly spoils some CPU, still) ?


Thanks in advance,

Peter Niemayer





-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
