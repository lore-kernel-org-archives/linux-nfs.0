From: Bruce Allen <ballen@gravity.phys.uwm.edu>
Subject: slow NFS performance extracting bits from large files
Date: Mon, 16 Dec 2002 01:02:55 -0600 (CST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.GSO.4.21.0212160054001.4121-100000@dirac.phys.uwm.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Bruce Allen <ballen@gravity.phys.uwm.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from uwm.edu ([129.89.7.2] ident=root)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18NpHK-0000F8-00
	for <nfs@lists.sourceforge.net>; Sun, 15 Dec 2002 23:03:02 -0800
Received: from dirac.phys.uwm.edu (dirac.phys.uwm.edu [129.89.57.19])
	by uwm.edu (8.12.6/8.12.6) with ESMTP id gBG72uMn026005
	for <nfs@lists.sourceforge.net>; Mon, 16 Dec 2002 01:02:56 -0600 (CST)
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

I've searched/browsed the mail archive and the online documentation but am
still a bit clueless about where to start.

I am working on a scientific data analysis application which needs to
extract a little bit of data from around 10,000 files.  The files
themselves are each around 1 MB in size. The application does:

for (i=0; i<10000; i++){
  open() ith file
  read() 32 bytes from beginning
  lseek() to somewhere in the middle of the file
  read() 620 bytes from the middle of the file
  close() ith file
}

If I run this with the data set on a local disk, the total run time is
around 1 sec -- very reasonable since I am transferring around 6 MB of
data.

If I run this on an NFS-mounted disk the performance is 100 times worse.
Both client and server are stock RH 7.3.  Note that if I run it a second
time, when the data is presumably cached, it takes just a few seconds to
run.

Is it obvious what needs to be changed/tuned to improve this performance?
Or if not, could someone suggest a tool and a strategy for tracing down
the cause of the poor performance?

Sincerely,
	Bruce Allen




-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
