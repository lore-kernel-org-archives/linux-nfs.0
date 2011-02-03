Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:7384 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753992Ab1BCIPc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Feb 2011 03:15:32 -0500
Message-ID: <4D4A6420.5020208@panasas.com>
Date: Thu, 03 Feb 2011 10:15:28 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] pnfs: avoid incorrect use of layout stateid
References: <1296487633-21057-1-git-send-email-iisaman@netapp.com>	 <1296487633-21057-2-git-send-email-iisaman@netapp.com>	 <4D4828DC.9020103@panasas.com>	 <AF70A3A4-2A06-4BD1-AC69-270658CF6365@netapp.com>	 <4D48DB59.9010102@panasas.com> <1296626165.8895.31.camel@heimdal.trondhjem.org>
In-Reply-To: <1296626165.8895.31.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-02-02 07:56, Trond Myklebust wrote:
> On Wed, 2011-02-02 at 06:19 +0200, Benny Halevy wrote: 
>> On 2011-02-01 18:31, Fred Isaman wrote:
>>>
>>> On Feb 1, 2011, at 10:38 AM, Benny Halevy wrote:
>>>
>>>> On 2011-01-31 17:27, Fred Isaman wrote:
>>>>> The code could violate the following from RFC5661, section 12.5.3:
>>>>> "Once a client has no more layouts on a file, the layout stateid is no
>>>>> longer valid and MUST NOT be used."
>>>>
>>>> NACK.
>>>>
>>>> Fred, this is your interpretation of the forgetful model and it is taken
>>>> out of context.
>>>>
>>>> Until the spec is changed only the server invalidates the stateid by returning
>>>> lrs_present=false on LAYOUTRETURN. Merely forgetting the layout state without
>>>> LAYOUTRETURN does not determine that.
>>>>
>>>>
>>>> Also from 12.5.3:
>>>>   Once a layout stateid is established, the "other"
>>>>   field will stay constant unless the stateid is revoked or the client
>>>>   returns all layouts on the file and the server disposes of the stateid.
>>>>   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
>>
>>> OK, so the question is, does sending a LAYOUTGET with openstateid "return all layouts".
>>> Making the answer to this "yes" is perfectly consistent with the spec, given its complete absence
>>> of direction here.
>>
>> I disagree, and so are other server implementations, including linux-pnfs!
>> (It will return BAD_STATEID if the client forgets the layout
>> in any case but LAYOUTRETURN or CB_LAYOUTRECALL/NOMATCHING_LAYOUT)
> 
> Where do you see this being allowed? I see nothing in RFC5661 that
> justifies the server returning BAD_STATEID (or any other error) if the
> client supplies an open stateid in LAYOUTGET. The only stateids that are
> explicitly disallowed in section 12 are the special stateids.
> IOW: I see no justification there for your interpretation or the above
> error message. Fix the linux pnfs server and the "other server
> implementation" if it does this.

This case is indeed not defined well in the spec.

> 
> The only text I can find is repeated in both section 12.5.2. and section
> 12.5.3 and states that the client uses an open stateid, delegation
> stateid or lock stateid if it holds no layouts.

Right, but the point in which it is defined to hold no layout is when
it has returned them to the server.  There is not much sense in arguing
that over and over again as we're in agreement regarding the proposed
errata.

Benny

> Section 12.5.5.1 then states that the client is allowed to forget
> layouts and that this is safe as long as it doesn't assume it holds
> layouts for ranges that lie beyond what the server granted. The same
> section states that the server has no control over what the client
> believes, and so it is allowed to recall a layout that the client knows
> nothing about if it is in doubt.
> 
> 
> Trond
