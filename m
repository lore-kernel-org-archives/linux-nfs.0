From: Matt Adams <matta@emerchant.ca>
Subject: uid/gid mapping question
Date: Wed, 23 Oct 2002 15:46:01 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021021202327.GB5598@emerchant.ca>
Reply-To: matta@emerchant.ca
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from toc1.kos.net ([199.246.2.136] helo=webserver01.emerchant.ca)
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 184RSC-0007jx-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Oct 2002 12:46:08 -0700
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
the client talks properly with the server, that the uid/gids in
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
Matt Adams <matta@emerchant.ca>
Systems Administrator, eMerchant.ca Inc.




-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0002en

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
