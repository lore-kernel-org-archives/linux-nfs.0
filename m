From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 015/100] nfsd: Fix handling of negative lengths in
	read_buf()
Date: Mon, 28 Jan 2008 17:14:06 -0500
Message-ID: <20080128221406.GQ16785@fieldses.org>
References: <1201303040-7779-9-git-send-email-bfields@citi.umich.edu> <1201303040-7779-10-git-send-email-bfields@citi.umich.edu> <1201303040-7779-11-git-send-email-bfields@citi.umich.edu> <1201303040-7779-12-git-send-email-bfields@citi.umich.edu> <1201303040-7779-13-git-send-email-bfields@citi.umich.edu> <1201303040-7779-14-git-send-email-bfields@citi.umich.edu> <1201303040-7779-15-git-send-email-bfields@citi.umich.edu> <346EF0C5-EFD6-4187-BA51-1946142920AB@oracle.com> <20080128201507.GG16785@fieldses.org> <F228287C-EE5C-4274-9DBE-35F87D7DE030@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:55236 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762108AbYA1WOI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Jan 2008 17:14:08 -0500
In-Reply-To: <F228287C-EE5C-4274-9DBE-35F87D7DE030@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 28, 2008 at 04:46:06PM -0500, Chuck Lever wrote:
> Hi Bruce-
>
> On Jan 28, 2008, at 3:15 PM, J. Bruce Fields wrote:
>> On Mon, Jan 28, 2008 at 01:00:47PM -0500, Chuck Lever wrote:
>>> Changing nbytes to an unsigned introduces a mixed-sign comparison:
>>>
>>>         int avail = (char*)argp->end - (char*)argp->p;
>>>         __be32 *p;
>>>         if (avail + argp->pagelen < nbytes)  <<<<<<
>>>
>>> "avail" and "argp->pagelen" are signed ints.
>>
>> OK.  Is the result incorrect?
>
> Whether it is or it isn't, I'm not comfortable with introducing a  
> mixed-sign comparison for no reason.  It's not a correctness issue, it's 
> a maintainability issue.

I understand, I just wanted to make sure.

(As a general rule, it would be helpful to me if, both in comments like
this and on any patches, you'd clearly state whether or not you've found
a run-time bug.)

>
>> (Any objections to just making "avail" unsigned?)
>
> If we can guarantee that argp->end is always larger than argp->p... then 
> there's no need for "avail" to be a signed int.  However:

OK.

>
>>>                 return NULL;
>>>         if (avail + PAGE_SIZE < nbytes) /* need more than a page !! 
>>> */
>>>                 return NULL;
>>>
>>> PAGE_SIZE is unsigned long (defined as "1UL << PAGE_SHIFT"), so  
>>> changing
>>> nbytes may have additional unintended consequences.
>
> ...and since that wasn't noticed or addressed by this patch, it suggests 
> that there may be other issues that the patch author didn't address and 
> that reviewers didn't catch.

The change in behavior of these comparisons was exactly the point of
the patch:

	"The length "nbytes" passed into read_buf should never be
	negative, but we check only for too-large values of "nbytes",
	not for too-small values.  Make nbytes unsigned, so it's clear
	that the former tests are sufficient."

Was my comment there unclear, or am I missing some other problem?

--b.
