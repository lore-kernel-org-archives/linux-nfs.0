Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f178.google.com ([209.85.220.178]:57054 "EHLO
	mail-vc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750971AbaIZQVI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Sep 2014 12:21:08 -0400
Received: by mail-vc0-f178.google.com with SMTP id lf12so7289456vcb.9
        for <linux-nfs@vger.kernel.org>; Fri, 26 Sep 2014 09:21:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140926154843.GA22675@lst.de>
References: <1411740170-18611-1-git-send-email-hch@lst.de>
	<1411740170-18611-2-git-send-email-hch@lst.de>
	<CAHQdGtTg8Tc8bRqbezW-ZWrcTJdG233uRTrqQMP5CvxAcjW9Fg@mail.gmail.com>
	<20140926154843.GA22675@lst.de>
Date: Fri, 26 Sep 2014 12:21:06 -0400
Message-ID: <CAHQdGtRYN_L4ONFU5-GW3=kJ1oz5HS_7kmsn=GWCCGTgBODQAA@mail.gmail.com>
Subject: Re: [PATCH] pnfs/blocklayout: serialize GETDEVICEINFO calls
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 26, 2014 at 11:48 AM, Christoph Hellwig <hch@lst.de> wrote:
> On Fri, Sep 26, 2014 at 10:29:34AM -0400, Trond Myklebust wrote:
>> It worries me that we're putting a mutex directly in the writeback
>> path. For small arrays, it might be acceptable, but what if you have a
>> block device with 1000s of disks on the back end?
>>
>> Is there no better way to fix this issue?
>
> Not without getting rid of the rpc_pipefs interface.  That is on my
> very long term TODO list, but it will require new userspace support.

Why is that? rpc_pipefs was designed to be message based, so it should
work quite well in a multi-threaded environment. We certainly don't
use mutexes around the gssd up/downcall, and the only reason for the
mutex in idmapd is to deal with the keyring upcall.

> Note that I'm actually worried about GETDEVICEINFO from the writeback
> path in general.  There is a lot that happens when we don't have
> a device in cache, including the need to open a block device for
> the block layout driver, which is a complex operation full of
> GFP_KERNEL allocation, or even a more complex scsi device scan
> for the object layout.  It's been on my more near term todo list
> to look into reproducers for deadlocks in this area which seem
> very possible, and then look into a fix for it; I can't really
> think of anything less drastic than refusing block or object layout
> I/O from memory reclaim if we don't have the device cached yet.
> The situation for file layouts seems less severe, so I'll need
> help from people more familar with to think about the situation there.

Agreed,

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
