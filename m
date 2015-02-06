Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f179.google.com ([209.85.220.179]:50898 "EHLO
	mail-vc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752585AbbBFNbW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Feb 2015 08:31:22 -0500
Received: by mail-vc0-f179.google.com with SMTP id la4so4994829vcb.10
        for <linux-nfs@vger.kernel.org>; Fri, 06 Feb 2015 05:31:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150206072637.2cf6597f@tlielax.poochiereds.net>
References: <1423197907-75541-1-git-send-email-trond.myklebust@primarydata.com>
	<20150206072637.2cf6597f@tlielax.poochiereds.net>
Date: Fri, 6 Feb 2015 08:31:21 -0500
Message-ID: <CAHQdGtQR4xc4Dge_nktpWO9reb=wDMiWk1drcEj6kDKQJVRdSQ@mail.gmail.com>
Subject: Re: [PATCH v3 1/5] NFSv4: Ensure we reference the inode for
 return-on-close in delegreturn
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Peng Tao <tao.peng@primarydata.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 6, 2015 at 7:26 AM, Jeff Layton <jeff.layton@primarydata.com> wrote:
> On Thu,  5 Feb 2015 23:45:03 -0500
> Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>
>> If we have to do a return-on-close in the delegreturn code, then
>> we must ensure that the inode and super block remain referenced.
>>
>> Cc: Peng Tao <tao.peng@primarydata.com>
>> Cc: stable@vger.kernel.org # 3.17.x
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> Reviewed-by: Peng Tao <tao.peng@primarydata.com>
>> ---
>>  fs/nfs/internal.h | 22 +++++++++++++++++++++-
>>  fs/nfs/nfs4proc.c | 14 +++++++++-----
>>  fs/nfs/super.c    |  9 ++++++---
>>  3 files changed, 36 insertions(+), 9 deletions(-)
>>
>> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
>> index a98cf2006179..21469e6e3834 100644
>> --- a/fs/nfs/internal.h
>> +++ b/fs/nfs/internal.h
>> @@ -391,7 +391,7 @@ extern struct rpc_stat nfs_rpcstat;
>>
>>  extern int __init register_nfs_fs(void);
>>  extern void __exit unregister_nfs_fs(void);
>> -extern void nfs_sb_active(struct super_block *sb);
>> +extern bool nfs_sb_active(struct super_block *sb);
>>  extern void nfs_sb_deactive(struct super_block *sb);
>>
>>  /* namespace.c */
>> @@ -514,6 +514,26 @@ extern int nfs41_walk_client_list(struct nfs_client *clp,
>>                               struct nfs_client **result,
>>                               struct rpc_cred *cred);
>>
>> +static inline struct inode *nfs_igrab_and_active(struct inode *inode)
>> +{
>> +     inode = igrab(inode);
>
> I would expect that you already hold a reference to the inode so
> shouldn't that never return NULL? If so, then you could use ihold()
> instead and simplify this a little.

The choice of igrab() is deliberate here because we may be called in
situations where the inode is in the process of being freed. Both
delegreturn and layoutreturn can be called as part of an 'evict_inode'
callback.

>
>> +     if (inode != NULL && !nfs_sb_active(inode->i_sb)) {
>> +             iput(inode);
>> +             inode = NULL;
>> +     }
>> +     return inode;
>> +}
>> +
>> +static inline void nfs_iput_and_deactive(struct inode *inode)
>> +{
>> +     if (inode != NULL) {
>> +             struct super_block *sb = inode->i_sb;
>> +
>> +             iput(inode);
>> +             nfs_sb_deactive(sb);
>> +     }
>> +}
>> +
>>  /*
>>   * Determine the device name as a string
>>   */
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index cd4295d84d54..dd892a4e7eb3 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -5175,9 +5175,13 @@ static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
>>  static void nfs4_delegreturn_release(void *calldata)
>>  {
>>       struct nfs4_delegreturndata *data = calldata;
>> +     struct inode *inode = data->inode;
>>
>> -     if (data->roc)
>> -             pnfs_roc_release(data->inode);
>> +     if (inode) {
>> +             if (data->roc)
>> +                     pnfs_roc_release(inode);
>> +             nfs_iput_and_deactive(inode);
>> +     }
>>       kfree(calldata);
>>  }
>>
>> @@ -5234,9 +5238,9 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
>>       nfs_fattr_init(data->res.fattr);
>>       data->timestamp = jiffies;
>>       data->rpc_status = 0;
>> -     data->inode = inode;
>> -     data->roc = list_empty(&NFS_I(inode)->open_files) ?
>> -                 pnfs_roc(inode) : false;
>> +     data->inode = nfs_igrab_and_active(inode);
>> +     if (data->inode)
>> +             data->roc = nfs4_roc(inode);
>>
>>       task_setup_data.callback_data = data;
>>       msg.rpc_argp = &data->args;
>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>> index 31a11b0e885d..368d9395d2e7 100644
>> --- a/fs/nfs/super.c
>> +++ b/fs/nfs/super.c
>> @@ -405,12 +405,15 @@ void __exit unregister_nfs_fs(void)
>>       unregister_filesystem(&nfs_fs_type);
>>  }
>>
>> -void nfs_sb_active(struct super_block *sb)
>> +bool nfs_sb_active(struct super_block *sb)
>>  {
>>       struct nfs_server *server = NFS_SB(sb);
>>
>> -     if (atomic_inc_return(&server->active) == 1)
>> -             atomic_inc(&sb->s_active);
>> +     if (!atomic_inc_not_zero(&sb->s_active))
>> +             return false;
>> +     if (atomic_inc_return(&server->active) != 1)
>> +             atomic_dec(&sb->s_active);
>
> Could you end up doing a 1->0 s_active transition here? Shouldn't this
> be a deactivate_super instead?

No. The above line ensures that we take 1 reference to sb->s_active
(when server->active does a 0->1 transition) and only that reference.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
