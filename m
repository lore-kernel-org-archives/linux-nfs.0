Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga03.intel.com ([134.134.136.65]:32155 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964777AbbBBK4j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Feb 2015 05:56:39 -0500
Message-ID: <1422874597.31903.358.camel@linux.intel.com>
Subject: Re: [PATCH v2 3/3] lib/string_helpers.c: Change semantics of
 string_escape_mem
From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Date: Mon, 02 Feb 2015 12:56:37 +0200
In-Reply-To: <87pp9vhm8l.fsf@rasmusvillemoes.dk>
References: <1422451543-12401-1-git-send-email-linux@rasmusvillemoes.dk>
	 <1422525801-26560-1-git-send-email-linux@rasmusvillemoes.dk>
	 <1422525801-26560-4-git-send-email-linux@rasmusvillemoes.dk>
	 <1422538178.31903.325.camel@linux.intel.com>
	 <87oaphbqym.fsf@rasmusvillemoes.dk>
	 <1422613655.31903.351.camel@linux.intel.com>
	 <87pp9vhm8l.fsf@rasmusvillemoes.dk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2015-01-31 at 00:39 +0100, Rasmus Villemoes wrote:
> On Fri, Jan 30 2015, Andy Shevchenko <andriy.shevchenko@linux.intel.com> wrote:
> >> >>   * Return:
> >> >> - * The amount of the characters processed to the destination buffer, or
> >> >> - * %-ENOMEM if the size of buffer is not enough to put an escaped character is
> >> >> - * returned.
> >> >> - *
> >> >> - * Even in the case of error @dst pointer will be updated to point to the byte
> >> >> - * after the last processed character.
> >> >> + * The total size of the escaped output that would be generated for
> >> >> + * the given input and flags. To check whether the output was
> >> >> + * truncated, compare the return value to osz. There is room left in
> >> >> + * dst for a '\0' terminator if and only if ret < osz.
> >> >>   */
> >> >> -int string_escape_mem(const char *src, size_t isz, char **dst, size_t osz,
> >> >> -		      unsigned int flags, const char *esc)
> >> >> +size_t string_escape_mem(const char *src, size_t isz, char *dst, size_t osz,
> >> >> +			 unsigned int flags, const char *esc)
> >> >
> >> > I prefer to leave the prototype the same. int for return is okay. dst
> >> > should be updated accordingly.
> >> 
> >> Please explain exactly what you think the return value should be, and
> >> what *dst should be set to.
> >
> > Return value like you proposed, *dst is incremented by it.
> 
> The more I think about it, the less I like having dst being char**.
> 
> (1) It is unlike most other functions taking buffer+size arguments.
> (2) It is inconvenient. Callers doing
> 
>   char escaped[SOME_SIZE];
> 
> or
> 
>   char *escaped = kmalloc(likely_big_enough);
> 
> can't just pass &escaped; they would need to use an extra dummy variable.
> 
> (3) With the return value telling the size of the would-be generated
> output, it is redundant.
> 
> In fact, I dislike it so much that I'm not going to sign off on a patch
> where dst is still char**.

Fair enough, though there usual case when temporary variable is already
present (at least current users).

Let's proceed with char *dst.

-- 
Andy Shevchenko <andriy.shevchenko@intel.com>
Intel Finland Oy

