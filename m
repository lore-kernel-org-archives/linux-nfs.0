From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] make capabilities support optional
Date: Mon, 26 Apr 2010 12:10:00 -0400
Message-ID: <4BD5BAD8.5040209@RedHat.com>
References: <1271753213-17374-1-git-send-email-vapier@gentoo.org> <4BD1CADD.4050200@RedHat.com> <4BD1D8AA.4030708@oracle.com> <4BD1E55B.2090703@RedHat.com> <4BD1F121.1060001@oracle.com> <4BD21DA1.4000001@RedHat.com> <4BD5B013.9060705@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Mike Frysinger <vapier@gentoo.org>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40330 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753458Ab0DZQKN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Apr 2010 12:10:13 -0400
In-Reply-To: <4BD5B013.9060705@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/26/2010 11:24 AM, Chuck Lever wrote:
> On 04/23/2010 06:22 PM, Steve Dickson wrote:
>>> As an aside, the patch description is where we should be documenting the
>>> thinking behind these decisions in an audit-able and transparent manner.
>>>   The description for this patch doesn't have a strong justification
>>> IMHO.  It would be hard for any of us to come back to this patch a year
>>> from now and figure out exactly why this change was made.  (I say this
>>> having spent the last year doing just that for a long history of patches
>>> to statd and mount).
>> True, the patch description could have been a bit more verbose, but I
>> feel I understood the reason for the patch and that reason the made
>> sense to me...
> 
> The problem is that this patch was never posted publicly, so you were
> the only reviewer.  The rest of us have no idea what this is about.
Well here is where I got the patch: 
    http://marc.info/?l=linux-nfs&m=127175324400983&w=2
off the mailing list.

> 
>> I feel backwards compatibility is important..
> 
> Sure, but this isn't necessarily the way to go about it, in this case.
> It's hard to know though, since the patch description was vague, and the
> patch itself was never publicly posted.
I agree the description was a bit vague, but the patch was posted 
publicly... 

>> Well dropping libcap is not the default and I don't see us (i.e.
>> upstream)
>> ever making it the default... If people want set that config flag, its
>> up to
>> them to document the ramifications, IMHO...
> 
> Er, I think it _is_ up to us chickens to document the ramifications.  If
> some new --enable flag just shows up on ./configure, how am I going to
> know whether I should set it or not?  
Hopefully the setting of an configure flag would come out in the 
discussion about the problem... Any changing of default values,
especially ones that will cause a recompile needed to be 
relayed early in any bug discussion... 

> 
> Now that we've answered the question of "why are we doing this," the
> question in my mind is how we want statd to behave if libcap isn't
> available.
> 
> At the very least, I think the man page should mention this bug somehow,
> and maybe a warning should be generated during the build.  Since this is
> mostly for embedded systems, according to Mike, I doubt an actual
> generated run-time warning would be visible to anyone.
> 
Mike would you be willing to test this out and document any
differences in statd behaviour with and without that config
flag set?

steved.
