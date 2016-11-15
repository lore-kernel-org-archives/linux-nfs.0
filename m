Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41314 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750998AbcKOQML (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 15 Nov 2016 11:12:11 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trond.myklebust@primarydata.com>,
        "Anna Schumaker" <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSv4.1: Don't allow a lock_state to be freed while
 checking
Date: Tue, 15 Nov 2016 11:12:04 -0500
Message-ID: <BD7D9CEA-11BA-40BB-AD49-3EB7635E1BE0@redhat.com>
In-Reply-To: <00FD5260-0053-45B0-B0FB-2B2F53947E39@redhat.com>
References: <0e6e9dac991cd93e2ae3e6a4b4b41bd974a040cb.1479142099.git.bcodding@redhat.com>
 <00FD5260-0053-45B0-B0FB-2B2F53947E39@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 14 Nov 2016, at 15:18, Benjamin Coddington wrote:

> On 14 Nov 2016, at 11:50, Benjamin Coddington wrote:
>
>> While walking the list of lock_states, keep the current 
>> nfs4_lock_state
>> referenced so that it isn't freed while checking.
>>
>> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
>> ---
>>  fs/nfs/nfs4proc.c | 12 +++++++++---
>>  1 file changed, 9 insertions(+), 3 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 7897826d7c51..9a1cb9e8c4fc 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -2564,12 +2564,15 @@ static void 
>> nfs41_check_delegation_stateid(struct nfs4_state *state)
>>  static int nfs41_check_expired_locks(struct nfs4_state *state)
>>  {
>>  	int status, ret = NFS_OK;
>> -	struct nfs4_lock_state *lsp;
>> +	struct nfs4_lock_state *lsp, *tmp;
>>  	struct nfs_server *server = NFS_SERVER(state->inode);
>>
>>  	if (!test_bit(LK_STATE_IN_USE, &state->flags))
>>  		goto out;
>> -	list_for_each_entry(lsp, &state->lock_states, ls_locks) {
>> +	spin_lock(&state->state_lock);
>> +	list_for_each_entry_safe(lsp, tmp, &state->lock_states, ls_locks) {
>> +		atomic_inc(&lsp->ls_count);
>> +		spin_unlock(&state->state_lock);
>>  		if (test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags)) {
>>  			struct rpc_cred *cred = lsp->ls_state->owner->so_cred;
>>
>> @@ -2588,7 +2591,10 @@ static int nfs41_check_expired_locks(struct 
>> nfs4_state *state)
>>  				break;
>>  			}
>>  		}
>> -	};
>> +		nfs4_put_lock_state(lsp);
>> +		spin_lock(&state->state_lock);
>> +	}
>> +	spin_unlock(&state->state_lock);
>>  out:
>>  	return ret;
>>  }
>
> Actually, something else may be wrong here.. after several more hours 
> of
> testing with this and Trond's two fixes for CLOSE races this popped 
> up:

I've been an idiot.  This patch is wrong in two ways:

1. list_for_each_entry_safe() won't keep the *next* entry from being 
freed
2. There shouldn't be any reason (I think) it can't hold the state lock 
over
    nfs41_test_and_free_expired_stateid(), so the much simpler fix is to 
hold it
    the entire time. (I expect the problem I saw with that the first 
time was the
    CLOSE/OPEN race recently fixed).

*ben goes off and tests what should be a simple fix again*

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7897826d7c51..34b36f148b65 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2569,6 +2569,7 @@ static int nfs41_check_expired_locks(struct 
nfs4_state *state)

         if (!test_bit(LK_STATE_IN_USE, &state->flags))
                 goto out;
+       spin_lock(&state->state_lock);
         list_for_each_entry(lsp, &state->lock_states, ls_locks) {
                 if (test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags)) {
                         struct rpc_cred *cred = 
lsp->ls_state->owner->so_cred;
@@ -2588,7 +2589,8 @@ static int nfs41_check_expired_locks(struct 
nfs4_state *state)
                                 break;
                         }
                 }
-       };
+       }
+       spin_unlock(&state->state_lock);
  out:
         return ret;
  }

No, it /does/ soft lockup this time:

crash> bt 2514
PID: 2514   TASK: ffff880131560000  CPU: 2   COMMAND: "::1-manager"
  #0 [ffffc90002a1b9d0] __schedule at ffffffff8182212e
  #1 [ffffc90002a1ba50] schedule at ffffffff818225d6
  #2 [ffffc90002a1ba68] rpc_wait_bit_killable at ffffffffa00d38f4 
[sunrpc]
  #3 [ffffc90002a1ba88] __wait_on_bit at ffffffff818229e1
  #4 [ffffc90002a1bac8] out_of_line_wait_on_bit at ffffffff81822b62
  #5 [ffffc90002a1bb40] __rpc_execute at ffffffffa00d477a [sunrpc]
  #6 [ffffc90002a1bba8] rpc_execute at ffffffffa00d6d41 [sunrpc]
  #7 [ffffc90002a1bbd8] rpc_run_task at ffffffffa00c7d99 [sunrpc]
  #8 [ffffc90002a1bc00] nfs4_call_sync_sequence at ffffffffa02d11e3 
[nfsv4]
  #9 [ffffc90002a1bc78] _nfs41_test_stateid at ffffffffa02d9941 [nfsv4]
#10 [ffffc90002a1bd30] nfs41_test_and_free_expired_stateid at 
ffffffffa02db9b9 [nfsv4]
#11 [ffffc90002a1bd90] nfs41_open_expired at ffffffffa02dbdd7 [nfsv4]
#12 [ffffc90002a1bdf0] nfs4_do_reclaim at ffffffffa02f057f [nfsv4]
#13 [ffffc90002a1be88] nfs4_run_state_manager at ffffffffa02f0f10 
[nfsv4]
#14 [ffffc90002a1bec8] kthread at ffffffff810c96a9
#15 [ffffc90002a1bf50] ret_from_fork at ffffffff81827615

crash> l *(0xffffffffa00d477a)
0xffffffffa00d477a is in __rpc_execute (net/sunrpc/sched.c:807).
802                     /* sync task: sleep here */
803                     dprintk("RPC: %5u sync task going to sleep\n", 
task->tk_pid);
804                     status = 
out_of_line_wait_on_bit(&task->tk_runstate,
805                                     RPC_TASK_QUEUED, 
rpc_wait_bit_killable,
806                                     TASK_KILLABLE);
807                     if (status == -ERESTARTSYS) {
808                             /*
809                              * When a sync task receives a signal, 
it exits with
810                              * -ERESTARTSYS. In order to catch any 
callbacks that
811                              * clean up after sleeping on some 
queue, we don't

Why it is queued here? Did the server return DELAY maybe?  
Investigations are
ongoing, advice welcomed.  I am going to resume email silence until I 
have
something worthwhile to contribute, rather than continue to reply to 
myself.

Ben
