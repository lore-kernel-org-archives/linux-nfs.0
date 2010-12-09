Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from nm14-vm1.bullet.mail.ird.yahoo.com ([77.238.189.91]:32414 "HELO
	nm14-vm1.bullet.mail.ird.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752403Ab0LIQKf convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Dec 2010 11:10:35 -0500
Message-ID: <616646.45534.qm@web29119.mail.ird.yahoo.com>
Date: Thu, 9 Dec 2010 16:03:52 +0000 (GMT)
From: mailing lists <listas.correo@yahoo.es>
Subject: low NFS performance with small files
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello,

 While trying to debug a low nfs throughput configuration between Linux servers 
and the NAS/SAN storage system and I was astonished by the low performance. I 
setup my pc (opensuse 11.3) as a nfs server and mount it through the loopback 
interface to discard network issues and again the numbers were surprisingly low. 


Let me show you the results, the first test is over /var/lib/xen/images (ext4) 
and the second test is the same directory exported by nfs (version 3) and 
mounted on /media/nfs. Changing application blocksize, network buffers or any 
other parameter (rsize,wsize,relatime,noatime,...) makes no big difference. The 
final system is for mail queues and mail storage so there will a lot of small 
files on average.

Any idea about were the bottleneck or misconfiguration could be?


#  grep nfs /proc/mounts 
nfsd /proc/fs/nfsd nfsd rw,relatime 0 0
localhost:/var/lib/xen/images /media/nfs nfs 
rw,relatime,vers=3,rsize=262144,wsize=262144,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=127.0.0.1,mountvers=3,mountport=56451,mountproto=udp,addr=127.0.0.1
 0 0

pm>show
Current configuration is:
The base number of files is 30000
Transactions: 10
Files range between 500 bytes and 9.77 kilobytes in size
Working directory: /var/lib/xen/images
Block sizes are: read=512 bytes, write=512 bytes
Biases are: read/append=-1, create/delete=10
Using Unix buffered file I/O
Random number generator seed is 42
Report format is verbose.
pm>run
Creating files...Done
Performing transactions..........Done
Deleting files...Done
Time:
        4 seconds total
        1 seconds of transactions (10 per second)

Files:
        30010 created (7502 per second)
                Creation alone: 30000 files (10000 per second)
                Mixed with transactions: 10 files (10 per second)
        0 read (0 per second)
        0 appended (0 per second)
        30010 deleted (7502 per second)
                Deletion alone: 30010 files (30010 per second)
                Mixed with transactions: 0 files (0 per second)

Data:
        0.000000 bytes read (0.000000 bytes per second)
        149.58 megabytes written (37.40 megabytes per second)
pm>set location /media/nfs
pm>run
Creating files...Done
Performing transactions..........Done
Deleting files...Done
Time:
        1156 seconds total
        1 seconds of transactions (10 per second)

Files:
        30010 created (25 per second)
                Creation alone: 30000 files (26 per second)
                Mixed with transactions: 10 files (10 per second)
        0 read (0 per second)
        0 appended (0 per second)
        30010 deleted (25 per second)
                Deletion alone: 30010 files (3751 per second)
                Mixed with transactions: 0 files (0 per second)

Data:
        0.000000 bytes read (0.000000 bytes per second)
        149.58 megabytes written (132.50 kilobytes per second)



      
