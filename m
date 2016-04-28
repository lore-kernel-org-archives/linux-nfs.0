Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:32315 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752967AbcD1QFa convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Apr 2016 12:05:30 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH] NFS: Fix an LOCK/OPEN race when unlinking an open file
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAN-5tyHeiiO4VJ-_ayiuZQhtM0v-eH42yN8R8e-4D9WCmrKy3w@mail.gmail.com>
Date: Thu, 28 Apr 2016 12:05:17 -0400
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        William Dauchy <wdauchy@gmail.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <F42CA24A-0D0A-4ED3-91E3-DC1BE4EA393A@oracle.com>
References: <20160411201733.20911.86904.stgit@manet.1015granger.net> <CAN-5tyERwuG2sdVOC+-oFjGQOyO-F_LwMW3DwXAXsGRDF4Xbhw@mail.gmail.com> <CAJ75kXbM1D=ZxLZXNxeF6ULnQAA8fq5f9QqBrR1fY+Y6ceuqjQ@mail.gmail.com> <dc46e09c-8c0c-6588-9a39-f65abd865079@Netapp.com> <7655D216-7C44-41A6-A6BC-BD5E91E5FDB6@oracle.com> <f737a7da-5815-a0b7-a8aa-2e2d043ff20a@Netapp.com> <CAN-5tyHeiiO4VJ-_ayiuZQhtM0v-eH42yN8R8e-4D9WCmrKy3w@mail.gmail.com>
To: Olga Kornievskaia <aglo@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Apr 28, 2016, at 11:56 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
> 
> Chuck or Anna,
> 
> If the patch is accepted, do you mind expanding the commit message to
> include the wording about the LOCK and CB_RECALL race (so that it's
> documented to look back into it).

Anna's choice.


> On Thu, Apr 28, 2016 at 10:09 AM, Anna Schumaker
> <Anna.Schumaker@netapp.com> wrote:
>> On 04/28/2016 10:06 AM, Chuck Lever wrote:
>>> 
>>>> On Apr 28, 2016, at 9:13 AM, Anna Schumaker <Anna.Schumaker@netapp.com> wrote:
>>>> 
>>>> The patch looks pretty straightforward to me, and it sounds like it fixes a few problems that people are seeing.  One question (below):
>>>> 
>>>> On 04/28/2016 08:43 AM, William Dauchy wrote:
>>>>> Hello Anna,
>>>>> 
>>>>> Could you have a look at this one please?
>>>>> 
>>>>> Thanks,
>>>>> 
>>>>> William
>>>>> 
>>>>> On Tue, Apr 26, 2016 at 4:24 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>>>> I believe this patch also helps with a race between a LOCK and
>>>>>> CB_RECALL. Application does a lock as the delegation is being
>>>>>> recalled. The lock thread sees the delegated state and acquires a
>>>>>> local lock. At the same time delegation doesn't see it the lock yet
>>>>>> and returns the delegation. Application proceeds to do IO. It ends up
>>>>>> using an open stateid for the IO (as there is no delegation stateid or
>>>>>> lock stateid). The server is unaware of the lock so it can give that
>>>>>> lock to somebody else. Yet this client thinks it has a local lock. It
>>>>>> leads to inconsistent data between clients.
>>>>>> 
>>>>>> On Mon, Apr 11, 2016 at 4:20 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>>>>> At Connectathon 2016, we found that recent upstream Linux clients
>>>>>>> would occasionally send a LOCK operation with a zero stateid. This
>>>>>>> appeared to happen in close proximity to another thread returning
>>>>>>> a delegation before unlinking the same file while it remained open.
>>>>>>> 
>>>>>>> Earlier, the client received a write delegation on this file and
>>>>>>> returned the open stateid. Now, as it is getting ready to unlink the
>>>>>>> file, it returns the write delegation. But there is still an open
>>>>>>> file descriptor on that file, so the client must OPEN the file
>>>>>>> again before it returns the delegation.
>>>>>>> 
>>>>>>> Since commit 24311f884189 ('NFSv4: Recovery of recalled read
>>>>>>> delegations is broken'), nfs_open_delegation_recall() clears the
>>>>>>> NFS_DELEGATED_STATE flag _before_ it sends the OPEN. This allows a
>>>>>>> racing LOCK on the same inode to be put on the wire before the OPEN
>>>>>>> operation has returned a valid open stateid.
>>>>>>> 
>>>>>>> To eliminate this race, serialize delegation return with the
>>>>>>> acquisition of a file lock on the same file. Adopt the same approach
>>>>>>> as is used in the unlock path.
>>>>>>> 
>>>>>>> Fixes: 24311f884189 ('NFSv4: Recovery of recalled read ... ')
>>>>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>>>>> ---
>>>>>>> Hi-
>>>>>>> 
>>>>>>> This fix appears to be both safe and effective. Please consider
>>>>>>> it for v4.7 and for stable. Thanks!
>>>>>>> 
>>>>>>> 
>>>>>>> fs/nfs/nfs4proc.c |    4 ++++
>>>>>>> 1 file changed, 4 insertions(+)
>>>>>>> 
>>>>>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>>>>>> index 01bef06..c40f1b6 100644
>>>>>>> --- a/fs/nfs/nfs4proc.c
>>>>>>> +++ b/fs/nfs/nfs4proc.c
>>>>>>> @@ -6054,6 +6054,7 @@ static int nfs41_lock_expired(struct nfs4_state *state, struct file_lock *reques
>>>>>>> static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock *request)
>>>>>>> {
>>>>>>>       struct nfs_inode *nfsi = NFS_I(state->inode);
>>>>>>> +       struct nfs4_state_owner *sp = state->owner;
>>>>>>>       unsigned char fl_flags = request->fl_flags;
>>>>>>>       int status = -ENOLCK;
>>>>>>> 
>>>>>>> @@ -6068,6 +6069,7 @@ static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock
>>>>>>>       status = do_vfs_lock(state->inode, request);
>>>>>>>       if (status < 0)
>>>>>>>               goto out;
>>>>>>> +       mutex_lock(&sp->so_delegreturn_mutex);
>>>> 
>>>> From what I can tell, the first call to do_vfs_lock() in this function is used to test if we can take the lock locally.  Do we need to worry about this racing with delegreturn, too?
>>> 
>>> When I included that call in the critical section,
>>> cthon04 locking tests deadlocked.
>> 
>> Got it.  Thanks for checking!
>> 
>> Anna
>> 
>>> 
>>> 
>>>> Thanks,
>>>> Anna
>>>> 
>>>>>>>       down_read(&nfsi->rwsem);
>>>>>>>       if (test_bit(NFS_DELEGATED_STATE, &state->flags)) {
>>>>>>>               /* Yes: cache locks! */
>>>>>>> @@ -6075,9 +6077,11 @@ static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock
>>>>>>>               request->fl_flags = fl_flags & ~FL_SLEEP;
>>>>>>>               status = do_vfs_lock(state->inode, request);
>>>>>>>               up_read(&nfsi->rwsem);
>>>>>>> +               mutex_unlock(&sp->so_delegreturn_mutex);
>>>>>>>               goto out;
>>>>>>>       }
>>>>>>>       up_read(&nfsi->rwsem);
>>>>>>> +       mutex_unlock(&sp->so_delegreturn_mutex);
>>>>>>>       status = _nfs4_do_setlk(state, cmd, request, NFS_LOCK_NEW);
>>>>>>> out:
>>>>>>>       request->fl_flags = fl_flags;
>>> 
>>> --
>>> Chuck Lever
>>> 
>>> 
>>> 
>> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



