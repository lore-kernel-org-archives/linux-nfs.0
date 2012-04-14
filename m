Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f174.google.com ([209.85.214.174]:54342 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751324Ab2DNA66 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Apr 2012 20:58:58 -0400
Received: by obbta14 with SMTP id ta14so1293554obb.19
        for <linux-nfs@vger.kernel.org>; Fri, 13 Apr 2012 17:58:57 -0700 (PDT)
Message-ID: <4F88CBCE.9060208@gmail.com>
Date: Fri, 13 Apr 2012 19:58:54 -0500
From: Calvin Owens <jcalvinowens@gmail.com>
MIME-Version: 1.0
To: Dave Quigley <dpquigl@davequigley.com>
CC: "Myklebust, Trond" <trond.myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [GSoC Project] Implementing NFS v4.2
References: <4F7E32D4.3030201@gmail.com> <1333682276.4792.32.camel@lade.trondhjem.org> <4F837E87.3070204@gmail.com> <b4c5095c047099c1c299345e174c9476@countercultured.net> <4F84C2FA.20700@gmail.com> <4F8672ED.10901@davequigley.com>
In-Reply-To: <4F8672ED.10901@davequigley.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/12/2012 01:15 AM, Dave Quigley wrote:
> On 4/10/2012 7:32 PM, Calvin Owens wrote:
>> On 04/09/2012 07:34 PM, David Quigley wrote:
>>> On 04/09/2012 20:27, Calvin Owens wrote:
>>>> On 04/05/2012 10:17 PM, Myklebust, Trond wrote:
>>>>> On Thu, 2012-04-05 at 19:03 -0500, Calvin Owens wrote:
>>>>>> Hello all,
>>>>>>
>>>>>> I'm interested in implementing the draft specification for NFS v4.2
>>>>>> as a
>>>>>> Google Summer of Code project. That includes server-side copying,
>>>>>> sparse
>>>>>> files, and carrying fadvise() calls through to the server, among other
>>>>>> things.
>>>>>>
>>>>>> The current document can be found here:
>>>>>> http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion2-07
>>>>>>
>>>>>> Is this something that you need to be done? If so, I'd very much
>>>>>> like to
>>>>>> be involved. :)
>>>>>
>>>>> Hi Calvin,
>>>>>
>>>>> Labelled NFS is likely to be merged into 3.5 (if Dave Q finds the time
>>>>> to port his existing code).
>>>>>
>>>>> Copy offload already exists in prototype form. The main remaining issue
>>>>> is working out the user syscall interface, which really requires
>>>>> getting
>>>>> all the interested filesystem maintainers to agree (we've started on
>>>>> doing that).
>>>>>
>>>>> If you'd like to contribute, then I'd suggest looking into SEEK (for
>>>>> providing lseek(SEEK_HOLE/SEEK_DATA) support. There is also the hole
>>>>> punching/space reservation, that should fit nicely into the fallocate()
>>>>> system call.
>>>>
>>>> Yes, that sounds good. I'll start looking into that.
>>>>
>>>>> The efficient sparse file read and fadvise support might be nice too,
>>>>> but I'd like to see numbers for how they improve matters before I feel
>>>>> comfortable saying yea or nay to adding those specific features.
>>>>
>>>> I definitely see your point. It does seem to be a lot of added
>>>> complexity for a negligible benefit.
>>>>
>>>>> Note that there are also a bunch of NFSv4.1 features that have yet
>>>>> to be
>>>>> implemented, so the above list of tasks is not exhaustive. I'd be happy
>>>>> to work with you to find something...
>>>>
>>>> What else, precisely, would you like to get done? I need to get some
>>>> more detailed objectives to put into my application. (Forgive me for
>>>> so blatantly not looking myself, but it seems more efficient than me
>>>> digging through the code finding missing features and lobbing them at
>>>> you for approval, when I'm sure you know exactly where your priorities
>>>> are...)
>>>>
>>>> Thanks very much,
>>>> Calvin Owens
>>>> -- 
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at http://vger.kernel.org/majordomo-info.html
>>>
>>> Finishing up the port of Labeled NFS would be some low hanging fruit if
>>> someone wants to help tackle it. I'll be trying to find time to work on
>>> it but its unclear how soon I'll be able to get around to it.
>>>
>>> Dave
>>
>> Okay. I took a look at your lnfs git tree - just to make sure I
>> understand: the patchset was originally against 2.6.33, and you're
>> working to make it apply to the current kernel, with the same
>> functionality? And stuff has changed enough since then that it's not
>> trivial? Or am I completely missing the point?
>>
>> Thanks,
>> Calvin Owens
>> -- 
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at http://vger.kernel.org/majordomo-info.html
>>
> 
> Sorry I somehow completely missed this email. The latest tree should be against 3.2 or something like that. Currently there is an issue where I couldn't port one of the parts over in lookup (see a previous email I sent to trond on list for the details). Once that issue is fixed I would assume the forward port to 3.5 would be mostly trivial.
> 
> The Labeled NFS tree is managed as two git trees for people's convenience. The tree listed first below [1] is the guilt patch set which I keep track of. The second tree is a git tree which has had the patches applied to it[2]. The tree currently has a v3.2-lnfs branch which needs the one fix figured out. The way I do development is to check out the kernel tag and the patch-set and just work from there.
> 
> Another issue is that currently, SELinux is really the only thing you can use to test Labeled NFS. I have a setup script which should give a small test environment to mess around with as well. If you're not familiar with SELinux I can help you with that part as well.
> 
> If you find this interesting and want to try to fix the issue and do the forward port I'd be glad to help you. It would be nice to get these changes upstream.
> 
> 
> [1] http://git.selinuxproject.org/git/?p=users/dpquigl/lnfs-patchset/.git;a=summary
> [2] http://git.selinuxproject.org/git/?p=users/dpquigl/lnfs/.git;a=summary
> 
> Dave

Well, after spending some time looking at it, I think it's probably better left to somebody more familiar with SELinux... I have absolutely no experience with it whatsoever.

Thanks very much for the info though.

Calvin
