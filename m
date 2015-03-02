Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga01.intel.com ([192.55.52.88]:48576 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751556AbbCBMha (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Mar 2015 07:37:30 -0500
Message-ID: <1425299846.14897.124.camel@linux.intel.com>
Subject: Re: [PATCH v3 3/3] lib/string_helpers.c: Change semantics of
 string_escape_mem
From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Date: Mon, 02 Mar 2015 14:37:26 +0200
In-Reply-To: <87k2z86xvs.fsf@rasmusvillemoes.dk>
References: <1422525801-26560-1-git-send-email-linux@rasmusvillemoes.dk>
	 <1423525491-12613-1-git-send-email-linux@rasmusvillemoes.dk>
	 <1423525491-12613-4-git-send-email-linux@rasmusvillemoes.dk>
	 <1423571552.31903.468.camel@linux.intel.com>
	 <87386dj4x0.fsf@rasmusvillemoes.dk>
	 <1423578150.31903.480.camel@linux.intel.com>
	 <87oaoo59n2.fsf@rasmusvillemoes.dk>
	 <1424695820.14897.10.camel@linux.intel.com>
	 <87k2z86xvs.fsf@rasmusvillemoes.dk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2015-02-23 at 23:55 +0100, Rasmus Villemoes wrote:
> On Mon, Feb 23 2015, Andy Shevchenko <andriy.shevchenko@linux.intel.com> wrote:

> >> If you insist on a separate function for doing the overflow testing,
> >> I'll just rip it out from my code and let you add such a test later.
> >
> > What about to make it a separate function *and* call from inside of
> > test_string_escape? Would it work for you?
> 
> See my earlier point about "quite a lot of state to pass". But if this
> 
> static __init void
> test_string_escape_overflow(const char *in, int p, char *out_real, int out_size,
> 			    unsigned int flags, const char *esc, int q_test,
> 			    const char *name)
> {
> 	int q_real;
> 
> 	memset(out_real, 'Z', out_size);
> 	q_real = string_escape_mem(in, p, out_real, 0, flags, esc);
> 	if (q_real != q_test)
> 		pr_warn("Test '%s' failed: flags = %u, osz = 0, expected %d, got %d\n",
> 			name, flags, q_test, q_real);
> 	if (memchr_inv(out_real, 'Z', out_size))
> 		pr_warn("Test '%s' failed: osz = 0 but string_escape_mem wrote to the buffer\n",
> 			name);
> }
> 
> is what you want, sure, have it your way.

Something like above, though might be few variables can be defined
inside it, such as out_real, out_size.

> I need to fix fs/proc/array.c in 3/3 as well, to make the kernel
> compile+boot and make the series bisectable. Before I send v4 please let
> me know what you think about this (the minimal fix I could come up with):
> 
> diff --git a/fs/proc/array.c b/fs/proc/array.c
> index 1295a00ca316..20f2d50e2dba 100644
> --- a/fs/proc/array.c
> +++ b/fs/proc/array.c
> @@ -99,10 +99,9 @@ static inline void task_name(struct seq_file *m, struct task_struct *p)
>         buf = m->buf + m->count;
>  
>         /* Ignore error for now */
> -       string_escape_str(tcomm, &buf, m->size - m->count,
> -                         ESCAPE_SPACE | ESCAPE_SPECIAL, "\n\\");
> +       m->count += string_escape_str(tcomm, buf, m->size - m->count,
> +                                     ESCAPE_SPACE | ESCAPE_SPECIAL, "\n\\");

Just a nitpick: what if we keep buf arithmetics in place, i.e.
buf += string_escape_str();
m->count = …

Also shouldn't we check if seq_overflow is set before even trying to
escape? Otherwise it will return something which is bigger that 0 and
advance m->count too far.

>  
> -       m->count = buf - m->buf;
>         seq_putc(m, '\n');
>  }
>  
> [Longer-term I think it would be a lot better not to poke around in
> the internals of struct seq_file. One way is to do the escaping into a
> stack buffer (2*sizeof(p->comm) should be enough) and then use something
> like seq_write(m, buffer, min(sizeof(buffer),
> return-value-from-string_escape_str)).
> 
> Another option is to do everything with a single seq_printf call,
> something like
> 
> seq_printf(m, "Name:\t%*pEcs\n, (int)strlen(tcomm), tcomm)
> 
> That will escape more than just \ and \n, but that would IMO be an
> improvement. But of course this is out of scope for this series.]

It should be %pT and reconsider policy how we print task name in
different cases (vsprintf.c::comm_name()).

-- 
Andy Shevchenko <andriy.shevchenko@intel.com>
Intel Finland Oy

