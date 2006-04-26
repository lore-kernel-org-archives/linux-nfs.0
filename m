From: Venkat Ram Reddy <reddy@apache-da.com>
Subject: rpc.mountd dies under heavy load
Date: Wed, 26 Apr 2006 10:10:30 -0700
Message-ID: <444FA986.7040709@apache-da.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FYnXH-0007TW-EQ
	for nfs@lists.sourceforge.net; Wed, 26 Apr 2006 10:10:43 -0700
Received: from [64.157.93.84] (helo=mailhost.apache-da.com)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FYnXF-0004UB-U5
	for nfs@lists.sourceforge.net; Wed, 26 Apr 2006 10:10:43 -0700
Received: from [192.168.1.123] (dmz [192.168.10.1])
	by mailhost.apache-da.com (8.13.4/8.13.4) with ESMTP id k3QHAUib019753
	for <nfs@lists.sourceforge.net>; Wed, 26 Apr 2006 10:10:30 -0700
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

Hi All,

I have a lsf farm with 20 running jobs writing data to a nfs exported 
disk. This causes high load average ( 15-20 ) on the nfs server, and 
rpc.mountd dies. What could be the problem? My nfs server is RHEL AS3.0 
AMD64 and has nfs-utils-1.0.6-42EL.

Thanks

-- 
Venkat Ram Reddy




-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
