Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f175.google.com ([209.85.220.175]:62462 "EHLO
	mail-vc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752246AbbBXQ4K (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Feb 2015 11:56:10 -0500
Received: by mail-vc0-f175.google.com with SMTP id hq12so10390898vcb.6
        for <linux-nfs@vger.kernel.org>; Tue, 24 Feb 2015 08:56:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <54ECA367.8010000@Netapp.com>
References: <1424728402-22455-1-git-send-email-Anna.Schumaker@Netapp.com>
	<CAHQdGtRh4kg11gUMdpL6Y=ot=A_Zt8vEC20B0WpaEh_w4dbQQA@mail.gmail.com>
	<54ECA367.8010000@Netapp.com>
Date: Tue, 24 Feb 2015 11:56:08 -0500
Message-ID: <CAHQdGtRwXSqHrCsdzFE7hktkMkcaxY7B4deTQg-oshvsFCWMEg@mail.gmail.com>
Subject: Re: [PATCH] NFS: Add a GETATTR to ALLOCATE and DEALLOCATE calls
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Thomas D Haynes <Thomas.Haynes@primarydata.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 24, 2015 at 11:14 AM, Anna Schumaker
<Anna.Schumaker@netapp.com> wrote:
> Hi Trond,
>
> Thanks for the review!
>
> On 02/23/2015 06:33 PM, Trond Myklebust wrote:
>> On Mon, Feb 23, 2015 at 4:53 PM, Anna Schumaker
>> <Anna.Schumaker@netapp.com> wrote:
>>> Adding a GETATTR lets us update file attributes immediately, rather than
>>> invalidating all cached data and updating later on.  I use the offset
>>> provided to fallocate() to determine what page cache data needs to be
>>> trashed.
>>>
>>> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
>>> ---
>>>  fs/nfs/inode.c          |  4 ++--
>>>  fs/nfs/nfs42proc.c      | 21 ++++++++++++++++-----
>>>  fs/nfs/nfs42xdr.c       | 20 ++++++++++++++++----
>>>  fs/nfs/nfs4file.c       |  1 -
>>>  include/linux/nfs_fs.h  |  1 +
>>>  include/linux/nfs_xdr.h |  4 ++++
>>>  6 files changed, 39 insertions(+), 12 deletions(-)
>>>
>>> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>>> index 83107be..f67aadb 100644
>>> --- a/fs/nfs/inode.c
>>> +++ b/fs/nfs/inode.c
>>> @@ -192,7 +192,6 @@ void nfs_zap_caches(struct inode *inode)
>>>         nfs_zap_caches_locked(inode);
>>>         spin_unlock(&inode->i_lock);
>>>  }
>>> -EXPORT_SYMBOL_GPL(nfs_zap_caches);
>>>
>>>  void nfs_zap_mapping(struct inode *inode, struct address_space *mapping)
>>>  {
>>> @@ -557,7 +556,7 @@ EXPORT_SYMBOL_GPL(nfs_setattr);
>>>   * corrected to take into account the fact that NFS requires
>>>   * inode->i_size to be updated under the inode->i_lock.
>>>   */
>>> -static int nfs_vmtruncate(struct inode * inode, loff_t offset)
>>> +int nfs_vmtruncate(struct inode * inode, loff_t offset)
>>>  {
>>>         int err;
>>>
>>> @@ -576,6 +575,7 @@ static int nfs_vmtruncate(struct inode * inode, loff_t offset)
>>>  out:
>>>         return err;
>>>  }
>>> +EXPORT_SYMBOL_GPL(nfs_vmtruncate);
>>>
>>>  /**
>>>   * nfs_setattr_update_inode - Update inode metadata after a setattr call.
>>> diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
>>> index cb17072..407bfc3 100644
>>> --- a/fs/nfs/nfs42proc.c
>>> +++ b/fs/nfs/nfs42proc.c
>>> @@ -36,24 +36,35 @@ static int _nfs42_proc_fallocate(struct rpc_message *msg, struct file *filep,
>>>                                  loff_t offset, loff_t len)
>>>  {
>>>         struct inode *inode = file_inode(filep);
>>> +       struct nfs_server *server = NFS_SERVER(inode);
>>>         struct nfs42_falloc_args args = {
>>>                 .falloc_fh      = NFS_FH(inode),
>>>                 .falloc_offset  = offset,
>>>                 .falloc_length  = len,
>>> +               .falloc_bitmask = server->attr_bitmask,
>>
>> Why do a full getattr? Won't the cache consistency bitmask suffice?
>> All you want is to get the change attribute, and possibly the new file
>> size so that you can verify it is correct.
>>
>>>         };
>>> -       struct nfs42_falloc_res res;
>>> -       struct nfs_server *server = NFS_SERVER(inode);
>>> -       int status;
>>> +       struct nfs42_falloc_res res = {
>>> +               .falloc_server  = server,
>>> +       };
>>> +       int status = -ENOMEM;
>>>
>>>         msg->rpc_argp = &args;
>>>         msg->rpc_resp = &res;
>>>
>>> +       nfs_fattr_init(&res.falloc_fattr);
>>> +
>>>         status = nfs42_set_rw_stateid(&args.falloc_stateid, filep, FMODE_WRITE);
>>>         if (status)
>>>                 return status;
>>>
>>> -       return nfs4_call_sync(server->client, server, msg,
>>> -                             &args.seq_args, &res.seq_res, 0);
>>> +       status = nfs4_call_sync(server->client, server, msg,
>>> +                               &args.seq_args, &res.seq_res, 0);
>>> +       if (!status) {
>>> +               nfs_vmtruncate(inode, offset);
>>
>> Do you need the vmtruncate? I thought ALLOCATE could only extend the
>> file, in which case calling truncate_pagecache() seems like overkill
>> (and maybe even racy).
>>
>> As for DEALLOCATE, you're punching a hole, so you really want to call
>> truncate_inode_pages_range().
>
> It looks like truncate_inode_pages_range() works just as well, so I'll switch over to that.  ALLOCATE needs to mark the entire range as "unallocated", so calling this function for both operations is correct.

No. ALLOCATE (a.k.a. fallocate(~FALLOC_FL_PUNCH_HOLE)) is not supposed
to change the contents of the data range being preallocated. If there
is data in that range, then it must remain unchanged. The only extra
requirement is that if you use it to extend the file, then the region
which did not previously contain any data must return zeros.
For that reason, both vmtruncate() and truncate_inode_pages_range()
must _not_ be used, as those will clear out data in the page cache.

DEALLOCATE (a.k.a. fallocate(FL_PUNCH_HOLE)) does, OTOH, change the
data contents in the range specified; it should zero out the data on
both the client and the server. That is why calling
truncate_inode_pages_range() on that range of the page cache is
correct.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
