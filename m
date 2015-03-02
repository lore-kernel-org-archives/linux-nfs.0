Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f175.google.com ([209.85.217.175]:36144 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751237AbbCBXDp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Mar 2015 18:03:45 -0500
Received: by lbiz11 with SMTP id z11so7514612lbi.3
        for <linux-nfs@vger.kernel.org>; Mon, 02 Mar 2015 15:03:43 -0800 (PST)
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
	<87k2z86xvs.fsf@rasmusvillemoes.dk>
	<1425299846.14897.124.camel@linux.intel.com>
Date: Tue, 03 Mar 2015 00:03:40 +0100
In-Reply-To: <1425299846.14897.124.camel@linux.intel.com> (Andy Shevchenko's
	message of "Mon, 02 Mar 2015 14:37:26 +0200")
Message-ID: <87a8zvovcj.fsf@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 02 2015, Andy Shevchenko <andriy.shevchenko@linux.intel.com> wrote:

> On Mon, 2015-02-23 at 23:55 +0100, Rasmus Villemoes wrote:
>> On Mon, Feb 23 2015, Andy Shevchenko <andriy.shevchenko@linux.intel.com> wrote:
>
>> > What about to make it a separate function *and* call from inside of
>> > test_string_escape? Would it work for you?
>> 
>> See my earlier point about "quite a lot of state to pass". But if this
>> 
>> static __init void
>> test_string_escape_overflow(const char *in, int p, char *out_real, int out_size,
>> 			    unsigned int flags, const char *esc, int q_test,
>> 			    const char *name)
>> {
>> 	int q_real;
>> 
>> 	memset(out_real, 'Z', out_size);
>> 	q_real = string_escape_mem(in, p, out_real, 0, flags, esc);
>> 	if (q_real != q_test)
>> 		pr_warn("Test '%s' failed: flags = %u, osz = 0, expected %d, got %d\n",
>> 			name, flags, q_test, q_real);
>> 	if (memchr_inv(out_real, 'Z', out_size))
>> 		pr_warn("Test '%s' failed: osz = 0 but string_escape_mem wrote to the buffer\n",
>> 			name);
>> }
>> 
>> is what you want, sure, have it your way.
>
> Something like above, though might be few variables can be defined
> inside it, such as out_real, out_size.

Or maybe not at all: We could pass NULL, 0, which is what has to work
anyway for the kasprintf case - failure will then be detected through an
oops, but I think that should be ok. That would also remove the memset and
memchr_inv calls above.

I don't like the idea of just defining a small stack buffer (say
buf[16]) and passing that (still with a size of 0): It's better to
either detect writes directly (by passing a large enough buffer with
known contents), or indirectly through an oops, as opposed to having to
figure it out from random stack corruption. And kmalloc'ing+error
handling+kfree'ing a buffer inside the overflow check would just be
plain silly, when we have a large enough buffer already.

>> I need to fix fs/proc/array.c in 3/3 as well, to make the kernel
>> compile+boot and make the series bisectable. Before I send v4 please let
>> me know what you think about this (the minimal fix I could come up with):
>> 
>> diff --git a/fs/proc/array.c b/fs/proc/array.c
>> index 1295a00ca316..20f2d50e2dba 100644
>> --- a/fs/proc/array.c
>> +++ b/fs/proc/array.c
>> @@ -99,10 +99,9 @@ static inline void task_name(struct seq_file *m, struct task_struct *p)
>>         buf = m->buf + m->count;
>>  
>>         /* Ignore error for now */
>> -       string_escape_str(tcomm, &buf, m->size - m->count,
>> -                         ESCAPE_SPACE | ESCAPE_SPECIAL, "\n\\");
>> +       m->count += string_escape_str(tcomm, buf, m->size - m->count,
>> +                                     ESCAPE_SPACE | ESCAPE_SPECIAL, "\n\\");
>
> Just a nitpick: what if we keep buf arithmetics in place, i.e.
> buf += string_escape_str();
> m->count = …

Yes, that will make the patch even smaller, just touching that single
line. Done.

> Also shouldn't we check if seq_overflow is set before even trying to
> escape? Otherwise it will return something which is bigger that 0 and
> advance m->count too far.

I don't think we need to care. AFAICT, task_name is only used for
/proc/*/status, and it is the first thing to fill anything into the
seq_file, so overflow is impossible. [Testing for pre-existing overflow
also wouldn't be enough; one should check whether there's actually room
for ~32 bytes.]

As I said, I do think that longer-term one shouldn't have to poke around
in the seq_file internals, but for now I'd like to make the patch minimal.

>> Another option is to do everything with a single seq_printf call,
>> something like
>> 
>> seq_printf(m, "Name:\t%*pEcs\n, (int)strlen(tcomm), tcomm)
>> 
>> That will escape more than just \ and \n, but that would IMO be an
>> improvement. But of course this is out of scope for this series.]
>
> It should be %pT and reconsider policy how we print task name in
> different cases (vsprintf.c::comm_name()).

Well, %pT is a completely new addition to vsprintf.c. Also, I don't
think that would be a very good match - not every user of %pT might want
escaping, so at the very least this would require implementing some
extra flags for %pT. But if task_name would be the only user of those
flags, I think the escaping logic is better kept there. Anyway, this is
outside this series' scope.

Rasmus
