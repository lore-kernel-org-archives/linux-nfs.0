Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:46587 "EHLO
        mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932225AbdJJSmC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Oct 2017 14:42:02 -0400
MIME-Version: 1.0
In-Reply-To: <20171010182425.GA19163@fieldses.org>
References: <20171010182425.GA19163@fieldses.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 10 Oct 2017 11:42:01 -0700
Message-ID: <CA+55aFz5vGYnwzZ5mMQz5PXXRaMd3RaDF_fe11WKRDzWJCahJQ@mail.gmail.com>
Subject: Re: [GIT PULL] nfsd changes for 4.14-rc
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 10, 2017 at 11:24 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> Please pull nfsd fixes from
>
>   git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.14-1

There's nothing there. That tag just points to my 4.14-rc1 commit.

> One fix for a 4.14 regression, and one minor fix to the MAINTAINERs
> file. (I was weirdly flattered by the idea that lots of random people
> suddenly seemed to think Jeff and I were VFS experts.  Turns out it was
> just a typo.)

.. and there's also no diffstat and commit list in your pull request,
probably exactly because you screwed up the tag so there's nothing to
pull..

                    Linus
