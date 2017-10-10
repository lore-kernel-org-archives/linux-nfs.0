Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:52797 "EHLO
        mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934519AbdJJUCn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Oct 2017 16:02:43 -0400
MIME-Version: 1.0
In-Reply-To: <20171010192706.GA18513@fieldses.org>
References: <20171010182425.GA19163@fieldses.org> <CA+55aFz5vGYnwzZ5mMQz5PXXRaMd3RaDF_fe11WKRDzWJCahJQ@mail.gmail.com>
 <20171010192706.GA18513@fieldses.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 10 Oct 2017 13:02:41 -0700
Message-ID: <CA+55aFzveh=26KxyPfnHiQc6w_Z6bSUfBwYgC7GYotgDsTrzgg@mail.gmail.com>
Subject: Re: [GIT PULL] nfsd changes for 4.14-rc
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 10, 2017 at 12:27 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>
> I just deleted redid the tag with the same name.  (Does it cause a
> problem that the old object is still sitting around somewhere with the
> same name but nothing pointing at it?  I'm assuming not.)

Thanks, that worked fine.

                   Linus
