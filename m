Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34508 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751391AbbG3M3F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 08:29:05 -0400
Message-ID: <55BA1881.90203@gmail.com>
Date: Thu, 30 Jul 2015 20:28:49 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Al Viro <viro@zeniv.linux.org.uk>
CC: "J. Bruce Fields" <bfields@fieldses.org>, NeilBrown <neilb@suse.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: Re: [PATCH 1/9 v8] fs_pin: Initialize value for fs_pin explicitly
References: <55B5A012.1030006@gmail.com> <55B5A04D.8090905@gmail.com> <20150729102519.16f2f70d@noble> <20150729194155.GC21949@fieldses.org> <20150730074824.6b7faedd@noble> <20150730003610.GA24778@fieldses.org>
In-Reply-To: <20150730003610.GA24778@fieldses.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/30/2015 08:36, J. Bruce Fields wrote:
> On Thu, Jul 30, 2015 at 07:48:24AM +1000, NeilBrown wrote:
>> On Wed, 29 Jul 2015 15:41:55 -0400 "J. Bruce Fields"
>> <bfields@fieldses.org> wrote:
>>
>>> On Wed, Jul 29, 2015 at 10:25:19AM +1000, NeilBrown wrote:
>>>> On Mon, 27 Jul 2015 11:06:53 +0800 Kinglong Mee <kinglongmee@gmail.com>
>>>> wrote:
>>>>
>>>>> Without initialized, done in fs_pin at stack space may
>>>>> contains strange value.
>>>>>
>>>>> v8, same as v3
>>>>> Adds macro for header file
>>>>>
>>>>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>>>>
>>>> Reviewed-by: NeilBrown <neilb@suse.com>
>>>>
>>>> It would be really good if some of these early patches could be applied
>>>> to the relevant trees so they appear in -next and we only need to keep
>>>> reviewing the more interesting code at the end.
>>>
>>> This patch seems a little bikeshed-y.  I'd rather just drop it or save
>>> it for some other day.  It's not necessary to the series.
>>
>> ???
>>
>> I accept that:
>>
>>
>>>>> @@ -1,3 +1,6 @@
>>>>> +#ifndef _LINUX_FS_PIN_H
>>>>> +#define _LINUX_FS_PIN_H
>>>>> +
>>>>>  #include <linux/wait.h>
>>
>> could be a little bike-shed-y, not that I've seen much bike shedding
>> going on.
>>
>> However:
>>>>>  
>>>>>  struct fs_pin {
>>>>> @@ -16,9 +19,12 @@ static inline void init_fs_pin(struct fs_pin *p, void (*kill)(struct fs_pin *))
>>>>>  	INIT_HLIST_NODE(&p->s_list);
>>>>>  	INIT_HLIST_NODE(&p->m_list);
>>>>>  	p->kill = kill;
>>>>> +	p->done = 0;
>>>>>  }
>>>>>  
>>
>> is quite important.
>> Without that assignment we would probably need to rename the function to
>>    init_most_of_fs_pin
>> or
>>    init_fs_pin_if_already_zeroed
>> or maybe just
>>    __init_fs_pin
>> with the time honoured interpretation that it sort-of does what the
>> name says, but maybe not exactly how you think and please use with care.
>>
>> Then in nfsd code we would need to add the assignment ourselves, or use
>> kzalloc where it would otherwise be completely unnecessary.
> 
> Right, the existing users do something like kzalloc, last I checked.
> Maybe it'd be an improvement not to.
> 
> I don't really care, but since Al's a bit overloaded, and you don't want
> to see this reposted, and it's not really essential to the series, why
> not drop it for now?

What's your opinion about this patch, Al?
Drop? needs update?

thanks,
Kinglong Mee
