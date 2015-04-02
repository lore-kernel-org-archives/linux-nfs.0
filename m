Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:36348 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750747AbbDBRiT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2015 13:38:19 -0400
MIME-Version: 1.0
In-Reply-To: <21857.1427983172@warthog.procyon.org.uk>
References: <21857.1427983172@warthog.procyon.org.uk>
Date: Thu, 2 Apr 2015 10:38:18 -0700
Message-ID: <CA+55aFx0oT8hPvZMQkTSufK4yNUC+Oo3wU17fM3ETO=6NnwOSw@mail.gmail.com>
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

On Thu, Apr 2, 2015 at 6:59 AM, David Howells <dhowells@redhat.com> wrote:
>
> Could you pull these FS-Cache fixes please?

I really think this is out of the merge window, and not at all appropriate.

There have been no fscache changes since September of last year, it
can't suddenly be so urgent that you need to get things into -rc7.

                         Linus
