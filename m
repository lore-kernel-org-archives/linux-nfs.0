From: "Saurabh Sehgal" <saurabh.r.s@gmail.com>
Subject: Nfs Failover
Date: Tue, 9 Oct 2007 15:40:22 -0400
Message-ID: <2a46ebd60710091240k37369e15rbc99b57d26579e8a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1798326725=="
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfKwG-00081B-El
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 12:40:20 -0700
Received: from fk-out-0910.google.com ([209.85.128.185])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IfKwK-0004Ix-ED
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 12:40:25 -0700
Received: by fk-out-0910.google.com with SMTP id 19so1644177fkr
	for <nfs@lists.sourceforge.net>; Tue, 09 Oct 2007 12:40:23 -0700 (PDT)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

--===============1798326725==
Content-Type: multipart/alternative;
	boundary="----=_Part_7665_15546596.1191958822817"

------=_Part_7665_15546596.1191958822817
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi all,

I am trying to do an nfs failover from one server to another in a 4 node
cluster . During this failover, I have a link from /var/lib/nfs directory to
a mount that resides on a shared disk. When i want to move the "resources"
from one node to the other ... this is how I go about initiating the move :

1) /etc/init.d/nfsserver stop
2) mount /var/lib/nfs on the failover node
3) move IP address to failover node
3) /etc/init.d/nfsserver start
4) /sbin/sm-notify -v <failover ip address>

Are these the correct steps ? What I end up getting is a Stale NFS File
handle on all client nodes, until I unmount and remount them again. For the
purpose of my application this mount/unmount of clients is undesirable .
What should I do ? Any help would be appreciated.

( I am using SLES 10 SP 1 as a platform :
uname -a
Linux mach1 2.6.16.46-0.12-smp #1 SMP Thu May 17 14:00:09 UTC 2007 x86_64
x86_64 x86_64 GNU/Linux  )


Thank you,

Saurabh

------=_Part_7665_15546596.1191958822817
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi all, <br><br>I am trying to do an nfs failover from one server to another in a 4 node cluster . During this failover, I have a link from /var/lib/nfs directory to a mount that resides on a shared disk. When i want to move the &quot;resources&quot; from one node to the other ... this is how I go about initiating the move :
<br><br>1) /etc/init.d/nfsserver stop<br>2) mount /var/lib/nfs on the failover node<br>3) move IP address to failover node<br>3) /etc/init.d/nfsserver start<br>4) /sbin/sm-notify -v &lt;failover ip address&gt;<br><br>Are these the correct steps ? What I end up getting is a Stale NFS File handle on all client nodes, until I unmount and remount them again. For the purpose of my application this mount/unmount of clients is undesirable . What should I do ? Any help would be appreciated.
<br><br>( I am using SLES 10 SP 1 as a platform :<br>uname -a<br>Linux mach1 2.6.16.46-0.12-smp #1 SMP Thu May 17 14:00:09 UTC 2007 x86_64 x86_64 x86_64 GNU/Linux&nbsp; )<br><br><br>Thank you, <br><br>Saurabh<br>

------=_Part_7665_15546596.1191958822817--


--===============1798326725==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--===============1798326725==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1798326725==--
