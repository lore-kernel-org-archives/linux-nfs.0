From: steven sagerian <steven_sagerian@attbi.com>
Subject: rpc time outs
Date: Thu, 31 Oct 2002 00:12:40 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3DC0C9D8.9060302@attbi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sccrmhc03.attbi.com ([204.127.202.63])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1878WH-0001QW-00
	for <nfs@lists.sourceforge.net>; Wed, 30 Oct 2002 22:09:29 -0800
Received: from attbi.com ([12.251.80.72]) by sccrmhc03.attbi.com
          (InterMail vM.4.01.03.27 201-229-121-127-20010626) with ESMTP
          id <20021031060923.GQHR24986.sccrmhc03.attbi.com@attbi.com>
          for <nfs@lists.sourceforge.net>; Thu, 31 Oct 2002 06:09:23 +0000
To: nfs <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hello,
Im trying to set up a simple nfs server for my home network, Ive got a 
old p2 system running Linux version 2.4.18-3. from my machine (waseca) I 
can get rpcinfo from both my machine and the server (oddly enough called 
"server" ;->).
but when I try to mount fs on server I get the following rpc time outs..
[root@waseca steven]# mount -t nfs server:/home/share /mnt/share
mount: RPC: Timed out

my exports file on server is simply one line..
/home/share waseca(rw,no_root_squash)

I can ping either machine from either host.

the /var/log/messages file on server says rpc.mountd authneticated mount 
request from waseca for /home/share

Every thing looks good..oh...one more bit..when I try to run rpcinfo 
from server (rpcinfo -p waseca) I get a "can contact mapper remote 
system error, connection refused".

Ok can anyone suggest a solution?

Thanks in advance...

Steve
-- 
                 Steven Sagerian
       Unemployed Telcom embedded Developer
"Will code for food (and health insurance :->)"



-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
