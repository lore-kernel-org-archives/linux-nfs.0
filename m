Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f43.google.com ([74.125.82.43]:50418 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755462AbaHZOxB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Aug 2014 10:53:01 -0400
Received: by mail-wg0-f43.google.com with SMTP id l18so14456067wgh.2
        for <linux-nfs@vger.kernel.org>; Tue, 26 Aug 2014 07:53:00 -0700 (PDT)
Message-ID: <53FC9F4A.5070007@gmail.com>
Date: Tue, 26 Aug 2014 17:52:58 +0300
From: Boaz Harrosh <openosd@gmail.com>
MIME-Version: 1.0
To: Boaz Harrosh <boaz@plexistor.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
CC: Christoph Hellwig <hch@lst.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Matt Benjamin <matt@linuxbox.com>
Subject: Re: [PATCH] pnfs: Kick a pnfs_layoutcommit_inode on recall
References: <1408637375-11343-1-git-send-email-hch@lst.de>	<1408637375-11343-4-git-send-email-hch@lst.de>	<53FA259C.9050807@gmail.com>	<20140824191839.GA9717@lst.de>	<53FC9545.4000800@plexistor.com> <CAHQdGtQNDvofWVzn9CmtmbDRSj39BLT_gNDyY34uUFw_nEDe0Q@mail.gmail.com> <53FC9BB1.2020007@plexistor.com>
In-Reply-To: <53FC9BB1.2020007@plexistor.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/26/2014 05:37 PM, Boaz Harrosh wrote:
> On 08/26/2014 05:26 PM, Trond Myklebust wrote:
>> On Tue, Aug 26, 2014 at 10:10 AM, Boaz Harrosh <boaz@plexistor.com> wrote:
>>> +
>>> +       /* kick out any segs held by need to commit */
>>> +       pnfs_layoutcommit_inode(ino, true);
>>
>> Making this call synchronous could deadlock the entire back channel.
>> Is there any reason why it can't just be made asynchonous?
>>
> 
> We were just talking about that.
> 
> So the logic here is that we want to save round trips and make this
> as efficient as possible with no extra round trips for the server
> recall. A single RECALL => LAYOUT_COMMIT => LAYOUT_COMMIT_REPLAY
> REACLL_REPLAY_NO_MATCHING.
> 
> Please explain the deadlock you foresee. The worst is that the
> mal-behaving server will time-out and after a long time the
> RECALL_REPLAY will return with ERR. But why do you say deadlock
> how can this deadlock?
> 
> Otherwise Christoph's version of this patch does the asynchonous
> way which will always cause another poll of the RECALL and more delays
> for every RECALL operation, which I was trying to avoid.
> 

Also, for any client there is only a single server on it's backchannel

do you mean that ANY recall from any server can only come on a single
thread? I did not know that I thought it was from a pool of RPC threads.

So are you saying that waiting on this server operation will cause
any other server's recall to some other mounts stall until the
operation is complete for this server?

Thanks
Boaz

