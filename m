From: Greg Banks <gnb-xTcybq6BZ68@public.gmane.org>
Subject: Re: [patch 03/29] knfsd: add userspace controls for stats tables
Date: Tue, 28 Apr 2009 11:31:49 +1000
Message-ID: <ac442c870904271831i2542b745ndd3ee276b88300fe@mail.gmail.com>
References: <20090331202800.739621000@sgi.com>
	 <20090331202938.939647000@sgi.com>
	 <20090425215745.GA5088@fieldses.org>
	 <20090425220329.GB5088@fieldses.org>
	 <A11EACD6-B05E-4A1A-A38C-F65B2DFB77B3@oracle.com>
	 <ac442c870904271827w6041a67ew82fe36a843beeac3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Linux NFS ML <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f180.google.com ([209.85.221.180]:49919 "EHLO
	mail-qy0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755331AbZD1Bbt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Apr 2009 21:31:49 -0400
Received: by qyk10 with SMTP id 10so540566qyk.33
        for <linux-nfs@vger.kernel.org>; Mon, 27 Apr 2009 18:31:49 -0700 (PDT)
In-Reply-To: <ac442c870904271827w6041a67ew82fe36a843beeac3-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

G'day,

Whoops, this bounced from the list because I accidentally had HTML
formatting on.  Resending.

On Tue, Apr 28, 2009 at 11:27 AM, Greg Banks <gnb-xTcybq6BZ68@public.gmane.org> wrote:
>
>
> On Tue, Apr 28, 2009 at 2:06 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>
>> On Apr 25, 2009, at 6:03 PM, J. Bruce Fields wrote:
>>>
>>> Pfft, did it again.
>>>
>>> --b.
>>>
>>> On Sat, Apr 25, 2009 at 05:57:45PM -0400, bfields wrote:
>>>>
>>>> On Wed, Apr 01, 2009 at 07:28:03AM +1100, Greg Banks wrote:
>>>>>
>>>>> +
>>>>> +/**
>>>>> + * write_stats_prune_period - Set or report the period for pruning
>>>>> + *                           old per-client/per-export stats entries,
>>>>> + *                           in seconds.
>>>>> + *
>>>>> + * Input:
>>>>> + *                     buf:            ignored
>>>>> + *                     size:           zero
>>>>> + *
>>>>> + * OR
>>>>> + *
>>>>> + * Input:
>>>>> + *                     buf:            C string containing an unsigned
>>>>> + *                                     integer value representing the
>>>>> new value
>>>>> + *                     size:           non-zero length of C string in
>>>>> @buf
>>>>> + * Output:
>>>>> + *     On success:     passed-in buffer filled with '\n'-terminated C
>>>>> string
>>>>> + *                     containing numeric value of the current setting
>>>>> + *                     return code is the size in bytes of the string
>>>>> + *     On error:       return code is zero or a negative errno value
>>>>> + */
>>>>
>>>> Just an idle remark, don't worry about this for now, but: we might want
>>>> to rein in this write_*() comment format a little some day.  A lot of
>>>> the content seems duplicated.
>>
>> I disagree.
>>
>> The present nfsctl user space API is entirely ad hoc.
>
> Agreed.
>
>>
>>
>> Although sometimes the behavior is the same, each function/file can behave
>> slightly differently than the others.  We have to be very specific about
>> this here because the comments serve as both "user" documentation and as
>> code/API specification.
>
> Sure, but the comments aren't organised in such a way that the subtle
> differences between each pseudofile are obvious.  Instead there are large
> swathes of text above each write_*() function which describe behaviours
> common to all the write_*() functions, and you have to hunt carefully for
> the differences.
>
> For example, we don't need 10 copies of this text:
>
>  *     On success:     passed-in buffer filled with '\n'-terminated C string
>  *                     containing numeric value of the current setting
>  *                     return code is the size in bytes of the string
>
> Bruce rightly points out that my patch was continuing this poor trend.
>
>>
>> Because this code wasn't adequately documented, features have been added
>> over time without a close examination of the operation of other parts of
>> this code.
>>
>> If you really want to simplify the comments, we should consider
>> simplifying the API first, imo.
>
> Meh.  Most of the stuff in the nfsd filesystem could be *simplified* by
> using the actual /proc filesystem mechanisms instead.
>
>
>
> --
> Greg.
>



-- 
Greg.
