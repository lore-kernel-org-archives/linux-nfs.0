Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57526 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751297AbdLNNI5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Dec 2017 08:08:57 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: Re: spurious sillyrename after O_DIRECT writes get ENOSPC
Date: Thu, 14 Dec 2017 08:08:53 -0500
Message-ID: <9383ABA6-B994-4DB3-95F4-C0D6F59580F9@redhat.com>
In-Reply-To: <20171213171815.GB9205@fieldses.org>
References: <20171208221626.GB22508@fieldses.org>
 <20171213171815.GB9205@fieldses.org>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 13 Dec 2017, at 12:18, J. Bruce Fields wrote:

> On Fri, Dec 08, 2017 at 05:16:26PM -0500, J. Bruce Fields wrote:
>> Last year Christoph noticed a bug that could result in a file being
>> unnecessarily sillyrenamed after O_DIRECT writes get ENOSPC:
>>
>> 	http://lkml.kernel.org/r/20160616150146.GA14015@infradead.org
>>
>> It's reproduceable on upstream, over v3 or v4.
>>
>> I looked into it some more, and it seems to reproduce whenever a write
>> system call results in multiple WRITE calls, only some of which receive
>> ENOSPC.  I think that's resulting in a leak of the wb_kref on some
>> nfs_pages (possibly the ones corresponding to the ENOSPC failures?).
>> Those nfs_pages in turn hold references on nfs_{lock,open}_contexts.  So
>> a "rm" on the client (even after the file is closed) results in a
>> sillyrename.
>>
>> I'll keep looking at this, but the relevant code is pretty opaque to me
>> so far.  Any ideas welcomed.
>
> Actually it looks like a leak of dreq->io_count?  That prevents commits
> from being sent (which I'm also seeing in network traces--the succesfull
> WRITEs are unstable but never get committed), which means
> nfs_direct_commit_complete() is never called, and the reference taken on
> wb_kref in the request_commit case of nfs_direct_write_completion is
> never put.

This sounds to me like the problem Scott's working - he sent a patch
yesterday "nfs/pnfs: fix nfs_direct_req ref leak when i/o falls back to the
mds".

I think the the rule should be that once we call
nfs_pgio_completion_ops->init_hdr, we have to finish with ->completion.
However, there are some paths where that is not the case.

The callgraph in between nfs_pgheader_init() and nfs_initiate_pgio() in
nfs_generic_pg_pgios() for this case might show where we're bailing out
early.

Ben
