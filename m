Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:36984 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1162571AbeBOTOZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 15 Feb 2018 14:14:25 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "Harald Dunkel" <harald.dunkel@aixigo.de>,
        linux-nfs@vger.kernel.org
Subject: Re: running NFS in LXC
Date: Thu, 15 Feb 2018 14:14:23 -0500
Message-ID: <67546F90-65D5-4005-A9C5-82D5E52E6EF3@redhat.com>
In-Reply-To: <20180215154516.GB9999@fieldses.org>
References: <5cedd413-81eb-6921-47bc-3c56e56d530a@aixigo.de>
 <6860CF8E-9790-4456-82D3-86A6A29E90BE@redhat.com>
 <8af7b137-0698-0c12-abc5-1cdd86c53a91@aixigo.de>
 <F9942544-0C31-4618-BF73-292FF4265C31@redhat.com>
 <20180215154516.GB9999@fieldses.org>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 15 Feb 2018, at 10:45, J. Bruce Fields wrote:

> On Wed, Feb 14, 2018 at 09:15:05AM -0500, Benjamin Coddington wrote:
>> On 14 Feb 2018, at 2:06, Harald Dunkel wrote:
>>
>>> Hi Ben,
>>>
>>> I take this as a "no serious problems by now". Good to hear.
>>> Which kernel are you using?
>>
>> This was years ago on a 2.6.32 series.  I don't expect you'll have
>> serious problems now, either.  As far as I know, my last employer is
>> still using that architecture, but I couldn't tell you what software
>> versions they're on now..
>>
>> We moved to the knfsd-in-a-container from an architecture that was
>> essentially a bunch of vanilla knfsds that could mount and any of
>> the block devices, and block devices were tied to IP addresses, and
>> this was all orchestrated by pacemaker.  The problem with that one
>> was that when a block device or filesystem was migrated, the server
>> receiving that filesystem had to be put into grace, which disrupted
>> any existing NFS serving that was going on.
>>
>> Test things, let us know how it works!
>
> I think you were using KVM, right, Ben?

That's right.

> Harald is talking about LXC, and there are still a few problems there.

Ah, yes -- What a bonehead I am, I'd forgotten about containing the
upcalls.. but if the state recovery db can be stored on the same filesystem
as the container, and there's only one knfsd container per "host", then the
HA model should still work I think.

Ben

> Jeff, do you object to going back to our plan B for reboot recovery (the
> daemon)?  The usermode helper containerization seems stalled and I have to
> admit I'm probably not going to take it on myself.  That might be the only
> knfsd-in-a-container obstacle left.
>
> --b.
