Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:3211 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750967Ab2CEPtP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Mar 2012 10:49:15 -0500
Message-ID: <4F54E05F.5040405@parallels.com>
Date: Mon, 05 Mar 2012 19:48:47 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v8 5/6] nfsd: add the infrastructure to handle the cld
 upcall
References: <1330720950-5872-1-git-send-email-jlayton@redhat.com>	<1330720950-5872-6-git-send-email-jlayton@redhat.com>	<4F547DF1.8090003@parallels.com>	<20120305074256.6dc36fed@tlielax.poochiereds.net>	<4F54B6B7.1010703@parallels.com>	<20120305093948.435f39cc@tlielax.poochiereds.net>	<4F54D367.4000503@parallels.com> <20120305101604.497e705f@tlielax.poochiereds.net>
In-Reply-To: <20120305101604.497e705f@tlielax.poochiereds.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

05.03.2012 19:16, Jeff Layton пишет:
> On Mon, 05 Mar 2012 18:53:27 +0400
> Stanislav Kinsbursky<skinsbursky@parallels.com>  wrote:
>
>> 05.03.2012 18:39, Jeff Layton пишет:
>>>
>>> Ok, I've started looking at the existing examples to try and ease the
>>> eventual containerization of this. Am I correct that the existing
>>> blocklayout pipe containerization is not yet complete?
>>>
>>> AIUI, you have a rpc_pipe per nfs_net struct, and those structs are
>>> allocated on a per-net basis. bl_pipe_downcall does this however:
>>>
>>>           if (copy_from_user(&bl_mount_reply, src, mlen) != 0)
>>>                   return -EFAULT;
>>>
>>> ...but bl_mount_reply is global:
>>>
>>>       static struct bl_dev_msg bl_mount_reply;
>>>
>>> So, if you're getting downcalls in two different network namespaces at
>>> the same time this could end up corrupt. It seems like bl_mount_reply
>>> needs to be part of nfs_net as well.
>>
>> Thanks for this catch, Jeff!
>> I need to fix this.
>>
>>>
>>> When you get a downcall, you have a filp pointer. Is there any way to
>>> determine the "correct" nfs_net object for a particular filp?
>>>
>>
>> Yes, sure.
>> This nfs_net object will be, obviously, in the same network namespace, as PipeFS
>> superblock. Network namespace is stored on PipeFS sb->s_fs_info.
>> IOW, code below should works:
>>
>> struct nfs_net *nn = net_generic(file->f_dentry->d_sb->s_fs_info, nfs_net_id);
>>
>
> Ok, I'm going to have to do something similar for the cld upcall
> eventually. We'll need a per-ns list of upcalls in flight, xid counter
> and spinlock.
>
> What may be best is to go ahead and introduce a nfsd_net struct as a
> per-net object start putting stuff inside it.
>

Agreed.
Would be cool, if you'll introduce this with your patch set.

-- 
Best regards,
Stanislav Kinsbursky
