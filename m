Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-da0-f46.google.com ([209.85.210.46]:62151 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753893Ab2KZP6s (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Nov 2012 10:58:48 -0500
Received: by mail-da0-f46.google.com with SMTP id p5so3776095dak.19
        for <linux-nfs@vger.kernel.org>; Mon, 26 Nov 2012 07:58:47 -0800 (PST)
Message-ID: <50B3918E.4020303@gmail.com>
Date: Mon, 26 Nov 2012 21:28:06 +0530
From: "dE ." <de.techno@gmail.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Re: Slow NFS loop performance.
References: <50AF57A3.3090000@gmail.com> <20121123172333.GB8776@fieldses.org>
In-Reply-To: <20121123172333.GB8776@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/23/12 22:53, J. Bruce Fields wrote:
> On Fri, Nov 23, 2012 at 04:31:55PM +0530, dE . wrote:
>> Humm... The last thing I expected was no response even in the mailing list.
>>
>> So I'm filing a bug on this.
>>
>> On Oct 23, 2012 2:19 PM, "dE ."<de.techno@gmail.com>  wrote:
>>> Hi!
>>>
>>> Great job with NFS server, it surely is fast, but not on loop devices.
>>>
>>> If I loop mount a file and share the mount point over NFS3 or NFS4, the
>>> write performance of the client on the loop mounted share is pretty bad.
>>>
>>> On a 100 Mbps (or 12.5MBps) full duplex Ethernet link, I get ~8MBps
>>> speeds, whereas on the loop mounted device, I get at best 6MBps.
> What exactly is your test?
>
> --b.

Sorry for the late response. I'd 200+ unread mails.

I'm writing a large file to the mounted loop device.
