Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:35960 "EHLO
        mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1161070AbdKRAzj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Nov 2017 19:55:39 -0500
MIME-Version: 1.0
In-Reply-To: <b2b323ae-447c-c44f-32a7-d9c1381545bf@gentoo.org>
References: <a17842c3-aae7-da98-424e-4441dd727e6d@gentoo.org>
 <CA+55aFzGDyeJctD5Y3paBnysWXbA0cMF1_7mvvzG3n2OAnNhHw@mail.gmail.com>
 <20171109193715.GB21978@ZenIV.linux.org.uk> <40ad7c6e-f0d7-959a-bf29-d3e3843f5d31@gentoo.org>
 <CA+55aFwqUbd5xVno7tH+yYD=yeu4nBdY=mpZQ+3fA0OEPS_WtQ@mail.gmail.com>
 <23f7da04-95f7-24e7-ee70-ce40c5b8fee3@gentoo.org> <CA+55aFx63wq=qN0+P+S-aahq7HzvYLi1tSxhPT9x78E8BrMNGQ@mail.gmail.com>
 <67939ef3-29c6-762c-7afe-46cc69630d95@gentoo.org> <ab1a286f-73dc-01aa-d797-0fef82534911@gentoo.org>
 <CA+55aFxw-ycca8+9ywckyXxH4dTggLJi5hXGdJtCQocjM86f5g@mail.gmail.com>
 <CAGXu5jL83V7hSpVLT69UTfgh3XkOsJw-S7Wc9_PQP7zGc8__rg@mail.gmail.com>
 <CA+55aFytWtipkgGtkZgzRTQqLPxG+QzJ2K9+oFdo9NVNXxB69g@mail.gmail.com>
 <3d948180-6bd7-c4e9-5ac8-5baef9cc15a7@gentoo.org> <CAGXu5jJBnJEPoUMQJTxxHXtHEUhpvq75xqzVdXsY5cKuHoe5Mg@mail.gmail.com>
 <09f2480f-e8e8-645b-6d94-b6ae4ca47806@gentoo.org> <CAGXu5jK=_BAKAAyhNms0MddJWPsLV2f78UWdnkxcSErmruhtNw@mail.gmail.com>
 <b2b323ae-447c-c44f-32a7-d9c1381545bf@gentoo.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 17 Nov 2017 16:55:37 -0800
Message-ID: <CA+55aFwSfaqGN1R=N0c8fyFe-oengamdkTtnyomcCwG7f3HU5Q@mail.gmail.com>
Subject: Re: [nfsd4] potentially hardware breaking regression in 4.14-rc and 4.13.11
To: Patrick McLean <chutzpah@gentoo.org>
Cc: Kees Cook <keescook@chromium.org>,
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

On Fri, Nov 17, 2017 at 4:27 PM, Patrick McLean <chutzpah@gentoo.org> wrote:
>
> I am still getting the crash at d9e12200852d, I figured I would
> double-check the "good" and "bad" kernels before starting a full bisect.

.. but without GCC_PLUGIN_RANDSTRUCT it's solid?

Kees removed even the baseline "randomize pure function pointer
structures", so at that commit, nothing should be randomized.

But maybe the plugin code itself ends up confusing gcc somehow?

Even when it doesn't actually do that "relayout_struct()" on the
structure, it always does those TYPE_ATTRIBUTES() games.

               Linus
