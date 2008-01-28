From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 015/100] nfsd: Fix handling of negative lengths in read_buf()
Date: Mon, 28 Jan 2008 18:16:14 -0500
Message-ID: <C56728F5-40AC-49F0-B9AD-574FEC4C404C@oracle.com>
References: <1201303040-7779-9-git-send-email-bfields@citi.umich.edu> <1201303040-7779-10-git-send-email-bfields@citi.umich.edu> <1201303040-7779-11-git-send-email-bfields@citi.umich.edu> <1201303040-7779-12-git-send-email-bfields@citi.umich.edu> <1201303040-7779-13-git-send-email-bfields@citi.umich.edu> <1201303040-7779-14-git-send-email-bfields@citi.umich.edu> <1201303040-7779-15-git-send-email-bfields@citi.umich.edu> <346EF0C5-EFD6-4187-BA51-1946142920AB@oracle.com> <20080128201507.GG16785@fieldses.org> <F228287C-EE5C-4274-9DBE-35F87D7DE030@oracle.com> <20080128221406.GQ16785@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:45492 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764670AbYA1XQf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2008 18:16:35 -0500
In-Reply-To: <20080128221406.GQ16785@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

On Jan 28, 2008, at 5:14 PM, J. Bruce Fields wrote:
> On Mon, Jan 28, 2008 at 04:46:06PM -0500, Chuck Lever wrote:
>> Hi Bruce-
>>
>> On Jan 28, 2008, at 3:15 PM, J. Bruce Fields wrote:
>>> On Mon, Jan 28, 2008 at 01:00:47PM -0500, Chuck Lever wrote:
>>>> Changing nbytes to an unsigned introduces a mixed-sign comparison:
>>>>
>>>>         int avail = (char*)argp->end - (char*)argp->p;
>>>>         __be32 *p;
>>>>         if (avail + argp->pagelen < nbytes)  <<<<<<
>>>>
>>>> "avail" and "argp->pagelen" are signed ints.
>>>
>>> OK.  Is the result incorrect?
>>
>> Whether it is or it isn't, I'm not comfortable with introducing a
>> mixed-sign comparison for no reason.  It's not a correctness  
>> issue, it's
>> a maintainability issue.
>
> I understand, I just wanted to make sure.

> (As a general rule, it would be helpful to me if, both in comments  
> like
> this and on any patches, you'd clearly state whether or not you've  
> found
> a run-time bug.)

I haven't checked it carefully enough to say whether there is a run- 
time problem with the old or the patched version of read_buf().  At  
this point it's not likely, but there is enough implicit type casting  
in the comparisons and when passing arguments that the original  
intention of the authors of this code is not exactly clear.

I do now make it a practice in patch descriptions to state "Clean  
up:" if the patch does not address a run-time bug.

> The change in behavior of these comparisons was exactly the point of
> the patch:
>
> 	"The length "nbytes" passed into read_buf should never be
> 	negative, but we check only for too-large values of "nbytes",
> 	not for too-small values.  Make nbytes unsigned, so it's clear
> 	that the former tests are sufficient."
>
> Was my comment there unclear, or am I missing some other problem?


In my opinion, introducing a mixed sign comparison makes the tests  
less clear.  I would fix at least "avail" and perhaps "argp- 
 >pagelen", and assert that argp->end > argp->p, to make the tests in  
read_buf() entirely precise.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
