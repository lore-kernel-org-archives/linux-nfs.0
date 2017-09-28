Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44622 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750775AbdI1Toz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 28 Sep 2017 15:44:55 -0400
Date: Thu, 28 Sep 2017 15:44:47 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v4 03/10] NFSD OFFLOAD_CANCEL xdr
Message-ID: <20170928194447.GQ10182@parsley.fieldses.org>
References: <20170928172945.50780-1-kolga@netapp.com>
 <20170928172945.50780-4-kolga@netapp.com>
 <20170928193452.GP10182@parsley.fieldses.org>
 <CAN-5tyEb4vx3RD8uRabJY8Kc6FBkbxVWdg1xC+jt7_CVojhRjQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAN-5tyEb4vx3RD8uRabJY8Kc6FBkbxVWdg1xC+jt7_CVojhRjQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 28, 2017 at 03:40:47PM -0400, Olga Kornievskaia wrote:
> On Thu, Sep 28, 2017 at 3:34 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> > On Thu, Sep 28, 2017 at 01:29:38PM -0400, Olga Kornievskaia wrote:
> >> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> >> ---
> >>  fs/nfsd/nfs4proc.c | 13 +++++++++++++
> >>  fs/nfsd/nfs4xdr.c  |  2 +-
> >>  2 files changed, 14 insertions(+), 1 deletion(-)
> >>
> >> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> >> index 8601fc4..11ade90 100644
> >> --- a/fs/nfsd/nfs4proc.c
> >> +++ b/fs/nfsd/nfs4proc.c
> >> @@ -1121,6 +1121,14 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
> >>  }
> >>
> >>  static __be32
> >> +nfsd4_offload_cancel(struct svc_rqst *rqstp,
> >> +                  struct nfsd4_compound_state *cstate,
> >> +                  union nfsd4_op_u *u)
> >> +{
> >> +     return 0;
> >> +}
> >> +
> >> +static __be32
> >>  nfsd4_fallocate(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >>               struct nfsd4_fallocate *fallocate, int flags)
> >>  {
> >> @@ -2472,6 +2480,11 @@ static inline u32 nfsd4_seek_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
> >>               .op_name = "OP_OFFLOAD_STATUS",
> >>               .op_rsize_bop = nfsd4_offload_status_rsize,
> >>       },
> >> +     [OP_OFFLOAD_CANCEL] = {
> >
> > I think you want .op_flags = OP_MODIFIES_SOMETHING as well.
> 
> Got it. Is it because it modifies state of the server? I guess I'm not
> clear what OP_MODIFIES_SOMETHING represents.

If OP_MODIFIES_SOMETHING is set then we will refuse to perform the
operation if it looks like we might run out of space to encode the
result.

Eh, now that I think about it I'm not actually sure if it matters for an
operation like this.  Probably doesn't hurt.

--b.

> 
> 
> >> +             .op_func = nfsd4_offload_cancel,
> >> +             .op_name = "OP_OFFLOAD_CANCEL",
> >> +             .op_rsize_bop = nfsd4_only_status_rsize,
> >> +     },
> >>  };
> >>
> >>  /**
> >> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> >> index ed8b61f..31ee5e1 100644
> >> --- a/fs/nfsd/nfs4xdr.c
> >> +++ b/fs/nfsd/nfs4xdr.c
> >> @@ -1880,7 +1880,7 @@ static __be32 nfsd4_decode_reclaim_complete(struct nfsd4_compoundargs *argp, str
> >>       [OP_IO_ADVISE]          = (nfsd4_dec)nfsd4_decode_notsupp,
> >>       [OP_LAYOUTERROR]        = (nfsd4_dec)nfsd4_decode_notsupp,
> >>       [OP_LAYOUTSTATS]        = (nfsd4_dec)nfsd4_decode_notsupp,
> >> -     [OP_OFFLOAD_CANCEL]     = (nfsd4_dec)nfsd4_decode_notsupp,
> >> +     [OP_OFFLOAD_CANCEL]     = (nfsd4_dec)nfsd4_decode_offload_status,
> >>       [OP_OFFLOAD_STATUS]     = (nfsd4_dec)nfsd4_decode_offload_status,
> >>       [OP_READ_PLUS]          = (nfsd4_dec)nfsd4_decode_notsupp,
> >>       [OP_SEEK]               = (nfsd4_dec)nfsd4_decode_seek,
> >> --
> >> 1.8.3.1
> >>
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
