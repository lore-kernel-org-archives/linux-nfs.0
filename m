Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:35583 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750780AbdLGFeh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Dec 2017 00:34:37 -0500
Date: Wed, 6 Dec 2017 21:34:29 -0800
From: Matthew Wilcox <willy@infradead.org>
To: NeilBrown <neilb@suse.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>,
        lkml <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Lennart Poettering <lennart@poettering.net>
Subject: Re: [PATCH] NFS: allow name_to_handle_at() to work for Amazon EFS.
Message-ID: <20171207053429.GB2739@bombadil.infradead.org>
References: <87po7zv62h.fsf@notabene.neil.brown.name>
 <CA+55aFxHmVi-PuAWWrZqQzrich1QS9NR35DbdGpMts=y9uMAVA@mail.gmail.com>
 <87r2s7ql5m.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87r2s7ql5m.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 07, 2017 at 02:20:05PM +1100, NeilBrown wrote:
> We can allocate in fs/notify/fdinfo.c:show_fdinfo() which is
> the earliest 'notify' specific code to run.  There is no
> opportunity to return an error but GFP_KERNEL allocations under 1 page
> never fail..

"never"

 * The default allocator behavior depends on the request size. We have a concept
 * of so called costly allocations (with order > PAGE_ALLOC_COSTLY_ORDER).
 * !costly allocations are too essential to fail so they are implicitly
 * non-failing by default (with some exceptions like OOM victims might fail so
 * the caller still has to check for failures) while costly requests try to be
 * not disruptive and back off even without invoking the OOM killer.
 * The following three modifiers might be used to override some of these
 * implicit rules

