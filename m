Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:21972 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755829Ab0LRDpQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Dec 2010 22:45:16 -0500
Message-ID: <4D0C2E4A.1040305@panasas.com>
Date: Sat, 18 Dec 2010 05:45:14 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/9] Revert "pnfs-submit: wave2: remove forgotten layoutreturn
 struct definitions"
References: <4D0908F9.4060208@panasas.com>	 <1292437854-21651-1-git-send-email-bhalevy@panasas.com>	 <1292437973.3068.15.camel@heimdal.trondhjem.org>	 <4D090E18.4060205@panasas.com>	 <1292441468.3068.53.camel@heimdal.trondhjem.org>	 <4D09BC93.9020502@panasas.com>	 <1292514922.2912.32.camel@heimdal.trondhjem.org>	 <4D0A3D44.2000101@panasas.com>	 <1292520916.2912.45.camel@heimdal.trondhjem.org>	 <4D0A4F9F.4040300@panasas.com> <1292523281.2912.62.camel@heimdal.trondhjem.org>
In-Reply-To: <1292523281.2912.62.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-12-16 20:14, Trond Myklebust wrote:
> On Thu, 2010-12-16 at 19:42 +0200, Benny Halevy wrote:
>> On 2010-12-16 19:35, Trond Myklebust wrote:
>>> On Thu, 2010-12-16 at 18:24 +0200, Benny Halevy wrote:
>>>> On 2010-12-16 17:55, Trond Myklebust wrote:
>>>>> OK, so why not just go the whole hog and do that for all rare cases,
>>>>> including the one where the server recalls a layout segment that we
>>>>> happen to be doing I/O to?
>>>>>
>>>>> The case we should be optimising for is the one where the layout is
>>>>> recalled, and no I/O to that segment is in progress. For that case,
>>>>> returning OK, then doing the LAYOUTRETURN instead of just returning
>>>>> NOMATCHING_LAYOUT is clearly wrong: it adds a completely unnecessary
>>>>> round trip to the server. Agreed?
>>>>
>>>> I agree that if the client can free the recalled layout synchronously
>>>> and if it need not send a LAYOUTCOMMIT or LAYOUTRETURN (e.g. in the objects case)
>>>> it can simply return NFS4ERR_NOMATCHING_LAYOUT.
>>>
>>> Objects and blocks != wave 2. We can cross that bridge when we get to
>>> it.
>>>
>>
>> Right.  This patchset is destined as post wave2.
> 
> In that case it has a very confusing title (which certainly caught me by
> surprise).
> 
>>
>>>>>
>>>>> As for the much rarer case of a recall of a layout that is in use, how
>>>>> does LAYOUTRETURN speed things up? As far as I can see, the MDS is still
>>>>> going to return NFS4ERR_DELAY to the client that requested the
>>>>> conflicting LAYOUTGET. That client then has to resend this LAYOUTGET
>>>>> request, at a time when the first client may or may not have returned
>>>>> its layout segment. So how is LAYOUTRETURN going to make all this a fast
>>>>> and scalable process?
>>>>>
>>>>
>>>> First, the server does not have to poll the client and waste cpu and network
>>>> resources on that.
>>>
>>> ...but this is a ____rare____ case. If you are seeing noticeable effects
>>> on the network from this, then something is wrong. If that is ever the
>>> case, then you should be writing through the MDS anyway.
>>>
>>> Furthermore, the MDS does need to be able to cope with NFS4ERR_DELAY
>>> anyway, so why add the extra complexity to the client?
>>>
>>>> Second, for the competing client, with notifications, it too does not have
>>>> to poll the server and can wait on getting the notification when the
>>>> layout becomes available.
>>>
>>> There is no notification of layout availability in RFC5661. Lock
>>> notification is for byte range locks, and device id notification is for
>>> device ids. The rest is for directory notifications.
>>>
>>
>> Hmm, CB_RECALLABLE_OBJ_AVAIL in response to loga_signal_layout_avail...
> 
> Hmm indeed. Section 12.3 states:
> 
> "CB_RECALLABLE_OBJ_AVAIL  (Section 20.7) tells a client that a
> recallable object that it was denied (in case of pNFS, a layout denied
> by LAYOUTGET) due to resource exhaustion is now available."
> 
> and 18.43.3 states:
> 
> "If client sets loga_signal_layout_avail to TRUE, then it is registering
> with the client a "want" for a layout in the event the layout cannot be
> obtained due to resource exhaustion."
> 
> I can't see how that is relevant to the case where a specific LAYOUTGET
> requires a layout recall from another client. That's not resource
> exhaustion.
> 
> 
> 

Yeah, the phrasing is miserable.
It should be useful for any reason making the layout temporarily
unavailable. Yet another errata entry...

Benny
