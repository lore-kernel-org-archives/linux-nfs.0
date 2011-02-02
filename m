Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7633 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754439Ab1BBPpp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Feb 2011 10:45:45 -0500
Subject: Re: [PATCH 1/3] pnfs: avoid incorrect use of layout stateid
Content-Type: text/plain; charset=us-ascii
From: Fred Isaman <iisaman@netapp.com>
In-Reply-To: <4D48DB59.9010102@panasas.com>
Date: Wed, 2 Feb 2011 10:45:18 -0500
Cc: linux-nfs@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>
Message-Id: <F2D196CC-A542-40DA-AB94-1ADB22A5E899@netapp.com>
References: <1296487633-21057-1-git-send-email-iisaman@netapp.com> <1296487633-21057-2-git-send-email-iisaman@netapp.com> <4D4828DC.9020103@panasas.com> <AF70A3A4-2A06-4BD1-AC69-270658CF6365@netapp.com> <4D48DB59.9010102@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Feb 1, 2011, at 11:19 PM, Benny Halevy wrote:

> On 2011-02-01 18:31, Fred Isaman wrote:
>> 
>> On Feb 1, 2011, at 10:38 AM, Benny Halevy wrote:
>> 
>>> On 2011-01-31 17:27, Fred Isaman wrote:
>>>> The code could violate the following from RFC5661, section 12.5.3:
>>>> "Once a client has no more layouts on a file, the layout stateid is no
>>>> longer valid and MUST NOT be used."
>>> 
>>> NACK.
>>> 
>>> Fred, this is your interpretation of the forgetful model and it is taken
>>> out of context.
>>> 
>>> Until the spec is changed only the server invalidates the stateid by returning
>>> lrs_present=false on LAYOUTRETURN. Merely forgetting the layout state without
>>> LAYOUTRETURN does not determine that.
>>> 
>>> 
>>> Also from 12.5.3:
>>>  Once a layout stateid is established, the "other"
>>>  field will stay constant unless the stateid is revoked or the client
>>>  returns all layouts on the file and the server disposes of the stateid.
>>>  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
>>> 
>> 
>> 
>> OK, so the question is, does sending a LAYOUTGET with openstateid "return all layouts".
>> Making the answer to this "yes" is perfectly consistent with the spec, given its complete absence
>> of direction here.
> 
> I disagree, and so are other server implementations, including linux-pnfs!
> (It will return BAD_STATEID if the client forgets the layout
> in any case but LAYOUTRETURN or CB_LAYOUTRECALL/NOMATCHING_LAYOUT)
> 
>> The alternative is a forgetful model where the client can forget layouts, but
>> not layout stateid.
> 
> Right, and this is the direction we should go until the errata is in place.
> 
>> 
>> The question is, is there any objection to the above interpretation of LAYOUTGET with openstateid?
>> Because if not, then we will shortly get an appropriate errata,
>> and there is no good reason to delay the patch until the errata is finalized.
>> I know previously you had objected on the basis that this prevents parallel use of openstateid with LAYOUTGET.
>> But given that you had indicated that such parallel use can not be done for other reasons,
>> I have been working on the assumption that the interpretation above will be accepted without controversy at the upcoming IETF.
>> 
>> On the other hand, if there is objection to the above interpretation, that should be made known.
> 
> I simulated this with the layout-sim and given the LAYOUTGET sent with the initial stateid
> is always fully serialized with other layout stateid-changing operations, this model works.
> 
> I object the timing, before the IETF discussion is over and before the upcoming Connectathon
> where other server vendors have no chance to implement this erratum.
> 

Our goal is to have at cthon working code to test that is basically what will be submitted upstream,  Waiting for the IETF to be over before implementing means nothing will be implemented.  Instead, we have been consistently making best guesses, with Trond's input, on how each spec ambiguity will be resolved.

This patch fixes two real existing bugs.  It prepares the way for fixing another real existing bug (lock inversion). Yes, it makes an assumption on how we will decide to clarify a spec issue, but so does much of the existing code.  (For example, we update seqid on NOMATCHING, all the roc code.) Finally, the current code *already* makes this assumption.  Because the client can randomly forget layouts, it has NO way to know when sending a NOMATCHING return whether it should keep the stateid or not, so it *already* uses the assumption that if it has none in memory, it will send an openstateid.
 
Fred

