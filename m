Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:51937 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753324Ab3JXQFs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Oct 2013 12:05:48 -0400
Content-Type: text/plain; charset=US-ASCII
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: [PATCH] exportfs: Return non-zero exit value on error
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <52694336.9050303@RedHat.com>
Date: Thu, 24 Oct 2013 12:05:35 -0400
Cc: NeilBrown <neilb@suse.de>, tasleson@redhat.com, linux-nfs@vger.kernel.org
Message-Id: <AE4061A2-B0F8-4B1D-9381-873E7322FA54@oracle.com>
References: <1380756584-13335-1-git-send-email-tasleson@redhat.com> <20131022092519.4f4683a8@notabene.brown> <52669862.6030409@redhat.com> <20131023124444.65ace6e3@notabene.brown> <52680917.4010509@redhat.com> <20131024091811.34b06e71@notabene.brown> <D9521932-DDAA-47D2-996F-62D2A37BA5B0@oracle.com> <52694336.9050303@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 24, 2013, at 11:56 AM, Steve Dickson <SteveD@redhat.com> wrote:

> 
> 
> On 23/10/13 19:31, Chuck Lever wrote:
>> 
>> On Oct 23, 2013, at 6:18 PM, NeilBrown <neilb@suse.de> wrote:
>> 
>>> On Wed, 23 Oct 2013 12:36:23 -0500 Tony Asleson <tasleson@redhat.com> wrote:
>>> 
>>>> On 10/22/2013 08:44 PM, NeilBrown wrote:
>>>>> On Tue, 22 Oct 2013 10:23:14 -0500 Tony Asleson <tasleson@redhat.com> wrote:
>>>>>> The reason I chose to return values was to make sure requested operation
>>>>>> actually completed requested operation.  Unexporting a non-existent
>>>>>> export is not considered an error and returns no indication you did
>>>>>> absolutely nothing.
>>>>> 
>>>>> Hi,
>>>>> thanks makes sense - I had missed that (even though you explained it in the
>>>>> patch description :-( )
>>>>> 
>>>>> With your patch, if asked to unexport something that wasn't exported it
>>>>> would not report any error, but would exit with an error status.  Is that
>>>>> correct?  I think I would rather have a message printed if there is an error.
>>>> 
>>>> Correct, I only made changes for the exit status.  I was trying to make
>>>> changes that would be mostly invisible to end users.  I have no concerns
>>>> adding a printed error output too, but others may.
>>>> 
>>>> Changing the behavior of any command line tool is potentially
>>>> problematic when scripted.
>>>> 
>>>>> So would something like this (on top of my patch) address you need, or was
>>>>> there something else I missed?
>>>> 
>>>> Yes, this should work for the unexport fs case.
>>>> 
>>>> However, the reason my patch was a little more invasive was to ensure
>>>> that both the export and unexport paths were covered.
>>>> 
>>>> For example, if the strdup call fails in function client_init, we fail
>>>> the operation and return exit value of 0.  Unlikely, but just the first
>>>> example I stumbled across.
>>> 
>>> I think it is a lot closer to "impossible" than just "unlikely".
>>> malloc doesn't fail in this sort of context, the OOM killer kills something
>>> off instead.
>>> My personal preference is to replace all malloc/calloc/strdup calls with
>>> the xmalloc, xstrdup etc calls in support/nfs/xcommon.c.
>>> If you are worried about malloc failing, I'd much prefer to see a patch which
>>> changes nfs-utils to use those uniformly.
>>> 
>>> There might be a question over the best behaviour for daemons like mountd
>>> and  gssd.  However as we move towards having systemd manage those, they will
>>> be restarted if they ever exit, and they are mostly stateless so that is
>>> quite safe.
>>> 
>>> Does anyone else have thoughts on this?
>> 
>> Yes.  My thought is "xmalloc is an abomination."  :-)
>> 
>> We really do not want any of these tools exiting left if there's a memory allocation failure.  
>> For a user, that's no better than a segfault.
> I the past I have agreed with this... But as Neil points out, we now live in
> a systemd world were daemons are restarted, so maybe it does make sense to 
> exit on these types of failures. With daemons like mountd there is 
> really no state that would be lost.... 

Neil's arguments are very practical, but ...

There are other reasons that malloc() can fail.  Software bugs are high on that list.  It can also fail if user input (or network input) is used to determine the requested allocation size.

In addition, rpmlint/fedpkg-lint complain if there's an exit(2) call in your linked libraries.  They would frown on xmalloc() invoking exit (they also aren't happy with xlog).

Whether or not it's OK for daemons, I still maintain that for administrative tools run directly by users like exportfs, we want to be more careful.  Since the daemons share the same libraries as the user tools, that means xmalloc and friends should be avoided everywhere, IMO.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



