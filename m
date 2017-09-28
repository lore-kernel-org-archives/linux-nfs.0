Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36745 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751345AbdI1UAB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Sep 2017 16:00:01 -0400
Received: by mail-io0-f193.google.com with SMTP id n69so1546156ioi.3
        for <linux-nfs@vger.kernel.org>; Thu, 28 Sep 2017 13:00:00 -0700 (PDT)
Subject: Re: [PATCH v4 08/12] NFS handle COPY reply CB_OFFLOAD call race
To: Olga Kornievskaia <aglo@umich.edu>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        Trond Myklebust <Trond.Myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
References: <20170928172819.50703-1-kolga@netapp.com>
 <20170928172819.50703-9-kolga@netapp.com>
 <bdd3c60c-2dba-d612-479e-63d3261b0a69@gmail.com>
 <CAN-5tyHZj6i_SOy5HLWAGhFXG3Pr2_8ARg0chbhfbfVV3+cCCQ@mail.gmail.com>
From: Anna Schumaker <schumaker.anna@gmail.com>
Message-ID: <693ee37f-aa97-5d7a-b1d3-e1c4bfee9b38@gmail.com>
Date: Thu, 28 Sep 2017 15:59:57 -0400
MIME-Version: 1.0
In-Reply-To: <CAN-5tyHZj6i_SOy5HLWAGhFXG3Pr2_8ARg0chbhfbfVV3+cCCQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/28/2017 03:57 PM, Olga Kornievskaia wrote:
> On Thu, Sep 28, 2017 at 3:50 PM, Anna Schumaker
> <schumaker.anna@gmail.com> wrote:
>> Hi Olga,
>>
>> On 09/28/2017 01:28 PM, Olga Kornievskaia wrote:
>>> It's possible that server replies back with CB_OFFLOAD call and
>>> COPY reply at the same time such that client will process
>>> CB_OFFLOAD before reply to COPY. For that keep a list of pending
>>> callback stateids received and them before waiting on completion
>>                     ^^^^^^^^^^^^^^^^^^^^^^^^
>> What are you doing with the stateids?
> 
> Is fixing "them" to "then" address the question?

Yes, it does! :)

> 
>>> check the pending list.
>>>
>>> Cleanup any pending copies on the client shutdown.
>>>
>>> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>>> ---
>>>  fs/nfs/callback_proc.c    | 17 ++++++++++++++---
>>>  fs/nfs/nfs42proc.c        | 24 +++++++++++++++++++++---
>>>  fs/nfs/nfs4client.c       | 15 +++++++++++++++
>>>  include/linux/nfs_fs_sb.h |  1 +
>>>  4 files changed, 51 insertions(+), 6 deletions(-)
>>>
>>> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
>>> index d3e7b61..d546c9f 100644
>>> --- a/fs/nfs/callback_proc.c
>>> +++ b/fs/nfs/callback_proc.c
>>> @@ -676,11 +676,12 @@ __be32 nfs4_callback_offload(void *data, void *dummy,
>>>       struct cb_offloadargs *args = data;
>>>       struct nfs_server *server;
>>>       struct nfs4_copy_state *copy;
>>> +     bool found = false;
>>>
>>> +     spin_lock(&cps->clp->cl_lock);
>>>       rcu_read_lock();
>>>       list_for_each_entry_rcu(server, &cps->clp->cl_superblocks,
>>>                               client_link) {
>>> -             spin_lock(&server->nfs_client->cl_lock);
>>>               list_for_each_entry(copy, &server->ss_copies, copies) {
>>>                       if (memcmp(args->coa_stateid.other,
>>>                                       copy->stateid.other,
>>> @@ -688,13 +689,23 @@ __be32 nfs4_callback_offload(void *data, void *dummy,
>>>                               continue;
>>>                       nfs4_copy_cb_args(copy, args);
>>>                       complete(&copy->completion);
>>> -                     spin_unlock(&server->nfs_client->cl_lock);
>>> +                     found = true;
>>>                       goto out;
>>>               }
>>> -             spin_unlock(&server->nfs_client->cl_lock);
>>>       }
>>>  out:
>>>       rcu_read_unlock();
>>> +     if (!found) {
>>> +             copy = kzalloc(sizeof(struct nfs4_copy_state), GFP_NOFS);
>>> +             if (!copy) {
>>> +                     spin_unlock(&cps->clp->cl_lock);
>>> +                     return -ENOMEM;
>>> +             }
>>> +             memcpy(&copy->stateid, &args->coa_stateid, NFS4_STATEID_SIZE);
>>> +             nfs4_copy_cb_args(copy, args);
>>> +             list_add_tail(&copy->copies, &cps->clp->pending_cb_stateids);
>>> +     }
>>> +     spin_unlock(&cps->clp->cl_lock);
>>>
>>>       return 0;
>>>  }
>>> diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
>>> index c8ca353..d0f454e 100644
>>> --- a/fs/nfs/nfs42proc.c
>>> +++ b/fs/nfs/nfs42proc.c
>>> @@ -137,15 +137,32 @@ static int handle_async_copy(struct nfs42_copy_res *res,
>>>                            uint64_t *ret_count)
>>>  {
>>>       struct nfs4_copy_state *copy;
>>> -     int status;
>>> +     int status = NFS4_OK;
>>
>> Might as well just move this bit to the previous patch :)
> 
> Got it.
> 
>> Anna
>>
>>> +     bool found_pending = false;
>>> +
>>> +     spin_lock(&server->nfs_client->cl_lock);
>>> +     list_for_each_entry(copy, &server->nfs_client->pending_cb_stateids,
>>> +                             copies) {
>>> +             if (memcmp(&res->write_res.stateid, &copy->stateid,
>>> +                             NFS4_STATEID_SIZE))
>>> +                     continue;
>>> +             found_pending = true;
>>> +             list_del(&copy->copies);
>>> +             break;
>>> +     }
>>> +     if (found_pending) {
>>> +             spin_unlock(&server->nfs_client->cl_lock);
>>> +             goto out;
>>> +     }
>>>
>>>       copy = kzalloc(sizeof(struct nfs4_copy_state), GFP_NOFS);
>>> -     if (!copy)
>>> +     if (!copy) {
>>> +             spin_unlock(&server->nfs_client->cl_lock);
>>>               return -ENOMEM;
>>> +     }
>>>       memcpy(&copy->stateid, &res->write_res.stateid, NFS4_STATEID_SIZE);
>>>       init_completion(&copy->completion);
>>>
>>> -     spin_lock(&server->nfs_client->cl_lock);
>>>       list_add_tail(&copy->copies, &server->ss_copies);
>>>       spin_unlock(&server->nfs_client->cl_lock);
>>>
>>> @@ -153,6 +170,7 @@ static int handle_async_copy(struct nfs42_copy_res *res,
>>>       spin_lock(&server->nfs_client->cl_lock);
>>>       list_del_init(&copy->copies);
>>>       spin_unlock(&server->nfs_client->cl_lock);
>>> +out:
>>>       *ret_count = copy->count;
>>>       memcpy(&res->write_res.verifier, &copy->verf, sizeof(copy->verf));
>>>       if (copy->count <= 0)
>>> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
>>> index e9bea90..46d4649 100644
>>> --- a/fs/nfs/nfs4client.c
>>> +++ b/fs/nfs/nfs4client.c
>>> @@ -156,9 +156,23 @@ struct rpc_clnt *
>>>       }
>>>  }
>>>
>>> +static void
>>> +nfs4_cleanup_callback(struct nfs_client *clp)
>>> +{
>>> +     struct nfs4_copy_state *cp_state;
>>> +
>>> +     while (!list_empty(&clp->pending_cb_stateids)) {
>>> +             cp_state = list_entry(clp->pending_cb_stateids.next,
>>> +                                     struct nfs4_copy_state, copies);
>>> +             list_del(&cp_state->copies);
>>> +             kfree(cp_state);
>>> +     }
>>> +}
>>> +
>>>  void nfs41_shutdown_client(struct nfs_client *clp)
>>>  {
>>>       if (nfs4_has_session(clp)) {
>>> +             nfs4_cleanup_callback(clp);
>>>               nfs4_shutdown_ds_clients(clp);
>>>               nfs4_destroy_session(clp->cl_session);
>>>               nfs4_destroy_clientid(clp);
>>> @@ -202,6 +216,7 @@ struct nfs_client *nfs4_alloc_client(const struct nfs_client_initdata *cl_init)
>>>  #if IS_ENABLED(CONFIG_NFS_V4_1)
>>>       init_waitqueue_head(&clp->cl_lock_waitq);
>>>  #endif
>>> +     INIT_LIST_HEAD(&clp->pending_cb_stateids);
>>>       return clp;
>>>
>>>  error:
>>> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
>>> index 511eefb..72f159e 100644
>>> --- a/include/linux/nfs_fs_sb.h
>>> +++ b/include/linux/nfs_fs_sb.h
>>> @@ -119,6 +119,7 @@ struct nfs_client {
>>>  #endif
>>>
>>>       struct net              *cl_net;
>>> +     struct list_head        pending_cb_stateids;
>>>  };
>>>
>>>  /*
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
