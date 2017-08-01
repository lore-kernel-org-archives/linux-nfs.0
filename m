Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from scorn.kernelslacker.org ([45.56.101.199]:58562 "EHLO
        scorn.kernelslacker.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751496AbdHARud (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Aug 2017 13:50:33 -0400
Date: Tue, 1 Aug 2017 13:50:31 -0400
From: "davej@codemonkey.org.uk" <davej@codemonkey.org.uk>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Trond Myklebust <trondmy@primarydata.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "schumaker.anna@gmail.com" <schumaker.anna@gmail.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [GIT PULL] Please pull NFS client changes for Linux 4.13
Message-ID: <20170801175031.74llpntgz3qirv3s@codemonkey.org.uk>
References: <cf7efbe6-899c-368d-6d56-c2cb3eb28acc@gmail.com>
 <20170714142543.k5xcbnb4mww3sxpy@codemonkey.org.uk>
 <20170716211530.sx7mn35f2mhmykug@codemonkey.org.uk>
 <1500245845.13893.3.camel@primarydata.com>
 <20170717030504.qca74wsswct26ytn@codemonkey.org.uk>
 <CA+55aFy6kUwPTbzKebO4=BovEc_Nq3XCoYMeofgCM3ypxrkvJg@mail.gmail.com>
 <20170731154322.tfzkukscda4fe7wm@codemonkey.org.uk>
 <CA+55aFwwkc-YJ8WQzE6Ax3BAJ3XXR8fhN+0AEH_U8TtcQn7opg@mail.gmail.com>
 <20170801155131.xy7nbw5ih7ml5fmf@codemonkey.org.uk>
 <CA+55aFyQdHt0qYQ0uBSK+9wfPOyFfx8mJE4r9FfWoxa3Gyei9g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+55aFyQdHt0qYQ0uBSK+9wfPOyFfx8mJE4r9FfWoxa3Gyei9g@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 01, 2017 at 10:20:31AM -0700, Linus Torvalds wrote:

 > So I think the 'pathname' part may actually be entirely a red herring,
 > and it's the underlying access itself that just picks up a random
 > pointer from a stack that now contains something different. And KASAN
 > didn't notice the stale stack access itself, because the stack slot is
 > still valid - it's just no longer the original 'verifier' allocation.
 > 
 > Or *something* like that.
 > 
 > None of this looks even remotely new, though - the code seems to go
 > back to 2009. Have you just changed what you're testing to trigger
 > these things?

No idea why it only just showed up, but it isn't 100% reproducable
either.  A month or so ago I did disable the V4 code on the server
completely (as I was using v3 everywhere else), so maybe I started hitting
a fallback path somewhere.  *shrug*

	Dave

