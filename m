Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:35419 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751437AbbDBSeY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2015 14:34:24 -0400
MIME-Version: 1.0
In-Reply-To: <27322.1427999073@warthog.procyon.org.uk>
References: <21857.1427983172@warthog.procyon.org.uk>
	<CA+55aFx0oT8hPvZMQkTSufK4yNUC+Oo3wU17fM3ETO=6NnwOSw@mail.gmail.com>
	<27322.1427999073@warthog.procyon.org.uk>
Date: Thu, 2 Apr 2015 11:34:23 -0700
Message-ID: <CA+55aFzHy-zkyD4-rWh3DJsQ4+PFWeSAyxVQJHAUsj1qEURZiQ@mail.gmail.com>
Subject: Re: [GIT PULL] FS-Cache: Fixes for dead objects handling and
 operation cancellation
From: Linus Torvalds <torvalds@linux-foundation.org>
To: David Howells <dhowells@redhat.com>
Cc: linux-cachefs@redhat.com, linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 2, 2015 at 11:24 AM, David Howells <dhowells@redhat.com> wrote:
>
> We weren't looking at -rc7 shortly when I first posted a pull request.

Bah. It was already rc5 when the first pull request came, don't try to
make it sound like anything but "very late in the rc" game.

If there are any *stable* patches in there that actually confirm to
the stable rules, they'll be backported.

And as mentioned, the whole thing with "you haven't sent me anything
for over six months" means that I don't for a moment believe in any
"this is suddenly oh so very very urgent" crap.

                         Linus
