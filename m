Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:34997 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753518Ab2CNEiA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Mar 2012 00:38:00 -0400
Received: by wejx9 with SMTP id x9so1267256wej.19
        for <linux-nfs@vger.kernel.org>; Tue, 13 Mar 2012 21:37:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F60141A.709@panasas.com>
References: <4F60141A.709@panasas.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 13 Mar 2012 21:37:39 -0700
Message-ID: <CA+55aFzCuDCo1tJvgetOVhwnO_W+FaYBDZiuZTGYD+YA4iwp0Q@mail.gmail.com>
Subject: Re: [PATCH] pnfs-obj: Uglify objio_segment allocation for the sake of
 the principle :-(
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 13, 2012 at 8:44 PM, Boaz Harrosh <bharrosh@panasas.com> wrote:
> Since then any use of "variable length arrays" has become blasphemous.
> Even in perfectly good, beautiful, perfectly safe code like the one
> below where the variable length arrays are only used as a sizeof()
> parameter, for type-safe dynamic structure allocations. GCC is not
> executing any stack allocation code.

If it's a compile-time constant, just make it one. Stop the whining.
No VLA's required. You could, for example, make a trivial wrapper
macro that just declares that array as a constant array in the caller,
and it really *is* a constant sized array with no questions asked.

Instead, you waste more time and effort *whining* than doing that
technical solution.

You do realize that VLA's have caused real problems, since you even
quote some of the background. Not to mention all the problems they
cause for semantics analysis and static checkers.

VLA's really aren't a very good thing in the kernel. And the
work-around I suggest above is actually *simpler* than using them and
then spednign the effort explaining "but they are actually constants
at compile time after all, and aren't the bad kinds of VLAs".

Just don't do them. They are a mistake.

                  Linus
