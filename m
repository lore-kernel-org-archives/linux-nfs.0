Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f175.google.com ([74.125.82.175]:44703 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750843Ab3KNEXD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Nov 2013 23:23:03 -0500
Received: by mail-we0-f175.google.com with SMTP id t60so1336589wes.34
        for <linux-nfs@vger.kernel.org>; Wed, 13 Nov 2013 20:23:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131113220036.GO28033@fieldses.org>
References: <CA+uAZNPquD-JA1SDpFHtx9ZawQA5=o+fBigOTy+9NEiDL+hmyw@mail.gmail.com>
	<20131031141538.GA621@fieldses.org>
	<CA+uAZNO7VrBA1MLgGoqGpXGPHMMy0VF_3KBr93Y5w1M=ZO7s4w@mail.gmail.com>
	<20131104230244.GD8828@fieldses.org>
	<CA+uAZNOJg3Jeu8uyCEeHx71JwHwC0P0d=mx1BiyKnyoS04KUsw@mail.gmail.com>
	<20131105195810.GC23329@fieldses.org>
	<CA+uAZNNfchaju7GrHcwUQ1O5qnaoTxJt0W0bkmFyS7YJwxKJLQ@mail.gmail.com>
	<20131113162443.GK28033@fieldses.org>
	<20131113220036.GO28033@fieldses.org>
Date: Thu, 14 Nov 2013 09:53:01 +0530
Message-ID: <CA+uAZNMPtt6EENAX-qMwku8-s+o5p4nDFt8zB9AVEntwe72aeA@mail.gmail.com>
Subject: Re: Need help with NFS Server SUNRPC performance issue
From: Shyam Kaushik <shyamnfs1@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks a lot Bruce for taking care of this!

I will apply this patch manually on the 3.8 NFSD version we use. Thanks.

--Shyam

On Thu, Nov 14, 2013 at 3:30 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Wed, Nov 13, 2013 at 11:24:44AM -0500, J. Bruce Fields wrote:
>> On Wed, Nov 06, 2013 at 12:57:38PM +0530, Shyam Kaushik wrote:
>> > Hi Bruce,
>> >
>> > This hack works great. All 32 of configured NFSD threads end up doing
>> > nfsd_write() which is great & I get higher IOPs/bandwidth from NFS
>> > client side.
>> >
>> > What do you think if we vary the signature of
>> > typedef __be32(*nfsd4_dec)(struct nfsd4_compoundargs *argp, void *);
>> >
>> > to include an additional return argument of the size estimate. This
>> > way we get size estimate from the decoders (like nfsd4_decode_read
>> > could return this estimate as rd_length + overhead) & in the worst
>> > case if decoder says cant estimate (like a special return code -1) we
>> > dont do svc_reserve() & leave it like it is. So when we run through
>> > the compound we have a sum of size estimate & just do svc_reserve() at
>> > the end of nfsd4_decode_compound() like your hack has.
>> >
>> > Does this sound reasonable to you? If not, perhaps can we just use the
>> > hack for now & worry about readdir etc when they support >4K buffer?
>>
>> Yep.  Actually looking at it again I think it needs a couple more
>> special cases (for readlink, readdir), but that should be good enough
>> for now.
>
> So I'm planning to commit the following.
>
> But eventually I agree we'd rather do the calculation in the decoder.
> (Which would make it easier for example to take into account whether a
> getattr op includes a request for an ACL.)
>
> --b.
>
> commit 6ff40decff0ef35a5d755ec60182d7f803356dfb
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Tue Nov 5 15:07:16 2013 -0500
>
>     nfsd4: improve write performance with better sendspace reservations
>
>     Currently the rpc code conservatively refuses to accept rpc's from a
>     client if the sum of its worst-case estimates of the replies it owes
>     that client exceed the send buffer space.
>
>     Unfortunately our estimate of the worst-case reply for an NFSv4 compound
>     is always the maximum read size.  This can unnecessarily limit the
>     number of operations we handle concurrently, for example in the case
>     most operations are writes (which have small replies).
>
>     We can do a little better if we check which ops the compound contains.
>
>     This is still a rough estimate, we'll need to improve on it some day.
>
>     Reported-by: Shyam Kaushik <shyamnfs1@gmail.com>
>     Tested-by: Shyam Kaushik <shyamnfs1@gmail.com>
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
>
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index d9d7fa9..9d76ee3 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1597,12 +1597,39 @@ nfsd4_opnum_in_range(struct nfsd4_compoundargs *argp, struct nfsd4_op *op)
>         return true;
>  }
>
> +/*
> + * Return a rough estimate of the maximum possible reply size.  Note the
> + * estimate includes rpc headers so is meant to be passed to
> + * svc_reserve, not svc_reserve_auth.
> + *
> + * Also note the current compound encoding permits only one operation to
> + * use pages beyond the first one, so the maximum possible length is the
> + * maximum over these values, not the sum.
> + */
> +static int nfsd4_max_reply(u32 opnum)
> +{
> +       switch (opnum) {
> +       case OP_READLINK:
> +       case OP_READDIR:
> +               /*
> +                * Both of these ops take a single page for data and put
> +                * the head and tail in another page:
> +                */
> +               return 2 * PAGE_SIZE;
> +       case OP_READ:
> +               return INT_MAX;
> +       default:
> +               return PAGE_SIZE;
> +       }
> +}
> +
>  static __be32
>  nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
>  {
>         DECODE_HEAD;
>         struct nfsd4_op *op;
>         bool cachethis = false;
> +       int max_reply = PAGE_SIZE;
>         int i;
>
>         READ_BUF(4);
> @@ -1652,10 +1679,14 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
>                  * op in the compound wants to be cached:
>                  */
>                 cachethis |= nfsd4_cache_this_op(op);
> +
> +               max_reply = max(max_reply, nfsd4_max_reply(op->opnum));
>         }
>         /* Sessions make the DRC unnecessary: */
>         if (argp->minorversion)
>                 cachethis = false;
> +       if (max_reply != INT_MAX)
> +               svc_reserve(argp->rqstp, max_reply);
>         argp->rqstp->rq_cachetype = cachethis ? RC_REPLBUFF : RC_NOCACHE;
>
>         DECODE_TAIL;
