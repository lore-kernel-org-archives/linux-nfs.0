From: David Dougall <davidd@et.byu.edu>
Subject: hung server
Date: Fri, 26 Jul 2002 08:59:26 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.33.0207260855450.14293-100000@lewis.et.byu.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from email2.byu.edu ([128.187.22.134])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Y6ZX-00069j-00
	for <nfs@lists.sourceforge.net>; Fri, 26 Jul 2002 08:00:03 -0700
Received: from lewis ([128.187.112.50]) by EMAIL1.BYU.EDU (PMDF V6.1-1 #30538)
 with ESMTP id <01KKJMSGWHGW90MVG2@EMAIL1.BYU.EDU> for
 nfs@lists.sourceforge.net; Fri, 26 Jul 2002 08:59:26 -0600 (MDT)
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

I have a linux NFS server running base 2.4.18 with xfs patches from SGI.
Seeminly random times, the nfs server will become unresponsive.  On
a client, doing showmount -e [server] will timeout.  Looking on the
server shows that the nfs daemons will go into the DW state as shown
by ps:
root       123  0.2  0.0     0    0 ?        DW   Jul25   2:53 [nfsd]
root       124  0.2  0.0     0    0 ?        DW   Jul25   2:50 [nfsd]
root       127  0.2  0.0     0    0 ?        DW   Jul25   2:52 [nfsd]
root       128  0.2  0.0     0    0 ?        DW   Jul25   2:52 [nfsd]
root       129  0.2  0.0     0    0 ?        DW   Jul25   2:53 [nfsd]
root       130  0.2  0.0     0    0 ?        DW   Jul25   2:53 [nfsd]
root       131  0.3  0.0     0    0 ?        DW   Jul25   2:55 [nfsd]
root       132  0.2  0.0     0    0 ?        DW   Jul25   2:53 [nfsd]

  The load will sit at about 8 which is how many nfsd's that I have
running.  I thought this was usually caused by a hardware problem, but I
am able to get the the local filesystems that are exported just fine.
Any help would be appreciated.
Thanks
--David Dougall



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
