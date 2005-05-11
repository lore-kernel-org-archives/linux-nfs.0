From: Jeff Block <jblock@mrsc.ucsf.edu>
Subject: NFS Performance issues
Date: Tue, 10 May 2005 22:31:06 -0700
Message-ID: <BEA6E6AA.11AD0%jblock@mrsc.ucsf.edu>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DVjoO-0003xi-8n
	for nfs@lists.sourceforge.net; Tue, 10 May 2005 22:31:12 -0700
Received: from smtp815.mail.sc5.yahoo.com ([66.163.170.1])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.41)
	id 1DVjoM-0008PO-KS
	for nfs@lists.sourceforge.net; Tue, 10 May 2005 22:31:12 -0700
To: <nfs@lists.sourceforge.net>
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


We seem to be having some major performance problems on our redhat
enterprise linux 3 boxes.  Some of our machines have RAIDs attached, some
have internal SCSI drives, and some have internal IDE drives.   The one
thing all the boxes have in common is that there solaris counterparts are
putting them to shame in the nfs performance battle.

Here's some of the info and what we've already tried.
/etc/exports is simple:
/export/data    @all-hosts(rw,sync)

The automounter is used so the default mount options are used, looks like
this:
server:/export/data /data/mountpoint nfs
rw,v3,rsize=8192,wsize=8192,hard,udp,lock,addr=server 0 0

We can't change the rsize and wsize on these mounts because the precompiled
redhat kernel for vers3 maxes out at 8K.  We could of course compile our own
kernel, but doing this for more than a handful of machines can be a big
headache.  

We've tried moving the journaling from RAID devices onto another internal
disk.  This helped a little, but not much.

We have tried async, and that certainly does speed things up, but we are
definitely not comfortable with using async.

The big problem that we are having seems to do with copying a bunch of data
from one machine to another.

We have 683MB of test data that we were playing with that represents the
file sizes that our users play with.  There are several small files in this
set so there is a lot of writes and commits.  Our users generally work with
data sets in the multiple gigabyte range.
      
Test data - 683 MB 
NFS Testing:
Client | Server | Storage | NFS cp Time | SCP Time
Solaris | Solaris | RAID | 1:32 | 1:59
Linux A | Solaris | RAID | 0:42 | 2:51
Linux A | Linux B | RAID5 /Journal to SCSI | 3:17 | 2:05
Linux A | Linux B | RAID5 /Journal to RAID | 5:07 | 1:45
Linux A | Linux B | SCSI | 3:17 | 1:52
Linux A | Linux B | IDE | 1:36 | 2:27
       
Other Tests      
       
Internal Tests:    
Host/Storage | Host/Storage | cp Time
Linux B Int. SCSI | Linux B Ext. RAID5 | 0:37
Sol Int. SCSI | Sol Ext. RAID5 | 0:35
       
Network:      
Host A | Host B | Throughput
linux A | linux B | 893 Mbit/sec

Probably hard to read, but the bottom line is this:
Copying the 683MB from a linux host to a solaris RAID took 42 seconds.
Copying the same data from a linux host to a linux RAID took 5:07 or 3:17
depending on where the journal is stored.  My SCP times from Linux to Linux
RAID are much quicker than my nfs copies which seems pretty backwards to me.

Thanks in advance for the help on this.

Jeff Block
Programmer / Analyst
Radiology Research Computing
University of California, San Francisco




-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=7393&alloc_id=16281&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
