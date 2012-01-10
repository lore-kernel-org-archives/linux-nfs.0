Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:9791 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756207Ab2AJM6p (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jan 2012 07:58:45 -0500
Message-ID: <4F0C35F3.7060508@parallels.com>
Date: Tue, 10 Jan 2012 16:58:27 +0400
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
Subject: Re: [PATCH 0/5] NFS: create blocklayout pipe per network namesapce
 context
References: <20111129090754.20730.64567.stgit@localhost6.localdomain6>	 <1325285705.10984.4.camel@lade.trondhjem.org> <1325797111.11084.22.camel@lade.trondhjem.org>
In-Reply-To: <1325797111.11084.22.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

06.01.2012 00:58, Trond Myklebust пишет:
> On Fri, 2011-12-30 at 17:55 -0500, Trond Myklebust wrote:
>> On Tue, 2011-11-29 at 13:10 +0300, Stanislav Kinsbursky wrote:
>>> This patch set was created in context of clone of git
>>> branch: git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git.
>>> tag: v3.1
>>>
>>> This patch set depends on previous patch sets titled:
>>> 1) "SUNRPC: initial part of making pipefs work in net ns"
>>> 2) "SUNPRC: cleanup PipeFS for network-namespace-aware users"
>>> 3) "SUNRPC: make RPC clients use network-namespace-aware PipeFS routines"
>>> 4) "NFS: create clients and IDMAP pipes per network namespace"
>>>
>>> This patch set is the final part of making SUNRPC PipeFS and it's users work in
>>> network namespace context.
>>>
>>> The following series consists of:
>>>
>>> ---
>>>
>>> Stanislav Kinsbursky (5):
>>>        NFS: handle blocklayout pipe PipeFS dentry by network namespace aware routines
>>>        NFS: blocklayout pipe creation per network namespace context introduced
>>>        NFS: blocklayout PipeFS notifier introduced
>>>        NFS: remove RPC PipeFS mount point reference from blocklayout routines
>>>        SUNRPC: kernel PipeFS mount point creation routines removed
>>>
>>>
>>>   fs/nfs/blocklayout/blocklayout.c    |  154 ++++++++++++++++++++++++++++-------
>>>   fs/nfs/blocklayout/blocklayout.h    |    3 -
>>>   fs/nfs/blocklayout/blocklayoutdev.c |    5 +
>>>   fs/nfs/blocklayout/blocklayoutdm.c  |    7 +-
>>>   fs/nfs/inode.c                      |    1
>>>   fs/nfs/netns.h                      |    1
>>>   include/linux/sunrpc/rpc_pipe_fs.h  |    2
>>>   net/sunrpc/rpc_pipe.c               |   21 -----
>>>   8 files changed, 137 insertions(+), 57 deletions(-)
>>
>>
>> These patches need rebasing in order to apply on top of 3.2-rc7...
>
> OK. Further testing seems to indicate that we're going to have to
> postpone merging these patches until the 3.4 merge window.
>
> The problems are twofold:
>
> As the patches stand now in the linux-next tree, they can (and
> occasionally do) Oops on unmount. The reason was that I rejected the
> PipeFS notifier patch for the idmapper (due to the reported problem of
> nfs_idmap_init/nfs_idmap_quit being undefined when CONFIG_NFS_V4 is
> undefined), and the fact that it is missing causes the unmount at the
> end of our tests to hit the BUG() in fs/dcache.c:905. This suggests that
> we will have the same problem with the pNFS block layout driver, since I
> still haven't received a rebased update of the 5 'create blocklayout
> pipe per network namesapce context' patches.
>

Hello, Trond.
I've resend the patch set (rebased with fix for nfs_idmap_init/nfs_idmap_quit).

> The second problem that was highlighted was the fact that as they stand
> today, these patchsets do not allow for bisection. When we hit the Oops,
> I had Bryan try to bisect where the problem arose. He ended up pointing
> at the patch "SUNRPC: handle RPC client pipefs dentries by network
> namespace aware routine", which is indeed the cause, but which is one of
> the _dependencies_ for all the PipeFS notifier patches that fix the
> problem.
>

I'm confused here. Does this means, that I have to fix patch "SUNRPC: handle RPC 
client pipefs dentries by network namespace aware routine" to make it able to 
bisect?

-- 
Best regards,
Stanislav Kinsbursky
