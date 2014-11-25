Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f49.google.com ([74.125.82.49]:35495 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750856AbaKYP4X convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Nov 2014 10:56:23 -0500
Received: by mail-wg0-f49.google.com with SMTP id x12so1241465wgg.22
        for <linux-nfs@vger.kernel.org>; Tue, 25 Nov 2014 07:56:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <5474A2D2.1040400@Netapp.com>
References: <1415389499-16721-1-git-send-email-Anna.Schumaker@Netapp.com>
	<1415389499-16721-2-git-send-email-Anna.Schumaker@Netapp.com>
	<CAHQdGtSfx7d+AyVSKw0wpQ2Tcj3RUARurtPKr5FO-3=q1Lvicw@mail.gmail.com>
	<5474A2D2.1040400@Netapp.com>
Date: Tue, 25 Nov 2014 10:56:22 -0500
Message-ID: <CAHQdGtS-Apbwtnwsszd0sd5WY=+P8xpHxForqPoQ5+KEU6Jf3g@mail.gmail.com>
Subject: Re: [PATCH v4 1/2] nfs: Add ALLOCATE support
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 25, 2014 at 10:40 AM, Anna Schumaker
<Anna.Schumaker@netapp.com> wrote:
> On 11/24/2014 04:45 PM, Trond Myklebust wrote:
>> On Fri, Nov 7, 2014 at 2:44 PM, Anna Schumaker
>> <Anna.Schumaker@netapp.com> wrote:
>>> This patch adds support for using the NFS v4.2 operation ALLOCATE to
>>> preallocate data in a file.
>>>
>>> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
>>> ---
>>>  fs/nfs/inode.c            |  1 +
>>>  fs/nfs/nfs42.h            |  1 +
>>>  fs/nfs/nfs42proc.c        | 58 ++++++++++++++++++++++++++++++++++++
>>>  fs/nfs/nfs42xdr.c         | 75 +++++++++++++++++++++++++++++++++++++++++++++++
>>>  fs/nfs/nfs4_fs.h          |  1 +
>>>  fs/nfs/nfs4file.c         | 28 ++++++++++++++++++
>>>  fs/nfs/nfs4proc.c         |  3 +-
>>>  fs/nfs/nfs4xdr.c          |  1 +
>>>  include/linux/nfs4.h      |  1 +
>>>  include/linux/nfs_fs_sb.h |  1 +
>>>  include/linux/nfs_xdr.h   | 14 +++++++++
>>>  11 files changed, 183 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>>> index 00689a8..bfffc33 100644
>>> --- a/fs/nfs/inode.c
>>> +++ b/fs/nfs/inode.c
>>> @@ -192,6 +192,7 @@ void nfs_zap_caches(struct inode *inode)
>>>         nfs_zap_caches_locked(inode);
>>>         spin_unlock(&inode->i_lock);
>>>  }
>>> +EXPORT_SYMBOL_GPL(nfs_zap_caches);
>>>
>>>  void nfs_zap_mapping(struct inode *inode, struct address_space *mapping)
>>>  {
>>> diff --git a/fs/nfs/nfs42.h b/fs/nfs/nfs42.h
>>> index d10333a..42656a9 100644
>>> --- a/fs/nfs/nfs42.h
>>> +++ b/fs/nfs/nfs42.h
>>> @@ -6,6 +6,7 @@
>>>  #define __LINUX_FS_NFS_NFS4_2_H
>>>
>>>  /* nfs4.2proc.c */
>>> +int nfs42_proc_allocate(struct file *, loff_t, loff_t);
>>>  loff_t nfs42_proc_llseek(struct file *, loff_t, int);
>>>
>>>  /* nfs4.2xdr.h */
>>> diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
>>> index 0886f1d..5da6e8e 100644
>>> --- a/fs/nfs/nfs42proc.c
>>> +++ b/fs/nfs/nfs42proc.c
>>> @@ -32,6 +32,64 @@ static int nfs42_set_rw_stateid(nfs4_stateid *dst, struct file *file,
>>>         return ret;
>>>  }
>>>
>>> +int _nfs42_proc_fallocate(struct rpc_message *msg, struct file *filep,
>>> +                         loff_t offset, loff_t len)
>>> +{
>>> +       struct inode *inode = file_inode(filep);
>>> +       struct nfs42_falloc_args args = {
>>> +               .falloc_fh      = NFS_FH(inode),
>>> +               .falloc_offset  = offset,
>>> +               .falloc_length  = len,
>>> +       };
>>> +       struct nfs42_falloc_res res;
>>> +       struct nfs_server *server = NFS_SERVER(inode);
>>> +       int status;
>>> +
>>> +       msg->rpc_argp = &args;
>>> +       msg->rpc_resp = &res;
>>> +
>>> +       status = nfs42_set_rw_stateid(&args.falloc_stateid, filep, FMODE_WRITE);
>>> +       if (status)
>>> +               return status;
>>> +
>>> +       return nfs4_call_sync(server->client, server, msg,
>>> +                             &args.seq_args, &res.seq_res, 0);
>>> +}
>>
>> /home/trondmy/devel/kernel/linux-nfs/fs/nfs/nfs42proc.c:35:5: warning:
>> no previous prototype for ‘_nfs42_proc_fallocate’
>> [-Wmissing-prototypes]
>
> Are you using a special config option to enable the -Wmissing-prototypes flag?  I haven't been able to hit this.
>

I'm just compiling with 'make W=1' on a recent Fedora 20 image.

Cheers
  Trond

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
