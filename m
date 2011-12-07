Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63708 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755050Ab1LGMpo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Dec 2011 07:45:44 -0500
Received: by wgbdr13 with SMTP id dr13so1271649wgb.1
        for <linux-nfs@vger.kernel.org>; Wed, 07 Dec 2011 04:45:43 -0800 (PST)
Message-ID: <4EDF5FF0.90904@tonian.com>
Date: Wed, 07 Dec 2011 14:45:36 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Benny Halevy <benny@tonian.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 03/13] pnfsd-block: reverse boolean_t values so they make
 sense
References: <4EDB79A9.2080109@tonian.com> <1323006496-13542-1-git-send-email-benny@tonian.com> <20111206021059.GB4486@fieldses.org> <4EDDFC39.4090800@tonian.com> <20111206115606.GA8474@fieldses.org>
In-Reply-To: <20111206115606.GA8474@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-12-06 13:56, J. Bruce Fields wrote:
> On Tue, Dec 06, 2011 at 01:27:53PM +0200, Benny Halevy wrote:
>> On 2011-12-06 04:10, J. Bruce Fields wrote:
>>> On Sun, Dec 04, 2011 at 03:48:16PM +0200, Benny Halevy wrote:
>>>> From: Benny Halevy <bhalevy@tonian.com>
>>>>
>>>> Signed-off-by: Benny Halevy <bhalevy@tonian.com>
>>>> ---
>>>>  fs/nfsd/bl_ops.c |    2 +-
>>>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>>>
>>>> diff --git a/fs/nfsd/bl_ops.c b/fs/nfsd/bl_ops.c
>>>> index 89249c4..4d2939e 100644
>>>> --- a/fs/nfsd/bl_ops.c
>>>> +++ b/fs/nfsd/bl_ops.c
>>>> @@ -57,7 +57,7 @@
>>>>  #endif
>>>>  
>>>>  
>>>> -typedef enum {True, False} boolean_t;
>>>> +typedef enum {False = 0, True = !False} boolean_t;
>>>
>>> Shouldn't we just use "bool"?
>>
>> Yes, in some cases. In others, the boolean status doesn't make sense
>> and I'd like to replace it with an integer.
> 
> I believe casts from bools to integers are defined to convert false and
> true to 0 and 1 respectively, so you should be fine.

True, but in several cases like layout_cache_fill_from* or extents_get
a single status bit hides errors I'd rather percolate up the stack.

I'm not diving into this right now because this code needs a overhaul
to allow memory allocation outside the lock.
I'm thinking of a dual pass implementation, doing a pass under the lock
to calculate how many items to allocate.  Doing the allocation after
releasing the (now mutex but better be spin) lock, and then running
through the list again under lock using the allocated memory.
The hard parts in this scheme are if the state of the layout changes and
we need more memory in the second pass.  In this case we'll need yet another
iteration for the remainder, rinse, wash, repeat.

Benny

> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
