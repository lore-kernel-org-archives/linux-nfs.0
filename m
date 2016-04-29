Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f196.google.com ([209.85.213.196]:36840 "EHLO
	mail-ig0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753279AbcD2NsO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Apr 2016 09:48:14 -0400
Received: by mail-ig0-f196.google.com with SMTP id c3so2836999igl.3
        for <linux-nfs@vger.kernel.org>; Fri, 29 Apr 2016 06:48:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <116450f3-1eb4-6a5f-f108-2121143e6b59@Netapp.com>
References: <20160411201733.20911.86904.stgit@manet.1015granger.net>
	<CAN-5tyERwuG2sdVOC+-oFjGQOyO-F_LwMW3DwXAXsGRDF4Xbhw@mail.gmail.com>
	<CAJ75kXbM1D=ZxLZXNxeF6ULnQAA8fq5f9QqBrR1fY+Y6ceuqjQ@mail.gmail.com>
	<dc46e09c-8c0c-6588-9a39-f65abd865079@Netapp.com>
	<7655D216-7C44-41A6-A6BC-BD5E91E5FDB6@oracle.com>
	<f737a7da-5815-a0b7-a8aa-2e2d043ff20a@Netapp.com>
	<CAN-5tyHeiiO4VJ-_ayiuZQhtM0v-eH42yN8R8e-4D9WCmrKy3w@mail.gmail.com>
	<F42CA24A-0D0A-4ED3-91E3-DC1BE4EA393A@oracle.com>
	<7ae5ae32-7721-fa8e-9b07-e7b705f85863@Netapp.com>
	<CAN-5tyGvnZJivfsmOEFsG5Gs3o2WoPFf_K8MN6F2+nF3hhNQqA@mail.gmail.com>
	<116450f3-1eb4-6a5f-f108-2121143e6b59@Netapp.com>
Date: Fri, 29 Apr 2016 09:48:09 -0400
Message-ID: <CAN-5tyGL9PRMzAhrQMBXCiE_DTn+hJAuLOhfs7bMao6Yn3ZwQQ@mail.gmail.com>
Subject: Re: [PATCH] NFS: Fix an LOCK/OPEN race when unlinking an open file
From: Olga Kornievskaia <aglo@umich.edu>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, William Dauchy <wdauchy@gmail.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 28, 2016 at 5:11 PM, Anna Schumaker
<Anna.Schumaker@netapp.com> wrote:
> On 04/28/2016 01:40 PM, Olga Kornievskaia wrote:
>> On Thu, Apr 28, 2016 at 1:22 PM, Anna Schumaker
>> <Anna.Schumaker@netapp.com> wrote:
>>> On 04/28/2016 12:05 PM, Chuck Lever wrote:
>>>>
>>>>> On Apr 28, 2016, at 11:56 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>>>
>>>>> Chuck or Anna,
>>>>>
>>>>> If the patch is accepted, do you mind expanding the commit message to
>>>>> include the wording about the LOCK and CB_RECALL race (so that it's
>>>>> documented to look back into it).
>>>>
>>>> Anna's choice.
>>>
>>> Sounds like a good idea.  Is there any particular wording that you want?  If not, then I can try to base something off of your email from Tuesday (4/26).
>>
>> No particular wording. Could be as little as: "helps with LOCK and
>> CB_RECALL race" or could include my explanation of what happens from
>> Tuesday.
>
> Okay, how does this look?  http://git.linux-nfs.org/?p=anna/linux-nfs.git;a=commit;h=aa56ecf86281edd8dd488484596675813928f140

looks good to me.

> As a side note, I just put together a [testing] branch with this patch and all the others I could find from the last month or so.  Please let me know if it looks like I'm missing anything!
>
> Thanks,
> Anna
>
>>
>>>
>>> Anna
>>>
>>>>
>>>>
>>>>> On Thu, Apr 28, 2016 at 10:09 AM, Anna Schumaker
>>>>> <Anna.Schumaker@netapp.com> wrote:
>>>>>> On 04/28/2016 10:06 AM, Chuck Lever wrote:
>>>>>>>
>>>>>>>> On Apr 28, 2016, at 9:13 AM, Anna Schumaker <Anna.Schumaker@netapp.com> wrote:
>>>>>>>>
>>>>>>>> The patch looks pretty straightforward to me, and it sounds like it fixes a few problems that people are seeing.  One question (below):
>>>>>>>>
>>>>>>>> On 04/28/2016 08:43 AM, William Dauchy wrote:
>>>>>>>>> Hello Anna,
>>>>>>>>>
>>>>>>>>> Could you have a look at this one please?
>>>>>>>>>
>>>>>>>>> Thanks,
>>>>>>>>>
>>>>>>>>> William
>>>>>>>>>
>>>>>>>>> On Tue, Apr 26, 2016 at 4:24 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>>>>>>>> I believe this patch also helps with a race between a LOCK and
>>>>>>>>>> CB_RECALL. Application does a lock as the delegation is being
>>>>>>>>>> recalled. The lock thread sees the delegated state and acquires a
>>>>>>>>>> local lock. At the same time delegation doesn't see it the lock yet
>>>>>>>>>> and returns the delegation. Application proceeds to do IO. It ends up
>>>>>>>>>> using an open stateid for the IO (as there is no delegation stateid or
>>>>>>>>>> lock stateid). The server is unaware of the lock so it can give that
>>>>>>>>>> lock to somebody else. Yet this client thinks it has a local lock. It
>>>>>>>>>> leads to inconsistent data between clients.
>>>>>>>>>>
>>>>>>>>>> On Mon, Apr 11, 2016 at 4:20 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>>>>>>>>> At Connectathon 2016, we found that recent upstream Linux clients
>>>>>>>>>>> would occasionally send a LOCK operation with a zero stateid. This
>>>>>>>>>>> appeared to happen in close proximity to another thread returning
>>>>>>>>>>> a delegation before unlinking the same file while it remained open.
>>>>>>>>>>>
>>>>>>>>>>> Earlier, the client received a write delegation on this file and
>>>>>>>>>>> returned the open stateid. Now, as it is getting ready to unlink the
>>>>>>>>>>> file, it returns the write delegation. But there is still an open
>>>>>>>>>>> file descriptor on that file, so the client must OPEN the file
>>>>>>>>>>> again before it returns the delegation.
>>>>>>>>>>>
>>>>>>>>>>> Since commit 24311f884189 ('NFSv4: Recovery of recalled read
>>>>>>>>>>> delegations is broken'), nfs_open_delegation_recall() clears the
>>>>>>>>>>> NFS_DELEGATED_STATE flag _before_ it sends the OPEN. This allows a
>>>>>>>>>>> racing LOCK on the same inode to be put on the wire before the OPEN
>>>>>>>>>>> operation has returned a valid open stateid.
>>>>>>>>>>>
>>>>>>>>>>> To eliminate this race, serialize delegation return with the
>>>>>>>>>>> acquisition of a file lock on the same file. Adopt the same approach
>>>>>>>>>>> as is used in the unlock path.
>>>>>>>>>>>
>>>>>>>>>>> Fixes: 24311f884189 ('NFSv4: Recovery of recalled read ... ')
>>>>>>>>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>>>>>>>>> ---
>>>>>>>>>>> Hi-
>>>>>>>>>>>
>>>>>>>>>>> This fix appears to be both safe and effective. Please consider
>>>>>>>>>>> it for v4.7 and for stable. Thanks!
>>>>>>>>>>>
>>>>>>>>>>>
>>>>>>>>>>> fs/nfs/nfs4proc.c |    4 ++++
>>>>>>>>>>> 1 file changed, 4 insertions(+)
>>>>>>>>>>>
>>>>>>>>>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>>>>>>>>>> index 01bef06..c40f1b6 100644
>>>>>>>>>>> --- a/fs/nfs/nfs4proc.c
>>>>>>>>>>> +++ b/fs/nfs/nfs4proc.c
>>>>>>>>>>> @@ -6054,6 +6054,7 @@ static int nfs41_lock_expired(struct nfs4_state *state, struct file_lock *reques
>>>>>>>>>>> static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock *request)
>>>>>>>>>>> {
>>>>>>>>>>>       struct nfs_inode *nfsi = NFS_I(state->inode);
>>>>>>>>>>> +       struct nfs4_state_owner *sp = state->owner;
>>>>>>>>>>>       unsigned char fl_flags = request->fl_flags;
>>>>>>>>>>>       int status = -ENOLCK;
>>>>>>>>>>>
>>>>>>>>>>> @@ -6068,6 +6069,7 @@ static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock
>>>>>>>>>>>       status = do_vfs_lock(state->inode, request);
>>>>>>>>>>>       if (status < 0)
>>>>>>>>>>>               goto out;
>>>>>>>>>>> +       mutex_lock(&sp->so_delegreturn_mutex);
>>>>>>>>
>>>>>>>> From what I can tell, the first call to do_vfs_lock() in this function is used to test if we can take the lock locally.  Do we need to worry about this racing with delegreturn, too?
>>>>>>>
>>>>>>> When I included that call in the critical section,
>>>>>>> cthon04 locking tests deadlocked.
>>>>>>
>>>>>> Got it.  Thanks for checking!
>>>>>>
>>>>>> Anna
>>>>>>
>>>>>>>
>>>>>>>
>>>>>>>> Thanks,
>>>>>>>> Anna
>>>>>>>>
>>>>>>>>>>>       down_read(&nfsi->rwsem);
>>>>>>>>>>>       if (test_bit(NFS_DELEGATED_STATE, &state->flags)) {
>>>>>>>>>>>               /* Yes: cache locks! */
>>>>>>>>>>> @@ -6075,9 +6077,11 @@ static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock
>>>>>>>>>>>               request->fl_flags = fl_flags & ~FL_SLEEP;
>>>>>>>>>>>               status = do_vfs_lock(state->inode, request);
>>>>>>>>>>>               up_read(&nfsi->rwsem);
>>>>>>>>>>> +               mutex_unlock(&sp->so_delegreturn_mutex);
>>>>>>>>>>>               goto out;
>>>>>>>>>>>       }
>>>>>>>>>>>       up_read(&nfsi->rwsem);
>>>>>>>>>>> +       mutex_unlock(&sp->so_delegreturn_mutex);
>>>>>>>>>>>       status = _nfs4_do_setlk(state, cmd, request, NFS_LOCK_NEW);
>>>>>>>>>>> out:
>>>>>>>>>>>       request->fl_flags = fl_flags;
>>>>>>>
>>>>>>> --
>>>>>>> Chuck Lever
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>
>>>>> --
>>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>>> the body of a message to majordomo@vger.kernel.org
>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>
>>>> --
>>>> Chuck Lever
>>>>
>>>>
>>>>
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>
