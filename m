From: Ian Grant <Ian.Grant@cl.cam.ac.uk>
Subject: Help with UDP NFS firewall rules
Date: Thu, 6 Jul 2006 16:51:58 +0100
Message-ID: <20060706165158.37943b1a.Ian.Grant@cl.cam.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FyW9A-0004WY-V6
	for nfs@lists.sourceforge.net; Thu, 06 Jul 2006 08:52:08 -0700
Received: from mta2.cl.cam.ac.uk ([128.232.0.14]
	ident=[zV+7F+VMUQw3ki9pUCA2HHhwTuT4rb0t])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FyW9A-0006gP-4k
	for nfs@lists.sourceforge.net; Thu, 06 Jul 2006 08:52:09 -0700
Received: from fenton.cl.cam.ac.uk ([128.232.8.60])
	by mta2.cl.cam.ac.uk with smtp (Exim 3.092 #1) id 1FyW90-0001WH-00
	for nfs@lists.sourceforge.net; Thu, 06 Jul 2006 16:51:58 +0100
To: nfs@lists.sourceforge.net
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

Dear NFS people,

I am trying to access NFS services running on a 2.4.20 kernel, using UDP. The client is running SUSE 9.3 with kernel 2.6.11.4-21.12 and iptables acting as a firewall.

The problem is that the nfsd on the server sends UDP replies to random ports <1024 on the client. Is there a way to fix the port chosen on the client end so that I can make a hole in the firewall for it?

Ian Grant

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
