From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [pnfs] [PATCH 5/5] nfsd41: replace page based DRC with buffer
	based DRC
Date: Tue, 1 Sep 2009 11:14:56 -0400
Message-ID: <20090901151456.GB22846@fieldses.org>
References: <1251389264-3009-1-git-send-email-andros@netapp.com> <1251389264-3009-2-git-send-email-andros@netapp.com> <1251389264-3009-3-git-send-email-andros@netapp.com> <1251389264-3009-4-git-send-email-andros@netapp.com> <1251389264-3009-5-git-send-email-andros@netapp.com> <1251389264-3009-6-git-send-email-andros@netapp.com> <20090828213323.GD2462@fieldses.org> <89c397150909010648v4a4f5db8t87e09717e5a2c950@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50790 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753837AbZIAPOy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Sep 2009 11:14:54 -0400
In-Reply-To: <89c397150909010648v4a4f5db8t87e09717e5a2c950-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 01, 2009 at 09:48:41AM -0400, William A. (Andy) Adamson wro=
te:
> On Fri, Aug 28, 2009 at 5:33 PM, J. Bruce Fields<bfields@fieldses.org=
> wrote:
> > On Thu, Aug 27, 2009 at 12:07:44PM -0400, andros@netapp.com wrote:
> >> From: Andy Adamson <andros@netapp.com>
> >>
> >> Use NFSD_SLOT_CACHE_SIZE size buffers for sessions DRC instead of =
holding nfsd
> >> pages in cache.
> >>
> >> Connectathon testing has shown that 1024 bytes for encoded compoun=
d operation
> >> responses past the sequence operation is sufficient, 512 bytes is =
a little too
> >> small. Set NFSD_SLOT_CACHE_SIZE to 1024.
> >>
> >> Allocate memory for the session DRC in the CREATE_SESSION operatio=
n
> >> to guarantee that the memory resource is available for caching res=
ponses.
> >> Allocate each slot individually in preparation for slot table size=
 negotiation.
> >>
> >> Remove struct nfsd4_cache_entry and helper functions for the old p=
age-based
> >> DRC.
> >>
> >> The iov_len calculation in nfs4svc_encode_compoundres is now alway=
s
> >> correct, clean up the nfs4svc_encode_compoundres session logic.
> >>
> >> The nfsd4_compound_state statp pointer is also not used.
> >> Remove nfsd4_set_statp().
> >>
> >> Move useful nfsd4_cache_entry fields into nfsd4_slot.
> >>
> >> Signed-off-by: Andy Adamson <andros@netapp.com
> >> ---
> >> =C2=A0fs/nfsd/nfs4state.c =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0207 +=
+++++++++++--------------------------------
> >> =C2=A0fs/nfsd/nfs4xdr.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0=
 13 ++--
> >> =C2=A0fs/nfsd/nfssvc.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0=
 =C2=A04 -
> >> =C2=A0include/linux/nfsd/state.h | =C2=A0 27 ++----
> >> =C2=A0include/linux/nfsd/xdr4.h =C2=A0| =C2=A0 =C2=A05 +-
> >> =C2=A05 files changed, 74 insertions(+), 182 deletions(-)
> >>
> >> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> >> index 4695cec..2d72d5c 100644
> >> --- a/fs/nfsd/nfs4state.c
> >> +++ b/fs/nfsd/nfs4state.c
> >> @@ -510,12 +510,22 @@ static int init_forechannel_attrs(struct svc=
_rqst *rqstp,
> >> =C2=A0 =C2=A0 =C2=A0 return status;
> >> =C2=A0}
> >>
> >> +static void
> >> +free_session_slots(struct nfsd4_session *ses)
> >> +{
> >> + =C2=A0 =C2=A0 int i;
> >> +
> >> + =C2=A0 =C2=A0 for (i =3D 0; i < ses->se_fchannel.maxreqs; i++)
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 kfree(ses->se_slots[i]=
);
> >> +}
> >> +
> >> =C2=A0static int
> >> =C2=A0alloc_init_session(struct svc_rqst *rqstp, struct nfs4_clien=
t *clp,
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0stru=
ct nfsd4_create_session *cses)
> >> =C2=A0{
> >> =C2=A0 =C2=A0 =C2=A0 struct nfsd4_session *new, tmp;
> >> - =C2=A0 =C2=A0 int idx, status =3D nfserr_serverfault, slotsize;
> >> + =C2=A0 =C2=A0 struct nfsd4_slot *sp;
> >> + =C2=A0 =C2=A0 int idx, status =3D nfserr_serverfault, slotsize, =
cachesize, i;
> >
> > Just as a style thing: that list's getting a little long. =C2=A0Cou=
ld you
> > keep at least "status" on a separate line?
> >
> >>
> >> =C2=A0 =C2=A0 =C2=A0 memset(&tmp, 0, sizeof(tmp));
> >>
> >> @@ -526,14 +536,23 @@ alloc_init_session(struct svc_rqst *rqstp, s=
truct nfs4_client *clp,
> >> =C2=A0 =C2=A0 =C2=A0 if (status)
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
> >>
> >> - =C2=A0 =C2=A0 /* allocate struct nfsd4_session and slot table in=
 one piece */
> >> - =C2=A0 =C2=A0 slotsize =3D tmp.se_fchannel.maxreqs * sizeof(stru=
ct nfsd4_slot);
> >> + =C2=A0 =C2=A0 /* allocate struct nfsd4_session and slot table po=
inters in one piece */
> >> + =C2=A0 =C2=A0 slotsize =3D tmp.se_fchannel.maxreqs * sizeof(stru=
ct nfsd4_slot *);
> >> =C2=A0 =C2=A0 =C2=A0 new =3D kzalloc(sizeof(*new) + slotsize, GFP_=
KERNEL);
> >
> > I think this is OK for now, but maybe stick something like:
> >
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0BUILD_BUG_ON(NFSD_MAX_SLOTS_PER_SESSION =
* sizeof(struct nfsd4_slot)
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0+ sizeof(struct nfsd4_session) > PAGE_SIZE);
> >
> > in state.h just to warn anyone who wants to blindly bump up
> > NFSD_MAX_SLOTS_PER_SESSION. =C2=A0(It's not really forbidden to kma=
lloc more
> > than a page, but it's also not reliable, and if it becomes necessar=
y
> > then we'd rather find some way to code around it.)
> >
> >> =C2=A0 =C2=A0 =C2=A0 if (!new)
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
> >>
> >> =C2=A0 =C2=A0 =C2=A0 memcpy(new, &tmp, sizeof(*new));
> >>
> >> + =C2=A0 =C2=A0 /* allocate each struct nfsd4_slot and data cache =
in one piece */
> >> + =C2=A0 =C2=A0 cachesize =3D new->se_fchannel.maxresp_cached - NF=
SD_MIN_HDR_SEQ_SZ;
> >> + =C2=A0 =C2=A0 for (i =3D 0; i < new->se_fchannel.maxreqs; i++) {
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sp =3D kzalloc(sizeof(=
*sp) + cachesize, GFP_KERNEL);
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!sp)
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 goto out_free;
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 new->se_slots[i] =3D s=
p;
> >> + =C2=A0 =C2=A0 }
> >> +
> >> =C2=A0 =C2=A0 =C2=A0 new->se_client =3D clp;
> >> =C2=A0 =C2=A0 =C2=A0 gen_sessionid(new);
> >> =C2=A0 =C2=A0 =C2=A0 idx =3D hash_sessionid(&new->se_sessionid);
> >> @@ -550,6 +569,10 @@ alloc_init_session(struct svc_rqst *rqstp, st=
ruct nfs4_client *clp,
> >> =C2=A0 =C2=A0 =C2=A0 status =3D nfs_ok;
> >> =C2=A0out:
> >> =C2=A0 =C2=A0 =C2=A0 return status;
> >> +out_free:
> >> + =C2=A0 =C2=A0 free_session_slots(new);
> >> + =C2=A0 =C2=A0 kfree(new);
> >> + =C2=A0 =C2=A0 goto out;
> >> =C2=A0}
> >>
> >> =C2=A0/* caller must hold sessionid_lock */
> >> @@ -592,22 +615,16 @@ release_session(struct nfsd4_session *ses)
> >> =C2=A0 =C2=A0 =C2=A0 nfsd4_put_session(ses);
> >> =C2=A0}
> >>
> >> -static void nfsd4_release_respages(struct page **respages, short =
resused);
> >> -
> >> =C2=A0void
> >> =C2=A0free_session(struct kref *kref)
> >> =C2=A0{
> >> =C2=A0 =C2=A0 =C2=A0 struct nfsd4_session *ses;
> >> - =C2=A0 =C2=A0 int i;
> >>
> >> =C2=A0 =C2=A0 =C2=A0 ses =3D container_of(kref, struct nfsd4_sessi=
on, se_ref);
> >> - =C2=A0 =C2=A0 for (i =3D 0; i < ses->se_fchannel.maxreqs; i++) {
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct nfsd4_cache_ent=
ry *e =3D &ses->se_slots[i].sl_cache_entry;
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nfsd4_release_respages=
(e->ce_respages, e->ce_resused);
> >> - =C2=A0 =C2=A0 }
> >> =C2=A0 =C2=A0 =C2=A0 spin_lock(&nfsd_drc_lock);
> >> =C2=A0 =C2=A0 =C2=A0 nfsd_drc_mem_used -=3D ses->se_fchannel.maxre=
qs * NFSD_SLOT_CACHE_SIZE;
> >> =C2=A0 =C2=A0 =C2=A0 spin_unlock(&nfsd_drc_lock);
> >> + =C2=A0 =C2=A0 free_session_slots(ses);
> >> =C2=A0 =C2=A0 =C2=A0 kfree(ses);
> >> =C2=A0}
> >>
> >> @@ -964,116 +981,32 @@ out_err:
> >> =C2=A0 =C2=A0 =C2=A0 return;
> >> =C2=A0}
> >>
> >> -void
> >> -nfsd4_set_statp(struct svc_rqst *rqstp, __be32 *statp)
> >> -{
> >> - =C2=A0 =C2=A0 struct nfsd4_compoundres *resp =3D rqstp->rq_resp;
> >> -
> >> - =C2=A0 =C2=A0 resp->cstate.statp =3D statp;
> >> -}
> >> -
> >> -/*
> >> - * Dereference the result pages.
> >> - */
> >> -static void
> >> -nfsd4_release_respages(struct page **respages, short resused)
> >> -{
> >> - =C2=A0 =C2=A0 int i;
> >> -
> >> - =C2=A0 =C2=A0 dprintk("--> %s\n", __func__);
> >> - =C2=A0 =C2=A0 for (i =3D 0; i < resused; i++) {
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!respages[i])
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 continue;
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 put_page(respages[i]);
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 respages[i] =3D NULL;
> >> - =C2=A0 =C2=A0 }
> >> -}
> >> -
> >> -static void
> >> -nfsd4_copy_pages(struct page **topages, struct page **frompages, =
short count)
> >> -{
> >> - =C2=A0 =C2=A0 int i;
> >> -
> >> - =C2=A0 =C2=A0 for (i =3D 0; i < count; i++) {
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 topages[i] =3D frompag=
es[i];
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!topages[i])
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 continue;
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 get_page(topages[i]);
> >> - =C2=A0 =C2=A0 }
> >> -}
> >> -
> >> =C2=A0/*
> >> - * Cache the reply pages up to NFSD_PAGES_PER_SLOT + 1, clearing =
the previous
> >> - * pages. We add a page to NFSD_PAGES_PER_SLOT for the case where=
 the total
> >> - * length of the XDR response is less than se_fmaxresp_cached
> >> - * (NFSD_PAGES_PER_SLOT * PAGE_SIZE) but the xdr_buf pages is use=
d for a
> >> - * of the reply (e.g. readdir).
> >> - *
> >> - * Store the base and length of the rq_req.head[0] page
> >> - * of the NFSv4.1 data, just past the rpc header.
> >> + * Cache a reply. nfsd4_check_drc_limit() has bounded the cache s=
ize.
> >> =C2=A0 */
> >> =C2=A0void
> >> =C2=A0nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
> >> =C2=A0{
> >> - =C2=A0 =C2=A0 struct nfsd4_cache_entry *entry =3D &resp->cstate.=
slot->sl_cache_entry;
> >> - =C2=A0 =C2=A0 struct svc_rqst *rqstp =3D resp->rqstp;
> >> - =C2=A0 =C2=A0 struct kvec *resv =3D &rqstp->rq_res.head[0];
> >> -
> >> - =C2=A0 =C2=A0 dprintk("--> %s entry %p\n", __func__, entry);
> >> + =C2=A0 =C2=A0 struct nfsd4_slot *slot =3D resp->cstate.slot;
> >> + =C2=A0 =C2=A0 unsigned int base;
> >>
> >> - =C2=A0 =C2=A0 nfsd4_release_respages(entry->ce_respages, entry->=
ce_resused);
> >> - =C2=A0 =C2=A0 entry->ce_opcnt =3D resp->opcnt;
> >> - =C2=A0 =C2=A0 entry->ce_status =3D resp->cstate.status;
> >> + =C2=A0 =C2=A0 dprintk("--> %s slot %p\n", __func__, slot);
> >>
> >> - =C2=A0 =C2=A0 /*
> >> - =C2=A0 =C2=A0 =C2=A0* Don't need a page to cache just the sequen=
ce operation - the slot
> >> - =C2=A0 =C2=A0 =C2=A0* does this for us!
> >> - =C2=A0 =C2=A0 =C2=A0*/
> >> + =C2=A0 =C2=A0 slot->sl_opcnt =3D resp->opcnt;
> >> + =C2=A0 =C2=A0 slot->sl_status =3D resp->cstate.status;
> >>
> >> =C2=A0 =C2=A0 =C2=A0 if (nfsd4_not_cached(resp)) {
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 entry->ce_resused =3D =
0;
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 entry->ce_rpchdrlen =3D=
 0;
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dprintk("%s Just cache=
 SEQUENCE. ce_cachethis %d\n", __func__,
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 resp->cstate.slot->sl_cache_entry.ce_cachethis);
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 slot->sl_datalen =3D 0=
;
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
> >> =C2=A0 =C2=A0 =C2=A0 }
> >> - =C2=A0 =C2=A0 entry->ce_resused =3D rqstp->rq_resused;
> >> - =C2=A0 =C2=A0 if (entry->ce_resused > NFSD_PAGES_PER_SLOT + 1)
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 entry->ce_resused =3D =
NFSD_PAGES_PER_SLOT + 1;
> >> - =C2=A0 =C2=A0 nfsd4_copy_pages(entry->ce_respages, rqstp->rq_res=
pages,
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0entry->ce_resused);
> >> - =C2=A0 =C2=A0 entry->ce_datav.iov_base =3D resp->cstate.statp;
> >> - =C2=A0 =C2=A0 entry->ce_datav.iov_len =3D resv->iov_len - ((char=
 *)resp->cstate.statp -
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (char *)page_address(rqstp->rq_respages=
[0]));
> >> - =C2=A0 =C2=A0 /* Current request rpc header length*/
> >> - =C2=A0 =C2=A0 entry->ce_rpchdrlen =3D (char *)resp->cstate.statp=
 -
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (char *)page_address(rqstp->rq_respages=
[0]);
> >> -}
> >> -
> >> -/*
> >> - * We keep the rpc header, but take the nfs reply from the replyc=
ache.
> >> - */
> >> -static int
> >> -nfsd41_copy_replay_data(struct nfsd4_compoundres *resp,
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 struct nfsd4_cache_entry *entry)
> >> -{
> >> - =C2=A0 =C2=A0 struct svc_rqst *rqstp =3D resp->rqstp;
> >> - =C2=A0 =C2=A0 struct kvec *resv =3D &resp->rqstp->rq_res.head[0]=
;
> >> - =C2=A0 =C2=A0 int len;
> >> -
> >> - =C2=A0 =C2=A0 /* Current request rpc header length*/
> >> - =C2=A0 =C2=A0 len =3D (char *)resp->cstate.statp -
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 (char *)page_address(rqstp->rq_respages[0]);
> >> - =C2=A0 =C2=A0 if (entry->ce_datav.iov_len + len > PAGE_SIZE) {
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dprintk("%s v41 cached=
 reply too large (%Zd).\n", __func__,
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 entry->ce_datav.iov_len);
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
> >> - =C2=A0 =C2=A0 }
> >> - =C2=A0 =C2=A0 /* copy the cached reply nfsd data past the curren=
t rpc header */
> >> - =C2=A0 =C2=A0 memcpy((char *)resv->iov_base + len, entry->ce_dat=
av.iov_base,
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 entry->ce_datav.iov_le=
n);
> >> - =C2=A0 =C2=A0 resv->iov_len =3D len + entry->ce_datav.iov_len;
> >> - =C2=A0 =C2=A0 return 1;
> >> + =C2=A0 =C2=A0 slot->sl_datalen =3D (char *)resp->p - (char *)res=
p->cstate.datap;
> >> + =C2=A0 =C2=A0 base =3D (char *)resp->cstate.datap -
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (char *)res=
p->xbuf->head[0].iov_base;
> >> + =C2=A0 =C2=A0 if (read_bytes_from_xdr_buf(resp->xbuf, base, slot=
->sl_data,
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 slot->sl_datalen))
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 printk(KERN_WARNING
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 "nfsd: sessions DRC could not cache compound\n");
> >
> > I'd make this WARN("nfsd:...") just to make it completely clear it'=
s a
> > kernel bug. =C2=A0(This case should be caught by nfsd4_check_drc_li=
mit unless
> > we've messed something up, right?)
> >
> >> + =C2=A0 =C2=A0 return;
> >> =C2=A0}
> >>
> >> =C2=A0/*
> >> @@ -1091,14 +1024,14 @@ nfsd4_enc_sequence_replay(struct nfsd4_com=
poundargs *args,
> >> =C2=A0 =C2=A0 =C2=A0 struct nfsd4_slot *slot =3D resp->cstate.slot=
;
> >>
> >> =C2=A0 =C2=A0 =C2=A0 dprintk("--> %s resp->opcnt %d cachethis %u \=
n", __func__,
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 resp->opcnt, resp->cst=
ate.slot->sl_cache_entry.ce_cachethis);
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 resp->opcnt, resp->cst=
ate.slot->sl_cachethis);
> >>
> >> =C2=A0 =C2=A0 =C2=A0 /* Encode the replayed sequence operation */
> >> =C2=A0 =C2=A0 =C2=A0 op =3D &args->ops[resp->opcnt - 1];
> >> =C2=A0 =C2=A0 =C2=A0 nfsd4_encode_operation(resp, op);
> >>
> >> =C2=A0 =C2=A0 =C2=A0 /* Return nfserr_retry_uncached_rep in next o=
peration. */
> >> - =C2=A0 =C2=A0 if (args->opcnt > 1 && slot->sl_cache_entry.ce_cac=
hethis =3D=3D 0) {
> >> + =C2=A0 =C2=A0 if (args->opcnt > 1 && slot->sl_cachethis =3D=3D 0=
) {
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 op =3D &args->ops=
[resp->opcnt++];
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 op->status =3D nf=
serr_retry_uncached_rep;
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nfsd4_encode_oper=
ation(resp, op);
> >> @@ -1107,57 +1040,29 @@ nfsd4_enc_sequence_replay(struct nfsd4_com=
poundargs *args,
> >> =C2=A0}
> >>
> >> =C2=A0/*
> >> - * Keep the first page of the replay. Copy the NFSv4.1 data from =
the first
> >> - * cached page. =C2=A0Replace any futher replay pages from the ca=
che.
> >> + * The sequence operation is not cached because we can use the sl=
ot and
> >> + * session values.
> >> =C2=A0 */
> >> =C2=A0__be32
> >> =C2=A0nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0struct nfsd4_sequence *seq)
> >> =C2=A0{
> >> - =C2=A0 =C2=A0 struct nfsd4_cache_entry *entry =3D &resp->cstate.=
slot->sl_cache_entry;
> >> + =C2=A0 =C2=A0 struct nfsd4_slot *slot =3D resp->cstate.slot;
> >> =C2=A0 =C2=A0 =C2=A0 __be32 status;
> >>
> >> - =C2=A0 =C2=A0 dprintk("--> %s entry %p\n", __func__, entry);
> >> -
> >> - =C2=A0 =C2=A0 /*
> >> - =C2=A0 =C2=A0 =C2=A0* If this is just the sequence operation, we=
 did not keep
> >> - =C2=A0 =C2=A0 =C2=A0* a page in the cache entry because we can j=
ust use the
> >> - =C2=A0 =C2=A0 =C2=A0* slot info stored in struct nfsd4_sequence =
that was checked
> >> - =C2=A0 =C2=A0 =C2=A0* against the slot in nfsd4_sequence().
> >> - =C2=A0 =C2=A0 =C2=A0*
> >> - =C2=A0 =C2=A0 =C2=A0* This occurs when seq->cachethis is FALSE, =
or when the client
> >> - =C2=A0 =C2=A0 =C2=A0* session inactivity timer fires and a solo =
sequence operation
> >> - =C2=A0 =C2=A0 =C2=A0* is sent (lease renewal).
> >> - =C2=A0 =C2=A0 =C2=A0*/
> >> + =C2=A0 =C2=A0 dprintk("--> %s slot %p\n", __func__, slot);
> >>
> >> =C2=A0 =C2=A0 =C2=A0 /* Either returns 0 or nfserr_retry_uncached =
*/
> >> =C2=A0 =C2=A0 =C2=A0 status =3D nfsd4_enc_sequence_replay(resp->rq=
stp->rq_argp, resp);
> >> =C2=A0 =C2=A0 =C2=A0 if (status =3D=3D nfserr_retry_uncached_rep)
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return status;
> >>
> >> - =C2=A0 =C2=A0 if (!nfsd41_copy_replay_data(resp, entry)) {
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* Not enough roo=
m to use the replay rpc header, send the
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* cached header.=
 Release all the allocated result pages.
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 svc_free_res_pages(res=
p->rqstp);
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nfsd4_copy_pages(resp-=
>rqstp->rq_respages, entry->ce_respages,
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 entry->ce_resused);
> >> - =C2=A0 =C2=A0 } else {
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Release all but the=
 first allocated result page */
> >> -
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 resp->rqstp->rq_resuse=
d--;
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 svc_free_res_pages(res=
p->rqstp);
> >> -
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nfsd4_copy_pages(&resp=
->rqstp->rq_respages[1],
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0&entry->ce_respages[1],
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0entry->ce_resused - 1);
> >> - =C2=A0 =C2=A0 }
> >> + =C2=A0 =C2=A0 /* The sequence operation has been encoded, cstate=
->datap set. */
> >> + =C2=A0 =C2=A0 memcpy(resp->cstate.datap, slot->sl_data, slot->sl=
_datalen);
> >>
> >> - =C2=A0 =C2=A0 resp->rqstp->rq_resused =3D entry->ce_resused;
> >> - =C2=A0 =C2=A0 resp->opcnt =3D entry->ce_opcnt;
> >> - =C2=A0 =C2=A0 resp->cstate.iovlen =3D entry->ce_datav.iov_len + =
entry->ce_rpchdrlen;
> >> - =C2=A0 =C2=A0 status =3D entry->ce_status;
> >> + =C2=A0 =C2=A0 resp->opcnt =3D slot->sl_opcnt;
> >> + =C2=A0 =C2=A0 resp->p =3D resp->cstate.datap + XDR_QUADLEN(slot-=
>sl_datalen);
> >> + =C2=A0 =C2=A0 status =3D slot->sl_status;
> >>
> >> =C2=A0 =C2=A0 =C2=A0 return status;
> >> =C2=A0}
> >> @@ -1489,7 +1394,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
> >> =C2=A0 =C2=A0 =C2=A0 if (seq->slotid >=3D session->se_fchannel.max=
reqs)
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
> >>
> >> - =C2=A0 =C2=A0 slot =3D &session->se_slots[seq->slotid];
> >> + =C2=A0 =C2=A0 slot =3D session->se_slots[seq->slotid];
> >> =C2=A0 =C2=A0 =C2=A0 dprintk("%s: slotid %d\n", __func__, seq->slo=
tid);
> >>
> >> =C2=A0 =C2=A0 =C2=A0 /* We do not negotiate the number of slots ye=
t, so set the
> >> @@ -1502,7 +1407,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cstate->slot =3D =
slot;
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cstate->session =3D=
 session;
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Return the cac=
hed reply status and set cstate->status
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* for nfsd4_svc_=
encode_compoundres processing */
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* for nfsd4_proc=
_compound processing */
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 status =3D nfsd4_=
replay_cache_entry(resp, seq);
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cstate->status =3D=
 nfserr_replay_cache;
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto replay_cache=
;
> >> @@ -1513,7 +1418,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
> >> =C2=A0 =C2=A0 =C2=A0 /* Success! bump slot seqid */
> >> =C2=A0 =C2=A0 =C2=A0 slot->sl_inuse =3D true;
> >> =C2=A0 =C2=A0 =C2=A0 slot->sl_seqid =3D seq->seqid;
> >> - =C2=A0 =C2=A0 slot->sl_cache_entry.ce_cachethis =3D seq->cacheth=
is;
> >> + =C2=A0 =C2=A0 slot->sl_cachethis =3D seq->cachethis;
> >>
> >> =C2=A0 =C2=A0 =C2=A0 cstate->slot =3D slot;
> >> =C2=A0 =C2=A0 =C2=A0 cstate->session =3D session;
> >> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> >> index fdf632b..49824ea 100644
> >> --- a/fs/nfsd/nfs4xdr.c
> >> +++ b/fs/nfsd/nfs4xdr.c
> >> @@ -3064,6 +3064,7 @@ nfsd4_encode_sequence(struct nfsd4_compoundr=
es *resp, int nfserr,
> >> =C2=A0 =C2=A0 =C2=A0 WRITE32(0);
> >>
> >> =C2=A0 =C2=A0 =C2=A0 ADJUST_ARGS();
> >> + =C2=A0 =C2=A0 resp->cstate.datap =3D p; /* DRC cache data pointe=
r */
> >> =C2=A0 =C2=A0 =C2=A0 return 0;
> >> =C2=A0}
> >>
> >> @@ -3166,7 +3167,7 @@ static int nfsd4_check_drc_limit(struct nfsd=
4_compoundres *resp)
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return status;
> >>
> >> =C2=A0 =C2=A0 =C2=A0 session =3D resp->cstate.session;
> >> - =C2=A0 =C2=A0 if (session =3D=3D NULL || slot->sl_cache_entry.ce=
_cachethis =3D=3D 0)
> >> + =C2=A0 =C2=A0 if (session =3D=3D NULL || slot->sl_cachethis =3D=3D=
 0)
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return status;
> >>
> >> =C2=A0 =C2=A0 =C2=A0 if (resp->opcnt >=3D args->opcnt)
> >> @@ -3291,6 +3292,7 @@ nfs4svc_encode_compoundres(struct svc_rqst *=
rqstp, __be32 *p, struct nfsd4_compo
> >> =C2=A0 =C2=A0 =C2=A0 /*
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0* All that remains is to write the tag =
and operation count...
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> >> + =C2=A0 =C2=A0 struct nfsd4_compound_state *cs =3D &resp->cstate;
> >> =C2=A0 =C2=A0 =C2=A0 struct kvec *iov;
> >> =C2=A0 =C2=A0 =C2=A0 p =3D resp->tagp;
> >> =C2=A0 =C2=A0 =C2=A0 *p++ =3D htonl(resp->taglen);
> >> @@ -3304,14 +3306,11 @@ nfs4svc_encode_compoundres(struct svc_rqst=
 *rqstp, __be32 *p, struct nfsd4_compo
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 iov =3D &rqstp->r=
q_res.head[0];
> >> =C2=A0 =C2=A0 =C2=A0 iov->iov_len =3D ((char*)resp->p) - (char*)io=
v->iov_base;
> >> =C2=A0 =C2=A0 =C2=A0 BUG_ON(iov->iov_len > PAGE_SIZE);
> >> - =C2=A0 =C2=A0 if (nfsd4_has_session(&resp->cstate)) {
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (resp->cstate.statu=
s =3D=3D nfserr_replay_cache &&
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 !nfsd4_not_cached(resp)) {
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 iov->iov_len =3D resp->cstate.iovlen;
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 } else {
> >> + =C2=A0 =C2=A0 if (nfsd4_has_session(cs)) {
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (cs->status !=3D nf=
serr_replay_cache) {
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 nfsd4_store_cache_entry(resp);
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 dprintk("%s: SET SLOT STATE TO AVAILABLE\n", __func__);
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 resp->cstate.slot->sl_inuse =3D 0;
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 resp->cstate.slot->sl_inuse =3D false;
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nfsd4_put_session=
(resp->cstate.session);
> >> =C2=A0 =C2=A0 =C2=A0 }
> >> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> >> index d68cd05..944ef01 100644
> >> --- a/fs/nfsd/nfssvc.c
> >> +++ b/fs/nfsd/nfssvc.c
> >> @@ -576,10 +576,6 @@ nfsd_dispatch(struct svc_rqst *rqstp, __be32 =
*statp)
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 + rqstp->rq_res.h=
ead[0].iov_len;
> >> =C2=A0 =C2=A0 =C2=A0 rqstp->rq_res.head[0].iov_len +=3D sizeof(__b=
e32);
> >>
> >> - =C2=A0 =C2=A0 /* NFSv4.1 DRC requires statp */
> >> - =C2=A0 =C2=A0 if (rqstp->rq_vers =3D=3D 4)
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nfsd4_set_statp(rqstp,=
 statp);
> >> -
> >> =C2=A0 =C2=A0 =C2=A0 /* Now call the procedure handler, and encode=
 NFS status. */
> >> =C2=A0 =C2=A0 =C2=A0 nfserr =3D proc->pc_func(rqstp, rqstp->rq_arg=
p, rqstp->rq_resp);
> >> =C2=A0 =C2=A0 =C2=A0 nfserr =3D map_new_errors(rqstp->rq_vers, nfs=
err);
> >> diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state=
=2Eh
> >> index ff0b771..e745100 100644
> >> --- a/include/linux/nfsd/state.h
> >> +++ b/include/linux/nfsd/state.h
> >> @@ -94,30 +94,23 @@ struct nfs4_cb_conn {
> >>
> >> =C2=A0/* Maximum number of slots per session. 160 is useful for lo=
ng haul TCP */
> >> =C2=A0#define NFSD_MAX_SLOTS_PER_SESSION =C2=A0 =C2=A0 160
> >> -/* Maximum number of pages per slot cache entry */
> >> -#define NFSD_PAGES_PER_SLOT =C2=A01
> >> -#define NFSD_SLOT_CACHE_SIZE =C2=A0 =C2=A0 =C2=A0 =C2=A0 PAGE_SIZ=
E
> >> =C2=A0/* Maximum number of operations per session compound */
> >> =C2=A0#define NFSD_MAX_OPS_PER_COMPOUND =C2=A0 =C2=A016
> >> +/* Maximum =C2=A0session per slot cache size */
> >> +#define NFSD_SLOT_CACHE_SIZE =C2=A0 =C2=A0 =C2=A0 =C2=A0 1024
> >> =C2=A0/* Maximum number of NFSD_SLOT_CACHE_SIZE slots per session =
*/
> >> =C2=A0#define NFSD_CACHE_SIZE_SLOTS_PER_SESSION =C2=A0 =C2=A032
> >> =C2=A0#define NFSD_MAX_MEM_PER_SESSION =C2=A0\
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (NFSD_CACHE_SIZE_=
SLOTS_PER_SESSION * NFSD_SLOT_CACHE_SIZE)
> >>
> >> -struct nfsd4_cache_entry {
> >> - =C2=A0 =C2=A0 __be32 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ce_status=
;
> >> - =C2=A0 =C2=A0 struct kvec =C2=A0 =C2=A0 ce_datav; /* encoded NFS=
v4.1 data in rq_res.head[0] */
> >> - =C2=A0 =C2=A0 struct page =C2=A0 =C2=A0 *ce_respages[NFSD_PAGES_=
PER_SLOT + 1];
> >> - =C2=A0 =C2=A0 int =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ce_c=
achethis;
> >> - =C2=A0 =C2=A0 short =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ce_resuse=
d;
> >> - =C2=A0 =C2=A0 int =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ce_o=
pcnt;
> >> - =C2=A0 =C2=A0 int =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ce_r=
pchdrlen;
> >> -};
> >> -
> >> =C2=A0struct nfsd4_slot {
> >> - =C2=A0 =C2=A0 bool =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0sl_inuse;
> >> - =C2=A0 =C2=A0 u32 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sl_seqid;
> >> - =C2=A0 =C2=A0 struct nfsd4_cache_entry =C2=A0 =C2=A0 =C2=A0 =C2=A0=
sl_cache_entry;
> >> + =C2=A0 =C2=A0 bool =C2=A0 =C2=A0sl_inuse;
> >> + =C2=A0 =C2=A0 u32 =C2=A0 =C2=A0 sl_seqid;
> >> + =C2=A0 =C2=A0 int =C2=A0 =C2=A0 sl_cachethis;
> >> + =C2=A0 =C2=A0 int =C2=A0 =C2=A0 sl_opcnt;
> >> + =C2=A0 =C2=A0 __be32 =C2=A0sl_status;
> >> + =C2=A0 =C2=A0 u32 =C2=A0 =C2=A0 sl_datalen;
> >> + =C2=A0 =C2=A0 char =C2=A0 =C2=A0sl_data[];
> >
> > Could you just move sl_inuse to the end? =C2=A0It'll save a few byt=
es in the
> > structure (because the compiler will probably stick 3 bytes after i=
t to
> > align sl_seqid.)
>=20
> How about this?
>=20
> struct nfsd4_slot {
> -       bool                            sl_inuse;
> -       u32                             sl_seqid;
> -       struct nfsd4_cache_entry        sl_cache_entry;
> +       bool    sl_inuse;
> +       bool    sl_cachethis;
> +       u16     sl_opcnt;
> +       u32     sl_seqid;
> +       __be32  sl_status;
> +       u32     sl_datalen;
> +       char    sl_data[];
>  };

Looks OK to me!  By the way, on recent distro's you should be able to
run apt-get install/yum install dwarves, then

	pahole fs/nfsd/nfsd.o

and look through the output for the struct of interest:

struct nfsd4_slot {
        bool                       sl_inuse;             /*     0     1=
 */

        /* XXX 3 bytes hole, try to pack */

        u32                        sl_seqid;             /*     4     4=
 */
        struct nfsd4_cache_entry   sl_cache_entry;       /*     8    36=
 */

        /* size: 44, cachelines: 1 */
        /* sum members: 41, holes: 1, sum holes: 3 */
        /* last cacheline: 44 bytes */
};      /* definitions: 3 */

(But no point obsessing over this kind of thing; I just happened to
notice the problem in this patch and figured for such a common structur=
e
it might be worth mentioning.)

--b.

>=20
> -->Andy
>=20
> > --b.
> >
> >> =C2=A0};
> >>
> >> =C2=A0struct nfsd4_channel_attrs {
> >> @@ -159,7 +152,7 @@ struct nfsd4_session {
> >> =C2=A0 =C2=A0 =C2=A0 struct nfs4_sessionid =C2=A0 se_sessionid;
> >> =C2=A0 =C2=A0 =C2=A0 struct nfsd4_channel_attrs se_fchannel;
> >> =C2=A0 =C2=A0 =C2=A0 struct nfsd4_channel_attrs se_bchannel;
> >> - =C2=A0 =C2=A0 struct nfsd4_slot =C2=A0 =C2=A0 =C2=A0 se_slots[];=
 =C2=A0 =C2=A0 /* forward channel slots */
> >> + =C2=A0 =C2=A0 struct nfsd4_slot =C2=A0 =C2=A0 =C2=A0 *se_slots[]=
; =C2=A0 =C2=A0/* forward channel slots */
> >> =C2=A0};
> >>
> >> =C2=A0static inline void
> >> diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
> >> index 3f71660..73164c2 100644
> >> --- a/include/linux/nfsd/xdr4.h
> >> +++ b/include/linux/nfsd/xdr4.h
> >> @@ -51,7 +51,7 @@ struct nfsd4_compound_state {
> >> =C2=A0 =C2=A0 =C2=A0 /* For sessions DRC */
> >> =C2=A0 =C2=A0 =C2=A0 struct nfsd4_session =C2=A0 =C2=A0*session;
> >> =C2=A0 =C2=A0 =C2=A0 struct nfsd4_slot =C2=A0 =C2=A0 =C2=A0 *slot;
> >> - =C2=A0 =C2=A0 __be32 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0*statp;
> >> + =C2=A0 =C2=A0 __be32 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0*datap;
> >> =C2=A0 =C2=A0 =C2=A0 size_t =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0iovlen;
> >> =C2=A0 =C2=A0 =C2=A0 u32 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 minorversion;
> >> =C2=A0 =C2=A0 =C2=A0 u32 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 status;
> >> @@ -472,8 +472,7 @@ static inline bool nfsd4_is_solo_sequence(stru=
ct nfsd4_compoundres *resp)
> >>
> >> =C2=A0static inline bool nfsd4_not_cached(struct nfsd4_compoundres=
 *resp)
> >> =C2=A0{
> >> - =C2=A0 =C2=A0 return !resp->cstate.slot->sl_cache_entry.ce_cache=
this ||
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 nfsd4_is_solo_sequence(resp);
> >> + =C2=A0 =C2=A0 return !resp->cstate.slot->sl_cachethis || nfsd4_i=
s_solo_sequence(resp);
> >> =C2=A0}
> >>
> >> =C2=A0#define NFS4_SVC_XDRSIZE =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 sizeof(struct nfsd4_compoundargs)
> >> --
> >> 1.6.2.5
> >>
> > _______________________________________________
> > pNFS mailing list
> > pNFS@linux-nfs.org
> > http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
> >
