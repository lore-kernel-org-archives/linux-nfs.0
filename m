Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vx0-f174.google.com ([209.85.220.174]:33537 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753410Ab1K2PFz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2011 10:05:55 -0500
MIME-Version: 1.0
In-Reply-To: <4ED4DA80.9080303@parallels.com>
References: <20111129090754.20730.64567.stgit@localhost6.localdomain6>
 <20111129091037.20730.59391.stgit@localhost6.localdomain6>
 <F19688880B763E40B28B2B462677FBF805E3A4AFF2@MX09A.corp.emc.com>
 <4ED4CDCE.9080804@parallels.com> <F19688880B763E40B28B2B462677FBF805E3A4AFFD@MX09A.corp.emc.com>
 <4ED4DA80.9080303@parallels.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Tue, 29 Nov 2011 23:05:33 +0800
Message-ID: <CA+a=Yy7GkbrvB3TsnCQUSnjvEU3DFOA8F8DT7U_xL9BGO2_Rtg@mail.gmail.com>
Subject: Re: [PATCH 4/5] NFS: remove RPC PipeFS mount point reference from
 blocklayout routines
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "tao.peng@emc.com" <tao.peng@emc.com>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        James Bottomley <jbottomley@parallels.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 29, 2011 at 9:13 PM, Stanislav Kinsbursky
<skinsbursky@parallels.com> wrote:
> 29.11.2011 16:40, tao.peng@emc.com пишет:
>
>>> -----Original Message-----
>>> From: Stanislav Kinsbursky [mailto:skinsbursky@parallels.com]
>>> Sent: Tuesday, November 29, 2011 8:19 PM
>>> To: Peng, Tao
>>> Cc: Trond.Myklebust@netapp.com; linux-nfs@vger.kernel.org; Pavel
>>> Emelianov; neilb@suse.de;
>>> netdev@vger.kernel.org; linux-kernel@vger.kernel.org; James Bottomley;
>>> bfields@fieldses.org;
>>> davem@davemloft.net; devel@openvz.org
>>> Subject: Re: [PATCH 4/5] NFS: remove RPC PipeFS mount point reference
>>> from blocklayout routines
>>>
>>> 29.11.2011 16:00, tao.peng@emc.com пишет:
>>>>>
>>>>> -----Original Message-----
>>>>> From: linux-nfs-owner@vger.kernel.org
>>>>> [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of
>>>
>>> Stanislav
>>>>>
>>>>> Kinsbursky
>>>>> Sent: Tuesday, November 29, 2011 6:11 PM
>>>>> To: Trond.Myklebust@netapp.com
>>>>> Cc: linux-nfs@vger.kernel.org; xemul@parallels.com; neilb@suse.de;
>>>>> netdev@vger.kernel.org; linux-
>>>>> kernel@vger.kernel.org; jbottomley@parallels.com; bfields@fieldses.org;
>>>>> davem@davemloft.net;
>>>>> devel@openvz.org
>>>>> Subject: [PATCH 4/5] NFS: remove RPC PipeFS mount point reference from
>>>>> blocklayout routines
>>>>>
>>>>> This is a cleanup patch. We don't need this reference anymore, because
>>>>> blocklayout pipes dentries now creates and destroys in per-net
>>>>> operations and
>>>>> on PipeFS mount/umount notification.
>>>>> Note that nfs4blocklayout_register_net() now returns 0 instead of
>>>>> -ENOENT in
>>>>> case of PipeFS superblock absence. This is ok, because blocklayout pipe
>>>>> dentry
>>>>> will be created on PipeFS mount event.
>>>>
>>>> When is the "pipefs mount event" going to happen? When inserting kernel
>>>> modules or when user issues
>>>
>>> mount command?
>>>>
>>>>
>>>
>>> When user issues mount command.
>>> Kernel mounts of PipeFS has been removed with all these patch sets I've
>>> sent
>>> already.
>>
>> Then it is going to break blocklayout user space program blkmapd, which is
>> stared before mounting any file system and it tries to open the pipe file
>> when started.
>
>
> Sorry, but I don't get it. Probably we have misunderstanding here.
> You said, that "blkmapd ... tries to open the pipe file when started". This
> pipe file is located on PipeFS, isn't it?
> If yes, then PipeFS have to be mounted already in user-space. And if it has
> been mounted - then pipe dentry is present.
> IOW, pipe (without dentry) will be created on module load. Pipe dentry will
> be created right after that (like it was before) if PipeFS was mounted from
> user-space. If not - then pipe dentry will be created  on PipeFS (!) mount
> (not NFS or pNFS mount) from user-space.
Sorry, I misunderstood. I was thinking about mounting NFS or pNFS when
you say "when user issues mount command". Thanks for the explanation.

Regards,
Tao
>
> Or I'm missing something in your reply?
>
>
>> Not sure if you implement the same logic on nfs pipe as well. But if you
>> do, then nfs client user space program idmapd will fail to start for the
>> same reason.
>>
>
> The same logic here.
>
>
>> Why not just fail to load module if you fail to initialize pipefs? When is
>> rpc_get_sb_net() going to fail?
>>
>
> Sorry, but I don't understand, what is your idea. And why do we need to fail
> at all.
> BTW, rpc_get_sb_net() just checks, was PipeFS mounted in passed net, or not.
> If not - not a problem. Dentries will be created on mount event. If yes,
> then it returns locked PipeFS sb and the next step is dentry creation.
>
>
>>>
>>>
>>>> Thanks,
>>>> Tao
>>>>
>>>>>
>>>>> Signed-off-by: Stanislav Kinsbursky<skinsbursky@parallels.com>
>>>>>
>>>>> ---
>>>>>   fs/nfs/blocklayout/blocklayout.c |    9 +--------
>>>>>   1 files changed, 1 insertions(+), 8 deletions(-)
>>>>>
>>>>> diff --git a/fs/nfs/blocklayout/blocklayout.c
>>>>> b/fs/nfs/blocklayout/blocklayout.c
>>>>> index acf7ac9..8211ffd 100644
>>>>> --- a/fs/nfs/blocklayout/blocklayout.c
>>>>> +++ b/fs/nfs/blocklayout/blocklayout.c
>>>>> @@ -1032,7 +1032,7 @@ static struct dentry
>>>>> *nfs4blocklayout_register_net(struct net *net,
>>>>>
>>>>>        pipefs_sb = rpc_get_sb_net(net);
>>>>>        if (!pipefs_sb)
>>>>> -               return ERR_PTR(-ENOENT);
>>>>> +               return 0;
>>>>>        dentry = nfs4blocklayout_register_sb(pipefs_sb, pipe);
>>>>>        rpc_put_sb_net(net);
>>>>>        return dentry;
>>>>> @@ -1083,7 +1083,6 @@ static struct pernet_operations
>>>>> nfs4blocklayout_net_ops = {
>>>>>
>>>>>   static int __init nfs4blocklayout_init(void)
>>>>>   {
>>>>> -       struct vfsmount *mnt;
>>>>>        int ret;
>>>>>
>>>>>        dprintk("%s: NFSv4 Block Layout Driver Registering...\n",
>>>>> __func__);
>>>>> @@ -1093,12 +1092,6 @@ static int __init nfs4blocklayout_init(void)
>>>>>                goto out;
>>>>>
>>>>>        init_waitqueue_head(&bl_wq);
>>>>> -
>>>>> -       mnt = rpc_get_mount();
>>>>> -       if (IS_ERR(mnt)) {
>>>>> -               ret = PTR_ERR(mnt);
>>>>> -               goto out_remove;
>>>>> -       }
>>>>>        ret = rpc_pipefs_notifier_register(&nfs4blocklayout_block);
>>>>>        if (ret)
>>>>>                goto out_remove;
>>>>>
>>>>> --
>>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>>> the body of a message to majordomo@vger.kernel.org
>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>
>>>>
>>>
>>>
>>> --
>>> Best regards,
>>> Stanislav Kinsbursky
>>
>>
>
>
> --
> Best regards,
> Stanislav Kinsbursky
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
