From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [pnfs] [PATCH 5/5] nfsd41: replace page based DRC with buffer
	based DRC
Date: Tue, 1 Sep 2009 09:48:41 -0400
Message-ID: <89c397150909010648v4a4f5db8t87e09717e5a2c950@mail.gmail.com>
References: <1251389264-3009-1-git-send-email-andros@netapp.com>
	 <1251389264-3009-2-git-send-email-andros@netapp.com>
	 <1251389264-3009-3-git-send-email-andros@netapp.com>
	 <1251389264-3009-4-git-send-email-andros@netapp.com>
	 <1251389264-3009-5-git-send-email-andros@netapp.com>
	 <1251389264-3009-6-git-send-email-andros@netapp.com>
	 <20090828213323.GD2462@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f188.google.com ([209.85.211.188]:60236 "EHLO
	mail-yw0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754772AbZIANsj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Sep 2009 09:48:39 -0400
Received: by ywh26 with SMTP id 26so7361131ywh.5
        for <linux-nfs@vger.kernel.org>; Tue, 01 Sep 2009 06:48:41 -0700 (PDT)
In-Reply-To: <20090828213323.GD2462@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 28, 2009 at 5:33 PM, J. Bruce Fields<bfields@fieldses.org> =
wrote:
> On Thu, Aug 27, 2009 at 12:07:44PM -0400, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>>
>> Use NFSD_SLOT_CACHE_SIZE size buffers for sessions DRC instead of ho=
lding nfsd
>> pages in cache.
>>
>> Connectathon testing has shown that 1024 bytes for encoded compound =
operation
>> responses past the sequence operation is sufficient, 512 bytes is a =
little too
>> small. Set NFSD_SLOT_CACHE_SIZE to 1024.
>>
>> Allocate memory for the session DRC in the CREATE_SESSION operation
>> to guarantee that the memory resource is available for caching respo=
nses.
>> Allocate each slot individually in preparation for slot table size n=
egotiation.
>>
>> Remove struct nfsd4_cache_entry and helper functions for the old pag=
e-based
>> DRC.
>>
>> The iov_len calculation in nfs4svc_encode_compoundres is now always
>> correct, clean up the nfs4svc_encode_compoundres session logic.
>>
>> The nfsd4_compound_state statp pointer is also not used.
>> Remove nfsd4_set_statp().
>>
>> Move useful nfsd4_cache_entry fields into nfsd4_slot.
>>
>> Signed-off-by: Andy Adamson <andros@netapp.com
>> ---
>> =A0fs/nfsd/nfs4state.c =A0 =A0 =A0 =A0| =A0207 ++++++++++++---------=
-----------------------
>> =A0fs/nfsd/nfs4xdr.c =A0 =A0 =A0 =A0 =A0| =A0 13 ++--
>> =A0fs/nfsd/nfssvc.c =A0 =A0 =A0 =A0 =A0 | =A0 =A04 -
>> =A0include/linux/nfsd/state.h | =A0 27 ++----
>> =A0include/linux/nfsd/xdr4.h =A0| =A0 =A05 +-
>> =A05 files changed, 74 insertions(+), 182 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index 4695cec..2d72d5c 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -510,12 +510,22 @@ static int init_forechannel_attrs(struct svc_r=
qst *rqstp,
>> =A0 =A0 =A0 return status;
>> =A0}
>>
>> +static void
>> +free_session_slots(struct nfsd4_session *ses)
>> +{
>> + =A0 =A0 int i;
>> +
>> + =A0 =A0 for (i =3D 0; i < ses->se_fchannel.maxreqs; i++)
>> + =A0 =A0 =A0 =A0 =A0 =A0 kfree(ses->se_slots[i]);
>> +}
>> +
>> =A0static int
>> =A0alloc_init_session(struct svc_rqst *rqstp, struct nfs4_client *cl=
p,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct nfsd4_create_session *cses=
)
>> =A0{
>> =A0 =A0 =A0 struct nfsd4_session *new, tmp;
>> - =A0 =A0 int idx, status =3D nfserr_serverfault, slotsize;
>> + =A0 =A0 struct nfsd4_slot *sp;
>> + =A0 =A0 int idx, status =3D nfserr_serverfault, slotsize, cachesiz=
e, i;
>
> Just as a style thing: that list's getting a little long. =A0Could yo=
u
> keep at least "status" on a separate line?
>
>>
>> =A0 =A0 =A0 memset(&tmp, 0, sizeof(tmp));
>>
>> @@ -526,14 +536,23 @@ alloc_init_session(struct svc_rqst *rqstp, str=
uct nfs4_client *clp,
>> =A0 =A0 =A0 if (status)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>>
>> - =A0 =A0 /* allocate struct nfsd4_session and slot table in one pie=
ce */
>> - =A0 =A0 slotsize =3D tmp.se_fchannel.maxreqs * sizeof(struct nfsd4=
_slot);
>> + =A0 =A0 /* allocate struct nfsd4_session and slot table pointers i=
n one piece */
>> + =A0 =A0 slotsize =3D tmp.se_fchannel.maxreqs * sizeof(struct nfsd4=
_slot *);
>> =A0 =A0 =A0 new =3D kzalloc(sizeof(*new) + slotsize, GFP_KERNEL);
>
> I think this is OK for now, but maybe stick something like:
>
> =A0 =A0 =A0 =A0BUILD_BUG_ON(NFSD_MAX_SLOTS_PER_SESSION * sizeof(struc=
t nfsd4_slot)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0+ sizeof(struct nfsd4_=
session) > PAGE_SIZE);
>
> in state.h just to warn anyone who wants to blindly bump up
> NFSD_MAX_SLOTS_PER_SESSION. =A0(It's not really forbidden to kmalloc =
more
> than a page, but it's also not reliable, and if it becomes necessary
> then we'd rather find some way to code around it.)
>
>> =A0 =A0 =A0 if (!new)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>>
>> =A0 =A0 =A0 memcpy(new, &tmp, sizeof(*new));
>>
>> + =A0 =A0 /* allocate each struct nfsd4_slot and data cache in one p=
iece */
>> + =A0 =A0 cachesize =3D new->se_fchannel.maxresp_cached - NFSD_MIN_H=
DR_SEQ_SZ;
>> + =A0 =A0 for (i =3D 0; i < new->se_fchannel.maxreqs; i++) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 sp =3D kzalloc(sizeof(*sp) + cachesize, GF=
P_KERNEL);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!sp)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_free;
>> + =A0 =A0 =A0 =A0 =A0 =A0 new->se_slots[i] =3D sp;
>> + =A0 =A0 }
>> +
>> =A0 =A0 =A0 new->se_client =3D clp;
>> =A0 =A0 =A0 gen_sessionid(new);
>> =A0 =A0 =A0 idx =3D hash_sessionid(&new->se_sessionid);
>> @@ -550,6 +569,10 @@ alloc_init_session(struct svc_rqst *rqstp, stru=
ct nfs4_client *clp,
>> =A0 =A0 =A0 status =3D nfs_ok;
>> =A0out:
>> =A0 =A0 =A0 return status;
>> +out_free:
>> + =A0 =A0 free_session_slots(new);
>> + =A0 =A0 kfree(new);
>> + =A0 =A0 goto out;
>> =A0}
>>
>> =A0/* caller must hold sessionid_lock */
>> @@ -592,22 +615,16 @@ release_session(struct nfsd4_session *ses)
>> =A0 =A0 =A0 nfsd4_put_session(ses);
>> =A0}
>>
>> -static void nfsd4_release_respages(struct page **respages, short re=
sused);
>> -
>> =A0void
>> =A0free_session(struct kref *kref)
>> =A0{
>> =A0 =A0 =A0 struct nfsd4_session *ses;
>> - =A0 =A0 int i;
>>
>> =A0 =A0 =A0 ses =3D container_of(kref, struct nfsd4_session, se_ref)=
;
>> - =A0 =A0 for (i =3D 0; i < ses->se_fchannel.maxreqs; i++) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 struct nfsd4_cache_entry *e =3D &ses->se_s=
lots[i].sl_cache_entry;
>> - =A0 =A0 =A0 =A0 =A0 =A0 nfsd4_release_respages(e->ce_respages, e->=
ce_resused);
>> - =A0 =A0 }
>> =A0 =A0 =A0 spin_lock(&nfsd_drc_lock);
>> =A0 =A0 =A0 nfsd_drc_mem_used -=3D ses->se_fchannel.maxreqs * NFSD_S=
LOT_CACHE_SIZE;
>> =A0 =A0 =A0 spin_unlock(&nfsd_drc_lock);
>> + =A0 =A0 free_session_slots(ses);
>> =A0 =A0 =A0 kfree(ses);
>> =A0}
>>
>> @@ -964,116 +981,32 @@ out_err:
>> =A0 =A0 =A0 return;
>> =A0}
>>
>> -void
>> -nfsd4_set_statp(struct svc_rqst *rqstp, __be32 *statp)
>> -{
>> - =A0 =A0 struct nfsd4_compoundres *resp =3D rqstp->rq_resp;
>> -
>> - =A0 =A0 resp->cstate.statp =3D statp;
>> -}
>> -
>> -/*
>> - * Dereference the result pages.
>> - */
>> -static void
>> -nfsd4_release_respages(struct page **respages, short resused)
>> -{
>> - =A0 =A0 int i;
>> -
>> - =A0 =A0 dprintk("--> %s\n", __func__);
>> - =A0 =A0 for (i =3D 0; i < resused; i++) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (!respages[i])
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> - =A0 =A0 =A0 =A0 =A0 =A0 put_page(respages[i]);
>> - =A0 =A0 =A0 =A0 =A0 =A0 respages[i] =3D NULL;
>> - =A0 =A0 }
>> -}
>> -
>> -static void
>> -nfsd4_copy_pages(struct page **topages, struct page **frompages, sh=
ort count)
>> -{
>> - =A0 =A0 int i;
>> -
>> - =A0 =A0 for (i =3D 0; i < count; i++) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 topages[i] =3D frompages[i];
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (!topages[i])
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> - =A0 =A0 =A0 =A0 =A0 =A0 get_page(topages[i]);
>> - =A0 =A0 }
>> -}
>> -
>> =A0/*
>> - * Cache the reply pages up to NFSD_PAGES_PER_SLOT + 1, clearing th=
e previous
>> - * pages. We add a page to NFSD_PAGES_PER_SLOT for the case where t=
he total
>> - * length of the XDR response is less than se_fmaxresp_cached
>> - * (NFSD_PAGES_PER_SLOT * PAGE_SIZE) but the xdr_buf pages is used =
for a
>> - * of the reply (e.g. readdir).
>> - *
>> - * Store the base and length of the rq_req.head[0] page
>> - * of the NFSv4.1 data, just past the rpc header.
>> + * Cache a reply. nfsd4_check_drc_limit() has bounded the cache siz=
e.
>> =A0 */
>> =A0void
>> =A0nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
>> =A0{
>> - =A0 =A0 struct nfsd4_cache_entry *entry =3D &resp->cstate.slot->sl=
_cache_entry;
>> - =A0 =A0 struct svc_rqst *rqstp =3D resp->rqstp;
>> - =A0 =A0 struct kvec *resv =3D &rqstp->rq_res.head[0];
>> -
>> - =A0 =A0 dprintk("--> %s entry %p\n", __func__, entry);
>> + =A0 =A0 struct nfsd4_slot *slot =3D resp->cstate.slot;
>> + =A0 =A0 unsigned int base;
>>
>> - =A0 =A0 nfsd4_release_respages(entry->ce_respages, entry->ce_resus=
ed);
>> - =A0 =A0 entry->ce_opcnt =3D resp->opcnt;
>> - =A0 =A0 entry->ce_status =3D resp->cstate.status;
>> + =A0 =A0 dprintk("--> %s slot %p\n", __func__, slot);
>>
>> - =A0 =A0 /*
>> - =A0 =A0 =A0* Don't need a page to cache just the sequence operatio=
n - the slot
>> - =A0 =A0 =A0* does this for us!
>> - =A0 =A0 =A0*/
>> + =A0 =A0 slot->sl_opcnt =3D resp->opcnt;
>> + =A0 =A0 slot->sl_status =3D resp->cstate.status;
>>
>> =A0 =A0 =A0 if (nfsd4_not_cached(resp)) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 entry->ce_resused =3D 0;
>> - =A0 =A0 =A0 =A0 =A0 =A0 entry->ce_rpchdrlen =3D 0;
>> - =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%s Just cache SEQUENCE. ce_cachet=
his %d\n", __func__,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 resp->cstate.slot->sl_cach=
e_entry.ce_cachethis);
>> + =A0 =A0 =A0 =A0 =A0 =A0 slot->sl_datalen =3D 0;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>> =A0 =A0 =A0 }
>> - =A0 =A0 entry->ce_resused =3D rqstp->rq_resused;
>> - =A0 =A0 if (entry->ce_resused > NFSD_PAGES_PER_SLOT + 1)
>> - =A0 =A0 =A0 =A0 =A0 =A0 entry->ce_resused =3D NFSD_PAGES_PER_SLOT =
+ 1;
>> - =A0 =A0 nfsd4_copy_pages(entry->ce_respages, rqstp->rq_respages,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0entry->ce_resused);
>> - =A0 =A0 entry->ce_datav.iov_base =3D resp->cstate.statp;
>> - =A0 =A0 entry->ce_datav.iov_len =3D resv->iov_len - ((char *)resp-=
>cstate.statp -
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (char *)pa=
ge_address(rqstp->rq_respages[0]));
>> - =A0 =A0 /* Current request rpc header length*/
>> - =A0 =A0 entry->ce_rpchdrlen =3D (char *)resp->cstate.statp -
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (char *)pa=
ge_address(rqstp->rq_respages[0]);
>> -}
>> -
>> -/*
>> - * We keep the rpc header, but take the nfs reply from the replycac=
he.
>> - */
>> -static int
>> -nfsd41_copy_replay_data(struct nfsd4_compoundres *resp,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct nfsd4_cache_entry *=
entry)
>> -{
>> - =A0 =A0 struct svc_rqst *rqstp =3D resp->rqstp;
>> - =A0 =A0 struct kvec *resv =3D &resp->rqstp->rq_res.head[0];
>> - =A0 =A0 int len;
>> -
>> - =A0 =A0 /* Current request rpc header length*/
>> - =A0 =A0 len =3D (char *)resp->cstate.statp -
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (char *)page_address(rqstp=
->rq_respages[0]);
>> - =A0 =A0 if (entry->ce_datav.iov_len + len > PAGE_SIZE) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%s v41 cached reply too large (%Z=
d).\n", __func__,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 entry->ce_datav.iov_len);
>> - =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> - =A0 =A0 }
>> - =A0 =A0 /* copy the cached reply nfsd data past the current rpc he=
ader */
>> - =A0 =A0 memcpy((char *)resv->iov_base + len, entry->ce_datav.iov_b=
ase,
>> - =A0 =A0 =A0 =A0 =A0 =A0 entry->ce_datav.iov_len);
>> - =A0 =A0 resv->iov_len =3D len + entry->ce_datav.iov_len;
>> - =A0 =A0 return 1;
>> + =A0 =A0 slot->sl_datalen =3D (char *)resp->p - (char *)resp->cstat=
e.datap;
>> + =A0 =A0 base =3D (char *)resp->cstate.datap -
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 (char *)resp->xbuf->head[0].iov_base;
>> + =A0 =A0 if (read_bytes_from_xdr_buf(resp->xbuf, base, slot->sl_dat=
a,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sl=
ot->sl_datalen))
>> + =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_WARNING
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "nfsd: sessions DRC could =
not cache compound\n");
>
> I'd make this WARN("nfsd:...") just to make it completely clear it's =
a
> kernel bug. =A0(This case should be caught by nfsd4_check_drc_limit u=
nless
> we've messed something up, right?)
>
>> + =A0 =A0 return;
>> =A0}
>>
>> =A0/*
>> @@ -1091,14 +1024,14 @@ nfsd4_enc_sequence_replay(struct nfsd4_compo=
undargs *args,
>> =A0 =A0 =A0 struct nfsd4_slot *slot =3D resp->cstate.slot;
>>
>> =A0 =A0 =A0 dprintk("--> %s resp->opcnt %d cachethis %u \n", __func_=
_,
>> - =A0 =A0 =A0 =A0 =A0 =A0 resp->opcnt, resp->cstate.slot->sl_cache_e=
ntry.ce_cachethis);
>> + =A0 =A0 =A0 =A0 =A0 =A0 resp->opcnt, resp->cstate.slot->sl_cacheth=
is);
>>
>> =A0 =A0 =A0 /* Encode the replayed sequence operation */
>> =A0 =A0 =A0 op =3D &args->ops[resp->opcnt - 1];
>> =A0 =A0 =A0 nfsd4_encode_operation(resp, op);
>>
>> =A0 =A0 =A0 /* Return nfserr_retry_uncached_rep in next operation. *=
/
>> - =A0 =A0 if (args->opcnt > 1 && slot->sl_cache_entry.ce_cachethis =3D=
=3D 0) {
>> + =A0 =A0 if (args->opcnt > 1 && slot->sl_cachethis =3D=3D 0) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 op =3D &args->ops[resp->opcnt++];
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 op->status =3D nfserr_retry_uncached_rep=
;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 nfsd4_encode_operation(resp, op);
>> @@ -1107,57 +1040,29 @@ nfsd4_enc_sequence_replay(struct nfsd4_compo=
undargs *args,
>> =A0}
>>
>> =A0/*
>> - * Keep the first page of the replay. Copy the NFSv4.1 data from th=
e first
>> - * cached page. =A0Replace any futher replay pages from the cache.
>> + * The sequence operation is not cached because we can use the slot=
 and
>> + * session values.
>> =A0 */
>> =A0__be32
>> =A0nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct nfsd4_sequence=
 *seq)
>> =A0{
>> - =A0 =A0 struct nfsd4_cache_entry *entry =3D &resp->cstate.slot->sl=
_cache_entry;
>> + =A0 =A0 struct nfsd4_slot *slot =3D resp->cstate.slot;
>> =A0 =A0 =A0 __be32 status;
>>
>> - =A0 =A0 dprintk("--> %s entry %p\n", __func__, entry);
>> -
>> - =A0 =A0 /*
>> - =A0 =A0 =A0* If this is just the sequence operation, we did not ke=
ep
>> - =A0 =A0 =A0* a page in the cache entry because we can just use the
>> - =A0 =A0 =A0* slot info stored in struct nfsd4_sequence that was ch=
ecked
>> - =A0 =A0 =A0* against the slot in nfsd4_sequence().
>> - =A0 =A0 =A0*
>> - =A0 =A0 =A0* This occurs when seq->cachethis is FALSE, or when the=
 client
>> - =A0 =A0 =A0* session inactivity timer fires and a solo sequence op=
eration
>> - =A0 =A0 =A0* is sent (lease renewal).
>> - =A0 =A0 =A0*/
>> + =A0 =A0 dprintk("--> %s slot %p\n", __func__, slot);
>>
>> =A0 =A0 =A0 /* Either returns 0 or nfserr_retry_uncached */
>> =A0 =A0 =A0 status =3D nfsd4_enc_sequence_replay(resp->rqstp->rq_arg=
p, resp);
>> =A0 =A0 =A0 if (status =3D=3D nfserr_retry_uncached_rep)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return status;
>>
>> - =A0 =A0 if (!nfsd41_copy_replay_data(resp, entry)) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 /*
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0* Not enough room to use the replay rpc=
 header, send the
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0* cached header. Release all the alloca=
ted result pages.
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> - =A0 =A0 =A0 =A0 =A0 =A0 svc_free_res_pages(resp->rqstp);
>> - =A0 =A0 =A0 =A0 =A0 =A0 nfsd4_copy_pages(resp->rqstp->rq_respages,=
 entry->ce_respages,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 entry->ce_resused);
>> - =A0 =A0 } else {
>> - =A0 =A0 =A0 =A0 =A0 =A0 /* Release all but the first allocated res=
ult page */
>> -
>> - =A0 =A0 =A0 =A0 =A0 =A0 resp->rqstp->rq_resused--;
>> - =A0 =A0 =A0 =A0 =A0 =A0 svc_free_res_pages(resp->rqstp);
>> -
>> - =A0 =A0 =A0 =A0 =A0 =A0 nfsd4_copy_pages(&resp->rqstp->rq_respages=
[1],
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&entry-=
>ce_respages[1],
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0entry->=
ce_resused - 1);
>> - =A0 =A0 }
>> + =A0 =A0 /* The sequence operation has been encoded, cstate->datap =
set. */
>> + =A0 =A0 memcpy(resp->cstate.datap, slot->sl_data, slot->sl_datalen=
);
>>
>> - =A0 =A0 resp->rqstp->rq_resused =3D entry->ce_resused;
>> - =A0 =A0 resp->opcnt =3D entry->ce_opcnt;
>> - =A0 =A0 resp->cstate.iovlen =3D entry->ce_datav.iov_len + entry->c=
e_rpchdrlen;
>> - =A0 =A0 status =3D entry->ce_status;
>> + =A0 =A0 resp->opcnt =3D slot->sl_opcnt;
>> + =A0 =A0 resp->p =3D resp->cstate.datap + XDR_QUADLEN(slot->sl_data=
len);
>> + =A0 =A0 status =3D slot->sl_status;
>>
>> =A0 =A0 =A0 return status;
>> =A0}
>> @@ -1489,7 +1394,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
>> =A0 =A0 =A0 if (seq->slotid >=3D session->se_fchannel.maxreqs)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>>
>> - =A0 =A0 slot =3D &session->se_slots[seq->slotid];
>> + =A0 =A0 slot =3D session->se_slots[seq->slotid];
>> =A0 =A0 =A0 dprintk("%s: slotid %d\n", __func__, seq->slotid);
>>
>> =A0 =A0 =A0 /* We do not negotiate the number of slots yet, so set t=
he
>> @@ -1502,7 +1407,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 cstate->slot =3D slot;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 cstate->session =3D session;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Return the cached reply status and se=
t cstate->status
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0* for nfsd4_svc_encode_compoundres proc=
essing */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* for nfsd4_proc_compound processing */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D nfsd4_replay_cache_entry(resp=
, seq);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 cstate->status =3D nfserr_replay_cache;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto replay_cache;
>> @@ -1513,7 +1418,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
>> =A0 =A0 =A0 /* Success! bump slot seqid */
>> =A0 =A0 =A0 slot->sl_inuse =3D true;
>> =A0 =A0 =A0 slot->sl_seqid =3D seq->seqid;
>> - =A0 =A0 slot->sl_cache_entry.ce_cachethis =3D seq->cachethis;
>> + =A0 =A0 slot->sl_cachethis =3D seq->cachethis;
>>
>> =A0 =A0 =A0 cstate->slot =3D slot;
>> =A0 =A0 =A0 cstate->session =3D session;
>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>> index fdf632b..49824ea 100644
>> --- a/fs/nfsd/nfs4xdr.c
>> +++ b/fs/nfsd/nfs4xdr.c
>> @@ -3064,6 +3064,7 @@ nfsd4_encode_sequence(struct nfsd4_compoundres=
 *resp, int nfserr,
>> =A0 =A0 =A0 WRITE32(0);
>>
>> =A0 =A0 =A0 ADJUST_ARGS();
>> + =A0 =A0 resp->cstate.datap =3D p; /* DRC cache data pointer */
>> =A0 =A0 =A0 return 0;
>> =A0}
>>
>> @@ -3166,7 +3167,7 @@ static int nfsd4_check_drc_limit(struct nfsd4_=
compoundres *resp)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return status;
>>
>> =A0 =A0 =A0 session =3D resp->cstate.session;
>> - =A0 =A0 if (session =3D=3D NULL || slot->sl_cache_entry.ce_cacheth=
is =3D=3D 0)
>> + =A0 =A0 if (session =3D=3D NULL || slot->sl_cachethis =3D=3D 0)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return status;
>>
>> =A0 =A0 =A0 if (resp->opcnt >=3D args->opcnt)
>> @@ -3291,6 +3292,7 @@ nfs4svc_encode_compoundres(struct svc_rqst *rq=
stp, __be32 *p, struct nfsd4_compo
>> =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0* All that remains is to write the tag and operation =
count...
>> =A0 =A0 =A0 =A0*/
>> + =A0 =A0 struct nfsd4_compound_state *cs =3D &resp->cstate;
>> =A0 =A0 =A0 struct kvec *iov;
>> =A0 =A0 =A0 p =3D resp->tagp;
>> =A0 =A0 =A0 *p++ =3D htonl(resp->taglen);
>> @@ -3304,14 +3306,11 @@ nfs4svc_encode_compoundres(struct svc_rqst *=
rqstp, __be32 *p, struct nfsd4_compo
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 iov =3D &rqstp->rq_res.head[0];
>> =A0 =A0 =A0 iov->iov_len =3D ((char*)resp->p) - (char*)iov->iov_base=
;
>> =A0 =A0 =A0 BUG_ON(iov->iov_len > PAGE_SIZE);
>> - =A0 =A0 if (nfsd4_has_session(&resp->cstate)) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (resp->cstate.status =3D=3D nfserr_repl=
ay_cache &&
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 !nfsd4_not=
_cached(resp)) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 iov->iov_len =3D resp->cst=
ate.iovlen;
>> - =A0 =A0 =A0 =A0 =A0 =A0 } else {
>> + =A0 =A0 if (nfsd4_has_session(cs)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (cs->status !=3D nfserr_replay_cache) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nfsd4_store_cache_entry(=
resp);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%s: SET SLOT ST=
ATE TO AVAILABLE\n", __func__);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 resp->cstate.slot->sl_inus=
e =3D 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 resp->cstate.slot->sl_inus=
e =3D false;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 nfsd4_put_session(resp->cstate.session);
>> =A0 =A0 =A0 }
>> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
>> index d68cd05..944ef01 100644
>> --- a/fs/nfsd/nfssvc.c
>> +++ b/fs/nfsd/nfssvc.c
>> @@ -576,10 +576,6 @@ nfsd_dispatch(struct svc_rqst *rqstp, __be32 *s=
tatp)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 + rqstp->rq_res.head[0].iov_len;
>> =A0 =A0 =A0 rqstp->rq_res.head[0].iov_len +=3D sizeof(__be32);
>>
>> - =A0 =A0 /* NFSv4.1 DRC requires statp */
>> - =A0 =A0 if (rqstp->rq_vers =3D=3D 4)
>> - =A0 =A0 =A0 =A0 =A0 =A0 nfsd4_set_statp(rqstp, statp);
>> -
>> =A0 =A0 =A0 /* Now call the procedure handler, and encode NFS status=
=2E */
>> =A0 =A0 =A0 nfserr =3D proc->pc_func(rqstp, rqstp->rq_argp, rqstp->r=
q_resp);
>> =A0 =A0 =A0 nfserr =3D map_new_errors(rqstp->rq_vers, nfserr);
>> diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
>> index ff0b771..e745100 100644
>> --- a/include/linux/nfsd/state.h
>> +++ b/include/linux/nfsd/state.h
>> @@ -94,30 +94,23 @@ struct nfs4_cb_conn {
>>
>> =A0/* Maximum number of slots per session. 160 is useful for long ha=
ul TCP */
>> =A0#define NFSD_MAX_SLOTS_PER_SESSION =A0 =A0 160
>> -/* Maximum number of pages per slot cache entry */
>> -#define NFSD_PAGES_PER_SLOT =A01
>> -#define NFSD_SLOT_CACHE_SIZE =A0 =A0 =A0 =A0 PAGE_SIZE
>> =A0/* Maximum number of operations per session compound */
>> =A0#define NFSD_MAX_OPS_PER_COMPOUND =A0 =A016
>> +/* Maximum =A0session per slot cache size */
>> +#define NFSD_SLOT_CACHE_SIZE =A0 =A0 =A0 =A0 1024
>> =A0/* Maximum number of NFSD_SLOT_CACHE_SIZE slots per session */
>> =A0#define NFSD_CACHE_SIZE_SLOTS_PER_SESSION =A0 =A032
>> =A0#define NFSD_MAX_MEM_PER_SESSION =A0\
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 (NFSD_CACHE_SIZE_SLOTS_PER_SESSION * NFS=
D_SLOT_CACHE_SIZE)
>>
>> -struct nfsd4_cache_entry {
>> - =A0 =A0 __be32 =A0 =A0 =A0 =A0 =A0ce_status;
>> - =A0 =A0 struct kvec =A0 =A0 ce_datav; /* encoded NFSv4.1 data in r=
q_res.head[0] */
>> - =A0 =A0 struct page =A0 =A0 *ce_respages[NFSD_PAGES_PER_SLOT + 1];
>> - =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 ce_cachethis;
>> - =A0 =A0 short =A0 =A0 =A0 =A0 =A0 ce_resused;
>> - =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 ce_opcnt;
>> - =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 ce_rpchdrlen;
>> -};
>> -
>> =A0struct nfsd4_slot {
>> - =A0 =A0 bool =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
sl_inuse;
>> - =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 sl_seqid;
>> - =A0 =A0 struct nfsd4_cache_entry =A0 =A0 =A0 =A0sl_cache_entry;
>> + =A0 =A0 bool =A0 =A0sl_inuse;
>> + =A0 =A0 u32 =A0 =A0 sl_seqid;
>> + =A0 =A0 int =A0 =A0 sl_cachethis;
>> + =A0 =A0 int =A0 =A0 sl_opcnt;
>> + =A0 =A0 __be32 =A0sl_status;
>> + =A0 =A0 u32 =A0 =A0 sl_datalen;
>> + =A0 =A0 char =A0 =A0sl_data[];
>
> Could you just move sl_inuse to the end? =A0It'll save a few bytes in=
 the
> structure (because the compiler will probably stick 3 bytes after it =
to
> align sl_seqid.)

How about this?

struct nfsd4_slot {
-       bool                            sl_inuse;
-       u32                             sl_seqid;
-       struct nfsd4_cache_entry        sl_cache_entry;
+       bool    sl_inuse;
+       bool    sl_cachethis;
+       u16     sl_opcnt;
+       u32     sl_seqid;
+       __be32  sl_status;
+       u32     sl_datalen;
+       char    sl_data[];
 };

-->Andy

> --b.
>
>> =A0};
>>
>> =A0struct nfsd4_channel_attrs {
>> @@ -159,7 +152,7 @@ struct nfsd4_session {
>> =A0 =A0 =A0 struct nfs4_sessionid =A0 se_sessionid;
>> =A0 =A0 =A0 struct nfsd4_channel_attrs se_fchannel;
>> =A0 =A0 =A0 struct nfsd4_channel_attrs se_bchannel;
>> - =A0 =A0 struct nfsd4_slot =A0 =A0 =A0 se_slots[]; =A0 =A0 /* forwa=
rd channel slots */
>> + =A0 =A0 struct nfsd4_slot =A0 =A0 =A0 *se_slots[]; =A0 =A0/* forwa=
rd channel slots */
>> =A0};
>>
>> =A0static inline void
>> diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
>> index 3f71660..73164c2 100644
>> --- a/include/linux/nfsd/xdr4.h
>> +++ b/include/linux/nfsd/xdr4.h
>> @@ -51,7 +51,7 @@ struct nfsd4_compound_state {
>> =A0 =A0 =A0 /* For sessions DRC */
>> =A0 =A0 =A0 struct nfsd4_session =A0 =A0*session;
>> =A0 =A0 =A0 struct nfsd4_slot =A0 =A0 =A0 *slot;
>> - =A0 =A0 __be32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*statp;
>> + =A0 =A0 __be32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*datap;
>> =A0 =A0 =A0 size_t =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0iovlen;
>> =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 minorversion=
;
>> =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 status;
>> @@ -472,8 +472,7 @@ static inline bool nfsd4_is_solo_sequence(struct=
 nfsd4_compoundres *resp)
>>
>> =A0static inline bool nfsd4_not_cached(struct nfsd4_compoundres *res=
p)
>> =A0{
>> - =A0 =A0 return !resp->cstate.slot->sl_cache_entry.ce_cachethis ||
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nfsd4_is_solo_sequence(res=
p);
>> + =A0 =A0 return !resp->cstate.slot->sl_cachethis || nfsd4_is_solo_s=
equence(resp);
>> =A0}
>>
>> =A0#define NFS4_SVC_XDRSIZE =A0 =A0 =A0 =A0 =A0 =A0 sizeof(struct nf=
sd4_compoundargs)
>> --
>> 1.6.2.5
>>
> _______________________________________________
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
>
