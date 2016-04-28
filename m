Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:36818 "EHLO
	mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751712AbcD1Mn4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Apr 2016 08:43:56 -0400
Received: by mail-lf0-f66.google.com with SMTP id y84so13439723lfc.3
        for <linux-nfs@vger.kernel.org>; Thu, 28 Apr 2016 05:43:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyERwuG2sdVOC+-oFjGQOyO-F_LwMW3DwXAXsGRDF4Xbhw@mail.gmail.com>
References: <20160411201733.20911.86904.stgit@manet.1015granger.net> <CAN-5tyERwuG2sdVOC+-oFjGQOyO-F_LwMW3DwXAXsGRDF4Xbhw@mail.gmail.com>
From: William Dauchy <wdauchy@gmail.com>
Date: Thu, 28 Apr 2016 14:43:35 +0200
Message-ID: <CAJ75kXbM1D=ZxLZXNxeF6ULnQAA8fq5f9QqBrR1fY+Y6ceuqjQ@mail.gmail.com>
Subject: Re: [PATCH] NFS: Fix an LOCK/OPEN race when unlinking an open file
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Olga Kornievskaia <aglo@umich.edu>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Anna,

Could you have a look at this one please?

Thanks,

William

On Tue, Apr 26, 2016 at 4:24 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> I believe this patch also helps with a race between a LOCK and
> CB_RECALL. Application does a lock as the delegation is being
> recalled. The lock thread sees the delegated state and acquires a
> local lock. At the same time delegation doesn't see it the lock yet
> and returns the delegation. Application proceeds to do IO. It ends up
> using an open stateid for the IO (as there is no delegation stateid or
> lock stateid). The server is unaware of the lock so it can give that
> lock to somebody else. Yet this client thinks it has a local lock. It
> leads to inconsistent data between clients.
>
> On Mon, Apr 11, 2016 at 4:20 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> At Connectathon 2016, we found that recent upstream Linux clients
>> would occasionally send a LOCK operation with a zero stateid. This
>> appeared to happen in close proximity to another thread returning
>> a delegation before unlinking the same file while it remained open.
>>
>> Earlier, the client received a write delegation on this file and
>> returned the open stateid. Now, as it is getting ready to unlink the
>> file, it returns the write delegation. But there is still an open
>> file descriptor on that file, so the client must OPEN the file
>> again before it returns the delegation.
>>
>> Since commit 24311f884189 ('NFSv4: Recovery of recalled read
>> delegations is broken'), nfs_open_delegation_recall() clears the
>> NFS_DELEGATED_STATE flag _before_ it sends the OPEN. This allows a
>> racing LOCK on the same inode to be put on the wire before the OPEN
>> operation has returned a valid open stateid.
>>
>> To eliminate this race, serialize delegation return with the
>> acquisition of a file lock on the same file. Adopt the same approach
>> as is used in the unlock path.
>>
>> Fixes: 24311f884189 ('NFSv4: Recovery of recalled read ... ')
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> Hi-
>>
>> This fix appears to be both safe and effective. Please consider
>> it for v4.7 and for stable. Thanks!
>>
>>
>>  fs/nfs/nfs4proc.c |    4 ++++
>>  1 file changed, 4 insertions(+)
>>
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 01bef06..c40f1b6 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -6054,6 +6054,7 @@ static int nfs41_lock_expired(struct nfs4_state *state, struct file_lock *reques
>>  static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock *request)
>>  {
>>         struct nfs_inode *nfsi = NFS_I(state->inode);
>> +       struct nfs4_state_owner *sp = state->owner;
>>         unsigned char fl_flags = request->fl_flags;
>>         int status = -ENOLCK;
>>
>> @@ -6068,6 +6069,7 @@ static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock
>>         status = do_vfs_lock(state->inode, request);
>>         if (status < 0)
>>                 goto out;
>> +       mutex_lock(&sp->so_delegreturn_mutex);
>>         down_read(&nfsi->rwsem);
>>         if (test_bit(NFS_DELEGATED_STATE, &state->flags)) {
>>                 /* Yes: cache locks! */
>> @@ -6075,9 +6077,11 @@ static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock
>>                 request->fl_flags = fl_flags & ~FL_SLEEP;
>>                 status = do_vfs_lock(state->inode, request);
>>                 up_read(&nfsi->rwsem);
>> +               mutex_unlock(&sp->so_delegreturn_mutex);
>>                 goto out;
>>         }
>>         up_read(&nfsi->rwsem);
>> +       mutex_unlock(&sp->so_delegreturn_mutex);
>>         status = _nfs4_do_setlk(state, cmd, request, NFS_LOCK_NEW);
>>  out:
>>         request->fl_flags = fl_flags;
>>

-- 
William
