Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f170.google.com ([209.85.212.170]:40124 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758363AbaHZOhk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Aug 2014 10:37:40 -0400
Received: by mail-wi0-f170.google.com with SMTP id f8so5292967wiw.3
        for <linux-nfs@vger.kernel.org>; Tue, 26 Aug 2014 07:37:39 -0700 (PDT)
Message-ID: <53FC9BB1.2020007@plexistor.com>
Date: Tue, 26 Aug 2014 17:37:37 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Christoph Hellwig <hch@lst.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Matt Benjamin <matt@linuxbox.com>
Subject: Re: [PATCH] pnfs: Kick a pnfs_layoutcommit_inode on recall
References: <1408637375-11343-1-git-send-email-hch@lst.de>	<1408637375-11343-4-git-send-email-hch@lst.de>	<53FA259C.9050807@gmail.com>	<20140824191839.GA9717@lst.de>	<53FC9545.4000800@plexistor.com> <CAHQdGtQNDvofWVzn9CmtmbDRSj39BLT_gNDyY34uUFw_nEDe0Q@mail.gmail.com>
In-Reply-To: <CAHQdGtQNDvofWVzn9CmtmbDRSj39BLT_gNDyY34uUFw_nEDe0Q@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/26/2014 05:26 PM, Trond Myklebust wrote:
> On Tue, Aug 26, 2014 at 10:10 AM, Boaz Harrosh <boaz@plexistor.com> wrote:
>> +
>> +       /* kick out any segs held by need to commit */
>> +       pnfs_layoutcommit_inode(ino, true);
> 
> Making this call synchronous could deadlock the entire back channel.
> Is there any reason why it can't just be made asynchonous?
> 

We were just talking about that.

So the logic here is that we want to save round trips and make this
as efficient as possible with no extra round trips for the server
recall. A single RECALL => LAYOUT_COMMIT => LAYOUT_COMMIT_REPLAY
REACLL_REPLAY_NO_MATCHING.

Please explain the deadlock you foresee. The worst is that the
mal-behaving server will time-out and after a long time the
RECALL_REPLAY will return with ERR. But why do you say deadlock
how can this deadlock?

Otherwise Christoph's version of this patch does the asynchonous
way which will always cause another poll of the RECALL and more delays
for every RECALL operation, which I was trying to avoid.

Thanks
Boaz

