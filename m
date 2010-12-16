Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20374 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750855Ab0LPWp0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Dec 2010 17:45:26 -0500
Message-ID: <4D0A9681.2060700@redhat.com>
Date: Thu, 16 Dec 2010 17:45:21 -0500
From: Ric Wheeler <rwheeler@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Steve Dickson <SteveD@redhat.com>, trond.myklebust@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/31] NFS XDR clean up for 2.6.38
References: <20101214144747.2293.68070.stgit@matisse.1015granger.net> <4D0A6503.7010901@RedHat.com> <CD110562-AF52-4A2F-BF74-D7ABC4D58D24@oracle.com> <4D0A74C5.1040104@gmail.com> <1C326FE3-22FF-4272-8D87-6242EB666297@oracle.com>
In-Reply-To: <1C326FE3-22FF-4272-8D87-6242EB666297@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 12/16/2010 04:04 PM, Chuck Lever wrote:
> On Dec 16, 2010, at 3:21 PM, Ric Wheeler wrote:
>
>> On 12/16/2010 03:04 PM, Chuck Lever wrote:
>>> On Dec 16, 2010, at 2:14 PM, Steve Dickson wrote:
>>>
>>>> Hello,
>>>>
>>>> I was wondering if it would be possible hold off on committing major
>>>> cleans ups like this one (and the RFC: Split nlm_host cache series)
>>>> until pNFS wave3 is committed into either Trond's tree and/or in the
>>>> mainline kernel.
>>>>
>>>> I realize this is a huge request to make, something we've never done
>>>> before. But talking with the powers to be on this end, include Ric
>>>> Wheeler, accepting these types of patches before the pNFS bits
>>>> settle down will make close to impossible for there to be any
>>>> meaningful pNFS support in the RHEL 6 kernels. We would have
>>>> to push the support off to RHEL 7.
>>>>
>>>> The reasoning is this, which I do agree with, these types of
>>>> patches, although probably needed, do not added any new features
>>>> or fix any outstanding bugs.
>>> The XDR series does add a new feature, FWIW: it adds buffer overflow protection to the client's reply processing logic.  Says so right in the patch descriptions.
>> Hi Chuck,
>>
>> My concern is one of testing one massive set of changes at a time and trying to get those stable (and through QA) before code refactoring. We have been focused on the pNFS bits for what feels like eons and they seem to be getting *really* close now :)
> Likewise, these XDR changes have been floating around since 2007 :-)  I'd rather not be penalized yet again because of the timing of other work.
>
>> I certainly do not object to this work, just want to get the pNFS flood absorbed and processed first.
>>
>> The risk of putting it all in the hopper together is that testing and debugging (in upstream, non-vendor distros and vendor distros) gets harder to qa, debug if/when issues arise  and get stable.
> Except for the across-the-board API change, the NFSv2 and NFSv3 XDR patches are entirely unrelated to pNFS.  Debugging, if any is needed, and QA can be done completely in parallel and by different developers (upstream).  Problems in that code will not have any effect on NFSv4 or pNFS.
>
> Again, you guys can lean on us upstream folks to help with troubleshooting and providing fixes.  Any fixes for bugs you find will have to come upstream anyway.

It is not the trouble shooting I worry about, it is being able to test major 
changes properly before doing refactoring.  Debugging we as a community do well, 
getting the code tested exhaustively depends on locking down resources outside 
of the developer community (qa people & test machines) and setting them loose to 
test things we don't.
>> It would certainly help us to stage pulling the XDR clean up work until after we settle the various pNFS "waves" of change, but I can also understand why you would prefer to push them in sooner.
> In principal, I can understand why you might hesitate to allow this change too.  But someone got scared by looking just at the patch count.  "fscache" this ain't.  There's a difference between complexity and changes that are simply broad.
>
> XDR is so basic that it will be obvious when something critical isn't right and how to fix it.  Bruce has already passed this through his magic automated test suite, multiple times.  A pass through linux-next will identify any significant remaining issues.
>
> Based on the age of these patches, the fact that any problems will likely be obvious, and the amount of testing they've already received, I expect it won't be anywhere near the kind of QA workload that pNFS will be.  However, I'd like to move forward with actual evidence about what it might cost you.  You can start looking at these now by pulling my git repo (git.linux-nfs.org cel-2.6) and trying a run through your QA cycle.  If you find a high defect rate, we can stop this conversation and hold off.
>
>

My concern is not just about Fedora and RHEL, rather it is about trying to get 
one massive, disruptive set of changes in & tested before launching into a 
refactoring that touches lots of critical bits. That is a concern with upstream 
& the distro of your choice.

If we do both at once, then we test them together and end up thrashing.

About putting the changes through QA, we only normally do that kind of extensive 
testing for major features that have a clear customer interest. I have to go to 
them and sell them on spending weeks of time, lobby partners to test, etc (not 
just Steve, Bruce, Jeff and our NFS developers :)).

And don't forget performance - correctness is one thing (it won't blow up or 
give bad data), but we also need to revalidate performance.

In the end, this is not my call, but it would be helpful to me and help me get 
pNFS features landed and tested if we could hold off a bit on non-critical 
changes for a release.

Do you all have any QA resources at Oracle that can torture your patches?

Thanks!

Ric

