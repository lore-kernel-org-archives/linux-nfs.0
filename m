Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga01.intel.com ([192.55.52.88]:21572 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752328AbbCCK0u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Mar 2015 05:26:50 -0500
Message-ID: <1425378405.14897.139.camel@linux.intel.com>
Subject: Re: [PATCH v3 3/3] lib/string_helpers.c: Change semantics of
 string_escape_mem
From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Date: Tue, 03 Mar 2015 12:26:45 +0200
In-Reply-To: <87a8zvovcj.fsf@rasmusvillemoes.dk>
References: <1422525801-26560-1-git-send-email-linux@rasmusvillemoes.dk>
	 <1423525491-12613-1-git-send-email-linux@rasmusvillemoes.dk>
	 <1423525491-12613-4-git-send-email-linux@rasmusvillemoes.dk>
	 <1423571552.31903.468.camel@linux.intel.com>
	 <87386dj4x0.fsf@rasmusvillemoes.dk>
	 <1423578150.31903.480.camel@linux.intel.com>
	 <87oaoo59n2.fsf@rasmusvillemoes.dk>
	 <1424695820.14897.10.camel@linux.intel.com>
	 <87k2z86xvs.fsf@rasmusvillemoes.dk>
	 <1425299846.14897.124.camel@linux.intel.com>
	 <87a8zvovcj.fsf@rasmusvillemoes.dk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2015-03-03 at 00:03 +0100, Rasmus Villemoes wrote:
> On Mon, Mar 02 2015, Andy Shevchenko <andriy.shevchenko@linux.intel.com> wrote:
> > On Mon, 2015-02-23 at 23:55 +0100, Rasmus Villemoes wrote:
> >> On Mon, Feb 23 2015, Andy Shevchenko <andriy.shevchenko@linux.intel.com> wrote:
> >
> >> > What about to make it a separate function *and* call from inside of
> >> > test_string_escape? Would it work for you?
> >> 
> >> See my earlier point about "quite a lot of state to pass". But if this
> >> 
> >> static __init void
> >> test_string_escape_overflow(const char *in, int p, char *out_real, int out_size,
> >> 			    unsigned int flags, const char *esc, int q_test,
> >> 			    const char *name)
> >> {
> >> 	int q_real;
> >> 
> >> 	memset(out_real, 'Z', out_size);
> >> 	q_real = string_escape_mem(in, p, out_real, 0, flags, esc);
> >> 	if (q_real != q_test)
> >> 		pr_warn("Test '%s' failed: flags = %u, osz = 0, expected %d, got %d\n",
> >> 			name, flags, q_test, q_real);
> >> 	if (memchr_inv(out_real, 'Z', out_size))
> >> 		pr_warn("Test '%s' failed: osz = 0 but string_escape_mem wrote to the buffer\n",
> >> 			name);
> >> }
> >> 
> >> is what you want, sure, have it your way.
> >
> > Something like above, though might be few variables can be defined
> > inside it, such as out_real, out_size.
> 
> Or maybe not at all: We could pass NULL, 0, which is what has to work
> anyway for the kasprintf case - failure will then be detected through an
> oops, but I think that should be ok. That would also remove the memset and
> memchr_inv calls above.
> 
> I don't like the idea of just defining a small stack buffer (say
> buf[16]) and passing that (still with a size of 0): It's better to
> either detect writes directly (by passing a large enough buffer with
> known contents), or indirectly through an oops, as opposed to having to
> figure it out from random stack corruption. And kmalloc'ing+error
> handling+kfree'ing a buffer inside the overflow check would just be
> plain silly, when we have a large enough buffer already.

Come with v4, I think I have no big objections to the approach.

> As I said, I do think that longer-term one shouldn't have to poke around
> in the seq_file internals, but for now I'd like to make the patch minimal.

Ok.

> >> Another option is to do everything with a single seq_printf call,
> >> something like
> >> 
> >> seq_printf(m, "Name:\t%*pEcs\n, (int)strlen(tcomm), tcomm)
> >> 
> >> That will escape more than just \ and \n, but that would IMO be an
> >> improvement. But of course this is out of scope for this series.]
> >
> > It should be %pT and reconsider policy how we print task name in
> > different cases (vsprintf.c::comm_name()).
> 
> Well, %pT is a completely new addition to vsprintf.c. Also, I don't
> think that would be a very good match - not every user of %pT might want
> escaping, so at the very least this would require implementing some
> extra flags for %pT.

Something like %pTe (for 'sanely Escaped' with flags you proposed
earlier) ?

>  But if task_name would be the only user of those
> flags, I think the escaping logic is better kept there. Anyway, this is
> outside this series' scope.

Yes.

-- 
Andy Shevchenko <andriy.shevchenko@intel.com>
Intel Finland Oy

