Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:55375 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754546Ab1IMPuO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Sep 2011 11:50:14 -0400
Received: by eyx24 with SMTP id 24so428696eyx.19
        for <linux-nfs@vger.kernel.org>; Tue, 13 Sep 2011 08:50:13 -0700 (PDT)
In-Reply-To: <20110913111441.4b2502b8@corrin.poochiereds.net>
References: <1312073576-11024-1-git-send-email-rees@umich.edu>
 <1312073576-11024-13-git-send-email-rees@umich.edu> <20110913111441.4b2502b8@corrin.poochiereds.net>
From: Peng Tao <bergwolf@gmail.com>
Date: Tue, 13 Sep 2011 23:49:52 +0800
Message-ID: <CA+a=Yy4oeBK4Tihq=nTQ89Z8PZObb6MO3c9PoWJCYeo5ja+XfQ@mail.gmail.com>
Subject: Re: [PATCH v7 12/26] pnfsblock: add device operations
To: Jeff Layton <jlayton@redhat.com>
Cc: Jim Rees <rees@umich.edu>, Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Sep 13, 2011 at 11:14 PM, Jeff Layton <jlayton@redhat.com> wrote:
> On Sat, 30 Jul 2011 20:52:42 -0400
> Jim Rees <rees@umich.edu> wrote:
>
>> Signed-off-by: Jim Rees <rees@umich.edu>
>> Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> Signed-off-by: Benny Halevy <bhalevy@tonian.com>
>> [upcall bugfixes]
>> Signed-off-by: Peng Tao <peng_tao@emc.com>
>> ---
>>  fs/nfs/blocklayout/Makefile         |    2 +-
>>  fs/nfs/blocklayout/blocklayout.c    |   42 ++++++++
>>  fs/nfs/blocklayout/blocklayout.h    |   40 +++++++
>>  fs/nfs/blocklayout/blocklayoutdev.c |  191 +++++++++++++++++++++++++++++++++++
>>  fs/nfs/client.c                     |    2 +-
>>  include/linux/nfs.h                 |    2 +
>>  6 files changed, 277 insertions(+), 2 deletions(-)
>>  create mode 100644 fs/nfs/blocklayout/blocklayoutdev.c
>>
>
> [...]
>> +static const struct rpc_pipe_ops bl_upcall_ops = {
>> +     .upcall         = bl_pipe_upcall,
>> +     .downcall       = bl_pipe_downcall,
>> +     .destroy_msg    = bl_pipe_destroy_msg,
>> +};
>> +
>>  static int __init nfs4blocklayout_init(void)
>>  {
>> +     struct vfsmount *mnt;
>> +     struct path path;
>>       int ret;
>>
>>       dprintk("%s: NFSv4 Block Layout Driver Registering...\n", __func__);
>>
>>       ret = pnfs_register_layoutdriver(&blocklayout_type);
>> +     if (ret)
>> +             goto out;
>> +
>> +     init_waitqueue_head(&bl_wq);
>> +
>> +     mnt = rpc_get_mount();
>> +     if (IS_ERR(mnt)) {
>> +             ret = PTR_ERR(mnt);
>> +             goto out_remove;
>> +     }
>> +
>
>
> Hmm...sorry for the late review on this, but I was just looking over
> this code as an example for some other stuff I'm working on...
>
> I notice that the above code does a rpc_get_mount to get a reference to
> the rpc_pipefs mount, but I don't see where that reference is ever put.
Thanks a lot for catching this.
Looking closer, we also missed a path_put() after vfs_path_lookup(). I
will send a patch fixing this.

Cheers,
Tao
>
>> +     ret = vfs_path_lookup(mnt->mnt_root,
>> +                           mnt,
>> +                           NFS_PIPE_DIRNAME, 0, &path);
>> +     if (ret)
>> +             goto out_remove;
>> +
>> +     bl_device_pipe = rpc_mkpipe(path.dentry, "blocklayout", NULL,
>> +                                 &bl_upcall_ops, 0);
>
>> +     if (IS_ERR(bl_device_pipe)) {
>> +             ret = PTR_ERR(bl_device_pipe);
>> +             goto out_remove;
>> +     }
>> +out:
>> +     return ret;
>> +
>> +out_remove:
>> +     pnfs_unregister_layoutdriver(&blocklayout_type);
>>       return ret;
>>  }
>>
>
>
>
> --
> Jeff Layton <jlayton@redhat.com>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
