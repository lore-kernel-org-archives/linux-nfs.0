From: Hua Qin <qinhua@poisson.ecse.rpi.edu>
Subject: nfs client hung when trying to write a big file to server (2.4.18,
 2.4.9)
Date: Tue, 12 Nov 2002 15:49:02 -0500 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.GSO.4.10.10211121544130.7384-100000@poisson.ecse.rpi.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.rpi.edu ([128.113.22.40])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Bhz3-0007Al-00
	for <nfs@lists.sourceforge.net>; Tue, 12 Nov 2002 12:50:05 -0800
Received: from poisson.ecse.rpi.edu (poisson.ecse.rpi.edu [128.113.50.30])
	by mail.rpi.edu (8.12.1/8.12.1) with ESMTP id gACKn8XK237496
	for <nfs@lists.sourceforge.net>; Tue, 12 Nov 2002 15:49:08 -0500
Received: from localhost (qinhua@localhost)
	by poisson.ecse.rpi.edu (8.9.1/8.9.1) with ESMTP id PAA07518
	for <nfs@lists.sourceforge.net>; Tue, 12 Nov 2002 15:49:02 -0500 (EST)
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


I mounted 10 points  from a nfs client to a nfs server  by using the
following command:
mount -t nfs nfs_server:/usr/nfs/dir0 /mnt/nfs0
mount -t nfs nfs_server:/usr/nfs/dir1 /mnt/nfs1
mount -t nfs nfs_server:/usr/nfs/dir2 /mnt/nfs2
mount -t nfs nfs_server:/usr/nfs/dir3 /mnt/nfs3
mount -t nfs nfs_server:/usr/nfs/dir4 /mnt/nfs4
mount -t nfs nfs_server:/usr/nfs/dir5 /mnt/nfs5
mount -t nfs nfs_server:/usr/nfs/dir6 /mnt/nfs6
mount -t nfs nfs_server:/usr/nfs/dir7 /mnt/nfs7
mount -t nfs nfs_server:/usr/nfs/dir8 /mnt/nfs8
mount -t nfs nfs_server:/usr/nfs/dir9 /mnt/nfs9

Then I tried to do nfs write on nfs client side:
cp /usr/lib/* /mnt/nfs0 &
cp /usr/lib/* /mnt/nfs1 &
cp /usr/lib/* /mnt/nfs2 &
cp /usr/lib/* /mnt/nfs3 &
cp /usr/lib/* /mnt/nfs4 &
cp /usr/lib/* /mnt/nfs5 &
cp /usr/lib/* /mnt/nfs6 &
cp /usr/lib/* /mnt/nfs7 &
cp /usr/lib/* /mnt/nfs8 &
cp /usr/lib/* /mnt/nfs9 &

nfs client always hung at trying to write a 20MB file like "libc.a"
I went to the crash the back trace the "cp" command, and I can see all the
cps hung at

crash3.3> bt 1319
PID: 1319   TASK: f3aaa000  CPU: 1   COMMAND: ?cp?
 #0 [f3aabe70] schedule at c011a7f0
    (void)
 #1 [f3aabee0] __lock_page at c01328b4
    (c19114d0)
 #2 [f3aabf24] do_generic_file_read at c0133256
    (f3b9f920, f3b9f940, f3aabf40, file_read_actor, 0)
 #3 [f3aabf5c] generic_file_new_read at c01336f1
    (f3b9f920, bffe5830, 2000, f3b9f940, 0)
 #4 [f3aabf78] generic_file_read at c013368a
    (f3b9f920, bffe5830, 2000, f3b9f940)
 #5 [f3aabfbc] sys_read at c0146b38
    (3, bffe5830, 2000)


Does someone know is there any patch for this? I tested 2.4.9 (as)and
2.4.18, same problem.

Thanks!
Hua







-------------------------------------------------------
This sf.net email is sponsored by: 
To learn the basics of securing your web site with SSL, 
click here to get a FREE TRIAL of a Thawte Server Certificate: 
http://www.gothawte.com/rd522.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
