From: Joshua Baker-LePain <jlb17@duke.edu>
Subject: Odd errors and bad performance -- NFS/MD/centOS 4
Date: Tue, 15 Nov 2005 13:51:44 -0500 (EST)
Message-ID: <Pine.LNX.4.62.0511151326270.806@chaos.egr.duke.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ec5uI-0005Bw-78
	for nfs@lists.sourceforge.net; Tue, 15 Nov 2005 10:51:50 -0800
Received: from chaos.egr.duke.edu ([152.3.195.82])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Ec5uG-0002yy-VA
	for nfs@lists.sourceforge.net; Tue, 15 Nov 2005 10:51:50 -0800
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

I recently upgraded 2 of my older, 2TB file servers from RH7.3(!!) to 
centos-4.  The servers each have 2 3ware 7500-8 boards and 16 drives.  In 
7.3, I ran the 3wares in hardware RAID5 mode (with a hot spare), and a 
software RAID0 across the 2 arrays.  I used XFS, and saw local write 
speeds of 150MB/s and reads of 300MB/s.

Given RH's absurd attitude toward XFS, I decided it was time to bite the 
bullet and transition to ext3.  So I took a snapshot backup, reinstalled, 
and tried to run in the same setup.  Performance with ext3 was a joke. 
Despite days of tweaking (all detailed on nahant-list), ext3 topped out at 
about 34 MB/s writing.

So I replicated my setup in software RAID -- 2 RAID5s and a RAID0 of those 
(I stayed away from 1 big RAID5 so as not to lose any redundancy compared 
to the original setup, and RAID6 in centos 4 seems to have a bad resync 
bug).  Local performance was just fine -- 120MB/s writes and 180MB/s reads 
(as measured by bonnie++ -- tiobench gave good numbers as well).  Yay, say 
I, now I can finally start restoring the data.

However, the NFS performance of these beasts is bad with the added fun of 
odd quirks.  Directory listings of even small directories can hang for 
long (10+ min) periods of times on one client while instantaneously 
returning on another.  At random times, users report that they get "No 
such file or directory" when trying to 'ls' dirs they know are there, or 
get "Stale NFS file handle" when 'cd'ing into said directories.  These 
tend to be accompanied by the following in the client logs:

RPC: error 512 connecting to server $SERVER
nfs_statfs: statfs error = 512

Clients are a mix of both centOS 3 and centOS 4, both 100Mbps and 1Gbps. 
The FSs are exported with (rw,sync,no_root_squash) and mounted with 
wsize=32768,rsize=32768,hard,intr,tcp.  The servers are Gbps with the 
following TCP related sysctl.conf options:

net.core.wmem_max = 8388608
net.core.rmem_max = 8388608
net.ipv4.tcp_rmem = 4096 16777216 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216

In terms of performance, a remote bonnie++ run via a gigabit connected 
client gives these numbers:

Version  1.03       ------Sequential Output------ --Sequential Input-  --Random-
                     -Per Chr- --Block-- -Rewrite- -Per Chr- --Block--  --Seeks--
Machine        Size K/sec %CP K/sec %CP K/sec %CP K/sec %CP K/sec %CP   /sec %CP
$HOST            4G           11392   2  8153   4           50265  13  250.2   0
                     ------Sequential Create------ --------Random  Create--------
                     -Create-- --Read--- -Delete-- -Create-- --Read---  -Delete--
               files  /sec %CP  /sec %CP  /sec %CP  /sec %CP  /sec %CP   /sec %CP
                  16    71   0  7031  10    76   0    70   0  8070   9     75   0
harry.egr.duke.edu,4G,,,11392,2,8153,4,,,50265,13,250.2,0,16,71,0,7031,10,76,0,70,0,8070,9,75,0

The write speed and the creation and deletion speeds seem awfully slow to 
me.  In addition, the load on the server goes *very* high despite little 
actual CPU usage (see <http://www.duke.edu/~jlb17/md.html> for ganglia 
generated graphs during the bonnie run).  I've tried pinning the IRQs for 
the network interfaces and 3wares to separate CPUs, but that had little to 
no effect on performance.

While I can somewhat live with the performance (although I'd rather not 
have to), the errors are frustrating as hell (especially as they're 
difficult to reproduce at will).  Is there a differential diagnosis for 
this galaxy of symptoms (sorry -- my wife's a doc)?  Any help would be 
*much* appreciated.

-- 
Joshua Baker-LePain
Department of Biomedical Engineering
Duke University


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
Register for a JBoss Training Course.  Free Certification Exam
for All Training Attendees Through End of 2005. For more info visit:
http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
