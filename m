Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f41.google.com ([209.85.216.41]:39393 "EHLO
	mail-qa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751283AbbBFCyj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Feb 2015 21:54:39 -0500
Received: by mail-qa0-f41.google.com with SMTP id bm13so8990896qab.0
        for <linux-nfs@vger.kernel.org>; Thu, 05 Feb 2015 18:54:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAKVebiVX7Nd76_byoDgaZfP6ojVZ_WZ_rHu8T+K9TnrCphJ8wA@mail.gmail.com>
References: <1423175831-54558-1-git-send-email-trond.myklebust@primarydata.com>
 <CAKVebiVC+EH+baPYF2WNy1yQT-TvgR8pVFBFKPVQqdrzRY6atA@mail.gmail.com> <CAKVebiVX7Nd76_byoDgaZfP6ojVZ_WZ_rHu8T+K9TnrCphJ8wA@mail.gmail.com>
From: Peng Tao <tao.peng@primarydata.com>
Date: Fri, 6 Feb 2015 10:54:18 +0800
Message-ID: <CAKVebiW4UHSy8_hCWL5CRHzqrZL1WXFifm1-dHRn2e+tPt+2cw@mail.gmail.com>
Subject: Re: [PATCH 1/5] NFSv4: Ensure we reference the inode for
 return-on-close in delegreturn
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 6, 2015 at 9:57 AM, Peng Tao <tao.peng@primarydata.com> wrote:
> On Fri, Feb 6, 2015 at 9:45 AM, Peng Tao <tao.peng@primarydata.com> wrote:
>> On Fri, Feb 6, 2015 at 6:37 AM, Trond Myklebust
>> <trond.myklebust@primarydata.com> wrote:
>>> If we have to do a return-on-close in the delegreturn code, then
>>> we must ensure that the inode and super block remain referenced.
>>>
> ah, a second thought. I looked for call sites of nfs_sb_active() and
> it gets called at five places in current tree:
> alloc_nfs_open_context, nfs4_opendata_alloc, nfs4_do_close,
> nfs_do_call_unlink, nfs_do_call_unlink
>
> So it appears that sb is activated while any file keeps opened and
> between unlink calls. Then it looks that we are allowed to keep
> delegations after sb is released? Maybe the best way to fix the sb
> reference part is to pin sb when getting the first delegation.
>
err, that cannot be working at all... by pinning super block, we
prevent umount from happening. and we are returning delegations while
shutting down nfs_server and evicting inode. I see your point that the
patch actually intends to deal with race between async delegation
return vs. nfs_server shutting down and inode eviction.

oops! sorry for the noise... you patch is definitely the way we want to go.

Cheers,
Tao

> Cheers,
> Tao
>
>> looks good. One nit is that maybe it's better to reuse the two helpers
>> in your 2ed patch.
>>
>> Reviewed-by: Peng Tao <tao.peng@primarydata.com>
>>> Cc: Peng Tao <tao.peng@primarydata.com>
>>> Cc: stable@vger.kernel.org # 3.17.x
>>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>>> ---
>>>  fs/nfs/nfs4proc.c | 19 ++++++++++++++-----
>>>  1 file changed, 14 insertions(+), 5 deletions(-)
>>>
>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>> index cd4295d84d54..b803c1d363e7 100644
>>> --- a/fs/nfs/nfs4proc.c
>>> +++ b/fs/nfs/nfs4proc.c
>>> @@ -5175,9 +5175,16 @@ static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
>>>  static void nfs4_delegreturn_release(void *calldata)
>>>  {
>>>         struct nfs4_delegreturndata *data = calldata;
>>> +       struct inode *inode = data->inode;
>>> +
>>> +       if (inode) {
>>> +               struct super_block *sb = inode->i_sb;
>>>
>>> -       if (data->roc)
>>> -               pnfs_roc_release(data->inode);
>>> +               if (data->roc)
>>> +                       pnfs_roc_release(inode);
>>> +               iput(inode);
>>> +               nfs_sb_deactive(sb);
>>> +       }
>>>         kfree(calldata);
>>>  }
>>>
>>> @@ -5234,9 +5241,11 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
>>>         nfs_fattr_init(data->res.fattr);
>>>         data->timestamp = jiffies;
>>>         data->rpc_status = 0;
>>> -       data->inode = inode;
>>> -       data->roc = list_empty(&NFS_I(inode)->open_files) ?
>>> -                   pnfs_roc(inode) : false;
>>> +       data->inode = igrab(inode);
>>> +       if (data->inode) {
>>> +               nfs_sb_active(inode->i_sb);
>>> +               data->roc = nfs4_roc(inode);
>>> +       }
>>>
>>>         task_setup_data.callback_data = data;
>>>         msg.rpc_argp = &data->args;
>>> --
>>> 2.1.0
>>>
