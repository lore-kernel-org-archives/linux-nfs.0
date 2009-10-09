From: Ian Kent <ikent@redhat.com>
Subject: Re: [PATCH 1/2] mount: ECONNREFUSED is a permanent error
Date: Sat, 10 Oct 2009 00:33:22 +0800
Message-ID: <4ACF65D2.8010809@redhat.com>
References: <20091008173520.12619.10662.stgit@matisse.1015granger.net> <20091008173703.12619.35788.stgit@matisse.1015granger.net> <4ACF37C2.6030208@RedHat.com> <DDBA069F-E9B8-4BE3-B13C-2B69406C3C9A@ORACLE.COM> <4ACF54B4.9020900@RedHat.com> <3D7C5D2E-971F-4F59-B660-C584288ED13B@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53621 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933941AbZJIQd5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Oct 2009 12:33:57 -0400
In-Reply-To: <3D7C5D2E-971F-4F59-B660-C584288ED13B@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> On Oct 9, 2009, at 11:20 AM, Steve Dickson wrote:
>> On 10/09/2009 11:13 AM, Chuck Lever wrote:
>>> On Oct 9, 2009, at 9:16 AM, Steve Dickson wrote:
>>>> On 10/08/2009 01:37 PM, Chuck Lever wrote:
>>>>> I had assumed early on that mount.nfs should retry a refused
>>>>> connection.
>>>>>
>>>>> Apparently this is not the case.  Legacy mount.nfs4 fails immediately
>>>>> if the NFS server refuses the connection.  Legacy mount.nfs and
>>>>> text-based mount.nfs both fail immediately if the rpcbind service is
>>>>> refusing connections.
>>>>>
>>>> What about if the server is on the way up (i.e the network is up)
>>>> but has not started the NFS service? In that window, the server will
>>>> return ECONNREFUSED since nobody is listening, but in a very short time
>>>> there will be a listener... The mount should not fail in that case...
>>>
>>> I agree, but I think it does fail today, and it has behaved this way for
>>> a long while.  No one has complained about it.  I'm actually not arguing
>>> in favor of either behavior; just reporting that the current behavior is
>>> inconsistent.
>>>
>>> With the current code, legacy and text-based v2/v3 fails immediately if
>>> the server's rpcbind refuses connection... Legacy mount.nfs4 fails
>>> immediately if the NFS server refuses connection.  Text-based mount.nfs4
>>> retries in this case.
>> I think the text-based mounts have it right...
> 
> It's a change from legacy behavior, however, so we should test
> carefully.  The trade-off is that the mount.nfs command is less
> responsive because it's retrying a connection refusal, but it's more
> likely that the mount request will succeed.
> 
> Again, I'm not advocating for one or the other, just pointing out the
> compromises.
> 
>>> So we will either need to fix v2/v3 to continue retrying, or fix NFSv4
>>> to stop retrying.  The retries would stop after mount.nfs's retry timer
>>> expires (just like the case where the server isn't responding at all).
>> The former, IMHO.. I also notice that the retry timer does not work since
>> the mount waits in the kernel well passed the timer expiring...
> 
> It does work, after a fashion, but yes, it's less responsive than it was
> before.  For background mounts it hardly matters because bg mounts retry
> for a good long while.  The case where it gets a little ugly is fg, when
> mount.nfs's retry timer is nearly always shorter than the kernel's
> connect retry timeout.
> 
> I've got some kernel level fixes for this... see the SOFTCONN patches
> from earlier this week.  Shortening the initial connect retry timeout in
> the kernel will also help the case where the server isn't responding at
> all.
> 
>>> Automounter might want different behavior in this case, but we should
>>> ask around before making a final decision, probably.
>> Ian... What do you think??

We've been here recently I think, a very similar discussion anyway.

I think the interactive mounts should wait for the reasons that Chuck
points out and Steve agrees with.

The later point sounds like RPC not letting go after a specified
timeout. I think that the any timeout that is given, user space or
kernel space, should be obeyed and whatever needs to be done to achieve
it should be done. That only leaves the decision of retries, which comes
back to interactive mounts should wait (I think even system startup can
be considered interactive in this case).

As for autofs, that's a different story.

Our recent, similar discussion, lead to the addition of an autofs option
to set a timeout to wait for a mount (considered to be interactive) to
complete which overrides the behaviour of mount. But this has two
problems. First, sending a TERM signal to the mount(8) process kills it
but leaves the mount.nfs(8) process to run to completion. While this
isn't to good it achieves what's required from the interactive user
perspective. And second, it looks like the task killable patches will
stop the mount.nfs(8) task from terminating on a TERM signal even if we
were to locate the process and send the signal to it.

Mmmm ... bit off topic I guess.
Ian

