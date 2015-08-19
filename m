Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:34538 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752115AbbHSUE3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Aug 2015 16:04:29 -0400
Received: by igui7 with SMTP id i7so116744349igu.1
        for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2015 13:04:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAKVebiWCC2hCOMhXr9yJrTHUWxNV-tF-Jndj0=tT5Wue8iGbTg@mail.gmail.com>
References: <1437677341-2943-1-git-send-email-trond.myklebust@primarydata.com>
 <CAKVebiUqbUHCAALFJ4hnMbqYhkPFVZyeAe9z80YRWtcVMg3bjg@mail.gmail.com> <CAKVebiWCC2hCOMhXr9yJrTHUWxNV-tF-Jndj0=tT5Wue8iGbTg@mail.gmail.com>
From: Peng Tao <bergwolf@primarydata.com>
Date: Wed, 19 Aug 2015 13:04:09 -0700
Message-ID: <CAKVebiXzv6zabEr65NG969UZW4fS+0joOg_rshAP54cKfph2uQ@mail.gmail.com>
Subject: Re: [PATCH 1/5] NFSv4/pnfs: Ensure we don't miss a file extension
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 19, 2015 at 11:40 AM, Peng Tao <bergwolf@primarydata.com> wrote:
> On Wed, Aug 19, 2015 at 10:50 AM, Peng Tao <bergwolf@primarydata.com> wrote:
>> Hi Trond,
>>
>> Can we please add following patch to stable as well? It not only fixes
>> pnfs write, but also fixes in band writes when delegations are
>> enabled. Without it, I can always get fstest read_write/mctime.t
>> failure with in band IO.
> ah, nvm, speaking too soon. I can still reproduce fstest
> read_write/mctime.t failure on delegation+inband IO with your testing
> branch...
>
> Looking into it...
>
oh, man, we do need the commit to fix delegation+inband IO. My VM's
time got screwed up and my last tests did not include the commit...
sorry again for more noise :(...

> sorry for the noise.
>
>>
>> Thanks,
>> Tao
>>
>> On Thu, Jul 23, 2015 at 11:48 AM, Trond Myklebust
>> <trond.myklebust@primarydata.com> wrote:
>>> pNFS writes don't return attributes, however that doesn't mean that we
>>> should ignore the fact that they may be extending the file. This patch
>>> ensures that if a write is seen to extend the file, then we always set
>>> an attribute barrier, and update the cached file size.
>>>
>>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>>> ---
>>>  fs/nfs/write.c | 15 +++++++++------
>>>  1 file changed, 9 insertions(+), 6 deletions(-)
>>>
>>> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
>>> index 359e9ad596c9..0e6a2b8786b4 100644
>>> --- a/fs/nfs/write.c
>>> +++ b/fs/nfs/write.c
>>> @@ -1378,24 +1378,27 @@ static void nfs_writeback_check_extend(struct nfs_pgio_header *hdr,
>>>  {
>>>         struct nfs_pgio_args *argp = &hdr->args;
>>>         struct nfs_pgio_res *resp = &hdr->res;
>>> +       u64 size = argp->offset + resp->count;
>>>
>>>         if (!(fattr->valid & NFS_ATTR_FATTR_SIZE))
>>> +               fattr->size = size;
>>> +       if (nfs_size_to_loff_t(fattr->size) < i_size_read(hdr->inode)) {
>>> +               fattr->valid &= ~NFS_ATTR_FATTR_SIZE;
>>>                 return;
>>> -       if (argp->offset + resp->count != fattr->size)
>>> -               return;
>>> -       if (nfs_size_to_loff_t(fattr->size) < i_size_read(hdr->inode))
>>> +       }
>>> +       if (size != fattr->size)
>>>                 return;
>>>         /* Set attribute barrier */
>>>         nfs_fattr_set_barrier(fattr);
>>> +       /* ...and update size */
>>> +       fattr->valid |= NFS_ATTR_FATTR_SIZE;
>>>  }
>>>
>>>  void nfs_writeback_update_inode(struct nfs_pgio_header *hdr)
>>>  {
>>> -       struct nfs_fattr *fattr = hdr->res.fattr;
>>> +       struct nfs_fattr *fattr = &hdr->fattr;
>>>         struct inode *inode = hdr->inode;
>>>
>>> -       if (fattr == NULL)
>>> -               return;
>>>         spin_lock(&inode->i_lock);
>>>         nfs_writeback_check_extend(hdr, fattr);
>>>         nfs_post_op_update_inode_force_wcc_locked(inode, fattr);
>>> --
>>> 2.4.3
>>>
