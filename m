From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/2] mount: ECONNREFUSED is a permanent error
Date: Fri, 9 Oct 2009 11:45:09 -0400
Message-ID: <3D7C5D2E-971F-4F59-B660-C584288ED13B@oracle.com>
References: <20091008173520.12619.10662.stgit@matisse.1015granger.net> <20091008173703.12619.35788.stgit@matisse.1015granger.net> <4ACF37C2.6030208@RedHat.com> <DDBA069F-E9B8-4BE3-B13C-2B69406C3C9A@ORACLE.COM> <4ACF54B4.9020900@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org, Ian Kent <ikent@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:17336 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758720AbZJIPqY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Oct 2009 11:46:24 -0400
In-Reply-To: <4ACF54B4.9020900-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Oct 9, 2009, at 11:20 AM, Steve Dickson wrote:
> On 10/09/2009 11:13 AM, Chuck Lever wrote:
>> On Oct 9, 2009, at 9:16 AM, Steve Dickson wrote:
>>> On 10/08/2009 01:37 PM, Chuck Lever wrote:
>>>> I had assumed early on that mount.nfs should retry a refused  
>>>> connection.
>>>>
>>>> Apparently this is not the case.  Legacy mount.nfs4 fails  
>>>> immediately
>>>> if the NFS server refuses the connection.  Legacy mount.nfs and
>>>> text-based mount.nfs both fail immediately if the rpcbind service  
>>>> is
>>>> refusing connections.
>>>>
>>> What about if the server is on the way up (i.e the network is up)
>>> but has not started the NFS service? In that window, the server will
>>> return ECONNREFUSED since nobody is listening, but in a very short  
>>> time
>>> there will be a listener... The mount should not fail in that  
>>> case...
>>
>> I agree, but I think it does fail today, and it has behaved this  
>> way for
>> a long while.  No one has complained about it.  I'm actually not  
>> arguing
>> in favor of either behavior; just reporting that the current  
>> behavior is
>> inconsistent.
>>
>> With the current code, legacy and text-based v2/v3 fails  
>> immediately if
>> the server's rpcbind refuses connection... Legacy mount.nfs4 fails
>> immediately if the NFS server refuses connection.  Text-based  
>> mount.nfs4
>> retries in this case.
> I think the text-based mounts have it right...

It's a change from legacy behavior, however, so we should test  
carefully.  The trade-off is that the mount.nfs command is less  
responsive because it's retrying a connection refusal, but it's more  
likely that the mount request will succeed.

Again, I'm not advocating for one or the other, just pointing out the  
compromises.

>> So we will either need to fix v2/v3 to continue retrying, or fix  
>> NFSv4
>> to stop retrying.  The retries would stop after mount.nfs's retry  
>> timer
>> expires (just like the case where the server isn't responding at  
>> all).
> The former, IMHO.. I also notice that the retry timer does not work  
> since
> the mount waits in the kernel well passed the timer expiring...

It does work, after a fashion, but yes, it's less responsive than it  
was before.  For background mounts it hardly matters because bg mounts  
retry for a good long while.  The case where it gets a little ugly is  
fg, when mount.nfs's retry timer is nearly always shorter than the  
kernel's connect retry timeout.

I've got some kernel level fixes for this... see the SOFTCONN patches  
from earlier this week.  Shortening the initial connect retry timeout  
in the kernel will also help the case where the server isn't  
responding at all.

>> Automounter might want different behavior in this case, but we should
>> ask around before making a final decision, probably.
> Ian... What do you think??

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



