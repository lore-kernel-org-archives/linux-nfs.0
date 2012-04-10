Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:1280 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754961Ab2DJPg6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Apr 2012 11:36:58 -0400
Message-ID: <4F84537A.40100@parallels.com>
Date: Tue, 10 Apr 2012 19:36:26 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "bfields@fieldses.org" <bfields@fieldses.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: Grace period
References: <4F82F16C.7030303@parallels.com> <20120409112739.6a823d6f@corrin.poochiereds.net> <4F830999.5000504@parallels.com> <20120409161114.GB6482@fieldses.org> <1333988226.2688.76.camel@lade.trondhjem.org> <20120409162107.GC6482@fieldses.org> <1333989216.2688.87.camel@lade.trondhjem.org> <4F8314CF.70302@parallels.com> <20120409181138.GA9581@fieldses.org> <4F8411CC.2070105@parallels.com> <20120410133913.GF18465@fieldses.org>
In-Reply-To: <20120410133913.GF18465@fieldses.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

10.04.2012 17:39, bfields@fieldses.org пишет:
> On Tue, Apr 10, 2012 at 02:56:12PM +0400, Stanislav Kinsbursky wrote:
>> 09.04.2012 22:11, bfields@fieldses.org пишет:
>>> Since NFSv4 doesn't have a separate MOUNT protocol, clients need to be
>>> able to do readdir's and lookups to get to exported filesystems.  We
>>> support this in the Linux server by exporting all the filesystems from
>>> "/" on down that must be traversed to reach a given filesystem.  These
>>> exports are very restricted (e.g. only parents of exports are visible).
>>>
>>
>> Ok, thanks for explanation.
>> So, this pseudoroot looks like a part of NFS server internal
>> implementation, but not a part of a standard. That's good.
>>
>>>> Why does it prevents implementing of check for "superblock-network
>>>> namespace" pair on NFS server start and forbid (?) it in case of
>>>> this pair is shared already in other namespace? I.e. maybe this
>>>> pseudoroot can be an exclusion from this rule?
>>>
>>> That might work.  It's read-only and consists only of directories, so
>>> the grace period doesn't affect it.
>>>
>>
>> I've just realized, that this per-sb grace period won't work.
>> I.e., it's a valid situation, when two or more containers located on
>> the same filesystem, but shares different parts of it. And there is
>> not conflict here at all.
>
> Well, there may be some conflict in that a file could be hardlinked into
> both subtrees, and that file could be locked from users of either
> export.
>

Is this case handled if both links or visible in the same export?
But anyway, this is not that bad. I.e it doesn't make things unpredictable.
Probably, there are some more issues like this one (bind-mounting, for example).
But I think, that it's root responsibility to handle such problems.

-- 
Best regards,
Stanislav Kinsbursky
