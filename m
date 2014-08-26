Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yk0-f173.google.com ([209.85.160.173]:39576 "EHLO
	mail-yk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751528AbaHZOzO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Aug 2014 10:55:14 -0400
Received: by mail-yk0-f173.google.com with SMTP id 131so11423550ykp.32
        for <linux-nfs@vger.kernel.org>; Tue, 26 Aug 2014 07:55:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53FC9BB1.2020007@plexistor.com>
References: <1408637375-11343-1-git-send-email-hch@lst.de>
	<1408637375-11343-4-git-send-email-hch@lst.de>
	<53FA259C.9050807@gmail.com>
	<20140824191839.GA9717@lst.de>
	<53FC9545.4000800@plexistor.com>
	<CAHQdGtQNDvofWVzn9CmtmbDRSj39BLT_gNDyY34uUFw_nEDe0Q@mail.gmail.com>
	<53FC9BB1.2020007@plexistor.com>
Date: Tue, 26 Aug 2014 10:55:13 -0400
Message-ID: <CAHQdGtQh76S-KXTESkmUCF7kSVEwTpJpL-5Cwog7xxE=M5u3mA@mail.gmail.com>
Subject: Re: [PATCH] pnfs: Kick a pnfs_layoutcommit_inode on recall
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Christoph Hellwig <hch@lst.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Matt Benjamin <matt@linuxbox.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 26, 2014 at 10:37 AM, Boaz Harrosh <boaz@plexistor.com> wrote:
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
> Thanks
> Boaz
>

The above can deadlock if there are no session slots available to send
the layoutcommit, in which case the recall won't complete, and the
layoutget won't get a reply (which would free up the slot).

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
