From: "Bruce Allan" <bruce.allan@us.ibm.com>
Subject: Re: 3 bugs with UDP mounts
Date: Mon, 22 Apr 2002 10:00:59 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OF1E841CCB.33C98FFC-ON88256BA3.005D4EE6@boulder.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from e31.co.us.ibm.com ([32.97.110.129])
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 16zhBm-0002WQ-00
	for <nfs@lists.sourceforge.net>; Mon, 22 Apr 2002 10:01:18 -0700
To: Andrew Ryan <andrewr@nam-shub.com>
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


I also witnessed the same problem (problem #3 below) at the Connectathon
event this year with NFSv3 on both TCP and UDP.  Trond was there and he
verified this was a bug in NetApp's ONTAP 6.1.1 having to do with, IIRC,
how they handle byte swapping against little-endian clients.  This bug was
also discovered at the 2001 Connectathon event.  NetApp fixed this in a
later release of ONTAP (I think they said it was fixed in 6.1.2 but don't
quote me on that).

---
Bruce Allan  <bruce.allan@us.ibm.com>
Software Engineer, Linux Technology Center
IBM Corporation, Beaverton OR
503-578-4187   IBM Tie-line 775-4187



                                                                                                                                      
                      Andrew Ryan                                                                                                     
                      <andrewr@nam-shub.co        To:       nfs@lists.sourceforge.net                                                 
                      m>                          cc:                                                                                 
                      Sent by:                    Subject:  [NFS] 3 bugs with UDP mounts                                              
                      nfs-admin@lists.sour                                                                                            
                      ceforge.net                                                                                                     
                                                                                                                                      
                                                                                                                                      
                      04/21/2002 12:06 PM                                                                                             
                                                                                                                                      
                                                                                                                                      




Running performance tests on NFS this past week, I've uncovered 3 apparent
bugs. The first bug is pretty unpleasant, but the second two are fairly
minor.

kernel: 2.4.17+NFS-ALL-2002-Jan-17, 2.4.19pre7+NFS-ALL. Both SMP on a 2-CPU
system.
nfs-utils-0.3.1-13.7.2.1, mount-2.11g-5
server: NetApp
network: 100baseTx-FD on client, gigE-FD on server

1. UDP read performance (v2 and v3) on large files is really poor. I first
noticed this problem when trying to get bonnie++ and tiobench results and
seeing runs which should take about 20 minutes take 24+ hours. To duplicate
this, I created a 1600MB file filled with zeros, and this went quickly.
While writing the file, on the server I saw ~500 NFS ops/sec, and about
4400 kB/s in on the network interface. When I tried reading the file back,
with 'cat /path/to/file > /dev/null' I saw initially fast reads; 7900kB/s
for a few seconds, then slowing down to 100kB/s and ~100 NFSops/sec after a
few seconds.

I can get excellent read performance, as long as the files are relatively
small. With a Solaris client, mounting the same server UDP (and also
100baseTx-FD), reading the same file is done at a consistently high speed,
so it definitely seems to be a linux-specific problem.


2. I accidentally mounted an NFS filesystem
"udp,nfsvers=3,rsize=32768,wsize=32768". For one, I don't exactly
understand why this was allowed, since it doesn't seem like I should be
allowed to mount NFS/UDP with these options. Also, this creates a
disagreement between what is returned by the 'mount' command and 'cat
/proc/mounts'.

The relevant line from the 'mount' command shows this:
fileserver:/vol/stage/data on /shared/data type nfs
(rw,udp,nfsvers=3,rsize=32768,wsize=32768,intr,hard,addr=192.168.100.240)

while the relevant line from /proc/mounts shows this:
fileserver:/vol/stage/data /shared/data nfs
rw,v3,rsize=8192,wsize=8192,hard,intr,udp,lock,addr=fileserver 0 0
This may be a problem with my version of mount or nfs-utils, anyone seen
this before?


3. Running the cthon02 tests with UDP/v3 I get one failure. This looks like
a trivial problem to fix, if in fact it is a problem and not just a
disagreement about how the spec is interpreted.
Test #6 - Try to lock the MAXEOF byte.
         Parent: 6.0  - F_TLOCK [7fffffff,       1] PASSED.
         Child:  6.1  - F_TEST  [7ffffffe,       1] PASSED.
         Child:  6.2  - F_TEST  [7ffffffe,       2] FAILED!
         Child:  **** Expected EACCES, returned EOVERFLOW...
         Child:  **** Probably implementation error.


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs




_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
