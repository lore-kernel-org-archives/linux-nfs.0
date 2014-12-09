Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:40766 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751665AbaLIVbG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2014 16:31:06 -0500
Message-ID: <54876A0C.3090109@RedHat.com>
Date: Tue, 09 Dec 2014 16:30:52 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: =?windows-1252?Q?David_H=E4rdeman?= <david@hardeman.nu>
CC: Timo Teras <timo.teras@iki.fi>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/5] rework access to /proc/net/rpc
References: <399e974867e03c052fedfa8e8fd688ca@hardeman.nu> <20141209104236.2204671c@vostro> <24f5038cdd74837afb8a53887eb4b803@hardeman.nu> <54871E87.7000300@RedHat.com> <20141209202652.GA32738@hardeman.nu>
In-Reply-To: <20141209202652.GA32738@hardeman.nu>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/09/2014 03:26 PM, David Härdeman wrote:
> On Tue, Dec 09, 2014 at 11:08:39AM -0500, Steve Dickson wrote:
>> On 12/09/2014 09:01 AM, David Härdeman wrote:
>>> On 2014-12-09 09:42, Timo Teras wrote:
>>>> On Tue, 09 Dec 2014 09:16:59 +0100
>>>> David Härdeman <david@hardeman.nu> wrote:
>>>>> At least the readline() function could be implemented using
>>>>> read/write (instead of fread/fwrite) and a dynamic buffer...no?
>>>>
>>>> It's extra complexity. I'd rather not add it unless it's required. My
>>>> understanding about the communication mechanism with kernel is that
>>>> it's not required. Why have code that would never be used?
>>>
>>> I agree that it depends on your view. I tend to be very sceptical of arbitrary 
>>> limitations unless they have a very good reason (like measurable and relevant 
>>> performance impact), I doubt that's the case here.
>> Your skeptical-ability of arbitrary limitations has become very clear in 
>> the last few hours... ;-) I guess I'm indifferent about it... From reading
>> your gssd patch set, it is a bit more artful not to use fixed size buffers
>> but again, I'm indifferent... That said... if patches appear removing these
>> fixed buffers they definitely would be considered... 
>>
>>>
>>> It's up to the maintainer though, I just wanted to point it out :)
>> My understanding these patches were needed to make nfs-utils compatible with the musl c-library.
>> That is the case, correct? 
> 
> The fread/fwrite removal seems reasonable, yes. The removal of the
> readline() function though (which could be implemented using normal
> read/malloc/realloc) seems less so.....IMHO.
> 
Patches welcome! 8-)

steved.
