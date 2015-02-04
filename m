Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f173.google.com ([209.85.220.173]:49392 "EHLO
	mail-vc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753091AbbBDBEh convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Feb 2015 20:04:37 -0500
Received: by mail-vc0-f173.google.com with SMTP id id10so17950958vcb.4
        for <linux-nfs@vger.kernel.org>; Tue, 03 Feb 2015 17:04:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <E706A147-93AB-46B8-B6C6-F52402A197E1@netapp.com>
References: <1423000784-93180-1-git-send-email-trond.myklebust@primarydata.com>
	<1423000784-93180-2-git-send-email-trond.myklebust@primarydata.com>
	<E706A147-93AB-46B8-B6C6-F52402A197E1@netapp.com>
Date: Tue, 3 Feb 2015 20:04:36 -0500
Message-ID: <CAHQdGtS53vrHi4pOsta=a9LEeyOePyEioodP-ouuvZ3fNENnfw@mail.gmail.com>
Subject: Re: [PATCH 2/2] NFSv4.1: Ask for no delegation on OPEN if already
 holding one
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "Kornievskaia, Olga" <Olga.Kornievskaia@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 3, 2015 at 5:47 PM, Kornievskaia, Olga
<Olga.Kornievskaia@netapp.com> wrote:
>
>> On Feb 3, 2015, at 4:59 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>>
>> If we already hold a delegation, there should be no reason for the
>> server to issue it to us again. Unfortunately, there appear to be
>> servers out there that engage in this practice. While it is often
>> harmless to do so, there is one case where this creates a problem
>> and that is when the client is in the process of returning that
>> delegation.
>> This patch uses the NFSv4.1 NFS4_SHARE_WANT_NO_DELEG flag to inform
>> the server not to return a delegation in these cases.
>>
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> ---
>> fs/nfs/nfs4proc.c | 25 ++++++++++++++++++++++---
>> 1 file changed, 22 insertions(+), 3 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index cd4295d84d54..fb41624bafc9 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -942,8 +942,10 @@ static bool nfs4_clear_cap_atomic_open_v1(struct nfs_server *server,
>>
>> static u32
>> nfs4_map_atomic_open_share(struct nfs_server *server,
>> +             struct inode *inode,
>>               fmode_t fmode, int openflags)
>> {
>> +     struct nfs_delegation *delegation;
>>       u32 res = 0;
>>
>>       switch (fmode & (FMODE_READ | FMODE_WRITE)) {
>> @@ -959,8 +961,25 @@ nfs4_map_atomic_open_share(struct nfs_server *server,
>>       if (!(server->caps & NFS_CAP_ATOMIC_OPEN_V1))
>>               goto out;
>>       /* Want no delegation if we're using O_DIRECT */
>> -     if (openflags & O_DIRECT)
>> +     if (openflags & O_DIRECT) {
>>               res |= NFS4_SHARE_WANT_NO_DELEG;
>> +             goto out;
>> +     }
>> +     if (inode == NULL)
>> +             goto out;
>> +     rcu_read_lock();
>> +     delegation = rcu_dereference(NFS_I(inode)->delegation);
>> +     /*
>> +      * If we have a delegation, either ask for an upgrade or ask for
>> +      * no delegation
>> +      */
>> +     if (delegation) {
>> +             if ((fmode & FMODE_WRITE) && !(delegation->type & FMODE_WRITE))
>> +                     res |= NFS4_SHARE_WANT_WRITE_DELEG;
>> +             else
>> +                     res |= NFS4_SHARE_WANT_NO_DELEG;
>> +     }
>> +     rcu_read_unlock();
>> out:
>>       return res;
>> }
>> @@ -1028,7 +1047,7 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
>>       p->o_arg.open_flags = flags;
>>       p->o_arg.fmode = fmode & (FMODE_READ|FMODE_WRITE);
>>       p->o_arg.share_access = nfs4_map_atomic_open_share(server,
>> -                     fmode, flags);
>> +                     dentry->d_inode, fmode, flags);
>>       /* don't put an ACCESS op in OPEN compound if O_EXCL, because ACCESS
>>        * will return permission denied for all bits until close */
>>       if (!(flags & O_EXCL)) {
>> @@ -2724,7 +2743,7 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
>>       }
>>       calldata->arg.share_access =
>>               nfs4_map_atomic_open_share(NFS_SERVER(inode),
>> -                             calldata->arg.fmode, 0);
>> +                             NULL, calldata->arg.fmode, 0);
>>
>>       nfs_fattr_init(calldata->res.fattr);
>>       calldata->timestamp = jiffies;
>> --
>> 2.1.0
>>
>
>
> Hi Trond,
>
> Do you see this of helping with the race? We won’t find a delegation on the racing open as it has been detached from the inode. For the other patch, aren’t we already checking if we can do a local open by checking for the delegation (can_open_delegated())?
>

Argh. You're 100% right in that it won't completely close the race.
However it narrows the race to the delegreturn itself, whereas
currently we also have a race while in the process of reclaiming opens
+ locks.

As for patch 1/2, I believe that O_DIRECT opens are still a valid case.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
