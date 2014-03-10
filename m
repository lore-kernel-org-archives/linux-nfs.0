Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:31919 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754007AbaCJPOd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Mar 2014 11:14:33 -0400
Message-ID: <531DD6D6.7090703@RedHat.com>
Date: Mon, 10 Mar 2014 11:14:30 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] mount.nfs: background mount now do directly into background
References: <1394284964-12997-1-git-send-email-steved@redhat.com>	<20140310101816.17e7d98a@notabene.brown> <20140310104327.212f72ce@notabene.brown>
In-Reply-To: <20140310104327.212f72ce@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Neil,

On 03/09/2014 07:43 PM, NeilBrown wrote:
> On Mon, 10 Mar 2014 10:18:16 +1100 NeilBrown <neilb@suse.de> wrote:
> 
>> On Sat,  8 Mar 2014 08:22:44 -0500 Steve Dickson <steved@redhat.com> wrote:
>>
>>> Modern day kernel will no longer return all timeout
>>> errors instead the process spins endlessly in the kernel.
>>> This behavior will cause the foreground mount to hang, never
>>> allowing the mount to go into background.
>>>
>>> So this patch eliminates the foreground mount cause
>>> background mounts to go directly into background
>>>
>>> Signed-off-by: Steve Dickson <steved@redhat.com>
>>
>> Did NFS mounts *ever* time out (when 'soft' isn't given)?
>>
>> If so, there is probably a regression which maybe should be fixed.
>>
>> If not, then this has always been a bug since sting-options were introduced
>> and the kernel started doing the mountd filehandle lookup...
>>
>> So I'm probably OK with the patch but I wonder if there is more of a story
>> behind this that we should be sure we understand...
>>
>> Thanks,
>> NeilBrown
> 
> Sorry, I really should read email in chronological order, shouldn't I :-)
> 
> The foregoing discussion seemed to focus on NFSv4.  Does NFSv3 behave the
> same way?  A quick test suggests that it doesn't.  
>    mount -o bg,vers=3 server:/path /mnt
> backgrounds as it should after a few seconds.
Right... After first RPC timeout the kernel returns ETIMEDOUT and 
the mount goes into background... This is what I was trying 
to simulate with my first set of patches....

> 
> So I suspect this patch should be version dependent?
It could be, but I'm not sure its necessary.
 
> 
> However falling-back from v4 (which we leave entirely to the kernel) to v3
> could be a bit awkward.
Why? Being in foreground or background should not effect any kind of mount behavior.

> 
> I think that an NFSv4 mount really does need to timeout - whether that
> happens in the kernel or through the use of "alarm()" doesn't really bother
> me.  But if it doesn't timeout, then it is violating the documentation and
> ignoring the retry= setting.
Yes... retry= does talk about different timeouts on fg and bg mounts....
I guess if the mount goes directly into bg the the first time out
is not tried... 

At the end of the day, too would prefer the kernel return timeouts 
like it once did... but unfortunately that is not going to happen.
The new way is to spin kernel and hang the process... forever...
which is unfortunate... IMHO...   

The only thing I against using alarm() is in the past NFS and signals 
have not always played nice together... Interrupting the kernel
in critical parts of the code is always dicey at best... but 
maybe this is no loner case.

One question I do have, does anybody know why the first foreground mount
was even tried before going into background? Since bg mount are usually
used in fstabs, going directly into background would definitely 
speed up mounts during booting... 

steved.

