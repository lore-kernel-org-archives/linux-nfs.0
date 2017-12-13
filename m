Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59508 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753685AbdLMCXT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 12 Dec 2017 21:23:19 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Christoph Hellwig" <hch@infradead.org>
Cc: "Trond Myklebust" <trond.myklebust@primarydata.com>,
        "Anna Schumaker" <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 2/3] pnfs/blocklayout: Revalidate SCSI disks after
 registration
Date: Tue, 12 Dec 2017 21:23:17 -0500
Message-ID: <3F9C4DC2-0F19-4AB0-AB22-00DDF2CEAA03@redhat.com>
In-Reply-To: <20171212143825.GA11132@infradead.org>
References: <cover.1512748321.git.bcodding@redhat.com>
 <7849a32ce8d429791eed114275496ec213dfaeb7.1512748321.git.bcodding@redhat.com>
 <20171212143825.GA11132@infradead.org>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12 Dec 2017, at 9:38, Christoph Hellwig wrote:

> On Fri, Dec 08, 2017 at 12:52:58PM -0500, Benjamin Coddington wrote:
>> If a SCSI device already has an exclusive access registrants only
>> reservation, the device's size cannot be known by the client until after
>> registration.  We should therefore delay setting the block device's length
>> until after the registration and revalidation of the disk.
>
> Table 13 in sbc4r14.pdf clearly indicates READ CAPACITY is allowed even
> for a not registered I_T nexus.  What kind of setup do you see this
> problem with?

It does indeed, I should have checked.  So it seems this patch should be
unnecessary, however I think if we do end up with d->len = 0, bad things
happen later.  My memory is fuzzy on this, I'll have to re-test it.

The SCSI devices are presented by the TCM driver on a 4.11 era kernel.  I
don't know that code at all, but with quick look it seems that
__target_execute_cmd() wants to check for reservations for all commands.

I think this patch should be dropped, and we can try to fix this on the TCM
side.

Ben
