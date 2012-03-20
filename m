Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vx0-f174.google.com ([209.85.220.174]:49826 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754050Ab2CTSll convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2012 14:41:41 -0400
Received: by vcqp1 with SMTP id p1so328135vcq.19
        for <linux-nfs@vger.kernel.org>; Tue, 20 Mar 2012 11:41:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1332262605.2963.61.camel@lade.trondhjem.org>
References: <1332260746-8351-1-git-send-email-iisaman@netapp.com>
	<1332262605.2963.61.camel@lade.trondhjem.org>
Date: Tue, 20 Mar 2012 14:41:40 -0400
Message-ID: <CADnza47KuSGqve_LQVQAwT9H+ujwN2c01pRR_Dj46Q+6Fz3KuQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] NFS4.1: filelayout_commit_pagelist needs to pass back error
From: Fred Isaman <faisaman4@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Isaman, Fred" <Fred.Isaman@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 20, 2012 at 12:56 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Tue, 2012-03-20 at 12:25 -0400, Fred Isaman wrote:
>> It was reporting success even if it did nothing.
>>
>> Note this is still not right.  Caller nfs_commit_unstable_pages
>> assumes this is all or none, and count is going to be off.
>>
>> Signed-off-by: Fred Isaman <iisaman@netapp.com>
>> ---
>>  fs/nfs/nfs4filelayout.c |    4 +++-
>>  1 files changed, 3 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
>> index e0bdbf4..08625a8 100644
>> --- a/fs/nfs/nfs4filelayout.c
>> +++ b/fs/nfs/nfs4filelayout.c
>> @@ -1027,6 +1027,7 @@ filelayout_commit_pagelist(struct inode *inode, struct list_head *mds_pages,
>>       struct nfs_write_data   *data, *tmp;
>>       LIST_HEAD(list);
>>       unsigned int nreq = 0;
>> +     int status = PNFS_ATTEMPTED;
>>
>>       if (!list_empty(mds_pages)) {
>>               data = nfs_commitdata_alloc();
>> @@ -1042,6 +1043,7 @@ filelayout_commit_pagelist(struct inode *inode, struct list_head *mds_pages,
>>
>>       if (nreq == 0) {
>>               nfs_commit_clear_lock(NFS_I(inode));
>> +             status = -ENOMEM;
>
> What if nreq != 0, but some of the allocations still failed?
>
> Then there's the issue of what if the one or more of the calls to
> nfs_initiate_commit() fail?
>
> Finally, there is the question of what if the commit RPC calls
> themselves fail, or cause a retransmission?
>
> IOW: Why do we single out some of these errors as worthy of reporting,
> but not others? The cleanup seems to be the same in all cases above
> (mark the requests for retransmission and mark the inode dirty).
>

I agree (which is why I didn't fix it "in full"), but I haven't traced
all the VFS callers and their expectations.  However, at one point
nfs_commit_inode returned the count of the number of pages sent to RPC
(and nfs_commit_unstable_pages uses that fact).  It would not be too
hard to get that to happen again.  Or stop returning a count
entirely...which means doing something about
nfs_commit_unstable_pages.  Or at least make clear in comments that
the count returned is an undercount

Fred
