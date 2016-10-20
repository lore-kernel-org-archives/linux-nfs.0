Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:36829 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932213AbcJTQJl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Oct 2016 12:09:41 -0400
MIME-Version: 1.0
In-Reply-To: <20161020155231.GA4347@fieldses.org>
References: <1472557703-5985-1-git-send-email-jlayton@redhat.com>
 <CA+55aFzVnBqtk5Az3VNMQ=HfTUBSYyOVejHykU2c63K70s24=A@mail.gmail.com> <20161020155231.GA4347@fieldses.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 20 Oct 2016 09:09:40 -0700
Message-ID: <CA+55aFw8ERWE13OJ7ejx=g=C5K1BtwZXA92wO-iSmLHyt1fDpw@mail.gmail.com>
Subject: Re: [PATCH] nfsd: more robust allocation failure handling in nfsd_reply_cache_init
To: Bruce Fields <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Olaf Hering <olaf@aepfle.de>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 20, 2016 at 8:52 AM, Bruce Fields <bfields@fieldses.org> wrote:
>
> Jeff was also wondering whether we could instead just allocate this with
> vmalloc--is there any drawback?  We only allocate this on nfsd startup,
> so if the only drawback is the allocation itself being expensive then
> that's no big deal.

vmalloc is ok. Generally if it's *usually* a small allocation, the
best pattern tends to be to first try to kmalloc (of get_free_pages())
using __GFP_NORETRY | __GFP_NOWARN, and then fall back on vmalloc().
That way you don't end up doing vmalloc's for things that really don't
need it.

If you do that, we have a "kvfree()" helper that is "free either
kmalloc or vmalloc area", so you don't have to track after-the-fact
which one you did.

               Linus
