From: Matthew Adams <madams@phantomware.ca>
Subject: uid/gid mapping problem
Date: Tue, 22 Oct 2002 09:07:01 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0210220904530.1385-100000@virtus.phantomware.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tomts20.bellnexxia.net ([209.226.175.74] helo=tomts20-srv.bellnexxia.net)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 183yyg-00089D-00
	for <nfs@lists.sourceforge.net>; Tue, 22 Oct 2002 06:21:46 -0700
Received: from facinorous.phantomware.ca ([216.208.193.61])
          by tomts20-srv.bellnexxia.net
          (InterMail vM.5.01.04.19 201-253-122-122-119-20020516) with ESMTP
          id <20021022132132.BZJP12763.tomts20-srv.bellnexxia.net@facinorous.phantomware.ca>
          for <nfs@lists.sourceforge.net>; Tue, 22 Oct 2002 09:21:32 -0400
Received: from virtus.phantomware.ca (virtus.phantomware.ca [192.168.0.3])
	by facinorous.phantomware.ca (8.9.3/8.9.3) with ESMTP id JAA30051
	for <nfs@lists.sourceforge.net>; Tue, 22 Oct 2002 09:12:03 -0400
Received: from virtus.phantomware.ca (localhost [127.0.0.1])
	by virtus.phantomware.ca (8.12.5/8.12.5) with ESMTP id g9MD73X0001394
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <nfs@lists.sourceforge.net>; Tue, 22 Oct 2002 09:07:04 -0400
Received: from localhost (madams@localhost)
	by virtus.phantomware.ca (8.12.5/8.12.5/Submit) with ESMTP id g9MD712F001391
	for <nfs@lists.sourceforge.net>; Tue, 22 Oct 2002 09:07:03 -0400
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

Hi:

I seem to be having a problem with the uid/gid mapping in my
exports.

My current configuration involves an NFS server (which also happens
to be the NIS server which I'm using for authentication, etc.) and a single
client.  The exports file containing the single line:

/home 192.168.0.15(root_squash,rw,map_nis=internal.domain.ca)

Based on my feeble understanding of NFS, I'd expect, since ypbind on
the client talks properly with the NIS server, that the uid/gids in
the export would map properly, however I get the following output
when I list the mounted export on the client machine:

total 32
drwxr-xr-x    3 root     root         4096 Oct  7 14:04 backup
drwx------    2 4294967294 4294967294    16384 Oct  3 16:23 lost+found
drwxr-xr-x   20 4294967294 4294967294     4096 Oct 20 19:26 madams
lrwxrwxrwx    1 4294967294 4294967294       19 Oct 16 13:05 robl
drwxr-xr-x    4 4294967294 4294967294     4096 Oct 16 12:25 samba
drwxr-xr-x    6 root     root         4096 Oct 15 14:46 smbshare

Does anyone have any ideas as to why I'm getting these extremely long
uid/gids?  This issue also seems to prevent me from getting proper
r/w access to the data.  I'd appreciate any suggestions or comments
anyone might have!  From what I can tell, NIS *appears* to be working
correctly - except in NFS.

I'm running Linux 2.2.20raid on the NFS server (userspace) and
Linux 2.4.18 on the NFS client.  Both the server and client are
using the same version of NFS utils, i.e. 2.2beta47.


Thanks in advance,

Matt
-- 
Matt Adams <madams@phantomware.ca>



-------------------------------------------------------
This sf.net emial is sponsored by: Influence the future of 
Java(TM) technology. Join the Java Community Process(SM) (JCP(SM)) 
program now. http://ad.doubleclick.net/clk;4699841;7576301;v?
http://www.sun.com/javavote
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
