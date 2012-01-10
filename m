Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:1136 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751638Ab2AJK22 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jan 2012 05:28:28 -0500
Message-ID: <4F0C1285.10002@parallels.com>
Date: Tue, 10 Jan 2012 14:27:17 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        James Bottomley <jbottomley@parallels.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH 6/6] NFS: idmap PipeFS notifier introduced
References: <20111128132805.4251.15252.stgit@localhost6.localdomain6>	 <20111128133410.4251.656.stgit@localhost6.localdomain6> <1325285643.10984.3.camel@lade.trondhjem.org>
In-Reply-To: <1325285643.10984.3.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

31.12.2011 02:54, Trond Myklebust пишет:
> On Mon, 2011-11-28 at 17:34 +0300, Stanislav Kinsbursky wrote:
>> This patch subscribes NFS clients to RPC pipefs notifications. Idmap notifier
>> is registering on NFS module load. This notifier callback is responsible for
>> creation/destruction of PipeFS idmap pipe dentry for NFS4 clients.
>>
>> Since ipdmap pipe is created in rpc client pipefs directory, we have make sure,
>> that this directory has been created already. IOW RPC client notifier callback
>> has been called already. To achive this, PipeFS notifier priorities has been
>> introduced (RPC clients notifier priority is greater than NFS idmap one).
>> But this approach gives another problem: unlink for RPC client directory will
>> be called before NFS idmap pipe unlink on UMOUNT event and will fail, because
>> directory is not empty.
>> The solution, introduced in this patch, is to try to remove client directory
>> once again after idmap pipe was unlinked. This looks like ugly hack, so
>> probably it should be replaced in some more elegant way.
>>
>> Note that no locking required in notifier callback because PipeFS superblock
>> pointer is passed as an argument from it's creation or destruction routine and
>> thus we can be sure about it's validity.
>>
>> Signed-off-by: Stanislav Kinsbursky<skinsbursky@parallels.com>
>
> This patch gives me:
>
> Kernel: arch/x86/boot/bzImage is ready  (#3)
>    Building modules, stage 2.
>    MODPOST 921 modules
> ERROR: "nfs_idmap_init" [fs/nfs/nfs.ko] undefined!
> ERROR: "nfs_idmap_quit" [fs/nfs/nfs.ko] undefined!
> make[2]: *** [__modpost] Error 1
> make[1]: *** [modules] Error 2
> make: *** [sub-make] Error 2
>
> if CONFIG_NFS_V4 is not defined.
>

Sorry.
Will resend soon.

> Cheers
>    Trond
>


-- 
Best regards,
Stanislav Kinsbursky
