From: Masatake YAMATO <yamato@redhat.com>
Subject: Re: [PATCH 1/2] Read /etc/exports.d/*.export as extra export files
Date: Mon, 07 Mar 2011 23:27:14 +0900 (JST)
Message-ID: <20110307.232714.1131504612653391209.yamato@redhat.com>
References: <4D74DAE7.5060503@RedHat.com>
	<20110307.225054.778816292497413667.yamato@redhat.com>
	<4D74E830.6020406@RedHat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: SteveD@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30734 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751011Ab1CGO1Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Mar 2011 09:27:16 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p27ERGlA017935
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 7 Mar 2011 09:27:16 -0500
In-Reply-To: <4D74E830.6020406-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> 
> 
> On 03/07/2011 08:50 AM, Masatake YAMATO wrote:
>>>
>>>
>>> On 03/07/2011 08:05 AM, Steve Dickson wrote:
>>>>
>>>>
>>>> On 03/06/2011 01:11 AM, Masatake YAMATO wrote:
>>>>> On Sat, 5 Mar 2011 20:51:06 -0500, Jim Rees <rees@umich.edu> wrote
>>>>>> Steve Dickson wrote:
>>>>>>
>>>>>>   Now, I realize you added the ".export" explanation to the man page 
>>>>>>   but is there a particular reason why file in that directory have 
>>>>>>   to end with ".export"? Out of "easy of use" sake, should any 
>>>>>>   and all files that exist in that directory be expected to 
>>>>>>   be exports files?
>>>>>>
>>>>>> I don't know if that's the best way to do it, but I think it would be useful
>>>>>> to have a way to keep files in the directory that don't get automatically
>>>>>> read.  As an analogy, I have the following files in my /etc/init:
>>>>>>
>>>>>> portmap.conf           This is the real one that gets used
>>>>>> portmap.conf~          This is a backup file produced by emacs
>>>>>> portmap.conf-20100603  This is the file that came with my distro
>>>>>>
>>>>>> Only the first one gets used, which is what I want, because it's the only
>>>>>> one ending in ".conf".
>>>> This makes sense... 
>>>>
>>>>>
>>>>> Jim, thank you for explanation. He wrote what I'd like to write.
>>>>>
>>>>> This technique is borrowed from util-linux-ng; libmount.so reads
>>>>> only *.fstab under /etc/fstab.d.
>>>>>
>>>>>
>>>>> In addition, ".export" suffix tells an editor which syntax highlighter
>>>>> should be used when editing .export file:P
>>>> True... But I noticed the suffix that gvim looks for is ".exports"
>>>> not ".export". 
>>>>
>>>> What editor are you using and does it look for a ".export" by default?
>>>>
>>> After thinking about this a little longer, I think making the 
>>> suffix ".exports" does make sense. Along with the that being 
>>> the default syntax  highlighter for gvim, more importantly, its
>>> also the name of the man page, exports(5).
>> 
>> I see. I didn't think what is the best suffix the file such deeply.
>> Do I need to resubmit a patch for s/.export/.exports/g?
> No... I'll take care of it...

Thanks. I'll watch the git repository.

Masatake YAMATO


 
> steved.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
