From: bond liu <csc_425@yahoo.com>
Subject: nfs mount problem in cluster
Date: Sun, 8 Feb 2004 14:10:23 -0800 (PST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040208221023.1528.qmail@web21510.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="0-2047626807-1076278223=:99822"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Apx8B-00012d-Bz
	for nfs@lists.sourceforge.net; Sun, 08 Feb 2004 14:10:23 -0800
Received: from web21510.mail.yahoo.com ([66.163.169.59])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1Apx8B-0001KH-3X
	for nfs@lists.sourceforge.net; Sun, 08 Feb 2004 14:10:23 -0800
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

--0-2047626807-1076278223=:99822
Content-Type: text/plain; charset=us-ascii

I use nfs on my beowulf cluster. I build two servers with multiple client nodes.
Two server has same hostname and ip address, they are totally identical with software and hardware. Only one is active at any time.
 
The problem is: Initially one server works fine with nfs client nodes.
                      but when I do failover and use another server as nfs server.
The clients can't get access to the second server although I do service nfs restart on the second server and clients. The error  is: nfs_oscar is not responding, still trying.
 
At that time, although I reboot clients , same problem still exists. I have to reboot the second server. On the other hand, if I switch back to original server, everything is fine again even without doing anything on clients or server.
 
What is the issue there? I need help.
Thanks.
 
~
Eric


---------------------------------
Do you Yahoo!?
Yahoo! Finance: Get your refund fast by filing online
--0-2047626807-1076278223=:99822
Content-Type: text/html; charset=us-ascii

<DIV>I use nfs on my beowulf cluster. I build two&nbsp;servers&nbsp;with multiple client nodes.</DIV>
<DIV>Two server has same hostname and ip address, they are totally identical with software and hardware. Only one is active at any time.</DIV>
<DIV>&nbsp;</DIV>
<DIV>The problem is:&nbsp;Initially&nbsp;one server works fine with nfs client nodes.</DIV>
<DIV>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; but when I do failover and use another server&nbsp;as nfs server.</DIV>
<DIV>The clients can't get access to the second server although I do service nfs restart on the second server and clients. The error&nbsp; is: nfs_oscar is not responding, still trying.</DIV>
<DIV>&nbsp;</DIV>
<DIV>At that time, although I reboot clients , same problem still exists. I have to reboot the second server. On the other hand, if I switch back to original server, everything is fine again even without doing anything on clients or server.</DIV>
<DIV>&nbsp;</DIV>
<DIV>What is the issue there? I need help.</DIV>
<DIV>Thanks.</DIV>
<DIV>&nbsp;</DIV>
<DIV>~</DIV>
<DIV>Eric</DIV><p><hr SIZE=1>
Do you Yahoo!?<br>
Yahoo! Finance: <a href="http://us.rd.yahoo.com/evt=22055/*http://taxes.yahoo.com/filing.html">Get your refund fast by filing online</a>
--0-2047626807-1076278223=:99822--


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
