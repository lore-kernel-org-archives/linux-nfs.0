Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:34337 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023AbbEFMPr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 May 2015 08:15:47 -0400
Received: by wgso17 with SMTP id o17so9410507wgs.1
        for <linux-nfs@vger.kernel.org>; Wed, 06 May 2015 05:15:46 -0700 (PDT)
Message-ID: <554A05FD.5080605@dev.mellanox.co.il>
Date: Wed, 06 May 2015 15:15:57 +0300
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>,
        Chuck Lever <chuck.lever@oracle.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org
Subject: Re: [PATCH v1 00/16] NFS/RDMA patches proposed for 4.1
References: <20150313211124.22471.14517.stgit@manet.1015granger.net> <20150505154411.GA16729@infradead.org> <5E1B32EA-9803-49AA-856D-BF0E1A5DFFF4@oracle.com> <20150505172540.GA19442@infradead.org>
In-Reply-To: <20150505172540.GA19442@infradead.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/5/2015 8:25 PM, Christoph Hellwig wrote:
> On Tue, May 05, 2015 at 12:04:00PM -0400, Chuck Lever wrote:
>>> Just curious if you ever though of moving this into the generic
>>> rdma layer?
>>
>> Not really. The new files are really just shims that adapt the RPC/RDMA
>> transport to memory registration verbs. There?s only a few hundred lines
>> per registration mode, and it?s all fairly specific to RPC/RDMA.
>
> While it's using RPC/RDMA specific data structures it basically
> abstracts out the action of mapping a number of pages onto the rdma
> hardware.   There isn't a whole lot of interaction with the actual
> sunrpc layer except for a few hardcoded limits.
>
> Btw, this is not a critique of the code, it's an obvious major
> improvement of what was there before, it justs seems like it would be
> nice to move it up to a higher layer.
>
>>> And from I see we litterly dont use them much different from the generic
>>> dma mapping API helpers (at a very high level) so it seems it should
>>> be easy to move a slightly expanded version of your API to the core
>>> code.
>>
>> IMO FRWR is the only registration mode that has legs for the long term,
>> and is specifically designed for storage.
>>
>> If you are not working on a legacy piece of code that has to support
>> older HCAs, why not stay with FRWR?

Hey Christoph,

I agree here,

FMRs (and FMR pools) are not supported over VFs. Also, I've seen some
unpredictable performance in certain workloads because the fmr pool
maintains a flush thread that executes a HW sync (terribly blocking on
mlx4 devices) when hitting some dirty_watermark...

If you are writing a driver, I suggest to stick FRWR as well.

>
> The raw FRWR API seems like an absolute nightmare, and I'm bound to
> get it wrong at first :)  This is only half joking, but despite that
> it's the first target for sure.  It's just very frustrating that there
> is no usable common API.

The FRWR API is a work request interface. The advantage here is the
option to concatenate it with a send/rdma work request and save an extra
send queue lock and more importantly a doorbell. This matters in high
workloads. The iser target is doing this and I have a patch for the
initiator code as well.

I'm not sure that providing an API that allows you to do post-lists
might be simpler...

Sagi.
