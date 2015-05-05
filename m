Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa08-10.prod.phx3.secureserver.net ([173.201.193.111]:35814
	"EHLO p3plsmtpa08-10.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758412AbbEEMDh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 May 2015 08:03:37 -0400
Message-ID: <5548B195.5070303@talpey.com>
Date: Tue, 05 May 2015 08:03:33 -0400
From: Tom Talpey <tom@talpey.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: RFC: combine xprtrdma and svcrdma
References: <CE0356DB-12BA-4208-83B1-E51B34B25388@oracle.com>
In-Reply-To: <CE0356DB-12BA-4208-83B1-E51B34B25388@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/4/2015 3:17 PM, Chuck Lever wrote:
> Hi-
>
> I’ve been experimenting with adding bi-directional RPC/RDMA support
> on both the client and server side. The problem is that both modules
> need to be loaded before the backchannel transports are registered
> and can be used by the upper layers.
>
> If I add a couple of request_module() call sites I get this:
>
>> WARNING: Module /lib/modules/4.1.0-rc2-00011-g1460752/kernel/net/sunrpc/xprtrdma/xprtrdma.ko ignored, due to loop
>> WARNING: Loop detected: /lib/modules/4.1.0-rc2-00011-g1460752/kernel/net/sunrpc/xprtrdma/svcrdma.ko needs xprtrdma.ko which needs svcrdma.ko again!
>> WARNING: Module /lib/modules/4.1.0-rc2-00011-g1460752/kernel/net/sunrpc/xprtrdma/svcrdma.ko ignored, due to loop
>> Installing kernel boot image ...
>> Constructing initramdisk ...
>> ERROR: modinfo: could not find module svcrdma
>
>
> This isn’t a problem for TCP because both client and server side
> TCP socket support are built into the sunrpc.ko module. The client and
> server RDMA transport support are in separate modules.
>
> A straightforward way to address this would be to combine xprtrdma.ko
> with svcrdma.ko. Any thoughts on this approach?

I think it's long overdue, go for it. In the end, it will reduce
overall code.

Tom.

