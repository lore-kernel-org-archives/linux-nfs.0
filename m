Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:31279 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753276Ab2B0PnY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Feb 2012 10:43:24 -0500
Message-ID: <4F4BA479.60907@parallels.com>
Date: Mon, 27 Feb 2012 19:42:49 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        James Bottomley <jbottomley@parallels.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH 2/4] NFS: replace per-net client lock by mutex
References: <20120227134623.13371.61185.stgit@localhost6.localdomain6>	 <20120227134900.13371.96849.stgit@localhost6.localdomain6> <1330354815.5541.24.camel@lade.trondhjem.org>
In-Reply-To: <1330354815.5541.24.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

27.02.2012 19:00, Myklebust, Trond пишет:
> On Mon, 2012-02-27 at 17:49 +0400, Stanislav Kinsbursky wrote:
>> Lockdep is sad otherwise, because inode mutex is taken on PipeFS dentry
>> creation, which can be called on mount notification, where this per-net client
>> lock is taken on clients list walk.
>>
>> Note: I used simple mutex instead of rw semaphore because of
>> nfs_put_client->atomic_dec_and_mutex_lock() call. Probably, there is a better
>> solution here.
>>
>> Signed-off-by: Stanislav Kinsbursky<skinsbursky@parallels.com>
>>
>
> This is overkill... We end up blocking NFSv4 callbacks while the
> rpc_pipefs notifier runs through the nfs_clients creating or destroying
> idmapper dentries.
>
> Surely the rpc_pipefs_event() can take a reference to the nfs_client and
> then drop the spin_lock if it sees that it needs to create or destroy a
> dentry?
>

Sure, thanks for notice.
Looks like this logic also works to SUNRPC clients.
I'll send updated version soon.

-- 
Best regards,
Stanislav Kinsbursky
