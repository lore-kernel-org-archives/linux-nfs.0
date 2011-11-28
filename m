Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:62393 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750900Ab1K1GZv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Nov 2011 01:25:51 -0500
Message-ID: <4ED32AAB.8010800@cn.fujitsu.com>
Date: Mon, 28 Nov 2011 14:31:07 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSV4 :All lock operations should be sent to the server
 for resolution
References: <4D2FF124.7020500@cn.fujitsu.com>	 <20110114181600.GA15352@fieldses.org> <1295029762.3576.9.camel@heimdal.trondhjem.org>
In-Reply-To: <1295029762.3576.9.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

Trond Myklebust:
> On Fri, 2011-01-14 at 13:16 -0500, J. Bruce Fields wrote: 
>> On Fri, Jan 14, 2011 at 02:45:56PM +0800, Fu Liankun wrote:
>>> The RFC3530 describes that the client's all lock operations, including those
>>> requesting non-exclusive locks, should be sent to the server for resolution,
>>> even if it holds a read open delegation. But the kernel implements like that
>>> lock operations can be performed locally when a client holds an open
>>> delegation.
>>>
>>> The following are the RFC3530 provisions for Open Delegation and File Locks:
>>>
>>> 9.4.2.  Open Delegation and File Locks
>>>
>>>    When a client holds a write open delegation, lock operations may be
>>>    performed locally.  This includes those required for mandatory file
>>>    locking.  This can be done since the delegation implies that there
>>>    can be no conflicting locks.  Similarly, all of the revalidations
>>>    that would normally be associated with obtaining locks and the
>>>    flushing of data associated with the releasing of locks need not be
>>>    done.
>>>
>>>    When a client holds a read open delegation, lock operations are not
>>>    performed locally.  All lock operations, including those requesting
>>>    non-exclusive locks, are sent to the server for resolution.
>> Weird.  Can the rfc really be right about that?
>>
>> I guess it does permit servers to allow write-locks on read-open files,
>> but it seems bizarre not to require them to break delegations in that
>> case.
> 
> The ability to cache locks is one of the main reasons for holding
> delegations in the first place. Sure, the spec allows for non-posix
> locking, but the Linux client doesn't.

  Would you mind tell me some about why we not support non-posix locking at NFS ?

thanks,
Mi Jinlong

> 
> IOW: This patch will not be applied.
> 
> Trond
> 
>> --b.
>>
>>> Signed-off-by: Fu Liankun <fuliankun@cn.fujitsu.com>
>>> ---
>>>  fs/nfs/nfs4proc.c |    7 -------
>>>  1 files changed, 0 insertions(+), 7 deletions(-)
>>>
>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>> index 0f24cdf..3bba85b 100644
>>> --- a/fs/nfs/nfs4proc.c
>>> +++ b/fs/nfs/nfs4proc.c
>>> @@ -4215,13 +4215,6 @@ static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock
>>>  	if (status < 0)
>>>  		goto out;
>>>  	down_read(&nfsi->rwsem);
>>> -	if (test_bit(NFS_DELEGATED_STATE, &state->flags)) {
>>> -		/* Yes: cache locks! */
>>> -		/* ...but avoid races with delegation recall... */
>>> -		request->fl_flags = fl_flags & ~FL_SLEEP;
>>> -		status = do_vfs_lock(request->fl_file, request);
>>> -		goto out_unlock;
>>> -	}
>>>  	status = _nfs4_do_setlk(state, cmd, request, NFS_LOCK_NEW);
>>>  	if (status != 0)
>>>  		goto out_unlock;
>>> -- 
>>> 1.7.3.1
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

