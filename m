Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:60336 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758609Ab3CYQvJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Mar 2013 12:51:09 -0400
Message-ID: <5150807B.2070402@RedHat.com>
Date: Mon, 25 Mar 2013 12:51:07 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Mike Frysinger <vapier@gentoo.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH [nfs-utils]] locktes/rpcgen: tweak how we override compiler
 settings
References: <1364163668-15490-1-git-send-email-vapier@gentoo.org> <51504638.8020408@RedHat.com> <201303251219.06502.vapier@gentoo.org>
In-Reply-To: <201303251219.06502.vapier@gentoo.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 25/03/13 12:19, Mike Frysinger wrote:
> On Monday 25 March 2013 08:42:32 Steve Dickson wrote:
>> On 24/03/13 18:21, Mike Frysinger wrote:
>>> Newer autotools will use both CFLAGS and <target>_CFLAGS when compiling
>>> the <target>.  Adding the build settings to the target-specific flags no
>>> longer works as a way to compile build-time tools.
>>>
>>> Instead, clobber the global flags.  This triggers an automake warning,
>>> but the end result actually works (unlike the existing code).
>>
>> This patch is causing the following warnings:
>> ...
>> You didn't see these in your testing?
> 
> in my summary:
> 
> 	Instead, clobber the global flags.  This triggers an automake warning,
> 	but the end result actually works (unlike the existing code).
Ok... I did miss that part of the summary... 

> 
>> Also what exactly broke that this patch fixes?
> 
> also in my summary:
> 
> 	Newer autotools will use both CFLAGS and <target>_CFLAGS when compiling
> 	the <target>.
> 
> so when you cross-compile (e.g. --build=x86_64-linux-gnu --host=arm-linux-
> gnu), and you set CFLAGS to include settings which are valid only for the host 
> (e.g. -mfloat-abi=hard -mfp=neon), those flags will also get passed to the build 
> compiler when compiling these tools and they'll error out (because the build 
> gcc doesn't recognize these flags).
And setting AM_CFLAGS does on take care of this problem...

I'm just trying to get rid of those warnings... 

steved.

