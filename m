From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [pnfs] [PATCH v2 21/47] nfsd41: nfsd DRC logic
Date: Wed, 1 Apr 2009 16:20:02 -0400
Message-ID: <89c397150904011320u2563d18fsbee6636c9a55b5f3@mail.gmail.com>
References: <49CDDFC2.4070402@panasas.com>
	 <1238229164-10922-1-git-send-email-bhalevy@panasas.com>
	 <20090331193044.GD20756@fieldses.org>
	 <89c397150904011201j3cc19794x4a017d4e97bcd8f5@mail.gmail.com>
	 <20090401191055.GE8899@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:44147 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756434AbZDAUUE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Apr 2009 16:20:04 -0400
Received: by yx-out-2324.google.com with SMTP id 31so205963yxl.1
        for <linux-nfs@vger.kernel.org>; Wed, 01 Apr 2009 13:20:02 -0700 (PDT)
In-Reply-To: <20090401191055.GE8899@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 1, 2009 at 3:10 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Wed, Apr 01, 2009 at 03:01:53PM -0400, William A. (Andy) Adamson wrote:
>> On Tue, Mar 31, 2009 at 3:30 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>> > On Sat, Mar 28, 2009 at 11:32:44AM +0300, Benny Halevy wrote:
>> >> From: Andy Adamson <andros@netapp.com>
>> >>
>> >> Replay a request in nfsd4_sequence.
>> >> Add a minorversion to struct nfsd4_compound_state.
>> >>
>> >> Pass the current slot to nfs4svc_encode_compound res via struct
>> >> nfsd4_compoundres to set an NFSv4.1 DRC entry.
>> >>
>> >> Signed-off-by: Andy Adamson<andros@netapp.com>
>> >> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> >> [nfsd41: use bool inuse for slot state]
>> >> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> >> ---
>> >>  fs/nfsd/nfs4proc.c        |    7 +++++++
>> >>  fs/nfsd/nfs4state.c       |    6 ++++++
>> >>  fs/nfsd/nfs4xdr.c         |   13 +++++++++++++
>> >>  include/linux/nfsd/xdr4.h |    1 +
>> >>  4 files changed, 27 insertions(+), 0 deletions(-)
>> >>
>> >> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
>> >> index e703ac2..bdbeb87 100644
>> >> --- a/fs/nfsd/nfs4proc.c
>> >> +++ b/fs/nfsd/nfs4proc.c
>> >> @@ -920,6 +920,12 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
>> >>                       BUG_ON(op->status == nfs_ok);
>> >>
>> >>  encode_op:
>> >> +             /* Only from SEQUENCE or CREATE_SESSION */
>> >> +             if (resp->cstate.status == nfserr_replay_cache) {
>> >> +                     dprintk("%s NFS4.1 replay from cache\n", __func__);
>> >> +                     status = op->status;
>> >> +                     goto out;
>> >> +             }
>> >>               if (op->status == nfserr_replay_me) {
>> >>                       op->replay = &cstate->replay_owner->so_replay;
>> >>                       nfsd4_encode_replay(resp, op);
>> >> @@ -948,6 +954,7 @@ encode_op:
>> >>               status = nfserr_jukebox;
>> >>       }
>> >>
>> >> +     resp->cstate.status = status;
>> >>       fh_put(&resp->cstate.current_fh);
>> >>       fh_put(&resp->cstate.save_fh);
>> >>       BUG_ON(resp->cstate.replay_owner);
>> >> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> >> index f0ce639..07c869d 100644
>> >> --- a/fs/nfsd/nfs4state.c
>> >> +++ b/fs/nfsd/nfs4state.c
>> >> @@ -997,6 +997,8 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp)
>> >>       }
>> >>
>> >>       resp->rqstp->rq_resused = entry->ce_resused;
>> >> +     resp->opcnt = entry->ce_opcnt;
>> >> +     resp->cstate.iovlen = entry->ce_datav.iov_len + entry->ce_rpchdrlen;
>> >>       status = entry->ce_status;
>> >>
>> >>       return status;
>> >> @@ -1217,6 +1219,10 @@ nfsd4_sequence(struct svc_rqst *rqstp,
>> >>       status = check_slot_seqid(seq->seqid, slot);
>> >>       if (status == nfserr_replay_cache) {
>> >>               cstate->slot = slot;
>> >> +             /* Return the cached reply status and set cstate->status
>> >> +              * for nfsd4_svc_encode_compoundres processing*/
>> >> +             status = nfsd4_replay_cache_entry(resp);
>> >> +             cstate->status = nfserr_replay_cache;
>> >>               goto replay_cache;
>> >>       }
>> >>       if (status)
>> >> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>> >> index c6b490e..57afb33 100644
>> >> --- a/fs/nfsd/nfs4xdr.c
>> >> +++ b/fs/nfsd/nfs4xdr.c
>> >> @@ -3059,6 +3059,19 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
>> >>               iov = &rqstp->rq_res.head[0];
>> >>       iov->iov_len = ((char*)resp->p) - (char*)iov->iov_base;
>> >>       BUG_ON(iov->iov_len > PAGE_SIZE);
>> >> +#ifdef CONFIG_NFSD_V4_1
>> >> +     if (resp->cstate.slot != NULL) {
>> >> +             if (resp->cstate.status == nfserr_replay_cache) {
>> >> +                     iov->iov_len = resp->cstate.iovlen;
>> >> +             } else {
>> >> +                     nfsd4_set_cache_entry(resp);
>> >> +                     dprintk("%s: SET SLOT STATE TO AVAILABLE\n", __func__);
>> >> +                     resp->cstate.slot->sl_inuse = 0;
>> >> +             }
>> >> +             if (resp->cstate.slot->sl_session)
>> >
>> > There's no way that sl_session could ever be NULL, so this check is
>> > unneeded.
>>
>> There should have been a comment.
>> CREATE_SESSION sets cstate->slot using the nfs4_client->cl_slot, a
>> single slot which it uses for the CREATE_SESSION replay cache. It does
>> not have a session.
>
> Hm.  In that case, there's no reference count on the client that holds
> the cl_slot structure, so is there anything preventing the cl_slot from
> being freed out from under us  by a concurrent expire_client()?

That is true, we don't bump the client cl_count....

>
> If that's correct: I'm not sure how to solve that problem with a minimum
> of special-casing.

Hmm. I see what you mean. We would like to take a reference to the
nfs4_client in nfsd4_create_session and drop it in
nfs4svc_encode_compoundres  if the session pointer is NULL.

if (resp->cstate->session)
        nfsd4_put_session(resp>cstate->session)
else
       nfsd4_put_client(???)

but - we currently have no nfs4_client back pointer (except in the
session which is null.......)


-->Andy

>
> --b.
>
>>
>>
>> >
>> > While we're at it: let's just eliminate the sl_session pointer from the
>> > slot.  I think all that would be needed would be a pointer to the
>> > session from the cstate, in addition to the pointer to the slot.
>>
>> OK.
>>
>> >
>> > --b.
>> >
>> >> +                     nfsd4_put_session(resp->cstate.slot->sl_session);
>> >> +     }
>> >> +#endif /* CONFIG_NFSD_V4_1 */
>> >>       return 1;
>> >>  }
>> >>
>> >> diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
>> >> index cde8947..5c0d376 100644
>> >> --- a/include/linux/nfsd/xdr4.h
>> >> +++ b/include/linux/nfsd/xdr4.h
>> >> @@ -51,6 +51,7 @@ struct nfsd4_compound_state {
>> >>       /* For sessions DRC */
>> >>       struct nfsd4_slot       *slot;
>> >>       __be32                  *statp;
>> >> +     size_t                  iovlen;
>> >>       u32                     status;
>> >>  };
>> >>
>> >> --
>> >> 1.6.2.1
>> >>
>> > _______________________________________________
>> > pNFS mailing list
>> > pNFS@linux-nfs.org
>> > http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
>> >
>
