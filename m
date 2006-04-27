From: "Michael Lackner" <thrawn@xin.at>
Subject: Update: NFS over a Win2k Server NAT Router with "DMZ": nfs: server not responding, still trying
Date: Thu, 27 Apr 2006 19:36:14 +0200
Message-ID: <000401c66a21$154a8c70$0200a8c0@novastorm>
References: <005401c66a19$2a6f6d30$0200a8c0@novastorm>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=response
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FZAPm-0003eq-D7
	for nfs@lists.sourceforge.net; Thu, 27 Apr 2006 10:36:30 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FZAPm-0006jn-DT
	for nfs@lists.sourceforge.net; Thu, 27 Apr 2006 10:36:30 -0700
Received: from 83-64-254-60.bruck-mur.xdsl-line.inode.at ([83.64.254.60] helo=xin.at)
	by mail.sourceforge.net with esmtps (TLSv1:RC4-MD5:128)
	(Exim 4.44)
	id 1FZAPh-00023r-T2
	for nfs@lists.sourceforge.net; Thu, 27 Apr 2006 10:36:30 -0700
Received: from novastorm by xin.at
	(MDaemon.PRO.v8.1.3.R)
	with ESMTP id md50000005495.msg
	for <nfs@lists.sourceforge.net>; Thu, 27 Apr 2006 19:36:08 +0200
To: <nfs@lists.sourceforge.net>
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

Greetings again.

A little update to the Situation as described in the mail before...

I now tried a "touch" on my NFS mounts, and to my surprise it worked. So i can
even write to NFS mounted directories from within the private network. But i still
cannot read...  

When mounting soft, i get input/output errors when trying ls, no matter what values i
set timeo and retrans to..  I also tried different values for rsize, down to 1024. Doesn't
work either..

Thanks again 
Best Regards
Michael Lackner
University of Leoben
Chair for Information Technology, IT Administration



-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
