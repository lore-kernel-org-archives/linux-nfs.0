From: Andreas Behnert <abehn@gmx.net>
Subject: cleaning up rmtab
Date: Tue, 15 Apr 2003 17:09:50 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E9C20BE.5020907@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pop.gmx.de ([213.165.64.20] helo=mail.gmx.net)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 195S4Q-0005OR-00
	for <nfs@lists.sourceforge.net>; Tue, 15 Apr 2003 08:10:02 -0700
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

(Sorry 'bout my poor English)
System is Debian 3.0r1, Kernel 2.4.21-pre7, knfsd, clients
are running IRIX 6.5.x, AIX 4, AIX 5, HP-UX 11, NetBSD, Linux.
Over the time a "showmount" on the server shows a lot of
clients that haven't mounted anything anymore because people
pull out the network cable of their notebook before the
shutdown process umounts nfs, people are configuring diskless
clients and during the tests something goes wrong and these
clients never umount the nfs mounted rootfs, sometimes clients
simply lock up so that they have to be switched off and on again.
Normally at least once a year we are shutting down all boxes for 
maintenance, stopping the nfs server, cleaning up /var/lib/nfs
(rmtab being the most important file there).
Is there a "proper" way of cleaning up /var/lib/nfs/rmtab
while the server is running?



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
