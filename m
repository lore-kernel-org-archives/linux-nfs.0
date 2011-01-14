Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mumba.upf.edu ([193.145.56.85]:43509 "EHLO mumba.upf.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753884Ab1ANMKw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Jan 2011 07:10:52 -0500
Received: from mumba.upf.edu (localhost [127.0.0.1])
	by mumba.upf.edu (8.13.6/8.13.6) with ESMTP id p0ECAmJo032725
	for <linux-nfs@vger.kernel.org>; Fri, 14 Jan 2011 13:10:49 +0100
Message-ID: <4D303D55.1080908@upf.edu>
Date: Fri, 14 Jan 2011 13:11:01 +0100
From: Txema Heredia Genestar <txema.heredia@upf.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 memory allocation bug?
References: <4D2DE18D.40604@upf.edu> <20110112183557.GB11718@fieldses.org> <4D2F1ECA.50703@upf.edu> <20110113161913.GG20946@fieldses.org> <4D2F3583.8090502@upf.edu> <20110113180534.GK20946@fieldses.org>
In-Reply-To: <20110113180534.GK20946@fieldses.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

  El 13/01/11 19:05, J. Bruce Fields escribió:
> On Thu, Jan 13, 2011 at 06:25:23PM +0100, Txema Heredia Genestar wrote:
>>   El 13/01/11 17:19, J. Bruce Fields escribió:
>>> On Thu, Jan 13, 2011 at 04:48:26PM +0100, Txema Heredia Genestar wrote:
>>>>   Hi Bruce, thanks for your answer
>>>>
>>>>
>>>> El 12/01/11 19:35, J. Bruce Fields escribió:
>>>>> On Wed, Jan 12, 2011 at 06:14:53PM +0100, Txema Heredia Genestar wrote:
>>>>>> Additionally, I have checked tcpdump and found, when mounting an
>>>>>> NFS4 drive from a working storage-system:
>>>>>> ...
>>>>>> 12:38:06.372303 IP client.907>    storage.nfs: . ack 29 win 46
>>>>>> <nop,nop,timestamp 4063464822 174132214>
>>>>>> 12:38:06.372429 IP client.2364980656>    storage.nfs: 148 getattr [|nfs]
>>>>>> 12:38:06.372792 IP storage.nfs>    client.2364980656: reply ok 248
>>>>>> getattr [|nfs]
>>>>>> 12:38:06.372958 IP client.2381757872>    storage.nfs: 172 getattr [|nfs]
>>>>>> 12:38:06.373132 IP storage.nfs>    client.2381757872: reply ok 88
>>>>>> getattr [|nfs]
>>>>>> 12:38:06.373157 IP client.2398535088>    storage.nfs: 176 getattr [|nfs]
>>>>>> 12:38:06.373316 IP storage.nfs>    client.2398535088: reply ok 100
>>>>>> getattr [|nfs]
>>>>>> 12:38:06.373339 IP client.2415312304>    storage.nfs: 172 getattr [|nfs]
>>>>>>
>>>>>>
>>>>>> But when I mount from the same client, the NFS4 share from my server
>>>>>> gets stuck on the "getattr" call
>>>>>> ...
>>>>>> 12:36:37.051840 IP client.926>    server.nfs: . ack 29 win 140
>>>>>> <nop,nop,timestamp 4063375488 434039929>
>>>>>> 12:36:37.051903 IP client.1734362088>    server.nfs: 148 getattr [|nfs]
>>>>>> 12:36:37.090274 IP server.nfs>    client.926: . ack 192 win 4742
>>>>>> <nop,nop,timestamp 434039939 4063375488>
>>>>>> ---silence---
>>>>> Something like wireshark would give a few more details.
>>>> I have wiresharked it and I don't see any differences between the
>>>> "getattr" packages in both cases. Do you want me to paste them in a
>>>> specific format?
>>> I'm curious which attributes were requested.  In particular, is the
>>> unreplied-to getattr the *first* time that the client requests the owner
>>> or owner_group attributes?
>>>
>> Yes, the "unreplied-to" getattr call is the very first (and only)
>> time it those are requested:
> Yeah, so almost certainly some idmapping problem.
Mi current idmap library is 0.12-16.20, built on 16/1/2009

>>> Might also be worth looking at the nfs4.idtoname cache contents after
>>> the hang:
>>>
>>> 	rpcdebug -m rpc -s cache
>>> 	cat /proc/net/rpc/nfs4.idtoname/content
>>>
>>> I seem to recall c9b6cbe56d3ac471e6cd72a59ec9e324b3417016 or
>>> 0a725fc4d3bfc4734164863d6c50208b109ca5c7 being possible causes of hangs.
>>>
>>> --b.
>> Unfortunately, rpcdebug is not present in this server. So my
>> /proc/net/rpc/nfs4.idtoname/content file is empty.
>>
>> May this command be of any use?
>> "echo "65535">  /proc/sys/sunrpc/rpc_debug"
> Yeah doing that may get you a little more information.
>
> Note that kernel's pretty out of date with respect to mainstream so your
> best bet is your distro support or seeing if you can reproduce the
> problem on a more recent kernel.
>
> --b.

This is the /var/log/messages log after enabling debugging for nfs, nfsd 
and rpc:

Jan 14 12:01:49 server kernel: svc: socket ffff81012024c7c0 TCP (listen) 
state change 10
Jan 14 12:01:49 server kernel: svc: socket ffff81012024c7c0 served by 
daemon ffff8102a5ede400
Jan 14 12:01:49 server kernel: svc: server ffff8102a5ede400, socket 
ffff8101fd09c080, inuse=1
Jan 14 12:01:49 server kernel: svc: tcp_recv ffff8101fd09c080 data 0 
conn 1 close 0
Jan 14 12:01:49 server kernel: svc: tcp_accept ffff8101fd09c080 sock 
ffff81028b747380
Jan 14 12:01:49 server kernel: svc: tcp_accept ffff810282a67780 allocated
Jan 14 12:01:49 server kernel: svc: socket ffff81012024c7c0 busy, not 
enqueued
Jan 14 12:01:49 server kernel: nfsd: connect from unprivileged port: 
172.22.201.203:40892
Jan 14 12:01:49 server kernel: nfsd: connect from 172.22.201.203:9fbc
Jan 14 12:01:49 server kernel: svc: svc_setup_socket ffff810282a67780
Jan 14 12:01:49 server kernel: setting up TCP socket for reading
Jan 14 12:01:49 server kernel: svc: svc_setup_socket created 
ffff810167ed3d80 (inet ffff810125e547c0)
Jan 14 12:01:49 server kernel: svc: socket ffff810125e547c0 served by 
daemon ffff810236f4f000
Jan 14 12:01:49 server kernel: svc: socket ffff81012024c7c0 served by 
daemon ffff81029edad000
Jan 14 12:01:49 server kernel: svc: socket ffff810125e547c0 TCP data 
ready (svsk ffff810167ed3d80)
Jan 14 12:01:49 server kernel: svc: socket ffff810125e547c0 busy, not 
enqueued
Jan 14 12:01:49 server kernel: svc: got len=0
Jan 14 12:01:49 server kernel: svc: socket ffff81012024c7c0 busy, not 
enqueued
Jan 14 12:01:49 server kernel: svc: server ffff8102a5ede400 waiting for 
data (to = 900000)
Jan 14 12:01:49 server kernel: svc: server ffff810236f4f000, socket 
ffff810167ed3d80, inuse=1
Jan 14 12:01:49 server kernel: svc: tcp_recv ffff810167ed3d80 data 1 
conn 0 close 0
Jan 14 12:01:49 server kernel: svc: socket ffff810167ed3d80 
recvfrom(ffff810167ed3e2c, 0) = 4
Jan 14 12:01:49 server kernel: svc: TCP record, 40 bytes
Jan 14 12:01:49 server kernel: svc: socket ffff810167ed3d80 
recvfrom(ffff810149105028, 4056) = 40
Jan 14 12:01:49 server kernel: svc: TCP complete record (40 bytes)
Jan 14 12:01:49 server kernel: svc: socket ffff810125e547c0 served by 
daemon ffff8102a5ede400
Jan 14 12:01:49 server kernel: svc: got len=40
Jan 14 12:01:49 server kernel: svc: svc_authenticate (0)
Jan 14 12:01:49 server kernel: svc: socket ffff810125e547c0 busy, not 
enqueued
Jan 14 12:01:49 server kernel: svc: calling dispatcher
Jan 14 12:01:49 server kernel: nfsd_dispatch: vers 4 proc 0
Jan 14 12:01:49 server kernel: svc: socket ffff810167ed3d80 
sendto([ffff8101dfe10000 28... ], 28) = 28 (addr cbc916ac)
Jan 14 12:01:49 server kernel: svc: socket ffff810125e547c0 busy, not 
enqueued
Jan 14 12:01:49 server kernel: svc: server ffff810236f4f000 waiting for 
data (to = 900000)
Jan 14 12:01:49 server kernel: svc: server ffff81029edad000, socket 
ffff8101fd09c080, inuse=1
Jan 14 12:01:49 server kernel: svc: tcp_recv ffff8101fd09c080 data 0 
conn 1 close 0
Jan 14 12:01:49 server kernel: svc: tcp_accept ffff8101fd09c080 sock 
ffff81028b747380
Jan 14 12:01:49 server kernel: svc: tcp_accept ffff810282a67d00 allocated
Jan 14 12:01:49 server kernel: svc: got len=0
Jan 14 12:01:49 server kernel: svc: server ffff81029edad000 waiting for 
data (to = 900000)
Jan 14 12:01:49 server kernel: svc: server ffff8102a5ede400, socket 
ffff810167ed3d80, inuse=1
Jan 14 12:01:49 server kernel: svc: tcp_recv ffff810167ed3d80 data 1 
conn 0 close 0
Jan 14 12:01:49 server kernel: svc: socket ffff810167ed3d80 
recvfrom(ffff810167ed3e28, 4) = -11
Jan 14 12:01:49 server kernel: RPC: TCP recvfrom got EAGAIN
Jan 14 12:01:49 server kernel: svc: got len=-11
Jan 14 12:01:49 server kernel: svc: server ffff8102a5ede400 waiting for 
data (to = 900000)
Jan 14 12:01:49 server kernel: svc: socket ffff810125e547c0 TCP 
(connected) state change 8 (svsk ffff810167ed3d80)
Jan 14 12:01:49 server kernel: svc: socket ffff810125e547c0 served by 
daemon ffff8102a5ede400
Jan 14 12:01:49 server kernel: svc: socket ffff810125e547c0 TCP data 
ready (svsk ffff810167ed3d80)
Jan 14 12:01:49 server kernel: svc: socket ffff810125e547c0 busy, not 
enqueued
Jan 14 12:01:49 server kernel: svc: server ffff8102a5ede400, socket 
ffff810167ed3d80, inuse=1
Jan 14 12:01:49 server kernel: svc: tcp_recv ffff810167ed3d80 data 1 
conn 0 close 1
Jan 14 12:01:49 server kernel: svc: svc_delete_socket(ffff810167ed3d80)
Jan 14 12:01:49 server kernel: svc: server socket destroy delayed
Jan 14 12:01:49 server kernel: svc: got len=0
Jan 14 12:01:49 server kernel: svc: releasing dead socket
Jan 14 12:01:49 server kernel: svc: server ffff8102a5ede400 waiting for 
data (to = 900000)
Jan 14 12:01:49 server kernel: svc: socket ffff81012024c7c0 TCP (listen) 
state change 10
Jan 14 12:01:49 server kernel: svc: socket ffff81012024c7c0 served by 
daemon ffff8102a5ede400
Jan 14 12:01:49 server kernel: svc: server ffff8102a5ede400, socket 
ffff8101fd09c080, inuse=1
Jan 14 12:01:49 server kernel: svc: tcp_recv ffff8101fd09c080 data 0 
conn 1 close 0
Jan 14 12:01:49 server kernel: svc: tcp_accept ffff8101fd09c080 sock 
ffff81028b747380
Jan 14 12:01:49 server kernel: svc: tcp_accept ffff810282a67780 allocated
Jan 14 12:01:49 server kernel: svc: socket ffff81012024c7c0 busy, not 
enqueued
Jan 14 12:01:49 server kernel: nfsd: connect from 172.22.201.203:03d0
Jan 14 12:01:49 server kernel: svc: svc_setup_socket ffff810282a67780
Jan 14 12:01:49 server kernel: setting up TCP socket for reading
Jan 14 12:01:49 server kernel: svc: svc_setup_socket created 
ffff810167ed3d80 (inet ffff810125e547c0)
Jan 14 12:01:49 server kernel: svc: socket ffff810125e547c0 TCP data 
ready (svsk ffff810167ed3d80)
Jan 14 12:01:49 server kernel: svc: socket ffff810125e547c0 busy, not 
enqueued
Jan 14 12:01:49 server kernel: svc: socket ffff810125e547c0 served by 
daemon ffff81029edad000
Jan 14 12:01:49 server kernel: svc: socket ffff81012024c7c0 served by 
daemon ffff810236f4f000
Jan 14 12:01:49 server kernel: svc: got len=0
Jan 14 12:01:49 server kernel: svc: socket ffff81012024c7c0 busy, not 
enqueued
Jan 14 12:01:49 server kernel: svc: server ffff8102a5ede400 waiting for 
data (to = 900000)
Jan 14 12:01:49 server kernel: svc: server ffff81029edad000, socket 
ffff810167ed3d80, inuse=1
Jan 14 12:01:49 server kernel: svc: tcp_recv ffff810167ed3d80 data 1 
conn 0 close 0
Jan 14 12:01:49 server kernel: svc: socket ffff810167ed3d80 
recvfrom(ffff810167ed3e2c, 0) = 4
Jan 14 12:01:49 server kernel: svc: TCP record, 40 bytes
Jan 14 12:01:49 server kernel: svc: socket ffff810167ed3d80 
recvfrom(ffff8102451ec028, 4056) = 40
Jan 14 12:01:49 server kernel: svc: TCP complete record (40 bytes)
Jan 14 12:01:49 server kernel: svc: socket ffff810125e547c0 served by 
daemon ffff8102a5ede400
Jan 14 12:01:49 server kernel: svc: got len=40
Jan 14 12:01:49 server kernel: svc: svc_authenticate (0)
Jan 14 12:01:49 server kernel: svc: socket ffff810125e547c0 busy, not 
enqueued
Jan 14 12:01:49 server kernel: svc: calling dispatcher
Jan 14 12:01:49 server kernel: nfsd_dispatch: vers 4 proc 0
Jan 14 12:01:49 server kernel: svc: socket ffff810167ed3d80 
sendto([ffff81017bafe000 28... ], 28) = 28 (addr cbc916ac)
Jan 14 12:01:49 server kernel: svc: socket ffff810125e547c0 busy, not 
enqueued
Jan 14 12:01:49 server kernel: svc: server ffff81029edad000 waiting for 
data (to = 900000)
Jan 14 12:01:49 server kernel: svc: server ffff810236f4f000, socket 
ffff8101fd09c080, inuse=1
Jan 14 12:01:49 server kernel: svc: tcp_recv ffff8101fd09c080 data 0 
conn 1 close 0
Jan 14 12:01:49 server kernel: svc: tcp_accept ffff8101fd09c080 sock 
ffff81028b747380
Jan 14 12:01:49 server kernel: svc: tcp_accept ffff810282a67d00 allocated
Jan 14 12:01:49 server kernel: svc: got len=0
Jan 14 12:01:49 server kernel: svc: server ffff810236f4f000 waiting for 
data (to = 900000)
Jan 14 12:01:49 server kernel: svc: server ffff8102a5ede400, socket 
ffff810167ed3d80, inuse=1
Jan 14 12:01:49 server kernel: svc: tcp_recv ffff810167ed3d80 data 1 
conn 0 close 0
Jan 14 12:01:49 server kernel: svc: socket ffff810167ed3d80 
recvfrom(ffff810167ed3e28, 4) = -11
Jan 14 12:01:49 server kernel: RPC: TCP recvfrom got EAGAIN
Jan 14 12:01:49 server kernel: svc: got len=-11
Jan 14 12:01:49 server kernel: svc: server ffff8102a5ede400 waiting for 
data (to = 900000)
Jan 14 12:01:49 server kernel: svc: socket ffff810125e547c0 TCP data 
ready (svsk ffff810167ed3d80)
Jan 14 12:01:49 server kernel: svc: socket ffff810125e547c0 served by 
daemon ffff8102a5ede400
Jan 14 12:01:49 server kernel: svc: server ffff8102a5ede400, socket 
ffff810167ed3d80, inuse=1
Jan 14 12:01:49 server kernel: svc: tcp_recv ffff810167ed3d80 data 1 
conn 0 close 0
Jan 14 12:01:49 server kernel: svc: socket ffff810167ed3d80 
recvfrom(ffff810167ed3e2c, 0) = 4
Jan 14 12:01:49 server kernel: svc: TCP record, 144 bytes
Jan 14 12:01:49 server kernel: svc: socket ffff810167ed3d80 
recvfrom(ffff810273143090, 3952) = 144
Jan 14 12:01:49 server kernel: svc: TCP complete record (144 bytes)
Jan 14 12:01:49 server kernel: svc: socket ffff810125e547c0 served by 
daemon ffff810236f4f000
Jan 14 12:01:49 server kernel: svc: got len=144
Jan 14 12:01:49 server kernel: svc: svc_authenticate (1)
Jan 14 12:01:49 server kernel: Want update, refage=120, age=0
Jan 14 12:01:49 server kernel: svc: svc_process dropit
Jan 14 12:01:49 server kernel: svc: socket ffff810167ed3d80 dropped request
Jan 14 12:01:49 server kernel: svc: socket ffff810125e547c0 busy, not 
enqueued
Jan 14 12:01:49 server kernel: svc: server ffff8102a5ede400 waiting for 
data (to = 900000)
Jan 14 12:01:49 server kernel: svc: server ffff810236f4f000, socket 
ffff810167ed3d80, inuse=2
Jan 14 12:01:49 server kernel: svc: tcp_recv ffff810167ed3d80 data 1 
conn 0 close 0
Jan 14 12:01:49 server kernel: svc: socket ffff810167ed3d80 
recvfrom(ffff810167ed3e28, 4) = -11
Jan 14 12:01:49 server kernel: RPC: TCP recvfrom got EAGAIN
Jan 14 12:01:49 server kernel: svc: got len=-11
Jan 14 12:01:49 server kernel: svc: server ffff810236f4f000 waiting for 
data (to = 900000)
Jan 14 12:01:49 server kernel: revisit queued
Jan 14 12:01:49 server kernel: svc: socket ffff810125e547c0 served by 
daemon ffff810236f4f000
Jan 14 12:01:49 server kernel: svc: server ffff810236f4f000, socket 
ffff810167ed3d80, inuse=1
Jan 14 12:01:49 server kernel: svc: tcp_recv ffff810167ed3d80 data 0 
conn 0 close 0
Jan 14 12:01:49 server kernel: svc: socket ffff810125e547c0 served by 
daemon ffff8102a5ede400
Jan 14 12:01:49 server kernel: svc: got len=144
Jan 14 12:01:49 server kernel: svc: svc_authenticate (1)
Jan 14 12:01:49 server kernel: svc: calling dispatcher
Jan 14 12:01:49 server kernel: nfsd_dispatch: vers 4 proc 1
Jan 14 12:01:49 server kernel: nfsv4 compound op #1: 24
Jan 14 12:01:49 server kernel: Want update, refage=120, age=0
Jan 14 12:01:49 server kernel: nfsd: Dropping request due to malloc failure!
**Jan 14 12:01:49 server kernel: svc: svc_process dropit**
**Jan 14 12:01:49 server kernel: svc: socket ffff810167ed3d80 dropped 
request**
Jan 14 12:01:49 server kernel: svc: socket ffff810125e547c0 busy, not 
enqueued
Jan 14 12:01:49 server kernel: svc: server ffff810236f4f000 waiting for 
data (to = 900000)
Jan 14 12:01:49 server kernel: svc: server ffff8102a5ede400, socket 
ffff810167ed3d80, inuse=2
Jan 14 12:01:49 server kernel: svc: tcp_recv ffff810167ed3d80 data 0 
conn 0 close 0
Jan 14 12:01:49 server kernel: svc: socket ffff810167ed3d80 
recvfrom(ffff810167ed3e28, 4) = -11
Jan 14 12:01:49 server kernel: RPC: TCP recvfrom got EAGAIN
Jan 14 12:01:49 server kernel: svc: got len=-11
Jan 14 12:01:49 server kernel: svc: server ffff8102a5ede400 waiting for 
data (to = 900000)


---After I Ctrl+C 'd the mount command in the client:---


Jan 14 12:01:57 server kernel: svc: socket ffff810125e547c0 TCP 
(connected) state change 8 (svsk ffff810167ed3d80)
Jan 14 12:01:57 server kernel: svc: socket ffff810125e547c0 served by 
daemon ffff8102a5ede400
Jan 14 12:01:57 server kernel: svc: socket ffff810125e547c0 TCP data 
ready (svsk ffff810167ed3d80)
Jan 14 12:01:57 server kernel: svc: socket ffff810125e547c0 busy, not 
enqueued
Jan 14 12:01:57 server kernel: svc: server ffff8102a5ede400, socket 
ffff810167ed3d80, inuse=2
Jan 14 12:01:57 server kernel: svc: tcp_recv ffff810167ed3d80 data 1 
conn 0 close 1
Jan 14 12:01:57 server kernel: svc: svc_delete_socket(ffff810167ed3d80)
Jan 14 12:01:57 server kernel: svc: server socket destroy delayed
Jan 14 12:01:57 server kernel: svc: got len=0
Jan 14 12:01:57 server kernel: svc: server ffff8102a5ede400 waiting for 
data (to = 900000)


I also tried to run idmap in verbose mode to see what it says
  # rpc.idmapd -vvv -f
rpc.idmapd: Opened /proc/net/rpc/nfs4.nametoid/channel
rpc.idmapd: Opened /proc/net/rpc/nfs4.idtoname/channel

but it doesn't send anything to messages and, when checking 
/proc/net/rpc/nfs4.idtoname/content, it's still empty
# cat /proc/net/rpc/nfs4.idtoname/content
#domain type id [name]

May this be a hint that my nfsd and idmapd are not communicating? (and 
so the getattr is never answered)


As for the kernel version, unfortunately I am not allowed to upgrade it 
right now, as this is a production host (it's in a High Availability 
cluster but I can do the nfs tests because the other one is serving the 
"main" nfs right now), but I expect there will be an updating stop 
during this year.

Txema

PS: Damn! I have just realized you are the author of idmap, thanks man!
