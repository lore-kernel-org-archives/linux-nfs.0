Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:33754 "EHLO
        mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753502AbdGUXhj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Jul 2017 19:37:39 -0400
MIME-Version: 1.0
In-Reply-To: <d339dd77-a96c-ad9a-17e2-7dacdfd2eb67@Netapp.com>
References: <d339dd77-a96c-ad9a-17e2-7dacdfd2eb67@Netapp.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 21 Jul 2017 16:37:38 -0700
Message-ID: <CA+55aFz9uu+HUVdvy_zWuPmcPymdw8KLpdnPbFvoH5vyW=bQHw@mail.gmail.com>
Subject: Re: [GIT PULL] Please pull NFS client fixes for 4.13
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 21, 2017 at 1:34 PM, Anna Schumaker
<Anna.Schumaker@netapp.com> wrote:
>
> gpg claims it was able to sync my key with the keyserver, so hopefully
> you're able to update it now.

I can see the updated key, yes.

However, this:

> Peng Tao (1):
>       nfs: add export operations

and probably a couple of other ones too are already in my tree, except
as different commits.

So now I have that twice. It merged fine, but why did that patch get
applied to two different trees?

The one I got from you in this pull request is this one:

    00422483ad41 nfs: add export operations

and the one I got in your *previous* pull request is this one:

    20fa19027286 nfs: add export operations

so you have screwed up something. That thing already came in through
that nfs-for-4.13-1 branch during the merge window.

I'll let it slide this time, BUT STOP REBASING YOUR BRANCHES!

                           Linus
