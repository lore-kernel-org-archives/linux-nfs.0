Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from devi.upf.edu ([193.145.56.107]:57110 "EHLO devi.upf.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751730Ab1ALROq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Jan 2011 12:14:46 -0500
Received: from devi.upf.edu (localhost [127.0.0.1])
	by devi.upf.edu (8.13.6/8.13.6) with ESMTP id p0CHEic7019745
	for <linux-nfs@vger.kernel.org>; Wed, 12 Jan 2011 18:14:44 +0100
Received: from ws091374.cm.upf.edu (ws091374.cm.upf.edu [172.22.2.247])
	(authenticated bits=0)
	by devi.upf.edu (8.13.6/8.13.6) with ESMTP id p0CHEh9J019741
	for <linux-nfs@vger.kernel.org>; Wed, 12 Jan 2011 18:14:43 +0100
Message-ID: <4D2DE18D.40604@upf.edu>
Date: Wed, 12 Jan 2011 18:14:53 +0100
From: Txema Heredia Genestar <txema.heredia@upf.edu>
To: linux-nfs@vger.kernel.org
Subject: NFSv4 memory allocation bug?
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

  Hello everybody,

I have a host serving disk through the network using NFS v3, and it has 
been working ok for 3 years. Recently I have been benchmarking its 
throughput and I wanted to test how it would work if I used NFS v4 
instead, but I couldn't mount a single drive.

This is what I see:

Client:
client# mount -v -t nfs4 serverurl:/ /mnt/NFS_test/
mount: pinging: prog 100003 vers 4 prot tcp port 2049
---no response---

Server:
No error messages. Once I enabled debugging with echo "65535" > 
/proc/sys/sunrpc/nfsd_debug :

/var/log/messages:
Jan 12 13:02:35 server kernel: NFSD: laundromat service - starting
Jan 12 13:02:35 server kernel: NFSD: laundromat_main - sleeping for 90 
seconds
Jan 12 13:02:40 server kernel: nfsd_dispatch: vers 4 proc 0
Jan 12 13:02:40 server kernel: nfsd_dispatch: vers 4 proc 0
Jan 12 13:02:40 server kernel: nfsd_dispatch: vers 4 proc 1
Jan 12 13:02:40 server kernel: nfsv4 compound op #1: 24
Jan 12 13:02:40 server kernel: nfsd: Dropping request due to malloc failure!


And if rpc debugging is enabled:

Jan 11 18:50:48 server kernel: svc: socket ffff810252868680 busy, not 
enqueued
Jan 11 18:50:48 server kernel: svc: calling dispatcher
Jan 11 18:50:48 server kernel: nfsd_dispatch: vers 4 proc 0
Jan 11 18:50:48 server kernel: svc: socket ffff81029c53a580 
sendto([ffff8102273eb000 28... ], 28) = 28 (addr cbc916ac)
Jan 11 18:50:48 server kernel: svc: socket ffff810252868680 busy, not 
enqueued
Jan 11 18:50:48 server kernel: svc: server ffff81027d33d000 waiting for 
data (to = 900000)
Jan 11 18:50:48 server kernel: svc: server ffff81025e481400, socket 
ffff810127c28880, inuse=1
Jan 11 18:50:48 server kernel: svc: tcp_recv ffff810127c28880 data 0 
conn 1 close 0
Jan 11 18:50:48 server kernel: svc: tcp_accept ffff810127c28880 sock 
ffff81029821b340
Jan 11 18:50:48 server kernel: svc: tcp_accept ffff81027c7f08c0 allocated
Jan 11 18:50:48 server kernel: svc: got len=0
Jan 11 18:50:48 server kernel: svc: server ffff81025e481400 waiting for 
data (to = 900000)
Jan 11 18:50:48 server kernel: svc: server ffff810251911800, socket 
ffff81029c53a580, inuse=1
Jan 11 18:50:48 server kernel: svc: tcp_recv ffff81029c53a580 data 1 
conn 0 close 0
Jan 11 18:50:48 server kernel: svc: socket ffff81029c53a580 
recvfrom(ffff81029c53a628, 4) = -11
Jan 11 18:50:48 server kernel: RPC: TCP recvfrom got EAGAIN
Jan 11 18:50:48 server kernel: svc: got len=-11
Jan 11 18:50:48 server kernel: svc: server ffff810251911800 waiting for 
data (to = 900000)
Jan 11 18:50:48 server kernel: svc: socket ffff810252868680 TCP data 
ready (svsk ffff81029c53a580)
Jan 11 18:50:48 server kernel: svc: socket ffff810252868680 served by 
daemon ffff810251911800
Jan 11 18:50:48 server kernel: svc: server ffff810251911800, socket 
ffff81029c53a580, inuse=1
Jan 11 18:50:48 server kernel: svc: tcp_recv ffff81029c53a580 data 1 
conn 0 close 0
Jan 11 18:50:48 server kernel: svc: socket ffff81029c53a580 
recvfrom(ffff81029c53a62c, 0) = 4
Jan 11 18:50:48 server kernel: svc: TCP record, 144 bytes
Jan 11 18:50:48 server kernel: svc: socket ffff81029c53a580 
recvfrom(ffff81011f93a090, 3952) = 144
Jan 11 18:50:48 server kernel: svc: TCP complete record (144 bytes)
Jan 11 18:50:48 server kernel: svc: socket ffff810252868680 served by 
daemon ffff81025e481400
Jan 11 18:50:48 server kernel: svc: got len=144
Jan 11 18:50:48 server kernel: svc: server ffff81025e481400, socket 
ffff81029c53a580, inuse=2
Jan 11 18:50:48 server kernel: svc: svc_authenticate (1)
Jan 11 18:50:48 server kernel: svc: tcp_recv ffff81029c53a580 data 1 
conn 0 close 0
Jan 11 18:50:48 server kernel: svc: socket ffff81029c53a580 
recvfrom(ffff81029c53a628, 4) = -11
Jan 11 18:50:48 server kernel: Want update, refage=120, age=0
Jan 11 18:50:48 server kernel: RPC: TCP recvfrom got EAGAIN
Jan 11 18:50:48 server kernel: svc: got len=-11
Jan 11 18:50:48 server kernel: svc: server ffff81025e481400 waiting for 
data (to = 900000)
Jan 11 18:50:48 server kernel: svc: svc_process dropit
Jan 11 18:50:48 server kernel: svc: socket ffff81029c53a580 dropped request
Jan 11 18:50:48 server kernel: svc: server ffff810251911800 waiting for 
data (to = 900000)
Jan 11 18:50:48 server kernel: revisit queued
Jan 11 18:50:48 server kernel: svc: socket ffff810252868680 served by 
daemon ffff810251911800
Jan 11 18:50:48 server kernel: svc: server ffff810251911800, socket 
ffff81029c53a580, inuse=1
Jan 11 18:50:48 server kernel: svc: tcp_recv ffff81029c53a580 data 0 
conn 0 close 0
Jan 11 18:50:48 server kernel: svc: socket ffff810252868680 served by 
daemon ffff81025e481400
Jan 11 18:50:48 server kernel: svc: got len=144
Jan 11 18:50:48 server kernel: svc: svc_authenticate (1)
Jan 11 18:50:48 server kernel: svc: server ffff81025e481400, socket 
ffff81029c53a580, inuse=2
Jan 11 18:50:48 server kernel: svc: calling dispatcher
Jan 11 18:50:48 server kernel: nfsd_dispatch: vers 4 proc 1
Jan 11 18:50:48 server kernel: svc: tcp_recv ffff81029c53a580 data 0 
conn 0 close 0
Jan 11 18:50:48 server kernel: svc: socket ffff81029c53a580 
recvfrom(ffff81029c53a628, 4) = -11
Jan 11 18:50:48 server kernel: nfsv4 compound op #1: 24
Jan 11 18:50:48 server kernel: RPC: TCP recvfrom got EAGAIN
Jan 11 18:50:48 server kernel: svc: got len=-11
Jan 11 18:50:48 server kernel: svc: server ffff81025e481400 waiting for 
data (to = 900000)
Jan 11 18:50:48 server kernel: Want update, refage=120, age=0
Jan 11 18:50:48 server kernel: nfsd: Dropping request due to malloc failure!
Jan 11 18:50:48 server kernel: svc: svc_process dropit
Jan 11 18:50:48 server kernel: svc: socket ffff81029c53a580 dropped request
Jan 11 18:50:48 server kernel: svc: server ffff810251911800 waiting for 
data (to = 900000)



Additionally, I have checked tcpdump and found, when mounting an NFS4 
drive from a working storage-system:
...
12:38:06.372303 IP client.907 > storage.nfs: . ack 29 win 46 
<nop,nop,timestamp 4063464822 174132214>
12:38:06.372429 IP client.2364980656 > storage.nfs: 148 getattr [|nfs]
12:38:06.372792 IP storage.nfs > client.2364980656: reply ok 248 getattr 
[|nfs]
12:38:06.372958 IP client.2381757872 > storage.nfs: 172 getattr [|nfs]
12:38:06.373132 IP storage.nfs > client.2381757872: reply ok 88 getattr 
[|nfs]
12:38:06.373157 IP client.2398535088 > storage.nfs: 176 getattr [|nfs]
12:38:06.373316 IP storage.nfs > client.2398535088: reply ok 100 getattr 
[|nfs]
12:38:06.373339 IP client.2415312304 > storage.nfs: 172 getattr [|nfs]


But when I mount from the same client, the NFS4 share from my server 
gets stuck on the "getattr" call
...
12:36:37.051840 IP client.926 > server.nfs: . ack 29 win 140 
<nop,nop,timestamp 4063375488 434039929>
12:36:37.051903 IP client.1734362088 > server.nfs: 148 getattr [|nfs]
12:36:37.090274 IP server.nfs > client.926: . ack 192 win 4742 
<nop,nop,timestamp 434039939 4063375488>
---silence---



So I suppose that the "RPC: TCP recvfrom got EAGAIN" on the messages log 
corresponds to that "getattr[|nfs]" call.

I have been searching around and I have found several threads about 
either the "malloc failure" message or the "EAGAIN" message. But I 
haven't found anything concerning them both at the same time. I have 
also checked for this kind of problems in NFS4 and found nothing useful.

May this be some kind of (already solved) bug in my nfs implementation? 
I'm running a pretty old version (SuSE LES 10.2, nfs-utils 1.0.7-36.2)

Thanks in advance,

Txema




My configuration files:

# cat /etc/sysconfig/nfs
USE_KERNEL_NFSD_NUMBER="4"
MOUNTD_PORT="980"
NFS_SECURITY_GSS="no"
NFS4_SUPPORT="yes"

# cat /etc/exports
#TESTS NFS 4
/NFS4exports    
172.22.201.0/24(rw,sync,no_root_squash,no_subtree_check,secure,secure_locks,acl,mp,fsid=0,no_wdelay)
/NFS4exports    
172.22.202.0/24(rw,sync,no_root_squash,no_subtree_check,secure,secure_locks,acl,mp,fsid=0,no_wdelay)
/NFS4exports/NFS_test_params    
172.22.201.0/24(rw,sync,no_root_squash,no_subtree_check,secure,hide,secure_locks,acl,mp,fsid=255,no_wdelay)
/NFS4exports/NFS_test_params    
172.22.202.0/24(rw,sync,no_root_squash,no_subtree_check,secure,hide,secure_locks,acl,mp,fsid=255,no_wdelay)
#NFS 3 working ones
#/sp/fs/NFS_test_params 
172.22.201.0/24(rw,sync,no_root_squash,no_subtree_check,secure,hide,secure_locks,acl,mp,fsid=255,no_wdelay) 
172.22.202.0/24(rw,sync,no_root_squash,no_subtree_check,secure,hide,secure_locks,acl,mp,fsid=255,no_wdelay)

# cat /etc/idmapd.conf
[General]
Verbosity=1
Pipefs-Directory=/var/lib/rpc_pipefs
Domain=mydomain
[Mapping]
Nobody-User=nobody
Nobody-Group=nobody

PS: This is my very first post on this list, so I'm not sure if I am 
missing something.

