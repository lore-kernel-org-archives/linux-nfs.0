Return-Path: linux-nfs-owner@vger.kernel.org
Received: from vms173025pub.verizon.net ([206.46.173.25]:53987 "EHLO
	vms173025pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742AbaFDTDV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jun 2014 15:03:21 -0400
Received: from CappsG570 ([unknown] [198.95.226.236])
 by vms173025.mailsrvcs.net
 (Sun Java(tm) System Messaging Server 7u2-7.02 32bit (built Apr 16 2009))
 with ESMTPA id <0N6N00IWWOSY6KD0@vms173025.mailsrvcs.net> for
 linux-nfs@vger.kernel.org; Wed, 04 Jun 2014 13:03:00 -0500 (CDT)
Reply-to: <capps@iozone.org>
From: "Iozone" <capps@iozone.org>
To: <linux-nfs@vger.kernel.org>
References: <004501cf8013$7a3373c0$6e9a5b40$@iozone.org>
In-reply-to: <004501cf8013$7a3373c0$6e9a5b40$@iozone.org>
Subject: FW: Forwarding request at suggestion from support
Date: Wed, 04 Jun 2014 13:02:54 -0500
Message-id: <005d01cf801f$363aabf0$a2b003d0$@iozone.org>
MIME-version: 1.0
Content-type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



From: Iozone [mailto:capps@iozone.org] 
Sent: Wednesday, June 04, 2014 11:39 AM
To: linux-nfs@vger.kernel.org
Subject: Forwarding request at suggestion from support

                Dear kernel folks,

                                Please take a look at Bugzilla bug: 
                               
https://bugzilla.redhat.com/show_bug.cgi?id=1104696

Description of problem:
 
   Linux NFSv3 clients can issue extra reads beyond EOF.
 
Condition of the test:  (32KB_file is a file that is 32KB in size)
          File is being read over an NFSv3 mount.
 
          dd if=/mnt/32KB_file  of=/dev/null iflag=direct bs=1M count=1
 
What one should expect over the wire:
          NFSv3_read for 32k, or NFS_read for 1M
          NFSv3_read Reply return of 32KB and EOF set.
 
What happens with Linux NFSv3 client:
          NFSv3 read for 128k
          NFSv3 read for 128k, 
          NFSv3 read for 128k, 
          NFSv3 read for 128k,
          NFSv3 read for 128k, 
          NFSv3 read for 128k, 
          NFSv3 read for 128k, 
          NFSv3 read for 128k.
       followed by:
          NFSv3 read reply of 32k, 
          NFSv3 read reply of 0, 
          NFSv3 read reply of 0, 
          NFSv3 read reply of 0,
          NFSv3 read reply of 0,  
          NFSv3 read reply of 0, 
          NFSv3 read reply of 0, 
          NFSv3 read reply of 0.
 
So… instead of a single round trip with a short read length returned, there 
were 8 async I/O ops sent to the NFS server, and 8 replies from the NFS
server.  
The client knew the file size before even sending the very first request,
but
went ahead and issued an large number of reads that it should have known
were
beyond EOF.
 
This client behavior hammers NFS servers with requests that are guaranteed
to always fail, and burn 
CPU cycles, for operations that it knew were pointless.
 
While the application is getting correct answers to the API calls, the poor
client and server are beating each other senseless over the wire.
 
NOTE: This only happens if O_DIRECT is being used… (thus the iflag=direct)
  
Version-Release number of selected component (if applicable):
   Every version of Linux that I have tested seems to do this...
 
How reproducible:
   Extremely. Though the actual transfer size being sent by the Linux
   client is sometimes a bunch of 32k transfers, or 128k or 256k, depending
   on the version of the kernel, and the NFS mount block size.
 
   A worse case is app does 1MB read (with O_DIRECT), with NFS block size 
   set to 32K, the number of async reads is 1 useful and 31 that were 
   beyond EOF.  So for each 32k of file data, there are 62 extra NFS 
   messages between the client and the server, and only 2 messages that 
   made sense or ever should have taken place.  ( IMHO )
 
Steps to Reproduce:
  The steps are above.
 
In the attachment, the file size is 32k, the NFS block size is 32k. So you
can see all of the extra async (back to back) client requests that are 
all going to return zero, except the very first one.
 
               
----------------------------------------------------------------------------
-----------------------------------

                More details of why this is an issue:
 
                   In the SPECsfs2014 benchmark (under development) there is
a workload that 
                simulates a software build environment.  There are billions
of small files.  One of the 
                operations that is tested is to read an entire file.  This
operation uses  a large transfer 
                size so that it can read the files as efficiently as
possible.   Whenever the file size is smaller
                than this large transfer size, the NFS client issues 8 to 64
times as many I/Os 
                as were necessary to read the small file.  
                   If you take into consideration that this benchmark is
simulating hundreds, or
                thousands of users, with billions of files, and is using
multiple client nodes
                to present load to the server under test…. This overshoot on
the reads is 
                burying the NFS server with work that should never have been
sent to 
                the server.  Instead of the benchmark measuring how fast the
NFS server
                can serve files, it becomes a test of how many insane
requests beyond
                EOF can the server tolerate from a Linux NFSv3 client, while
serving almost
               no file data at all.  
 
                   I don’t understand why the Linux NFS client would ever
issue reads beyond
                EOF.    These files were opened, (LOOKUP, GETATTR, ACCESS)
so the Linux
                kernel knows the file size.  It should be a one line change
to the code to simply
                *not* issue async read-aheads for file data that is beyond
EOF. 

       AND….
       
                The Linux NFS client code certainly appears to know how to
not read beyond EOF when
               the O_DIRECT flag is off.  Why is this not the same when the
O_DIRECT flag is on ?  

Thank you,
Don Capps
Capps at iozone dot org

P.S.  This overshoot is also confirmed to be happening in the NFSv4 client
code.


