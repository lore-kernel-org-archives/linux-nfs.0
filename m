Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:4795 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756223Ab2DJMrC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Apr 2012 08:47:02 -0400
Message-ID: <4F842BAE.2010804@parallels.com>
Date: Tue, 10 Apr 2012 16:46:38 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH][RFC] nfsd/lockd: have locks_in_grace take a sb arg
References: <1333455279-11200-1-git-send-email-jlayton@redhat.com>	<4F841D2A.9020504@parallels.com> <20120410081612.65dd25fa@tlielax.poochiereds.net>
In-Reply-To: <20120410081612.65dd25fa@tlielax.poochiereds.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

10.04.2012 16:16, Jeff Layton пишет:
> On Tue, 10 Apr 2012 15:44:42 +0400
>
> (sorry about the earlier truncated reply, my MUA has a mind of its own
> this morning)
>

OK then. Previous letter confused me a bit.

>
> TBH, I haven't considered that in depth. That is a valid situation, but
> one that's discouraged. It's very difficult (and expensive) to
> sequester off portions of a filesystem for serving.
>
> A filehandle is somewhat analogous to a device/inode combination. When
> the server gets a filehandle, it has to determine "is this within a
> path that's exported to this host"? That process is called subtree
> checking. It's expensive and difficult to handle. It's always better to
> export along filesystem boundaries.
>
> My suggestion would be to simply not deal with those cases in this
> patch. Possibly we could force no_subtree_check when we export an fs
> with a locks_in_grace option defined.
>

Sorry, but without dealing with those cases your patch looks a bit... Useless.
I.e. it changes nothing, it there will be no support from file systems, going to 
be exported.
But how are you going to push developers to implement these calls? Or, even if 
you'll try to implement them by yourself, how they will looks like?
Simple check only for superblock looks bad to me, because any other start of 
NFSd will lead to grace period for all other containers (which uses the same 
filesystem).

>> Also, don't we need to prevent of exporting the same file system parts but
>> different servers always, but not only for grace period?
>>
>
> I'm not sure I understand what you're asking here. Were you referring
> to my suggestion earlier of not allowing the export of the same
> filesystem from more than one container? If so, then yes that would
> apply before and after the grace period ends.
>

I was talking about preventing of exporting intersecting directories by 
different server.
IOW, exporting of the same file system by different NFS server is allowed, but 
only if their exporting directories doesn't intersect.
This check is expensive (as you mentioned), but have to be done only once on NFS 
server start.
With this solution, grace period can simple, and no support from exporting file 
system is required.
But the main problem here is that such intersections can be checked only in 
initial file system environment (containers with it's own roots, gained via 
chroot, can't handle this situation).
So, it means, that there have to be some daemon (kernel or user space), which 
will handle such requests from different NFS server instances... Which in turn 
means, that some way of communication between this daemon and NFS servers is 
required. And unix (any of them) sockets doesn't suits here, which makes this 
problem more difficult.

-- 
Best regards,
Stanislav Kinsbursky
