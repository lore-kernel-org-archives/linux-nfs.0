From: Marten Lehmann <lehmann@cnm.de>
Subject: NFS limits?
Date: Mon, 08 May 2006 19:43:50 +0200
Message-ID: <445F8356.1030605@cnm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Fd9lx-0001yA-TA
	for nfs@lists.sourceforge.net; Mon, 08 May 2006 10:43:53 -0700
Received: from relay1.mail.vrmd.de ([81.28.232.18])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Fd9lw-0000KP-AQ
	for nfs@lists.sourceforge.net; Mon, 08 May 2006 10:43:54 -0700
Received: from [217.83.26.183] (helo=[192.168.33.66])
	by relay1.mail.vrmd.de with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.60)
	(envelope-from <lehmann@cnm.de>)
	id 1Fd9lq-0005z0-4V
	for nfs@lists.sourceforge.net; Mon, 08 May 2006 19:43:46 +0200
To: nfs@lists.sourceforge.net
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

Hello,

a mailserver of us is storing the messages on another server with NFS 
through TCP. A lot of concurrent deliveries occur, but I can only see 
about 8 nfs processes on the storage server. The mailserver which 
accesses the storage often has very high I/O waits (>400 seconds), 
because the NFS server doesn't respond in time. How can I increase the 
NFS-processes on the storage server? Right NFS is a real bottleneck and 
a lot of mails are delivered with a delay of 1-3 hours.

Regards
Marten


-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
