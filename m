Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50423 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751496Ab0J1Twt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Oct 2010 15:52:49 -0400
Subject: Re: [PATCH] nfs4: The difference of 2 pointers is size_t
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
        Linux Kernel Development <linux-kernel@vger.kernel.org>
In-Reply-To: <AANLkTimyNXV9K7hfz9CzmHa8CYMYdhi+zOgZzAT+CesQ@mail.gmail.com>
References: <alpine.DEB.2.00.1010282004390.31018@ayla.of.borg>
	 <20101028112535.442f47a7.akpm@linux-foundation.org>
	 <AANLkTimyNXV9K7hfz9CzmHa8CYMYdhi+zOgZzAT+CesQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 28 Oct 2010 15:52:42 -0400
Message-ID: <1288295562.14221.24.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-10-28 at 20:38 +0200, Geert Uytterhoeven wrote:
> On Thu, Oct 28, 2010 at 20:25, Andrew Morton <akpm@linux-foundation.org> wrote:
> > On Thu, 28 Oct 2010 20:06:19 +0200 (CEST)
> > Geert Uytterhoeven <geert@linux-m68k.org> wrote:
> >
> >> On m68k, which is 32-bit:
> >>
> >> fs/nfs/nfs4proc.c: In function ___nfs41_sequence_done___:
> >> fs/nfs/nfs4proc.c:432: warning: format ___%ld___ expects type ___long int___, but argument 3 has type ___int___
> >> fs/nfs/nfs4proc.c: In function ___nfs4_setup_sequence___:
> >> fs/nfs/nfs4proc.c:576: warning: format ___%ld___ expects type ___long int___, but argument 5 has type ___int___
> >>
> >> On 32-bit, size_t is int; on 64-bit, size_t is long.
> >>
> >> Introduced by commit dfb4f309830359352539919f23accc59a20a3758 ("NFSv4.1: keep
> >> seq_res.sr_slot as pointer rather than an index")
> >>
> >> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> >> ---
> >>  fs/nfs/nfs4proc.c |    4 ++--
> >>  1 files changed, 2 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> >> index 32c8758..80229dc 100644
> >> --- a/fs/nfs/nfs4proc.c
> >> +++ b/fs/nfs/nfs4proc.c
> >> @@ -429,7 +429,7 @@ static int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *
> >>                * returned NFS4ERR_DELAY as per Section 2.10.6.2
> >>                * of RFC5661.
> >>                */
> >> -             dprintk("%s: slot=%ld seq=%d: Operation in progress\n",
> >> +             dprintk("%s: slot=%zd seq=%d: Operation in progress\n",
> >>                       __func__,
> >>                       res->sr_slot - res->sr_session->fc_slot_table.slots,
> >>                       res->sr_slot->seq_nr);
> >> @@ -573,7 +573,7 @@ int nfs4_setup_sequence(const struct nfs_server *server,
> >>               goto out;
> >>       }
> >>
> >> -     dprintk("--> %s clp %p session %p sr_slot %ld\n",
> >> +     dprintk("--> %s clp %p session %p sr_slot %zd\n",
> >>               __func__, session->clp, session, res->sr_slot ?
> >>                       res->sr_slot - session->fc_slot_table.slots : -1);
> >>
> >
> > I think it should formally be %t, for a ptrdiff_t.
> 
> You're correct.
> 
> I didn't know we "did" %t. I almost have enough fingers and toes to
> count its users ;-)
> 
> Gr{oetje,eeting}s,
> 
>                         Geert

I did a s/size_t/ptrdiff_t/, s/%z/%t/ to the above and committed the
result with no other changes.

Cheers
  Trond
