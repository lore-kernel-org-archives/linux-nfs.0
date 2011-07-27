Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lucidpixels.com ([72.73.18.11]:40131 "EHLO lucidpixels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754858Ab1G0T5J (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Jul 2011 15:57:09 -0400
Date: Wed, 27 Jul 2011 15:57:07 -0400 (EDT)
From: Justin Piszcz <jpiszcz@lucidpixels.com>
To: Christoph Hellwig <hch@infradead.org>
cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: 2.6.xx: NFS: directory motion/cam2 contains a readdir loop
In-Reply-To: <20110727194722.GA9345@infradead.org>
Message-ID: <alpine.DEB.2.02.1107271553290.1451@p34.internal.lan>
References: <alpine.DEB.2.02.1107270952270.1451@p34.internal.lan> <20110727160752.GC974@fieldses.org> <alpine.DEB.2.02.1107271227340.1451@p34.internal.lan> <20110727181111.GA23009@infradead.org> <alpine.DEB.2.02.1107271530340.1451@p34.internal.lan>
 <20110727193937.GA5354@infradead.org> <alpine.DEB.2.02.1107271540100.1451@p34.internal.lan> <20110727194722.GA9345@infradead.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On Wed, 27 Jul 2011, Christoph Hellwig wrote:

> On Wed, Jul 27, 2011 at 03:44:20PM -0400, Justin Piszcz wrote:
>>
>>
>> On Wed, 27 Jul 2011, Christoph Hellwig wrote:
>>
>>> On Wed, Jul 27, 2011 at 03:35:01PM -0400, Justin Piszcz wrote:
>>>> Currently I do not see any dupes, however I have a script that moves
>>>> images out of the directory once an hour:
>>>> 0 * * * * /usr/local/bin/move_to_old2.sh > /dev/null 2>&1
>>>
>>> Do you keep adding files to the directory while you move files out?
>> Yes, otherwise there are too many files in the directory and viewers, e.g.,
>> each geeqie (picture viewer) will use > 4-6GB of memory, so I try to keep
>> it around 5,000 pictures or less.
>>
>>> What's the rate of additions/removals to the directory?
>> Additions it depends, around 5,000 over a 12hr period, 416/hr, current:
>>
>> atom:/d1/motion# find cam1|wc
>>    5215    5215  166853
>> atom:/d1/motion# find cam2|wc
>>    5069    5069  162181
>> atom:/d1/motion# find cam3|wc
>>    5594    5594  178981
>> atom:/d1/motion#
>
> This sounds a lot like xfs simply filling up the directory index slots
> of files that you just moved out with new files, and nfs falsely
> claiming that this is a problem.
>
> Any chance to figure out if the file you hit the printk with was one
> that got either recently added or moved when you hit it?  (I can't
> follow the nfs code enough to check if it prints the first or second hit
> of the same cookie)
>

It seems to happen across all directories, these are from the past 24 hours.

[41901.041923] NFS: directory motion/cam2 contains a readdir loop.  Please contact your server vendor.  Offending cookie: 14368
[41901.275284] NFS: directory motion/cam3 contains a readdir loop.  Please contact your server vendor.  Offending cookie: 17435
[45497.265250] NFS: directory motion/cam1 contains a readdir loop.  Please contact your server vendor.  Offending cookie: 14488
[45498.832696] NFS: directory motion/cam1 contains a readdir loop.  Please contact your server vendor.  Offending cookie: 16416
[45507.812712] NFS: directory motion/cam2 contains a readdir loop.  Please contact your server vendor.  Offending cookie: 14778
[45508.458785] NFS: directory motion/cam2 contains a readdir loop.  Please contact your server vendor.  Offending cookie: 14778
[92223.918892] NFS: directory motion/cam2 contains a readdir loop.  Please contact your server vendor.  Offending cookie: 10272
[99413.259688] NFS: directory motion/cam1 contains a readdir loop.  Please contact your server vendor.  Offending cookie: 10272
[113791.004006] NFS: directory motion/cam1 contains a readdir loop.  Please contact your server vendor.  Offending cookie: 6848

Interestingly, I have two machines that perform this function, both XFS and it 
only affects the client running 2.6.38:

$ df -h
2.6.38 - Has a kernel driver that was removed in 2.6.39 (rt2870sta) which
works really well.
atomw:/d1              30G   13G   18G  43% /nfs/atomw/d1

2.6.39:
d630w:/d1              75G  2.6G   72G   4% /nfs/d630w/d1

However, to rule out any kernel issues I'll try 3.0 and see if the problem recurs with a newer version as it is _NOT_ happening with 2.6.39 (similar setup) on both; however:

d630 => 32bit installation (core2duo t7500)
atomw => 64-bit atom

Justin.

