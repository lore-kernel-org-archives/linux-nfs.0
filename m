Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga03.intel.com ([134.134.136.65]:30945 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759420AbbA1Uhs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Jan 2015 15:37:48 -0500
Message-ID: <1422457545.31903.301.camel@linux.intel.com>
Subject: Re: [PATCH 2/2] string_helpers: Change semantics of
 string_escape_mem
From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Date: Wed, 28 Jan 2015 17:05:45 +0200
In-Reply-To: <1422451543-12401-3-git-send-email-linux@rasmusvillemoes.dk>
References: <1422451543-12401-1-git-send-email-linux@rasmusvillemoes.dk>
	 <1422451543-12401-3-git-send-email-linux@rasmusvillemoes.dk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2015-01-28 at 14:25 +0100, Rasmus Villemoes wrote:
> The current semantics of string_escape_mem are inadequate for one of
> its two current users, vsnprintf(). If that is to honour its contract,
> it must know how much space would be needed for the entire escaped
> buffer, and string_escape_mem provides no way of obtaining that (short
> of allocating a large enough buffer (~4 times input string) to let it
> play with, and that's definitely a big no-no inside vsnprintf).
> 
> So change the semantics for string_escape_mem to be more
> snprintf-like: Return the size of the output that would be generated
> if the destination buffer was big enough, but of course still only
> write to the part of dst it is allowed to, and don't do
> '\0'-termination. It is then up to the caller to detect whether output
> was truncated and to append a '\0' if desired.
> 
> This also fixes a bug in the escaped_string() helper function, which
> used to unconditionally pass a length of "end-buf" to
> string_escape_mem(); since the latter doesn't check osz for being
> insanely large, it would happily write to dst. For example,
> kasprintf(GFP_KERNEL, "something and then %pE", ...); is an easy way
> to trigger an oops.

> The patch is somewhat larger than I'd like, but I couldn't find a way
> of splitting it into smaller pieces. Implementation-wise, I changed
> the various escape_* helpers to return true if they handled the
> character, updating dst appropriately, false otherwise. Maybe there's
> a more elegant way, but this seems to work.

Can we split this to at least two parts: internal API changes to
string_escape_mem() and the rest?

> In test-string_helpers.c, I removed the now meaningless -ENOMEM test,
> and replaced it with testing for getting the expected return value
> even if the buffer is too small. Also ensure that nothing is written
> when osz==0.
> 
> In net/sunrpc/cache.c, I think qword_add still has the same
> semantics. Someone should definitely double-check this.


-- 
Andy Shevchenko <andriy.shevchenko@intel.com>
Intel Finland Oy

