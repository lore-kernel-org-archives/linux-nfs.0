Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:49646 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754264Ab2K2Ms6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Nov 2012 07:48:58 -0500
Message-ID: <50B759AB.6010504@parallels.com>
Date: Thu, 29 Nov 2012 16:48:43 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>
Subject: Re: NFSd in container - it works
References: <50B64628.4070007@parallels.com> <20121128200126.GA17875@fieldses.org> <20121128152813.2b4c388d@tlielax.poochiereds.net> <50B74CCB.9080000@parallels.com> <20121129071309.6550614e@tlielax.poochiereds.net>
In-Reply-To: <20121129071309.6550614e@tlielax.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

29.11.2012 16:13, Jeff Layton пишет:
> On Thu, 29 Nov 2012 15:53:47 +0400
> Stanislav Kinsbursky <skinsbursky@parallels.com> wrote:
>
>> 29.11.2012 00:28, Jeff Layton пишет:
>>> On Wed, 28 Nov 2012 15:01:26 -0500
>>> "bfields@fieldses.org" <bfields@fieldses.org> wrote:
>>>
>>>>> 3) Holding net by tracker looks redundant. What was the reason for this?
>>>>
>>>> I don't understand, what's tracker?
>>>
>>> I assume he means the clientid tracker. That was necessary for the
>>> nfsdcld upcall because it used rpc_pipefs files, and those were
>>> net-namespacified. Once we deprecate that in 3.10, I don't think we'll
>>> need to worry about the net namespace in the clientid tracker.
>>>
>>
>> Sorry, I don't understand. Rpc_pipefs superblock already holds network namespace.
>>
>
> ...and how do you know which rpc_pipefs superblock you're dealing with?
> In any case, I'm ok with ripping out references to the net namespace
> there if you think it's valid.
>

I'm not saying, that you don't need to have a reference to network namespace.
I'm not sure, that you need to grab the reference to it (i.e. call get_net()).

>>> We probably *will* need to concern ourselves with the mnt namespace
>>> there though since each container will presumably have its own clientid
>>> database...
>>
>> Since NFSd server in network namespace based, it means, that we can create one server for more than one mount namespace.
>> And clietid tracker holds files opened. Thus holds mount.
>> Mount namespace itself doesn't look that important to me.
>> Or I'm wrong?
>>
>
> I confess I don't understand the design well enough to reasonably
> comment here...
>
> Both the new clientid tracker and the legacy one involve storing data
> on a local filesystem somewhere. In the case of the new tracker, we
> upcall using call_usermodehelper to spawn a process to handle access to
> the on disk database. In the legacy tracker, it's done directly by the
> kernel using vfs calls.
>
> Presumably, you will have multiple containers serving NFS, so you'll
> have multiple sets of client id data being stored. You'll need some
> mechanism to ensure that the usermodehelper is spawned within the
> correct container or that the legacy tracker accesses the files in the
> correct container.
>
> My assumption there was that you'd need to ensure that it's using the
> right mount namespace in order to do that...
>

Yes, I see... Look like it's better to disable this type tracker in containers for now.
As, I see it, the problem is not in mount namespace itself, but in proper root path for khelper.
I.e. the problem is the same as with portmapper Unix sockets.
But, luckily, usermode khelper allow to pass init/cleanup functions.
Init function could be like these:

init() {
	unshare_fs_struct();	// to make sure, that we won't affect other kthreads
	swap_root();		// replace root, get new one, put old one.
}

Cleanup function is not required: fs struct will be destroyed on usermode khelper thread exit.

-- 
Best regards,
Stanislav Kinsbursky
