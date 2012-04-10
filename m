Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:47519 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754322Ab2DJK4o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Apr 2012 06:56:44 -0400
Message-ID: <4F8411CC.2070105@parallels.com>
Date: Tue, 10 Apr 2012 14:56:12 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "bfields@fieldses.org" <bfields@fieldses.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: Grace period
References: <4F82C6E3.3030009@parallels.com> <20120409094743.56932677@tlielax.poochiereds.net> <4F82F16C.7030303@parallels.com> <20120409112739.6a823d6f@corrin.poochiereds.net> <4F830999.5000504@parallels.com> <20120409161114.GB6482@fieldses.org> <1333988226.2688.76.camel@lade.trondhjem.org> <20120409162107.GC6482@fieldses.org> <1333989216.2688.87.camel@lade.trondhjem.org> <4F8314CF.70302@parallels.com> <20120409181138.GA9581@fieldses.org>
In-Reply-To: <20120409181138.GA9581@fieldses.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

09.04.2012 22:11, bfields@fieldses.org пишет:
> On Mon, Apr 09, 2012 at 08:56:47PM +0400, Stanislav Kinsbursky wrote:
>> 09.04.2012 20:33, Myklebust, Trond пишет:
>>> On Mon, 2012-04-09 at 12:21 -0400, bfields@fieldses.org wrote:
>>>> On Mon, Apr 09, 2012 at 04:17:06PM +0000, Myklebust, Trond wrote:
>>>>> On Mon, 2012-04-09 at 12:11 -0400, bfields@fieldses.org wrote:
>>>>>> On Mon, Apr 09, 2012 at 08:08:57PM +0400, Stanislav Kinsbursky wrote:
>>>>>>> 09.04.2012 19:27, Jeff Layton пишет:
>>>>>>>>
>>>>>>>> If you allow one container to hand out conflicting locks while another
>>>>>>>> container is allowing reclaims, then you can end up with some very
>>>>>>>> difficult to debug silent data corruption. That's the worst possible
>>>>>>>> outcome, IMO. We really need to actively keep people from shooting
>>>>>>>> themselves in the foot here.
>>>>>>>>
>>>>>>>> One possibility might be to only allow filesystems to be exported from
>>>>>>>> a single container at a time (and allow that to be overridable somehow
>>>>>>>> once we have a working active/active serving solution). With that, you
>>>>>>>> may be able limp along with a per-container grace period handling
>>>>>>>> scheme like you're proposing.
>>>>>>>>
>>>>>>>
>>>>>>> Ok then. Keeping people from shooting themselves here sounds reasonable.
>>>>>>> And I like the idea of exporting a filesystem only from once per
>>>>>>> network namespace.
>>>>>>
>>>>>> Unfortunately that's not going to get us very far, especially not in the
>>>>>> v4 case where we've got the common read-only pseudoroot that everyone
>>>>>> has to share.
>>>>>
>>>>> I don't see how that can work in cases where each container has its own
>>>>> private mount namespace. You're going to have to tie that pseudoroot to
>>>>> the mount namespace somehow.
>>>>
>>>> Sure, but in typical cases it'll still be shared; requiring that they
>>>> not be sounds like a severe limitation.
>>>
>>> I'd expect the typical case to be the non-shared namespace: the whole
>>> point of containers is to provide for complete isolation of processes.
>>> Usually that implies that you don't want them to be able to communicate
>>> via a shared filesystem.
>>>
>>
>> BTW, we DO use one mount namespace for all containers and host in
>> OpenVZ. This allows us to have an access to containers mount points
>> from initial environment. Isolation between containers is done via
>> chroot and some simple tricks on /proc/mounts read operation.
>> Moreover, with one mount namespace, we currently support
>> bind-mounting on NFS from one container into another...
>>
>> Anyway, I'm sorry, but I'm not familiar with this pseudoroot idea.
>
> Since NFSv4 doesn't have a separate MOUNT protocol, clients need to be
> able to do readdir's and lookups to get to exported filesystems.  We
> support this in the Linux server by exporting all the filesystems from
> "/" on down that must be traversed to reach a given filesystem.  These
> exports are very restricted (e.g. only parents of exports are visible).
>

Ok, thanks for explanation.
So, this pseudoroot looks like a part of NFS server internal implementation, but 
not a part of a standard. That's good.

>> Why does it prevents implementing of check for "superblock-network
>> namespace" pair on NFS server start and forbid (?) it in case of
>> this pair is shared already in other namespace? I.e. maybe this
>> pseudoroot can be an exclusion from this rule?
>
> That might work.  It's read-only and consists only of directories, so
> the grace period doesn't affect it.
>

I've just realized, that this per-sb grace period won't work.
I.e., it's a valid situation, when two or more containers located on the same 
filesystem, but shares different parts of it. And there is not conflict here at all.
I don't see any clear and simple way how to handle such races, because otherwise 
we have to tie network namespace and filesystem namespace.
I.e. there will be required some way to define, was passed export directory 
shared already somewhere else or not.

Realistic solution - since export check should be done in initial file system 
environment (most probably container will have it's own root), then we to pass 
this data to some kernel thread/userspace daemon in initial file system 
environment somehow (sockets doesn't suits here... Shared memory?).

Improbable solution - patching VFS layer...

-- 
Best regards,
Stanislav Kinsbursky
