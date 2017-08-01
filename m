Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:33672 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751942AbdHARxT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Aug 2017 13:53:19 -0400
MIME-Version: 1.0
In-Reply-To: <CA+55aFyQdHt0qYQ0uBSK+9wfPOyFfx8mJE4r9FfWoxa3Gyei9g@mail.gmail.com>
References: <cf7efbe6-899c-368d-6d56-c2cb3eb28acc@gmail.com>
 <20170714142543.k5xcbnb4mww3sxpy@codemonkey.org.uk> <20170716211530.sx7mn35f2mhmykug@codemonkey.org.uk>
 <1500245845.13893.3.camel@primarydata.com> <20170717030504.qca74wsswct26ytn@codemonkey.org.uk>
 <CA+55aFy6kUwPTbzKebO4=BovEc_Nq3XCoYMeofgCM3ypxrkvJg@mail.gmail.com>
 <20170731154322.tfzkukscda4fe7wm@codemonkey.org.uk> <CA+55aFwwkc-YJ8WQzE6Ax3BAJ3XXR8fhN+0AEH_U8TtcQn7opg@mail.gmail.com>
 <20170801155131.xy7nbw5ih7ml5fmf@codemonkey.org.uk> <CA+55aFyQdHt0qYQ0uBSK+9wfPOyFfx8mJE4r9FfWoxa3Gyei9g@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 1 Aug 2017 10:53:17 -0700
Message-ID: <CA+55aFxVG4xJ2AWpuo5fHPvkCTB6eAgogQ0UoJuQHo=MsXRb1w@mail.gmail.com>
Subject: Re: [GIT PULL] Please pull NFS client changes for Linux 4.13
To: "davej@codemonkey.org.uk" <davej@codemonkey.org.uk>,
        Trond Myklebust <trondmy@primarydata.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "schumaker.anna@gmail.com" <schumaker.anna@gmail.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 1, 2017 at 10:20 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> So I think the 'pathname' part may actually be entirely a red herring,
> and it's the underlying access itself that just picks up a random
> pointer from a stack that now contains something different. And KASAN
> didn't notice the stale stack access itself, because the stack slot is
> still valid - it's just no longer the original 'verifier' allocation.
>
> Or *something* like that.

I think the "something like that" is actually just reading the
cdata->args.verifier->data pointer itself, and it *is* the stack
access - but the stack page has been free'd (because of the same fatal
signal that interrupted the rpc_wait_for_completion_task() call), and
then re-allocated (and free'd again) as a pathname page.

Maybe.

Regardless, my patch still looks conceptually correct, even if it
might have bugs due to total lack of testing.

                    Linus
