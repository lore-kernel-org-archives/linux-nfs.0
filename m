Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:39126 "EHLO smtp.gentoo.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755639AbdKJB64 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Nov 2017 20:58:56 -0500
Subject: Re: [nfsd4] potentially hardware breaking regression in 4.14-rc and
 4.13.11
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
        Bruce Fields <bfields@redhat.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        stable <stable@vger.kernel.org>,
        Thorsten Leemhuis <regressions@leemhuis.info>
References: <a17842c3-aae7-da98-424e-4441dd727e6d@gentoo.org>
 <CA+55aFzGDyeJctD5Y3paBnysWXbA0cMF1_7mvvzG3n2OAnNhHw@mail.gmail.com>
 <20171109193715.GB21978@ZenIV.linux.org.uk>
 <40ad7c6e-f0d7-959a-bf29-d3e3843f5d31@gentoo.org>
 <CA+55aFwqUbd5xVno7tH+yYD=yeu4nBdY=mpZQ+3fA0OEPS_WtQ@mail.gmail.com>
From: Patrick McLean <chutzpah@gentoo.org>
Message-ID: <23f7da04-95f7-24e7-ee70-ce40c5b8fee3@gentoo.org>
Date: Thu, 9 Nov 2017 17:58:53 -0800
MIME-Version: 1.0
In-Reply-To: <CA+55aFwqUbd5xVno7tH+yYD=yeu4nBdY=mpZQ+3fA0OEPS_WtQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2017-11-09 12:04 PM, Linus Torvalds wrote:
> On Thu, Nov 9, 2017 at 11:51 AM, Patrick McLean <chutzpah@gentoo.org> wrote:
>>
>> We do have CONFIG_GCC_PLUGIN_STRUCTLEAK and
>> CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF_ALL enabled on these boxes as well as
>> CONFIG_GCC_PLUGIN_RANDSTRUCT as you pointed out before.
> 
> It might be worth just verifying without RANDSTRUCT in particular.
> 
> And most obviously: if there is some module or part of the kernel that
> got compiled with a different seed for the randstruct hashing, that
> will break in nasty nasty ways. Your out-of-kernel module is the
> obvious suspect for something like that, but honestly, it could be
> some missing build dependency, or simply a missing special case in the
> plugin itself a missing __no_randomize_layout or any number of things.
> 

We will check our fork against the in-kernel cp201x driver to make sure
we didn't miss anything, but it seems odd we would be hitting the issue
so consistently in the NFS code path, rather than somewhere in USB,
serial, or GPIO paths.

> So since you seem to be able to reproduce this _reasonably_ easily,
> it's definitely worth checking that it still reproduces even without
> the gcc plugins.

I haven't been able to reproduce it with RANDSTRUCT disabled (and
structleak enabled). I will keep trying for a little while more, but
evidence seems to be pointing to that.

Something must have changed since 4.13.8 to trigger this though. This
did not crop up at all until we tried 4.13.11, where it we saw it pretty
quickly. We have a pretty large number of machines running 4.13.6 with
RANDSTRUCT enabled and running a the same workload with many more
clients, and have not seen this bug at all.
