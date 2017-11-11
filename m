Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:60754 "EHLO smtp.gentoo.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754143AbdKKA1k (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 10 Nov 2017 19:27:40 -0500
Subject: Re: [nfsd4] potentially hardware breaking regression in 4.14-rc and
 4.13.11
From: Patrick McLean <chutzpah@gentoo.org>
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
 <23f7da04-95f7-24e7-ee70-ce40c5b8fee3@gentoo.org>
 <CA+55aFx63wq=qN0+P+S-aahq7HzvYLi1tSxhPT9x78E8BrMNGQ@mail.gmail.com>
 <67939ef3-29c6-762c-7afe-46cc69630d95@gentoo.org>
Message-ID: <ab1a286f-73dc-01aa-d797-0fef82534911@gentoo.org>
Date: Fri, 10 Nov 2017 16:27:37 -0800
MIME-Version: 1.0
In-Reply-To: <67939ef3-29c6-762c-7afe-46cc69630d95@gentoo.org>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2017-11-10 03:26 PM, Patrick McLean wrote:
> 
> 
> On 2017-11-10 10:42 AM, Linus Torvalds wrote:
>> On Thu, Nov 9, 2017 at 5:58 PM, Patrick McLean <chutzpah@gentoo.org> wrote:
>>>
>>> Something must have changed since 4.13.8 to trigger this though.
>>
>> Arnd pointed to some commits that might be relevant for the cp210x
>> module, but those are all already in 4.13.8, so if 4.13.8 really is
>> rock solid for you, I don't think that's it.
>>
>> I really don't see anything that looks even half-way suspicious in
>> that 4.13.8..11 range. But as mentioned, compiler interactions can be
>> _really_ subtle.
>>
>> And hey, it can be a real kernel bug too, that just happens to be
>> exposed by RANDSTRUCT, so a bisect really would be very nice.
> 
> I am working on bisecting the issue now, but I think I have some more
> evidence pointing to a compiler issue related to RANDSTRUCT. There are
> actually 3 issues that we have seen. Sometimes we get the null pointer
> deref in the initial message, sometimes we get the GPF, and sometimes we
> see an issue where the NFS clients see all files as root-owned
> directories. Any given kernel will always see the same issue, but after
> a "make mrproper" and recompile (with the same .config), the issue will
> often change. I suspect that all 3 of these problems are actually the
> same issue manifesting itself in different ways depending on what seed
> the RANDSTRUCT gcc plugin is using.
> 

Further update on this, using the same seed for RANDSTRUCT, I have
reproduced this issue on v4.13.0, so it does not seem to be recently
introduced. The older kernel apparently only worked for us because we
were lucky. Generally we always compile new kernels from a fresh tree,
so they are never using the same seed.

In case someone wants to play with this, here are some interesting seeds
(in include/generated/randomize_layout_hash.h):

Produce a NULL pointer dereference (though I am not sure what the client
does to produce this).
    5970d6494d0f4236ec57147a46e700f4f501536236d96f6f68ea223e06a258bc

All files for nfsd4 clients appear as directories owned as root, no
matter the real owner (this happens for all clients we have tested):
    3f158cd1014800ce5eb6c1f532ac64f2357fdb9a684096557d2fbb1d281f325e

This is the seed that was breaking motherboards (make sure you have a
way to flash the BIOS with this one):
    3e32f2d1b4a3dde9f2fd95151386cd1d5bd6167597a0b868f6273aabfc5712dd

Finally, here is a seed that produces a kernel that does not exhibit any
problems we are aware of:
    e8698c12137fcd1dcbff6d1ed97e5d766128447a27ce9f9d61e0cb8c05ad4d3b

>>
>> Because in the end, compiler bugs are very rare. They are particularly
>> annoying when they do happen, though, so they loom big in the mind of
>> people who have had to chase them down.
>>
