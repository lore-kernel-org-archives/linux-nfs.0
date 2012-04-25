Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:57611 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759273Ab2DYU7K convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Apr 2012 16:59:10 -0400
Message-ID: <4F98659B.6060409@parallels.com>
Date: Thu, 26 Apr 2012 00:59:07 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH 0/3] SUNRPC: three bugfixes for PipeFS event handling
References: <20120420141419.10848.84280.stgit@localhost6.localdomain6> <20120425182409.GE751@fieldses.org>
In-Reply-To: <20120425182409.GE751@fieldses.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

25.04.2012 22:24, J. Bruce Fields написал:
> On Fri, Apr 20, 2012 at 06:18:59PM +0400, Stanislav Kinsbursky wrote:
>> These bugfixes were caught (or noticed) due to the following simple script:
> I'm assuming Trond should take these (possibly for 3.4?).

I think so.
But would be great if you'll take them as well (since I'm mostly working 
with your tree).
Of course, only if its not a big deal for you.
But if there will be any conflicts - then don't worry. I can just keep 
these patches in my repo.

> --b.
>
>> ======================================================================
>>
>> #!/bin/bash
>> service rpcbind stop
>> service rpcidmapd stop
>> killall -TERM rpc.statd
>> umount /var/lib/nfs/rpc_pipefs
>> rmmod nfs
>> service rpcbind start
>> service nfs start
>> mount -t rpc_pipefs sunrpc /var/lib/nfs/rpc_pipefs
>>
>> =======================================================================
>>
>> The following series consists of:
>>
>> ---
>>
>> Stanislav Kinsbursky (3):
>>        SUNRPC: skip clients with program without PipeFS entries
>>        SUNRPC: traverse clients tree on PipeFS event
>>        SUNRPC: set per-net PipeFS superblock before notification
>>
>>
>>   net/sunrpc/clnt.c     |   34 ++++++++++++++++++++++++++++------
>>   net/sunrpc/rpc_pipe.c |    3 ++-
>>   2 files changed, 30 insertions(+), 7 deletions(-)
>>

