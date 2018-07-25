Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:36478 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729187AbeGYTgG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jul 2018 15:36:06 -0400
MIME-Version: 1.0
References: <7828.1532527332@warthog.procyon.org.uk> <CA+55aFy2v3OW+mmSDF4MPWW673WsJEdQef3LChWg5k9=_k9ggg@mail.gmail.com>
 <25183.1532542685@warthog.procyon.org.uk>
In-Reply-To: <25183.1532542685@warthog.procyon.org.uk>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 25 Jul 2018 11:23:03 -0700
Message-ID: <CA+55aFwvKerkzigZmm0zrUTnsqDpJs0XBtX72Ltmek+_ic-KmA@mail.gmail.com>
Subject: Re: [GIT PULL] fscache and cachefiles fixes
To: David Howells <dhowells@redhat.com>
Cc: kiran.modukuri@gmail.com, linux-cachefs@redhat.com,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 25, 2018 at 11:18 AM David Howells <dhowells@redhat.com> wrote:
>
> Linus Torvalds <torvalds@linux-foundation.org> wrote:
>
> > Why do they have commit times literally *minutes* before your email to
> > ask me to pull?
>
> I split the first patch into two because it had two more-or-less independent
> changes and it made it easier to describe them separately.

This didn't explain the background before that happened.

I really want the warm and fuzzies about things, and when I see
something being changed just minutes before, something like

  "I did a rebase becasue XYZ, but this was around in linux-next for a
week before that without problems"

tells me not only why the times are so recent, but also tells me that
I really shouldn't worry because so-and-so.

                  Linus
