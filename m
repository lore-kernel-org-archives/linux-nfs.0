Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f195.google.com ([209.85.217.195]:46183 "EHLO
        mail-ua0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754339AbdJSSeW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Oct 2017 14:34:22 -0400
Received: by mail-ua0-f195.google.com with SMTP id w45so6675295uac.3
        for <linux-nfs@vger.kernel.org>; Thu, 19 Oct 2017 11:34:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171019181718.GF16942@parsley.fieldses.org>
References: <CAN-5tyEXeesbAk02LsGDjwoBqZr6q8AzWUhMSV0-V2aUwm44dA@mail.gmail.com>
 <1508361919-30495-1-git-send-email-bfields@redhat.com> <CAN-5tyHBv9iFfTEPTgCfNyBo9veiqWiD_2xzVwhHjQ_tNdMFZw@mail.gmail.com>
 <20171019181718.GF16942@parsley.fieldses.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 19 Oct 2017 14:34:20 -0400
Message-ID: <CAN-5tyFCBrfLnw91R5awik6+miCO7vGfB-K40D1yQw-+nJ6eiQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] nfsd4: fix cached replies to solo SEQUENCE compounds
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 19, 2017 at 2:17 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> On Thu, Oct 19, 2017 at 01:21:46PM -0400, Olga Kornievskaia wrote:
>> On Wed, Oct 18, 2017 at 5:25 PM, J. Bruce Fields <bfields@redhat.com> wrote:
>> > From: "J. Bruce Fields" <bfields@redhat.com>
>> >
>> > Currently our handling of 4.1+ requests without "cachethis" set is
>> > confusing and not quite correct.
>> >
>> > Suppose a client sends a compound consisting of only a single SEQUENCE
>> > op, and it matches the seqid in a session slot (so it's a retry), but
>> > the previous request with that seqid did not have "cachethis" set.
>> >
>> > The obvious thing to do might be to return NFS4ERR_RETRY_UNCACHED_REP,
>> > but the protocol only allows that to be returned on the op following the
>> > SEQUENCE, and there is no such op in this case.
>> >
>> > The protocol permits us to cache replies even if the client didn't ask
>> > us to.  And it's easy to do so in the case of solo SEQUENCE compounds.
>> >
>> > So, when we get a solo SEQUENCE, we can either return the previously
>> > cached reply or NFSERR_SEQ_FALSE_RETRY if we notice it differs in some
>> > way from the original call.
>>
>> I'm confused in my testing the error was SEQ_MISORDERED and not
>> SEQ_FALSE_RETRY error?
>
> Yes, I must have a typo somewhere, but I haven't spotted it yet.  That
> was with both patches applied?

Yes both patches.

> --b.
>
>>
>> > Currently, we're returning a corrupt reply in the case a solo SEQUENCE
>> > matches a previous compound with more ops.  This actually matters
>> > because the Linux client recently started doing this as a way to recover
>> > from lost replies to idempotent operations in the case the process doing
>> > the original reply was killed: in that case it's difficult to keep the
>> > original arguments around to do a real retry, and the client no longer
>> > cares what the result is anyway, but it would like to make sure that the
>> > slot's sequence id has been incremented, and the solo SEQUENCE assures
>> > that: if the server never got the original reply, it will increment the
>> > sequence id.  If it did get the original reply, it won't increment, and
>> > nothing else that about the reply really matters much.  But we can at
>> > least attempt to return valid xdr!
>> >
>> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
>> > ---
>> >  fs/nfsd/nfs4state.c | 23 ++++++++++++++++-------
>> >  fs/nfsd/state.h     |  1 +
>> >  fs/nfsd/xdr4.h      | 13 +++++++++++--
>> >  3 files changed, 28 insertions(+), 9 deletions(-)
>> >
>> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> > index 9db8a19cceaa..7bd3ad88b85c 100644
>> > --- a/fs/nfsd/nfs4state.c
>> > +++ b/fs/nfsd/nfs4state.c
>> > @@ -2292,14 +2292,15 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
>> >
>> >         dprintk("--> %s slot %p\n", __func__, slot);
>> >
>> > -       slot->sl_opcnt = resp->opcnt;
>> > -       slot->sl_status = resp->cstate.status;
>> > -
>> >         slot->sl_flags |= NFSD4_SLOT_INITIALIZED;
>> > -       if (nfsd4_not_cached(resp)) {
>> > -               slot->sl_datalen = 0;
>> > +       if (!nfsd4_cache_this(resp)) {
>> > +               slot->sl_flags &= !NFSD4_SLOT_CACHED;
>> >                 return;
>> >         }
>> > +       slot->sl_flags |= NFSD4_SLOT_CACHED;
>> > +       slot->sl_opcnt = resp->opcnt;
>> > +       slot->sl_status = resp->cstate.status;
>> > +
>> >         base = resp->cstate.data_offset;
>> >         slot->sl_datalen = buf->len - base;
>> >         if (read_bytes_from_xdr_buf(buf, base, slot->sl_data, slot->sl_datalen))
>> > @@ -2326,8 +2327,16 @@ nfsd4_enc_sequence_replay(struct nfsd4_compoundargs *args,
>> >         op = &args->ops[resp->opcnt - 1];
>> >         nfsd4_encode_operation(resp, op);
>> >
>> > -       /* Return nfserr_retry_uncached_rep in next operation. */
>> > -       if (args->opcnt > 1 && !(slot->sl_flags & NFSD4_SLOT_CACHETHIS)) {
>> > +       if (slot->sl_flags & NFSD4_SLOT_CACHED)
>> > +               return op->status;
>> > +       if (args->opcnt == 1) {
>> > +               /*
>> > +                * The original operation wasn't a solo sequence--we
>> > +                * always cache those--so this retry must not match the
>> > +                * original:
>> > +                */
>> > +               op->status = nfserr_seq_false_retry;
>> > +       } else {
>> >                 op = &args->ops[resp->opcnt++];
>> >                 op->status = nfserr_retry_uncached_rep;
>> >                 nfsd4_encode_operation(resp, op);
>> > diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
>> > index 005c911b34ac..2488b7df1b35 100644
>> > --- a/fs/nfsd/state.h
>> > +++ b/fs/nfsd/state.h
>> > @@ -174,6 +174,7 @@ struct nfsd4_slot {
>> >  #define NFSD4_SLOT_INUSE       (1 << 0)
>> >  #define NFSD4_SLOT_CACHETHIS   (1 << 1)
>> >  #define NFSD4_SLOT_INITIALIZED (1 << 2)
>> > +#define NFSD4_SLOT_CACHED      (1 << 3)
>> >         u8      sl_flags;
>> >         char    sl_data[];
>> >  };
>> > diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
>> > index 1e4edbf70052..bc29511b6405 100644
>> > --- a/fs/nfsd/xdr4.h
>> > +++ b/fs/nfsd/xdr4.h
>> > @@ -649,9 +649,18 @@ static inline bool nfsd4_is_solo_sequence(struct nfsd4_compoundres *resp)
>> >         return resp->opcnt == 1 && args->ops[0].opnum == OP_SEQUENCE;
>> >  }
>> >
>> > -static inline bool nfsd4_not_cached(struct nfsd4_compoundres *resp)
>> > +/*
>> > + * The session reply cache only needs to cache replies that the client
>> > + * actually asked us to.  But it's almost free for us to cache compounds
>> > + * consisting of only a SEQUENCE op, so we may as well cache those too.
>> > + * Also, the protocol doesn't give us a convenient response in the case
>> > + * of a replay of a solo SEQUENCE op that wasn't cached
>> > + * (RETRY_UNCACHED_REP can only be returned in the second op of a
>> > + * compound).
>> > + */
>> > +static inline bool nfsd4_cache_this(struct nfsd4_compoundres *resp)
>> >  {
>> > -       return !(resp->cstate.slot->sl_flags & NFSD4_SLOT_CACHETHIS)
>> > +       return (resp->cstate.slot->sl_flags & NFSD4_SLOT_CACHETHIS)
>> >                 || nfsd4_is_solo_sequence(resp);
>> >  }
>> >
>> > --
>> > 2.13.5
>> >
>> > --
>> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> > the body of a message to majordomo@vger.kernel.org
>> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
