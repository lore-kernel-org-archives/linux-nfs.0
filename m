Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32978 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751554AbeB0WAw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 27 Feb 2018 17:00:52 -0500
Subject: Re: [PATCH 1/1] mount.nfs: minorversion setting is being ignored with
 -t flag
To: NeilBrown <neilb@suse.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20180226191542.31447-1-steved@redhat.com>
 <20180226191542.31447-2-steved@redhat.com>
 <87zi3vgoza.fsf@notabene.neil.brown.name>
 <517662da-56b9-5a41-7e3f-25431ced819b@RedHat.com>
 <87woyygnuq.fsf@notabene.neil.brown.name>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <eccb6c11-402d-4af5-cd39-70f93bed79bf@RedHat.com>
Date: Tue, 27 Feb 2018 17:00:51 -0500
MIME-Version: 1.0
In-Reply-To: <87woyygnuq.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/27/2018 03:49 PM, NeilBrown wrote:
> On Tue, Feb 27 2018, Steve Dickson wrote:
>> Question, do packages like glibc have these types of policies?
> 
> glibc documents in README the minimum kernel version.
> In Apr 2014 it was raised to 2.6.32.
> In Map 2017 it was raised to 3.2
> Though some archs have different rules
>   git grep arch_minimum_kernel sysdeps
> in the glibc source.
> 
> systemd also sets a minimum, currently:
> REQUIREMENTS:
>         Linux kernel >= 3.13
>         Linux kernel >= 4.2 for unified cgroup hierarchy support
> 
> according to README.
> 
> So if we want to require 3.5 or later, then I have not problem with
> that.
> I just think it should be clearly announced in the git commit, and
> documented in a README or similar.
Thanks for pointing this out... 

I'm thinking we should probably create this kernel requirement
once the option is deprecated... 

Since the precedent has already been set to check the kernel version in 
the mounting code, I'm going to use that to fix the bug, so I can back 
port the fix to other releases... 

Again, thanks for the info and the suggestions! 

steved.
