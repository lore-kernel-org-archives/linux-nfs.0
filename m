From: Phil Garcia <apgarcia@oppie.phys.uwm.edu>
Subject: high load
Date: Fri, 18 Apr 2003 14:48:44 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030418194844.GB29491@oppie.phys.uwm.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from oppie.phys.uwm.edu
	([129.89.57.60] helo=oppie ident=mail)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 196brJ-0006N6-00
	for <nfs@lists.sourceforge.net>; Fri, 18 Apr 2003 12:49:17 -0700
Received: from apgarcia by oppie with local (Exim 3.35 #1 (Debian))
	id 196bqm-0007hJ-00
	for <nfs@lists.sourceforge.net>; Fri, 18 Apr 2003 14:48:44 -0500
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

Hi,

We've come across a problem that seems related to the interaction
between NFS and a 3ware 7500-8 running RAID 5 with one hot spare.  We
have a test program that opens a file and then loops, writing up to
255 bytes to the file and then sleeping for up to 10 seconds.  We run
around 200 instances of the program simultaneously for about 25
minutes.

When we run the processes on 200 separate slaves, writing to a
(reiserfs) directory under the 3ware controller, the load on the
server shoots up to over 20 and then gradually declines over the next
5 minutes or so.

When we run the processes on 200 separate slaves, writing to a
different disk/directory (again reiserfs) on the same NFS server, the
load stays fine.

When we run 200 processes locally on the server, writing to the
directory under the 3ware controller, again the load stays low.

Any insights would be much appreciated...


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
