From: Maurice Volaski <mvolaski@aecom.yu.edu>
Subject: [Q] Why is my NFSv4 client trying to contact the portmapper?
Date: Wed, 13 Sep 2006 13:44:58 -0400
Message-ID: <a06240411c12deeab9cb6@[129.98.90.227]>
References: <mailman.63002.1155542509.19399.nfs@lists.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GNYoz-000171-EG
	for nfs@lists.sourceforge.net; Wed, 13 Sep 2006 10:46:49 -0700
Received: from mailgw.aecom.yu.edu ([129.98.1.16])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GNYow-00053K-M0
	for nfs@lists.sourceforge.net; Wed, 13 Sep 2006 10:46:50 -0700
Received: from draco.aecom.yu.edu (draco.aecom.yu.edu [129.98.1.160])
	by mailgw.aecom.yu.edu (8.12.11.20060308/8.12.11) with ESMTP id
	k8DHkgIu028563
	for <nfs@lists.sourceforge.net>; Wed, 13 Sep 2006 13:46:42 -0400
Received: from draco.aecom.yu.edu (unknown [127.0.0.1])
	by draco.aecom.yu.edu (Symantec Mail Security) with ESMTP id
	A10793299C4
	for <nfs@lists.sourceforge.net>; Wed, 13 Sep 2006 13:44:47 -0400 (EDT)
Received: from post.aecom.yu.edu (post.aecom.yu.edu [129.98.1.100])
	by draco.aecom.yu.edu (Symantec Mail Security) with ESMTP id
	696A12E5724
	for <nfs@lists.sourceforge.net>; Wed, 13 Sep 2006 13:44:47 -0400 (EDT)
Received: from [129.98.90.227] (usseinstein.aecom.yu.edu [129.98.90.227])
	by post.aecom.yu.edu (Postfix) with ESMTP id B242F26
	for <nfs@lists.sourceforge.net>; Wed, 13 Sep 2006 13:46:41 -0400 (EDT)
In-Reply-To: <mailman.63002.1155542509.19399.nfs@lists.sourceforge.net>
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

 From where I can find documentation on NFSv4, it seems that only one 
TCP port 2049 should be being used and the portmapper is no longer 
used. Examples include

http://www.vanemery.com/Linux/NFSv4/NFSv4-no-rpcsec.html
and
http://nfsv4.bullopensource.org/doc/NFS3_NFS4_migration.pdf

But that doesn't seem to be the reality. I'm trying to mount a Gentoo 
Linux server from a Gentoo Linux client (sudo mount -t nfs4 
thewarehouse:/ /mnt/thewarehouse) and I even recompiled the client's 
kernel to support only NFSv4 and I'm seeing this message on the 
server end:

[portmap] connect from 129.98.90.163 to getport(nfs): request from 
unauthorized host

So it appears the portmapper and TCP 111 is required after all. 
What's going on?


(other keywords: firewall, iptables, tcpwrappers, hosts.allow)
-- 

Maurice Volaski, mvolaski@aecom.yu.edu
Computing Support, Rose F. Kennedy Center
Albert Einstein College of Medicine of Yeshiva University

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
