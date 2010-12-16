Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:29169 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756243Ab0LPRhH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Dec 2010 12:37:07 -0500
Message-ID: <4D0A4E40.2070405@panasas.com>
Date: Thu, 16 Dec 2010 19:37:04 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Peng Tao <bergwolf@gmail.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/9] Revert "pnfs-submit: wave2: remove forgotten layoutreturn
 struct definitions"
References: <4D0908F9.4060208@panasas.com> <1292437854-21651-1-git-send-email-bhalevy@panasas.com> <1292437973.3068.15.camel@heimdal.trondhjem.org> <4D090E18.4060205@panasas.com> <1292441468.3068.53.camel@heimdal.trondhjem.org> <1292444651.3068.67.camel@heimdal.trondhjem.org> <4D09BF3F.3070209@panasas.com> <AANLkTikWLE8Z665yf7B4ERXtHKY8y0pRbbCH7Z-QqLwo@mail.gmail.com>
In-Reply-To: <AANLkTikWLE8Z665yf7B4ERXtHKY8y0pRbbCH7Z-QqLwo@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-12-16 19:21, Peng Tao wrote:
> Hi, Benny,
> 
> On Thu, Dec 16, 2010 at 3:26 PM, Benny Halevy <bhalevy@panasas.com> wrote:
>> On 2010-12-15 22:24, Trond Myklebust wrote:
>>> On Wed, 2010-12-15 at 14:31 -0500, Trond Myklebust wrote:
>>>> On Wed, 2010-12-15 at 20:51 +0200, Benny Halevy wrote:
>>>
>>>>> Eventually, when CB_LAYOUTRECALL is clear to go sending the LAYOUTRETURN
>>>>> or replying with CB_NOMATCHING_LAYOUT (assuming no I/O error to report
>>>>> for pnfs-obj) should be equivalent [note: need errata to clarify the
>>>>> resulting stateid after NOMATCHING_LAYOUT].
>>>>> Is this the serialization "crap" you're talking about?
>>>>> What makes checking the conditions for returning NFS4ERR_DELAY to
>>>>> CB_LAYOUTRECALL so different from implementing a barrier and doing the
>>>>> returns asynchronously with the CB_LAYOUTRECALL?
>>>>
>>>> "CB_LAYOUTRECALL request processing MUST be processed in "seqid" order
>>>> at all times." (section 12.5.3).
>>>>
>>>> In other words, you cannot just 'do the returns asynchronously': the
>>>> CB_LAYOUTRECALL requests are required by the protocol to be processed in
>>>> order, which means that you must serialise those LAYOUTRETURN calls to
>>>> ensure that they all happen in the order the wretched server expects.
>>>
>>> BTW: one consequence of the way the protocol was written is that you
>>> can't just throw out a LAYOUTRETURN for the entire file if the server
>>> just recalls a segment. Instead, you have to first return the segment,
>>> then send the LAYOUTRETURN for the entire file.
>>>
>>
>> It is true that the protocol requires the return of the exact recalled range
>> but why can't the client do return the whole file before returning the recalled
>> range?
> Just for clarification, do you mean that after client returns more
> than server recalls, clients still has to do an echoing LAYOUTRETURN?
> It is barely overhead...
> Why would server require some behavior like that?
> 

The reason for that in the protocol was to provide a simple way to
complete a CB_LAYOUTRECALL "meta operation" when the client returns
the layout in smaller ranges than recalled. We overlooked this case
of the client returning a range containing the returned range.
which is easier to deal with, with further stateid related functionality
we introduced after specifying how layout recall initially worked...

Benny

>>
>>> That part of the protocol is just one insane idea after another...
>>>
>>
>> This was done to ensure that the server and client are in-sync after a
>> CB_LAYOUTRECALL.  I agree that returning the whole layout thus resetting
>> the layout state achieves the same goal and we should consider allowing it
>> in the next version.
>>
>> Benny
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> 
> 
> 
