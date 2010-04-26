Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:62915 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752191Ab0DZPNG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Apr 2010 11:13:06 -0400
Message-ID: <4BD5AD68.6010200@oracle.com>
Date: Mon, 26 Apr 2010 11:12:40 -0400
From: Chuck Lever <chuck.lever@oracle.com>
To: Mike Frysinger <vapier@gentoo.org>
CC: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] make capabilities support optional
References: <1271753213-17374-1-git-send-email-vapier@gentoo.org> <201004231529.42370.vapier@gentoo.org> <4BD1FE77.1050000@oracle.com> <201004240042.27705.vapier@gentoo.org>
In-Reply-To: <201004240042.27705.vapier@gentoo.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 04/24/2010 12:42 AM, Mike Frysinger wrote:
> On Friday 23 April 2010 16:09:27 Chuck Lever wrote:
>> On 04/23/2010 03:29 PM, Mike Frysinger wrote:
>>> On Friday 23 April 2010 15:12:33 Chuck Lever wrote:
>>>> If we really do need to drop libcap for some configurations, then such a
>>>> change should be thoroughly tested in those environments.  Some features
>>>> won't always work without libcap, and appropriate warnings should be
>>>> added to man pages and/or should be displayed by statd.
>>>
>>> there should be appropriate documentation regardless.  current nfs-utils
>>> lists no information at all in ChangeLog/NEWS/README/INSTALL or any
>>> other document explaining why/what/how libcap is needed/used.  you cant
>>> do documentless dumps on distro maintainers and expect them to "just
>>> know" what is going on.
>>
>> "git log" has served as the ChangeLog for some time now.  The commits I
>> referenced in my last e-mail explain exactly why libcap was introduced.
>
> none of the scm metadata is relevant to distro maintainers.  that info is fine
> for developers of nfs-utils, but that's it.

Obviously, that metadata _is_ relevant to distro maintainers, as your 
example shows.  The nfs-utils ChangeLog is an exact copy of the the git 
log (up to about mid 2006).  Why keep an extra copy?

However, as soon as a distributor sends patches (rather than, say, 
simply posting a bug report), you become a developer, and are thus 
obligated to act like one by reviewing the content of the local source 
management system before making changes, and by posting your patches to 
this list for us to review.

> people attempting to package nfs-
> utils shouldnt need to crawl these backends to try and glean info themselves.

As I pointed out, you don't need git on your local system to look at 
this metadata: it's already available on linux-nfs.org if you have a web 
browser.

>> Patches are posted on this mailing list for review before they are
>> committed.  Anyone has a chance to object, comment, or suggest a simpler
>> way to do things.
>
> again, this isnt relevant to distro maintainers.

How are nfs-utils developers supposed to know of a problem if distro 
maintainers don't tell us?

I specifically asked on this list about libcap before adding it.  We've 
been discussing the addition of libsqlite and libtirpc as well, and I 
specifically requested feedback from distributors.  There was no 
response.  So how are we supposed to know these are problems?  Where 
else should I have asked this question?

>> It's important to realize that it's much harder to make things optional
>> than to insist that they be built in.  Adding build options means
>> there's more work for distributors to configure the build, and it
>> exponentially increases our test matrix (which is already out of
>> control).  Every change now has to be tested with each combination of
>> build options.  Add one more --enable option, and that doubles the
>> number of combinations.
>
> hardcoding optional features in autotools is worse for distro maintainers than
> proper optional configure flags.  dont kid yourself in this regard.

>> I didn't see a clear explanation of why your proposed change was
>> necessary, nor was it clear from the patch description that you
>> understood why libcap was added in the first place, nor does it seem
>> that the regressions caused by disabling libcap are adequately addressed.
>
> things worked before libcap was introduced, so clearly it's possible.  it may
> be reduced security footprint, but plenty of people are fine with it.

I claim that "things" did not work.  When statd was shut down, it left a 
dangling rpcbind registration, and that's a bug in all environments.

If my bug fix is not complete or is inappropriate for some environments, 
then we should have a discussion about that.  It's pretty hard to tell 
what you were trying to address from your patch description (and that's 
all I have right now because the actual patch was never publicly posted).

>> So, why do you want to make libcap optional?
>
> there are plenty of systems where privileges are meaningless (like embedded)
> and so libcap is pure cruft.

In that case, your patch description should explain that so we can 
understand why you've added another --enable switch.  These switches are 
overused, so a clear rationalization is needed when adding yet another.

By and large, those who participate on this list felt that "--enable" 
flags are less desirable than automatic feature checking.  Your view is 
novel, I think.

>> And why is yet another build option needed (rather than just using
>> AC_FUNCTIONS and HAVE_LIBCAP) ?
>
> magic detections are terrible for distro maintainers and one of the things we
> spend a lot of time fixing.

nfs-utils uses autotools, so that's what we have.  How else should it be 
done?

-- 
chuck[dot]lever[at]oracle[dot]com
