Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f169.google.com ([209.85.217.169]:43306 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753181AbbBWWzz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Feb 2015 17:55:55 -0500
Received: by lbiw7 with SMTP id w7so21356999lbi.10
        for <linux-nfs@vger.kernel.org>; Mon, 23 Feb 2015 14:55:54 -0800 (PST)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Subject: Re: [PATCH v3 3/3] lib/string_helpers.c: Change semantics of string_escape_mem
References: <1422525801-26560-1-git-send-email-linux@rasmusvillemoes.dk>
	<1423525491-12613-1-git-send-email-linux@rasmusvillemoes.dk>
	<1423525491-12613-4-git-send-email-linux@rasmusvillemoes.dk>
	<1423571552.31903.468.camel@linux.intel.com>
	<87386dj4x0.fsf@rasmusvillemoes.dk>
	<1423578150.31903.480.camel@linux.intel.com>
	<87oaoo59n2.fsf@rasmusvillemoes.dk>
	<1424695820.14897.10.camel@linux.intel.com>
Date: Mon, 23 Feb 2015 23:55:51 +0100
In-Reply-To: <1424695820.14897.10.camel@linux.intel.com> (Andy Shevchenko's
	message of "Mon, 23 Feb 2015 14:50:20 +0200")
Message-ID: <87k2z86xvs.fsf@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 23 2015, Andy Shevchenko <andriy.shevchenko@linux.intel.com> wrote:

>> >> > So, why couldn't we split this to separate test case? It seems I already
>> >> > pointed this out.
>> >> >
>> >> 
>> >> This actually provides better coverage
>> >
>> > I do not see much advantage of doing so. You may create a loop with
>> > random number for in-size and check. So, I prefer to see separate case
>> > for that.
>> 
>> It's not about the size, it's about exercising all the various escape_*
>> helpers, to ensure that they all respect the end of the buffer, while
>> still returning the correct would-be output size. For that, one needs to
>> call string_escape_mem with various combinations of flags and input
>> buffers. The logic for that is already in place in test_string_escape
>> and its caller, and I see no point in duplicating all that.
>
> Thanks for clarification.
>
>> If you insist on a separate function for doing the overflow testing,
>> I'll just rip it out from my code and let you add such a test later.
>
> What about to make it a separate function *and* call from inside of
> test_string_escape? Would it work for you?

See my earlier point about "quite a lot of state to pass". But if this

static __init void
test_string_escape_overflow(const char *in, int p, char *out_real, int out_size,
			    unsigned int flags, const char *esc, int q_test,
			    const char *name)
{
	int q_real;

	memset(out_real, 'Z', out_size);
	q_real = string_escape_mem(in, p, out_real, 0, flags, esc);
	if (q_real != q_test)
		pr_warn("Test '%s' failed: flags = %u, osz = 0, expected %d, got %d\n",
			name, flags, q_test, q_real);
	if (memchr_inv(out_real, 'Z', out_size))
		pr_warn("Test '%s' failed: osz = 0 but string_escape_mem wrote to the buffer\n",
			name);
}

is what you want, sure, have it your way.

I need to fix fs/proc/array.c in 3/3 as well, to make the kernel
compile+boot and make the series bisectable. Before I send v4 please let
me know what you think about this (the minimal fix I could come up with):

diff --git a/fs/proc/array.c b/fs/proc/array.c
index 1295a00ca316..20f2d50e2dba 100644
--- a/fs/proc/array.c
+++ b/fs/proc/array.c
@@ -99,10 +99,9 @@ static inline void task_name(struct seq_file *m, struct task_struct *p)
        buf = m->buf + m->count;
 
        /* Ignore error for now */
-       string_escape_str(tcomm, &buf, m->size - m->count,
-                         ESCAPE_SPACE | ESCAPE_SPECIAL, "\n\\");
+       m->count += string_escape_str(tcomm, buf, m->size - m->count,
+                                     ESCAPE_SPACE | ESCAPE_SPECIAL, "\n\\");
 
-       m->count = buf - m->buf;
        seq_putc(m, '\n');
 }
 
[Longer-term I think it would be a lot better not to poke around in
the internals of struct seq_file. One way is to do the escaping into a
stack buffer (2*sizeof(p->comm) should be enough) and then use something
like seq_write(m, buffer, min(sizeof(buffer),
return-value-from-string_escape_str)).

Another option is to do everything with a single seq_printf call,
something like

seq_printf(m, "Name:\t%*pEcs\n, (int)strlen(tcomm), tcomm)

That will escape more than just \ and \n, but that would IMO be an
improvement. But of course this is out of scope for this series.]

Rasmus
