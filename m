From: Steffen Kolbe <kolbe@vwi.tu-dresden.de>
Subject: nfs export from mount point with --bind ?
Date: Wed, 10 May 2006 08:47:29 +0200
Message-ID: <44618C81.5050503@vwi.tu-dresden.de>
Reply-To: kolbe@vwi.tu-dresden.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FdiTz-00054u-EA
	for nfs@lists.sourceforge.net; Tue, 09 May 2006 23:47:39 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FdiTz-0008Ad-06
	for nfs@lists.sourceforge.net; Tue, 09 May 2006 23:47:39 -0700
Received: from rks36.urz.tu-dresden.de ([141.30.66.166] helo=mailgate.urz.tu-dresden.de)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FdiTw-0002eu-HC
	for nfs@lists.sourceforge.net; Tue, 09 May 2006 23:47:39 -0700
Received: from [127.0.0.1] (helo=localhost)
	  by mailgate.urz.tu-dresden.de with esmtp (exim-4.51)
	  for <nfs@lists.sourceforge.net>
	  id 1FdiTq-0007nU-A6; Wed, 10 May 2006 08:47:30 +0200
Received: from mailgate.urz.tu-dresden.de ([127.0.0.1])
 by localhost (rks36 [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
 id 17688-448 for <nfs@lists.sourceforge.net>;
 Wed, 10 May 2006 08:47:29 +0200 (MEST)
Received: from [141.30.186.11] (helo=vwitme011.vwi.vkw.tu-dresden.de)
	  by mailgate.urz.tu-dresden.de with esmtp (exim-4.51)
	  for <nfs@lists.sourceforge.net>
	  id 1FdiTp-0007nP-Qy; Wed, 10 May 2006 08:47:29 +0200
Received: from vwitme048.vwi.vkw.tu-dresden.de ([141.30.186.48])
	by vwitme011.vwi.vkw.tu-dresden.de with esmtp (Exim 4.52)
	id 1FdiTk-0007BC-2y
	for nfs@lists.sourceforge.net; Wed, 10 May 2006 08:47:24 +0200
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

A server has mounted some luns (partitions) from a fc-storage to different
mount points in the system.
These are mounted for export via 'mount --bind' under an /export folder.
Is it possible to export only these /export folder via NFS or can I only 
export
every "sub mount point (= --bind) in /exports" with the NFS kernel server?

The user server can this, but he hangs some times (Debian AMD64). So I 
changed
to the kernel server whitch works stable. But he seems not to export 
folders
which are mounted via --bind under a "master export". If I mount these 
master
folder to a client, the folder is empty.

Is their a solutions or special option for this available?

Thanks
Steffen


-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
