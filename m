From: dJu` <dju.ml@wanadoo.fr>
Subject: nfs hangs up when listing a directory
Date: Tue, 27 May 2003 09:20:05 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200305270920.05161.dju.ml@wanadoo.fr>
Reply-To: dju.ml@wanadoo.fr
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smtp3.wanadoo.fr ([193.252.22.25] helo=mwinf0602.wanadoo.fr)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19KYkT-0001A5-00
	for <nfs@lists.sourceforge.net>; Tue, 27 May 2003 00:19:53 -0700
Received: from wyvern.local.dju (unknown [81.48.138.57])
	by mwinf0602.wanadoo.fr (SMTP Server) with ESMTP id 134575400241
	for <nfs@lists.sourceforge.net>; Tue, 27 May 2003 09:19:46 +0200 (CEST)
To: nfs@lists.sourceforge.net
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

Hello. I have a strange problem, I hope I'm asking for help at the right 
place. I have a server (named sterenn) sharing a directory to a client. They 
are running linux. Mounting is fine, but I get a long hang up when I try to 
list the shared dir, and then it says there are no files in that dir :

/myshareddir# ls
total: 0

What's wrong ? I have portmap running on each side, rpcinfo -p shows the same 
information from each side, mounting the exported dir seems to work fine, but 
listing the files (and of course using them) makes the whole thing hang. I 
have "[kernel] nfs: server sterenn not responding, timed out" in the logs. 
Did I miss something ? Thanks.



-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
