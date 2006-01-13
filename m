From: Andi Kleen <ak@suse.de>
Subject: LTP NFS data corruption in 2.6.15-git9
Date: Fri, 13 Jan 2006 21:37:10 +0100
Message-ID: <200601132137.10615.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ExVgM-0003Kh-O7
	for nfs@lists.sourceforge.net; Fri, 13 Jan 2006 12:37:58 -0800
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ExVgM-0008He-7M
	for nfs@lists.sourceforge.net; Fri, 13 Jan 2006 12:37:58 -0800
To: okir@suse.de, neilb@suse.de, trond.myklebust@fys.uio.no
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


FWIW - i was just running LTP- for 2.6.15-git9 on a x86-64 nfs root machine
talking to 2.6.15 machine with NFSv3/UDP. During the IO tests I got 
this. Export was with rw,async. 

The network was 100 GBit/s so I wouldn't assume it was caused by 
fragment reordering [Why UDP? That is what the kernel nfs root 
mounter selected]

To reproduce just run LTP 20051103 runltp over NFS.

-Andi

doio(rwtest03) (21516) 04:19:53
---------------------
*** DATA COMPARISON ERROR ***
check_file(/tmp/ltp-16542/mm-buff-21500, 6133913, 37155, B:21516:linux:doio*, 19
, 0) failed

Comparison fd is 3, with open flags 0
Corrupt regions follow - unprintable chars are represented as '.'
-----------------------------------------------------------------
corrupt bytes starting at file offset 6160384
    1st 32 expected bytes:  516:linux:doio*B:21516:linux:doi
    1st 32 actual bytes:    ................................

Request number 12
          fd 4 is file /tmp/ltp-16542/mm-buff-21500 - open flags are 02 O_RDWR,
          write done at file offset 6133913 - pattern is B (0102)
          number of requests is 1, strides per request is 1
          i/o byte count = 37155
          memory alignment is unaligned

syscall:  mmap-write(NULL, 12800000, PROT_WRITE, MAP_SHARED, 4, 0)
        file is mmaped to: 0xf71f2000
        file-mem=0xf77cb899, length=37155, buffer=0x8073368


doio(rwtest03) (21514) 04:19:53
---------------------
(parent) pid 21516 exited because of data compare errors
rwtest(rwtest03) : doio reported errors (r=4)
rwtest03    1  FAIL  :  doio reported errors (r=4)
rwtest03    1  FAIL  :  Test failed

doio(rwtest04) (21540) 04:21:03
---------------------
*** DATA COMPARISON ERROR ***
check_file(/tmp/ltp-16542/mm-sync-21525, 12522037, 83920, Q:21540:linux:doio*, 1
9, 0) failed

Comparison fd is 5, with open flags 0
Corrupt regions follow - unprintable chars are represented as '.'
-----------------------------------------------------------------
corrupt bytes starting at file offset 12582913
    1st 32 expected bytes:  Q:21540:linux:doio*Q:21540:linux
    1st 32 actual bytes:    B:21541:linux:doio*B:21541:linux

Request number 126
          fd 4 is file /tmp/ltp-16542/mm-sync-21525 - open flags are 010002 O_RD
WR,O_SYNC,
          write done at file offset 12522037 - pattern is Q (0121)
          number of requests is 1, strides per request is 1
          i/o byte count = 83920
          memory alignment is unaligned

syscall:  mmap-write(NULL, 12800000, PROT_WRITE, MAP_SHARED, 4, 0)
        file is mmaped to: 0xf7257000
        file-mem=0xf7e48235, length=83920, buffer=0x8073369


doio(rwtest04) (21539) 04:21:03
---------------------
(parent) pid 21540 exited because of data compare errors


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
