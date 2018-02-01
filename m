Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f193.google.com ([209.85.217.193]:44096 "EHLO
        mail-ua0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751602AbeBAQXe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Feb 2018 11:23:34 -0500
Received: by mail-ua0-f193.google.com with SMTP id x4so12197738uaj.11
        for <linux-nfs@vger.kernel.org>; Thu, 01 Feb 2018 08:23:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <87bmiul8r6.fsf@notabene.neil.brown.name>
References: <87r2rzo8qi.fsf@notabene.neil.brown.name> <87bmiul8r6.fsf@notabene.neil.brown.name>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 1 Feb 2018 11:23:33 -0500
Message-ID: <CAN-5tyGf6d=K_9baA6YucbfcVduufVjcLm72jLe2_8XMyT-P2g@mail.gmail.com>
Subject: Re: [PATCH] NFSv4: always set NFS_LOCK_LOST when a lock is lost.
To: NeilBrown <neilb@suse.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 19, 2017 at 4:15 PM, NeilBrown <neilb@suse.com> wrote:
> On Wed, Dec 13 2017, NeilBrown wrote:
>
>> There are 2 comments in the NFSv4 code which suggest that
>> SIGLOST should possibly be sent to a process.  In these
>> cases a lock has been lost.
>> The current practice is to set NFS_LOCK_LOST so that
>> read/write returns EIO when a lock is lost.
>> So change these comments to code when sets NFS_LOCK_LOST.
>>
>> One case is when lock recovery after apparent server restart
>> fails with NFS4ERR_DENIED, NFS4ERR_RECLAIM_BAD, or
>> NFS4ERRO_RECLAIM_CONFLICT.  The other case is when a lock
>> attempt as part of lease recovery fails with NFS4ERR_DENIED.
>>
>> In an ideal world, these should not happen.  However I have
>> a packet trace showing an NFSv4.1 session getting
>> NFS4ERR_BADSESSION after an extended network parition.  The
>> NFSv4.1 client treats this like server reboot until/unless
>> it get NFS4ERR_NO_GRACE, in which case it switches over to
>> "nograce" recovery mode.  In this network trace, the client
>> attempts to recover a lock and the server (incorrectly)
>> reports NFS4ERR_DENIED rather than NFS4ERR_NO_GRACE.  This
>> leads to the ineffective comment and the client then
>> continues to write using the OPEN stateid.
>>
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>>
>> Note that I have not tested this as I do not have direct access to a
>> faulty NFS server.  Once I get confirmation I will provide an update.
>
> Hi,
>  I have now received confirmation that this change does fix the locking
>  behavior in this case where the server is returning the wrong error
>  code.
>

Hi Neil,

I'm testing your patch and in my testing it does not address the
issue. But I'd like to double check if my testing scenario is the
problem the same as what the patch suppose to address.

My testing,
1. client 1 opens a file, grabs a lock (goes to sleep so that I could
trigger network partition).
2. wait sufficient amount of time for the client 1's state goes stale
on the server.
3. client 2 opens the same file, and grabs the lock and starting doing
IO (say writing).
4. plug network back into client 1. it recovers its client id and
session and initiates state recovery. server didn't reboot so it
doesn't reply with ERR_NO_GRACE to client's open and it succeeds. the
client sends a LOCK and gets ERR_DENIED from the server (because
client 2 is holding the lock now).
5. client 1's app now wakes up and does IO.

What should happen is that IO should fail. What I see is client 1
continues to do IO (say writing).

Is my scenario same as yours?



> Thanks,
> NeilBrown
>
>
>>
>> NeilBrown
>>
>>  fs/nfs/nfs4proc.c  | 12 ++++++++----
>>  fs/nfs/nfs4state.c |  5 ++++-
>>  2 files changed, 12 insertions(+), 5 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 56fa5a16e097..083802f7a1e9 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -2019,7 +2019,7 @@ static int nfs4_open_reclaim(struct nfs4_state_owner *sp, struct nfs4_state *sta
>>       return ret;
>>  }
>>
>> -static int nfs4_handle_delegation_recall_error(struct nfs_server *server, struct nfs4_state *state, const nfs4_stateid *stateid, int err)
>> +static int nfs4_handle_delegation_recall_error(struct nfs_server *server, struct nfs4_state *state, const nfs4_stateid *stateid, struct file_lock *fl, int err)
>>  {
>>       switch (err) {
>>               default:
>> @@ -2066,7 +2066,11 @@ static int nfs4_handle_delegation_recall_error(struct nfs_server *server, struct
>>                       return -EAGAIN;
>>               case -ENOMEM:
>>               case -NFS4ERR_DENIED:
>> -                     /* kill_proc(fl->fl_pid, SIGLOST, 1); */
>> +                     if (fl) {
>> +                             struct nfs4_lock_state *lsp = fl->fl_u.nfs4_fl.owner;
>> +                             if (lsp)
>> +                                     set_bit(NFS_LOCK_LOST, &lsp->ls_flags);
>> +                     }
>>                       return 0;
>>       }
>>       return err;
>> @@ -2102,7 +2106,7 @@ int nfs4_open_delegation_recall(struct nfs_open_context *ctx,
>>               err = nfs4_open_recover_helper(opendata, FMODE_READ);
>>       }
>>       nfs4_opendata_put(opendata);
>> -     return nfs4_handle_delegation_recall_error(server, state, stateid, err);
>> +     return nfs4_handle_delegation_recall_error(server, state, stateid, NULL, err);
>>  }
>>
>>  static void nfs4_open_confirm_prepare(struct rpc_task *task, void *calldata)
>> @@ -6739,7 +6743,7 @@ int nfs4_lock_delegation_recall(struct file_lock *fl, struct nfs4_state *state,
>>       if (err != 0)
>>               return err;
>>       err = _nfs4_do_setlk(state, F_SETLK, fl, NFS_LOCK_NEW);
>> -     return nfs4_handle_delegation_recall_error(server, state, stateid, err);
>> +     return nfs4_handle_delegation_recall_error(server, state, stateid, fl, err);
>>  }
>>
>>  struct nfs_release_lockowner_data {
>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>> index e4f4a09ed9f4..91a4d4eeb235 100644
>> --- a/fs/nfs/nfs4state.c
>> +++ b/fs/nfs/nfs4state.c
>> @@ -1482,6 +1482,7 @@ static int nfs4_reclaim_locks(struct nfs4_state *state, const struct nfs4_state_
>>       struct inode *inode = state->inode;
>>       struct nfs_inode *nfsi = NFS_I(inode);
>>       struct file_lock *fl;
>> +     struct nfs4_lock_state *lsp;
>>       int status = 0;
>>       struct file_lock_context *flctx = inode->i_flctx;
>>       struct list_head *list;
>> @@ -1522,7 +1523,9 @@ static int nfs4_reclaim_locks(struct nfs4_state *state, const struct nfs4_state_
>>               case -NFS4ERR_DENIED:
>>               case -NFS4ERR_RECLAIM_BAD:
>>               case -NFS4ERR_RECLAIM_CONFLICT:
>> -                     /* kill_proc(fl->fl_pid, SIGLOST, 1); */
>> +                     lsp = fl->fl_u.nfs4_fl.owner;
>> +                     if (lsp)
>> +                             set_bit(NFS_LOCK_LOST, &lsp->ls_flags);
>>                       status = 0;
>>               }
>>               spin_lock(&flctx->flc_lock);
>> --
>> 2.14.0.rc0.dirty
