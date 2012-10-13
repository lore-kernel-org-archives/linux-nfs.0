Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f44.google.com ([74.125.82.44]:50817 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752307Ab2JMChY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Oct 2012 22:37:24 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so2895314wgb.1
        for <linux-nfs@vger.kernel.org>; Fri, 12 Oct 2012 19:37:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5078D17C.9090002@panasas.com>
References: <20121012211701.GA8301@bitmover.com> <CA+55aFymSQYnutQgv0B2yXHL00hHs-3UZZGEXVik18QUdPTgyg@mail.gmail.com>
 <5078D17C.9090002@panasas.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 13 Oct 2012 11:37:01 +0900
Message-ID: <CA+55aFyreSgqjkc5_hFjcX2PkWp0TXjMccPydO6wMj+hwC5Qqw@mail.gmail.com>
Subject: Re: kernel BUG at /build/buildd/linux-3.2.0/fs/lockd/clntxdr.c:226!
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Bruce Fields <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Larry McVoy <lm@bitmover.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Oct 13, 2012 at 11:27 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>
> I suspect the BUG_ON() belongs else where.
> Perhaps we should add __func__ to the BUG_ON macro exactly for times
> that source and Kernel get out of sync.

BUG_ON already does the whole "line and file" thing, so the exact
BUG_ON() should be very well pinpointed.

Sometimes various distro changes do make the lines move around, but
clntxdr.c has been very stable, and line 226 has the same BUG_ON in it
in both 3.2 and 3.6, so I seriously doubt that's the case.

And that function is definitely called, it's just that you missed the
magic cpp stuff. See the preprocessor using it like this:

  .p_encode    = (kxdreproc_t)nlm_xdr_enc_##argtype,

so the nlm_xdr_enc_res() function ends up being used as the .p_encode
function for the 'res' argtype.. (and same for testres)

             Linus
