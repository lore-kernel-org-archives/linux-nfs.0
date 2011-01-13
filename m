Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mumba.upf.edu ([193.145.56.85]:56694 "EHLO mumba.upf.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756751Ab1AMPsU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Jan 2011 10:48:20 -0500
Received: from mumba.upf.edu (localhost [127.0.0.1])
	by mumba.upf.edu (8.13.6/8.13.6) with ESMTP id p0DFmFBj001863
	for <linux-nfs@vger.kernel.org>; Thu, 13 Jan 2011 16:48:16 +0100
Message-ID: <4D2F1ECA.50703@upf.edu>
Date: Thu, 13 Jan 2011 16:48:26 +0100
From: Txema Heredia Genestar <txema.heredia@upf.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 memory allocation bug?
References: <4D2DE18D.40604@upf.edu> <20110112183557.GB11718@fieldses.org>
In-Reply-To: <20110112183557.GB11718@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

  Hi Bruce, thanks for your answer


El 12/01/11 19:35, J. Bruce Fields escribió:
> On Wed, Jan 12, 2011 at 06:14:53PM +0100, Txema Heredia Genestar wrote:
>> Additionally, I have checked tcpdump and found, when mounting an
>> NFS4 drive from a working storage-system:
>> ...
>> 12:38:06.372303 IP client.907>  storage.nfs: . ack 29 win 46
>> <nop,nop,timestamp 4063464822 174132214>
>> 12:38:06.372429 IP client.2364980656>  storage.nfs: 148 getattr [|nfs]
>> 12:38:06.372792 IP storage.nfs>  client.2364980656: reply ok 248
>> getattr [|nfs]
>> 12:38:06.372958 IP client.2381757872>  storage.nfs: 172 getattr [|nfs]
>> 12:38:06.373132 IP storage.nfs>  client.2381757872: reply ok 88
>> getattr [|nfs]
>> 12:38:06.373157 IP client.2398535088>  storage.nfs: 176 getattr [|nfs]
>> 12:38:06.373316 IP storage.nfs>  client.2398535088: reply ok 100
>> getattr [|nfs]
>> 12:38:06.373339 IP client.2415312304>  storage.nfs: 172 getattr [|nfs]
>>
>>
>> But when I mount from the same client, the NFS4 share from my server
>> gets stuck on the "getattr" call
>> ...
>> 12:36:37.051840 IP client.926>  server.nfs: . ack 29 win 140
>> <nop,nop,timestamp 4063375488 434039929>
>> 12:36:37.051903 IP client.1734362088>  server.nfs: 148 getattr [|nfs]
>> 12:36:37.090274 IP server.nfs>  client.926: . ack 192 win 4742
>> <nop,nop,timestamp 434039939 4063375488>
>> ---silence---
> Something like wireshark would give a few more details.

I have wiresharked it and I don't see any differences between the 
"getattr" packages in both cases. Do you want me to paste them in a 
specific format?


>> So I suppose that the "RPC: TCP recvfrom got EAGAIN" on the messages
>> log corresponds to that "getattr[|nfs]" call.
>>
>> I have been searching around and I have found several threads about
>> either the "malloc failure" message or the "EAGAIN" message. But I
>> haven't found anything concerning them both at the same time. I have
>> also checked for this kind of problems in NFS4 and found nothing
>> useful.
>>
>> May this be some kind of (already solved) bug in my nfs
>> implementation? I'm running a pretty old version (SuSE LES 10.2,
>> nfs-utils 1.0.7-36.2)
> What kernel version does that correspond to?
>
> My first impulse would be to make sure rpc.idmapd is running.  (If not,
> the server would do an upcall to idmapd and never get a response, hence
> fail to respond to a client getattr.)
>
> --b.

My server kernel is 2.6.16.60-0.39.3
# uname -a
Linux bhsrv2 2.6.16.60-0.39.3-smp #1 SMP Mon May 11 11:46:34 UTC 2009 
x86_64 x86_64 x86_64 GNU/Linux


I'm positive idmapd is running in both, server and client:

server
# ps -ef | grep idmap
root     11254     1  0 Jan12 ?        00:00:00 /usr/sbin/rpc.idmapd

client
# ps -ef | grep idmap
root      3262     1  0  2010 ?        00:00:02 rpc.idmapd

but it doesn't appear in rpcinfo -p, should it?

server
# rpcinfo -p
    program vers proto   port
     100000    2   tcp    111  portmapper
     100000    2   udp    111  portmapper
     100003    2   udp   2049  nfs
     100003    3   udp   2049  nfs
     100003    4   udp   2049  nfs
     100003    2   tcp   2049  nfs
     100003    3   tcp   2049  nfs
     100003    4   tcp   2049  nfs
     100024    1   udp   2526  status
     100021    1   udp   2526  nlockmgr
     100021    3   udp   2526  nlockmgr
     100021    4   udp   2526  nlockmgr
     100024    1   tcp   5726  status
     100021    1   tcp   5726  nlockmgr
     100021    3   tcp   5726  nlockmgr
     100021    4   tcp   5726  nlockmgr
     100005    1   udp    980  mountd
     100005    1   tcp    980  mountd
     100005    2   udp    980  mountd
     100005    2   tcp    980  mountd
     100005    3   udp    980  mountd
     100005    3   tcp    980  mountd
1073741824    1   tcp  13587

and client:
# rpcinfo -p
    program vers proto   port
     100000    2   tcp    111  portmapper
     100000    2   udp    111  portmapper
     100024    1   udp    850  status
     100024    1   tcp    853  status
     100021    1   tcp  42074  nlockmgr
     100021    3   tcp  42074  nlockmgr
     100021    4   tcp  42074  nlockmgr
     100021    1   udp  45871  nlockmgr
     100021    3   udp  45871  nlockmgr
     100021    4   udp  45871  nlockmgr
1073741824    1   tcp  57121




Thanks for any insight,

Txema



