From: "jacky" <jacky.xia@raidtec.ie>
Subject: what is dump ?
Date: Fri, 23 May 2003 18:28:05 +0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <002d01c32115$ff6fc250$227ba8c0@jacky>
References: <E19IK1R-00061X-00@notabene.cse.unsw.edu.au> <3ECDEAFC.A7AEBB7E@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [61.242.91.194] (helo=beijing.raidtec.cn)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19J9kw-0006nO-00
	for <nfs@lists.sourceforge.net>; Fri, 23 May 2003 03:26:35 -0700
Received: from jacky (unknown [192.168.123.34])
	by beijing.raidtec.cn (Postfix) with SMTP id 571524332A
	for <nfs@lists.sourceforge.net>; Fri, 23 May 2003 18:34:24 +0800 (CST)
To: <nfs@lists.sourceforge.net>
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

Since I've installed and run and NFS, I've my log 
flooded with this message 
(every 10 seconds) : 
--- 
Feb 24 12:03:50 [rpc.mountd] dump request from 1.2.3.4 
Feb 24 12:03:53 [rpc.mountd] dump request from 1.2.3.4 
Feb 24 12:03:56 [rpc.mountd] dump request from 1.2.3.4 
Feb 24 12:03:59 [rpc.mountd] dump request from 1.2.3.4 
Feb 24 12:04:02 [rpc.mountd] dump request from 1.2.3.4 
--- 
(where 1.2.3.4 is the fixed ip of the NFS server). 

Therefore I have 2 questions: 
- What's this dump request ? (can I safely turn it off 
(and how) ?) 
- If it's normal feature where can I specify that I 
don't want such logging 
(especially every 10 seconds) ? 




-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
