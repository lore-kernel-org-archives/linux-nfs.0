From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] nfs-utils: Removed a number of warn_unused_result warnings
Date: Wed, 25 Mar 2009 10:39:45 -0400
Message-ID: <49CA4231.3050303@RedHat.com>
References: <49C797C6.8030102@RedHat.com> <654687AD-E743-45A4-99B1-BBBEAA5D915D@oracle.com> <49C910C3.2090700@RedHat.com> <74BEB80C-976E-48D5-B356-16534F210209@oracle.com> <49C91A2F.90501@RedHat.com> <44414CBB-0EF8-4B6E-A972-D4500440128B@oracle.com> <49C91DB7.1050006@RedHat.com> <693939BC-0ED1-4224-BD5A-20F7F4D29D8B@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:55614 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751135AbZCYOmh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Mar 2009 10:42:37 -0400
In-Reply-To: <693939BC-0ED1-4224-BD5A-20F7F4D29D8B@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> On Mar 24, 2009, at 1:51 PM, Steve Dickson wrote:
>> Chuck Lever wrote:
>>>>>>> Also, note that you can use the "%m" format specifier to generate
>>>>>>> the
>>>>>>> same string you get from strerror(errno).
>>>>>> Yeah.. I knew that... but I thought there some memory corruption
>>>>>> or service denial issue with using "%m" so I've always stuck
>>>>>> with '%d (%s)'.
>>>>>
>>>>> I use %m routinely.  What exactly are these issues?
>>>> It was a while ago... but I seem to remember there as an issue
>>>> with one of the daemons using '%m'.. I want to say a buffer overflow
>>>> but I just don't remember... It was probably some funky way '%m'
>>>> was being used...since I sure the normal every day use of '%m"
>>>> is fine...
>>>
>>> I'm not a security expert, but I can't see how that could be a problem
>>> for generating log messages (especially any message that precedes a
>>> daemon's exit).  I'd like to continue using "%m" with xlog() in my own
>>> patches for the time being.  Is that OK with you?
>> Sure.. I have no problem with that...
> 
> Hey Steve, it looks like you're dropping short descriptions again when
> committing patches.  The last two patches in the nfs-utils repo don't
> have short descriptions.  Jeff's patch description doesn't make too much
> sense without the short description.
Yeah I noticed that after I did the commit... I didn't think it was worth 
going back and redoing the commit just to added that line.... The code
in Jeff's patches are pretty straightforward so I'm thinking it will
not take to much to understand what he was doing... 

steved.

