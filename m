Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga03.intel.com ([134.134.136.65]:23919 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751898AbbBWMuY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Feb 2015 07:50:24 -0500
Message-ID: <1424695820.14897.10.camel@linux.intel.com>
Subject: Re: [PATCH v3 3/3] lib/string_helpers.c: Change semantics of
 string_escape_mem
From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Date: Mon, 23 Feb 2015 14:50:20 +0200
In-Reply-To: <87oaoo59n2.fsf@rasmusvillemoes.dk>
References: <1422525801-26560-1-git-send-email-linux@rasmusvillemoes.dk>
	 <1423525491-12613-1-git-send-email-linux@rasmusvillemoes.dk>
	 <1423525491-12613-4-git-send-email-linux@rasmusvillemoes.dk>
	 <1423571552.31903.468.camel@linux.intel.com>
	 <87386dj4x0.fsf@rasmusvillemoes.dk>
	 <1423578150.31903.480.camel@linux.intel.com>
	 <87oaoo59n2.fsf@rasmusvillemoes.dk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2015-02-21 at 02:35 +0100, Rasmus Villemoes wrote:
> On Tue, Feb 10 2015, Andy Shevchenko <andriy.shevchenko@linux.intel.com> wrote:

> >> >> @@ -301,29 +301,26 @@ static __init void test_string_escape(const char *name,
> >> >>  		q_test += len;
> >> >>  	}
> >> >>  
> >> >> -	q_real = string_escape_mem(in, p, &buf, q_real, flags, esc);
> >> >> +	q_real = string_escape_mem(in, p, out_real, out_size, flags, esc);
> >> >>  
> >> >>  	test_string_check_buf(name, flags, in, p, out_real, q_real, out_test,
> >> >>  			      q_test);
> >> >> +
> >> >> +	memset(out_real, 'Z', out_size);
> >> >> +	q_real = string_escape_mem(in, p, out_real, 0, flags, esc);
> >> >> +	if (q_real != q_test)
> >> >> +		pr_warn("Test '%s' failed: flags = %u, osz = 0, expected %d, got %d\n",
> >> >> +			name, flags, q_test, q_real);
> >> >> +	if (memchr_inv(out_real, 'Z', out_size))
> >> >> +		pr_warn("Test '%s' failed: osz = 0 but string_escape_mem wrote to the buffer\n",
> >> >> +			name);
> >> >> +
> >> >
> >> > So, why couldn't we split this to separate test case? It seems I already
> >> > pointed this out.
> >> >
> >> 
> >> This actually provides better coverage
> >
> > I do not see much advantage of doing so. You may create a loop with
> > random number for in-size and check. So, I prefer to see separate case
> > for that.
> 
> It's not about the size, it's about exercising all the various escape_*
> helpers, to ensure that they all respect the end of the buffer, while
> still returning the correct would-be output size. For that, one needs to
> call string_escape_mem with various combinations of flags and input
> buffers. The logic for that is already in place in test_string_escape
> and its caller, and I see no point in duplicating all that.

Thanks for clarification.

> If you insist on a separate function for doing the overflow testing,
> I'll just rip it out from my code and let you add such a test later.

What about to make it a separate function *and* call from inside of
test_string_escape? Would it work for you?

> I've updated 2/3 with the early returns you suggested, but I'll wait a
> little before sending out a v4.


-- 
Andy Shevchenko <andriy.shevchenko@intel.com>
Intel Finland Oy

