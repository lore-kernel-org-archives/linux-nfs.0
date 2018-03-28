Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.pingtimeout.net ([87.108.18.35]:50723 "EHLO
        mx1.pingtimeout.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753908AbeC1Pf6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Mar 2018 11:35:58 -0400
Subject: Re: Regarding client fairness
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
References: <f9c6c1c493d0dde6c4a24afeca00fa5b@pingtimeout.net>
 <20180328145406.GA2641@fieldses.org> <20180328145930.GB2641@fieldses.org>
From: =?UTF-8?B?QW50dGkgVMO2bmt5csOk?= <daedalus@pingtimeout.net>
Message-ID: <4abd5e4f-2992-730b-8d44-5e611a3a2451@pingtimeout.net>
Date: Wed, 28 Mar 2018 18:35:53 +0300
MIME-Version: 1.0
In-Reply-To: <20180328145930.GB2641@fieldses.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2018-03-28 17:59, J. Bruce Fields wrote:
> On Wed, Mar 28, 2018 at 10:54:06AM -0400, bfields wrote:
>> On Wed, Mar 28, 2018 at 02:04:57PM +0300, daedalus@pingtimeout.net wrote:
>>> I came across a rather annoying issue where a single NFS client
>>> caused resource starvation for NFS server. The server has several
>>> storage pools which are used, in this particular case a single
>>> client did fairly large read requests and effectively ate all nfsd
>>> threads on the server and during that other clients were getting
>>> hardly any I/O through to the other storage pool which was
>>> completely idle.
>> What version of the kernel are you running on your server?
4.15.10 on the system I am testing on.
> I'm thinking that if it includes upstream 637600f3ffbf "SUNRPC: Change
> TCP socket space reservation" (in upstream 4.8), then you may want to
> experiment setting the sunrpc.svc_rpc_per_connection_limit module
> parameter added in ff3ac5c3dc23 "SUNRPC: Add a server side
> per-connection limit".
>
> You probably want to experiment with values greater than 0 (the default,
> no limit) and the number of server threads.
That helps for the client slowing down the whole server, thanks for the 
tip! Of course this doesn't help with the case of client accessing 2 
different shares on the same server but that is something I can work around.
>
> --b.
>
>> --b.
>>
>>> I then proceeded to make a simple testcase and noticed that reading
>>> a file with large blocksize causes NFS server to read using multiple
>>> threads, effectively consuming all nfsd threads on the server and
>>> causing starvation to other clients regardless of the share/backing
>>> disk they were accessing.
>>>
>>> In my testcase a simple (ridiculous) dd was able to effectively
>>> reserve the entire NFS server for itself:
>>>
>>> # dd if=fgsfds bs=1000M count=10000 iflag=direct
>>>
>>> Also several similar dd runs with blocksize of 100M caused the same
>>> effect. During those dd-runs the server was responding at a very
>>> slow rate to any other requests by other clients (or to other NFS
>>> shares on different disks on the server).
>>>
>>> My question here is that are there any methods to ensure client
>>> fairness with Linux NFS and/or are there some best common practices
>>> to ensure something like that. I think it would be pretty awesome if
>>> clients had some kind of limit/fairness that would be scoped like
>>> {client, share-on-server} so client which accesses a single share on
>>> a server (with large read IO requests) would not effectively cause
>>> denial of service for the entire NFS server but rather only to the
>>> share it is accessing and at same time other clients accessing
>>> different/same share would get fair amount of access to the data.
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

