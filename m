Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40987 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751534AbbDBSYi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Apr 2015 14:24:38 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <CA+55aFx0oT8hPvZMQkTSufK4yNUC+Oo3wU17fM3ETO=6NnwOSw@mail.gmail.com>
References: <CA+55aFx0oT8hPvZMQkTSufK4yNUC+Oo3wU17fM3ETO=6NnwOSw@mail.gmail.com> <21857.1427983172@warthog.procyon.org.uk>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: dhowells@redhat.com, linux-cachefs@redhat.com,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [GIT PULL] FS-Cache: Fixes for dead objects handling and operation cancellation
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Thu, 02 Apr 2015 19:24:33 +0100
Message-ID: <27322.1427999073@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Linus Torvalds <torvalds@linux-foundation.org> wrote:

> > Could you pull these FS-Cache fixes please?
> 
> I really think this is out of the merge window, and not at all appropriate.
> 
> There have been no fscache changes since September of last year, it
> can't suddenly be so urgent that you need to get things into -rc7.

We weren't looking at -rc7 shortly when I first posted a pull request.  The
patchset does fix three oopses, but if you'd rather wait till the merge
window, fine.

David
