Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:37641 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932932Ab1AMQTO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Jan 2011 11:19:14 -0500
Date: Thu, 13 Jan 2011 11:19:13 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Txema Heredia Genestar <txema.heredia@upf.edu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 memory allocation bug?
Message-ID: <20110113161913.GG20946@fieldses.org>
References: <4D2DE18D.40604@upf.edu>
 <20110112183557.GB11718@fieldses.org>
 <4D2F1ECA.50703@upf.edu>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <4D2F1ECA.50703@upf.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jan 13, 2011 at 04:48:26PM +0100, Txema Heredia Genestar wrote:
>  Hi Bruce, thanks for your answer
> 
> 
> El 12/01/11 19:35, J. Bruce Fields escribió:
> >On Wed, Jan 12, 2011 at 06:14:53PM +0100, Txema Heredia Genestar wrote:
> >>Additionally, I have checked tcpdump and found, when mounting an
> >>NFS4 drive from a working storage-system:
> >>...
> >>12:38:06.372303 IP client.907>  storage.nfs: . ack 29 win 46
> >><nop,nop,timestamp 4063464822 174132214>
> >>12:38:06.372429 IP client.2364980656>  storage.nfs: 148 getattr [|nfs]
> >>12:38:06.372792 IP storage.nfs>  client.2364980656: reply ok 248
> >>getattr [|nfs]
> >>12:38:06.372958 IP client.2381757872>  storage.nfs: 172 getattr [|nfs]
> >>12:38:06.373132 IP storage.nfs>  client.2381757872: reply ok 88
> >>getattr [|nfs]
> >>12:38:06.373157 IP client.2398535088>  storage.nfs: 176 getattr [|nfs]
> >>12:38:06.373316 IP storage.nfs>  client.2398535088: reply ok 100
> >>getattr [|nfs]
> >>12:38:06.373339 IP client.2415312304>  storage.nfs: 172 getattr [|nfs]
> >>
> >>
> >>But when I mount from the same client, the NFS4 share from my server
> >>gets stuck on the "getattr" call
> >>...
> >>12:36:37.051840 IP client.926>  server.nfs: . ack 29 win 140
> >><nop,nop,timestamp 4063375488 434039929>
> >>12:36:37.051903 IP client.1734362088>  server.nfs: 148 getattr [|nfs]
> >>12:36:37.090274 IP server.nfs>  client.926: . ack 192 win 4742
> >><nop,nop,timestamp 434039939 4063375488>
> >>---silence---
> >Something like wireshark would give a few more details.
> 
> I have wiresharked it and I don't see any differences between the
> "getattr" packages in both cases. Do you want me to paste them in a
> specific format?

I'm curious which attributes were requested.  In particular, is the
unreplied-to getattr the *first* time that the client requests the owner
or owner_group attributes?

> My server kernel is 2.6.16.60-0.39.3
> # uname -a
> Linux bhsrv2 2.6.16.60-0.39.3-smp #1 SMP Mon May 11 11:46:34 UTC
> 2009 x86_64 x86_64 x86_64 GNU/Linux
> 
> 
> I'm positive idmapd is running in both, server and client:
> 
> server
> # ps -ef | grep idmap
> root     11254     1  0 Jan12 ?        00:00:00 /usr/sbin/rpc.idmapd

OK.

> 
> client
> # ps -ef | grep idmap
> root      3262     1  0  2010 ?        00:00:02 rpc.idmapd
> 
> but it doesn't appear in rpcinfo -p, should it?

No, it just handles requests from the kernel, not from the network.

Might also be worth looking at the nfs4.idtoname cache contents after
the hang:

	rpcdebug -m rpc -s cache
	cat /proc/net/rpc/nfs4.idtoname/content

I seem to recall c9b6cbe56d3ac471e6cd72a59ec9e324b3417016 or
0a725fc4d3bfc4734164863d6c50208b109ca5c7 being possible causes of hangs.

--b.
