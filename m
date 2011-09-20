Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:2495 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755780Ab1ITMNn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Sep 2011 08:13:43 -0400
Message-ID: <4E788359.4040303@parallels.com>
Date: Tue, 20 Sep 2011 16:13:13 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
To: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "davem@davemloft.net" <davem@davemloft.net>
Subject: Re: [PATCH 0/2] SUNRPC: pipefs virtualization
References: <20110912141633.6261.72180.stgit@localhost6.localdomain6>
In-Reply-To: <20110912141633.6261.72180.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Probably, holding mount point of network namespace is not a good solution.
There is another one. But I really hope for discussion of it.

RPC pipefs can be virtualized in the way like sysfs done.
But the main problem here is that currently we have only one RPC pipefs mount 
point (superblock, root) for all.
New mount point can be created per every pipefs mount call. We can even have 
some shared privates on dentries with the same name, like sysfs does (but I 
don't see any good reason for this).
But with many mount points we have a problem with RPC pipes creation. I.e. we 
have to find proper mount point for current network namespace, which is required 
for vfs_path_lookup(), which is done prior to pipe creation.
And thus we have to store this per-netns mount points somewhere. It could be 
some static variable. But we have to implement search function for them.
This approach can hide all pipefs virtualization from it's users. But it's still 
look ugly from my pow.

Maybe, somebody have suggest better solution for this problem?

12.09.2011 18:19, Stanislav Kinsbursky пишет:
> This patch set is a part of further RPC layer virtualization and it's aim is to
> make RPC pipefs mount creation and destruction per network namespace context.
> It moves RPC pipefs internal data to sunrpc_net instance of network namespace
> context.
> With this patch set all calls to pipefs infrastructure are performed with
> "&init_net" except rpc_new_client() and rpc_setup_pipedir() functions (but they
> still passes pointer to "init_net" by current design).
> This "init_net" pointer will be replaced later with NFS virtualization.
>
> The following series consists of:
>
> ---
>
> Stanislav Kinsbursky (2):
>        SUNRPC: make rpc pipefs mount per network namespace
>        SUNRPC: RPC pipefs virtualization
>
>
>   fs/nfs/blocklayout/blocklayout.c   |    2 +-
>   fs/nfs/cache_lib.c                 |    7 ++++---
>   include/linux/sunrpc/rpc_pipe_fs.h |    4 ++--
>   net/sunrpc/clnt.c                  |    8 ++++----
>   net/sunrpc/netns.h                 |    3 +++
>   net/sunrpc/rpc_pipe.c              |   23 +++++++++++++++--------
>   6 files changed, 29 insertions(+), 18 deletions(-)
>


-- 
Best regards,
Stanislav Kinsbursky
