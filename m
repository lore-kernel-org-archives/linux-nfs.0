From: Matthew Mitchell <matthew@geodev.com>
Subject: mmap() and NFS server performance
Date: Fri, 13 Dec 2002 15:09:46 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3DFA4C9A.50101@geodev.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from gateway2.geodev.com ([64.45.165.170] ident=[hqeabSHtIuUrYL3ew5d/LXu3jiQ8GoY/])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Mx85-0004dJ-00
	for <nfs@lists.sourceforge.net>; Fri, 13 Dec 2002 13:13:53 -0800
Received: from geodev.com (mariner.geodev.com [192.168.201.124])
	by gateway2.geodev.com (8.11.6/8.11.6) with ESMTP id gBDL9Qq28279
	for <nfs@lists.sourceforge.net>; Fri, 13 Dec 2002 15:09:26 -0600
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

Hello,

We've noticed some interesting behavior regarding mmap file IO and were 
wondering if anyone here had some clues as to what might be going on.

We have some applications that mmap() files into memory for the purpose 
of updating some potentially scattered word-sized data values.  These 
apps were originally written on Solaris with Solaris NFS servers assumed 
to be the data source; the Sun guys said that mmap would be much faster 
than read/write and they were correct.  However, now that we have a few 
Linux NFS servers, we're seeing the opposite.

It takes, for example, 20-24 hours to update a 2GB file (there are on 
the order of 1M words to update) via mmap, whereas reading in the whole 
file, updating it in memory, and writing it out again takes about 30 
minutes (limited by network speed in our case).  This when the file 
resides on the Linux server.  On Solaris the mmap update runs on the 
order of 15-20 minutes.  Client in both cases is a Solaris 8 machine.

What we are speculating is that the Solaris NFS server is "cheating" by 
keeping file state information between NFS reads and writes.  (The 
updates do occur in sequence.)  Are there any heuristics or 
optimizations done by the Linux NFS server that might help the 
performance here?

All things, alas, are not equal in this comparison -- the Solaris server 
in question is an 8 CPU Enterprise 4500 with 8GB of RAM, and the Linux 
server is a single-processor P4 with 512MB of RAM.  The Solaris server 
is much busier than the Linux server, though (I know it cannot be 
caching the whole file in memory).  The Linux server is running Red 
Hat's 2.4.18-14 kernel.

Anyone have any ideas as to why this is happening and what, if anything, 
we can do to speed up the mmap IO when using the Linux server?

-- 
Matthew Mitchell
Systems Programmer/Administrator            matthew@geodev.com
Geophysical Development Corporation         phone 713 782 1234
1 Riverway Suite 2100, Houston, TX  77056     fax 713 782 1829



-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
