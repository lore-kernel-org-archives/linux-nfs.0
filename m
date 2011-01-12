Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33344 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753830Ab1ALSf6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Jan 2011 13:35:58 -0500
Date: Wed, 12 Jan 2011 13:35:57 -0500
To: Txema Heredia Genestar <txema.heredia@upf.edu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 memory allocation bug?
Message-ID: <20110112183557.GB11718@fieldses.org>
References: <4D2DE18D.40604@upf.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D2DE18D.40604@upf.edu>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jan 12, 2011 at 06:14:53PM +0100, Txema Heredia Genestar wrote:
>  Hello everybody,
> 
> I have a host serving disk through the network using NFS v3, and it
> has been working ok for 3 years. Recently I have been benchmarking
> its throughput and I wanted to test how it would work if I used NFS
> v4 instead, but I couldn't mount a single drive.
> 
> This is what I see:
> 
> Client:
> client# mount -v -t nfs4 serverurl:/ /mnt/NFS_test/
> mount: pinging: prog 100003 vers 4 prot tcp port 2049
> ---no response---
> 
> Server:
> No error messages. Once I enabled debugging with echo "65535" >
> /proc/sys/sunrpc/nfsd_debug :
...
> Jan 11 18:50:48 server kernel: RPC: TCP recvfrom got EAGAIN
> Jan 11 18:50:48 server kernel: svc: got len=-11
> Jan 11 18:50:48 server kernel: svc: server ffff81025e481400 waiting
> for data (to = 900000)
> Jan 11 18:50:48 server kernel: Want update, refage=120, age=0
> Jan 11 18:50:48 server kernel: nfsd: Dropping request due to malloc failure!

I wouldn't take that error too seriously; it's normal when the server is
doing upcalls to rpc.svcgssd or rpc.idmapd.

> Jan 11 18:50:48 server kernel: svc: svc_process dropit
> Jan 11 18:50:48 server kernel: svc: socket ffff81029c53a580 dropped request
> Jan 11 18:50:48 server kernel: svc: server ffff810251911800 waiting
> for data (to = 900000)
> 
> 
> 
> Additionally, I have checked tcpdump and found, when mounting an
> NFS4 drive from a working storage-system:
> ...
> 12:38:06.372303 IP client.907 > storage.nfs: . ack 29 win 46
> <nop,nop,timestamp 4063464822 174132214>
> 12:38:06.372429 IP client.2364980656 > storage.nfs: 148 getattr [|nfs]
> 12:38:06.372792 IP storage.nfs > client.2364980656: reply ok 248
> getattr [|nfs]
> 12:38:06.372958 IP client.2381757872 > storage.nfs: 172 getattr [|nfs]
> 12:38:06.373132 IP storage.nfs > client.2381757872: reply ok 88
> getattr [|nfs]
> 12:38:06.373157 IP client.2398535088 > storage.nfs: 176 getattr [|nfs]
> 12:38:06.373316 IP storage.nfs > client.2398535088: reply ok 100
> getattr [|nfs]
> 12:38:06.373339 IP client.2415312304 > storage.nfs: 172 getattr [|nfs]
> 
> 
> But when I mount from the same client, the NFS4 share from my server
> gets stuck on the "getattr" call
> ...
> 12:36:37.051840 IP client.926 > server.nfs: . ack 29 win 140
> <nop,nop,timestamp 4063375488 434039929>
> 12:36:37.051903 IP client.1734362088 > server.nfs: 148 getattr [|nfs]
> 12:36:37.090274 IP server.nfs > client.926: . ack 192 win 4742
> <nop,nop,timestamp 434039939 4063375488>
> ---silence---

Something like wireshark would give a few more details.

> So I suppose that the "RPC: TCP recvfrom got EAGAIN" on the messages
> log corresponds to that "getattr[|nfs]" call.
> 
> I have been searching around and I have found several threads about
> either the "malloc failure" message or the "EAGAIN" message. But I
> haven't found anything concerning them both at the same time. I have
> also checked for this kind of problems in NFS4 and found nothing
> useful.
> 
> May this be some kind of (already solved) bug in my nfs
> implementation? I'm running a pretty old version (SuSE LES 10.2,
> nfs-utils 1.0.7-36.2)

What kernel version does that correspond to?

My first impulse would be to make sure rpc.idmapd is running.  (If not,
the server would do an upcall to idmapd and never get a response, hence
fail to respond to a client getattr.)

--b.
