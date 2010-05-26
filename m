Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:5913 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755525Ab0EZSNN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 May 2010 14:13:13 -0400
Message-ID: <4BFD64B6.5070109@panasas.com>
Date: Wed, 26 May 2010 21:13:10 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Dean Hildebrand <seattleplus@gmail.com>
CC: Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/22] LAYOUTGET invocation
References: <1273972993-15369-1-git-send-email-iisaman@netapp.com> <4BFC1686.4000509@gmail.com> <51AD8F7D-D172-4DE6-8F7A-CDFA292CBF8B@netapp.com> <4BFC2FA2.2050506@gmail.com> <4BFCDF1B.60608@panasas.com> <4BFD5CEF.8030703@gmail.com>
In-Reply-To: <4BFD5CEF.8030703@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/26/2010 08:39 PM, Dean Hildebrand wrote:
> Try to remember that this isn't some new feature that we are disabling, 
> or a new way of doing things, this is a primary I/O path. We MUST fix 
> this with the B-list code submission, so why go through the hassle of 
> searching through old patches and tags to find it.

No, this is no hassle. uncommenting old code and hopping for the best
is the hassle. (insert here the explanation from previous mail)

> 
> If you want to talk about a *REAL* solution, then we need to figure out 
> who broke O_DIRECT and reject their patches until they fix it.  You 
> can't submit patches that break a primary I/O path.  But again, since we 
> are focused on A-list items, ifdef'ing the code out for now in the 
> B-list branch seems like a reasonable compromise.
> 

No "ifdef'ing the code out" is never a "reasonable compromise" if you want
then keep it in a separate clean patch, with "BROKEN:" at subject line and
committed in a branch that is above the pnfs-all-latest. So it can be rebased
from time to time, but not included in the regular test scenario, until fixed.

(Which is BTW what it means the keep it out-of-tree, these git games are done
 routinely, every day)

Boaz

> Dean
> 
> Boaz Harrosh wrote:
>> On 05/25/2010 11:14 PM, Dean Hildebrand wrote:
>>   
>>>     
>>>> I can send some post_submit patches with the code ifdef'ed out if people would be content with that.
>>>>   
>>>>       
>>> Thanks for the background.  I would be much happier if you sent patches 
>>> with the code ifdef'd out, added with the comment in the code regarding 
>>> which patches you believe introduced the problem.
>>>
>>> Dean
>>>     
>>>> Fred
>>>>       
>>
>> I disagree. Source code is not a version management system. We have git
>> for that. The code is never lost it is there for eternity in the git
>> tree. We could ask Benny to tag the last branch that had broken directIO
>> as LAST_directIO_VERSION for easy random access at future time.
>>
>> If in the future someone smart wants to forward port the code and fix it
>> then the *right* way to do it is by manual octopus merge at the point of
>> branch.
>> Never, Never uncomment out code that was sitting collecting dust.
>> Manual octopus merge I mean using the two diffs from the two sides of the
>> branch, and replaying one on the other. For instance if at one patch
>> a function was moved, then redo the move of the current function again, not
>> leave the old code as it was before. Let the merge point out the points of
>> friction. Because you see, with commented code, there is never a merge
>> conflict it will always uncomment.
>>
>> And anyway the Kernel people will never accept code in comments. There
>> are out-of-tree gits to do that. So I don't even think it is an option.
>> The pnfs branches are patches that should eventually go upstream. Or
>> are currently the only option for the testing of upstream code.
>>
>> Boaz
>>   

