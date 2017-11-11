Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:47169 "EHLO
        mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751690AbdKKRbf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 11 Nov 2017 12:31:35 -0500
MIME-Version: 1.0
In-Reply-To: <CAGXu5jL83V7hSpVLT69UTfgh3XkOsJw-S7Wc9_PQP7zGc8__rg@mail.gmail.com>
References: <a17842c3-aae7-da98-424e-4441dd727e6d@gentoo.org>
 <CA+55aFzGDyeJctD5Y3paBnysWXbA0cMF1_7mvvzG3n2OAnNhHw@mail.gmail.com>
 <20171109193715.GB21978@ZenIV.linux.org.uk> <40ad7c6e-f0d7-959a-bf29-d3e3843f5d31@gentoo.org>
 <CA+55aFwqUbd5xVno7tH+yYD=yeu4nBdY=mpZQ+3fA0OEPS_WtQ@mail.gmail.com>
 <23f7da04-95f7-24e7-ee70-ce40c5b8fee3@gentoo.org> <CA+55aFx63wq=qN0+P+S-aahq7HzvYLi1tSxhPT9x78E8BrMNGQ@mail.gmail.com>
 <67939ef3-29c6-762c-7afe-46cc69630d95@gentoo.org> <ab1a286f-73dc-01aa-d797-0fef82534911@gentoo.org>
 <CA+55aFxw-ycca8+9ywckyXxH4dTggLJi5hXGdJtCQocjM86f5g@mail.gmail.com> <CAGXu5jL83V7hSpVLT69UTfgh3XkOsJw-S7Wc9_PQP7zGc8__rg@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 11 Nov 2017 09:31:34 -0800
Message-ID: <CA+55aFytWtipkgGtkZgzRTQqLPxG+QzJ2K9+oFdo9NVNXxB69g@mail.gmail.com>
Subject: Re: [nfsd4] potentially hardware breaking regression in 4.14-rc and 4.13.11
To: Kees Cook <keescook@chromium.org>
Cc: Patrick McLean <chutzpah@gentoo.org>,
        Emese Revfy <re.emese@gmail.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Bruce Fields <bfields@redhat.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        stable <stable@vger.kernel.org>,
        Thorsten Leemhuis <regressions@leemhuis.info>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Boris Lukashev points out that Patrick should probably check a newer
version of gcc.

I looked around, and in one of the emails, Patrick said:

  "No changes, both the working and broken kernels were built with
   distro-provided gcc 5.4.0 and binutils 2.28.1"

and gcc-5.4.0 is certainly not very recent. It's not _ancient_, but
it's a bug-fix release to a pretty old branch that is not exactly new.

It would probably be good to check if the problems persist with gcc
6.x or 7.x.. I have no idea which gcc version the randstruct people
tend to use themselves.

               Linus


On Sat, Nov 11, 2017 at 8:13 AM, Kees Cook <keescook@chromium.org> wrote:
>
> I'll take a closer look at this and see if I can provide something to
> narrow it down.
