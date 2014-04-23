Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f174.google.com ([209.85.213.174]:54440 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753935AbaDWOkc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Apr 2014 10:40:32 -0400
Received: by mail-ig0-f174.google.com with SMTP id h18so4394495igc.1
        for <linux-nfs@vger.kernel.org>; Wed, 23 Apr 2014 07:40:32 -0700 (PDT)
Content-Type: multipart/mixed; boundary="Apple-Mail=_882AA5BD-FB30-4828-87A6-8CA7F8605937"
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH 05/17] nfs: add support for multiple nfs reqs per page
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <4C28869F-B929-424D-98B4-650B9D2AA4C8@primarydata.com>
Date: Wed, 23 Apr 2014 10:40:33 -0400
Cc: linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <ABC748BE-A9D2-4299-B11B-CD0E54890EF7@primarydata.com>
References: <1398202165-78897-1-git-send-email-dros@primarydata.com> <1398202165-78897-6-git-send-email-dros@primarydata.com> <4C28869F-B929-424D-98B4-650B9D2AA4C8@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Apple-Mail=_882AA5BD-FB30-4828-87A6-8CA7F8605937
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=windows-1252

Ok, the posted version with the recent =93clean up=94 utterly broke the =
case of more than one
request per page. Sorry for the noise.

The fixup follows. I=92ll post a v2 of my patchset later, possibly after =
merging on top of=20
Anna=92s recent changes (depending on how that goes).

-dros


--Apple-Mail=_882AA5BD-FB30-4828-87A6-8CA7F8605937
Content-Disposition: attachment;
	filename=0001-fixup-handle-sub-request-handoff-between-write-and-c.patch
Content-Type: application/octet-stream;
	name="0001-fixup-handle-sub-request-handoff-between-write-and-c.patch"
Content-Transfer-Encoding: quoted-printable

=46rom=202316b80f1dfaa4e6158ab5e73f338126c18c5e44=20Mon=20Sep=2017=20=
00:00:00=202001=0AFrom:=20Weston=20Andros=20Adamson=20=
<dros@primarydata.com>=0ADate:=20Tue,=2022=20Apr=202014=2021:54:49=20=
-0400=0ASubject:=20[PATCH]=20fixup:=20handle=20sub=20request=20handoff=20=
between=20write=20and=20commit=0A=20lists=0A=0AThis=20is=20a=20proposed=20=
fixup=20of=20the=20patch=20I=20posted=20to=20linux-nfs=20on=20April=20=
22,=202014:=0A"nfs:=20add=20support=20for=20multiple=20nfs=20reqs=20per=20=
page"=0A=0AThe=20handoff=20between=20write=20and=20commit=20expects=20an=20=
extra=20reference=20for=0Aeach=20request,=20so=20that=20the=20reference=20=
count=20doesnt=20reach=20zero.=0AThe=20read=20path=20doesn't=20need=20=
this=20as=20it=20only=20ever=20has=20one=20operation.=0A=0AThe=20=
solution=20is=20to=20mark=20the=20head=20request=20when=20this=20extra=20=
reference=20is=20taken,=0Ato=20know=20when=20to=20take=20extra=20refs=20=
for=20sub=20requests.=20This=20way=20all=20requests=20can=0Abe=20=
released=20in=20nfs_inode_remove_request.=0A=0ASigned-off-by:=20Weston=20=
Andros=20Adamson=20<dros@primarydata.com>=0A---=0A=20fs/nfs/pagelist.c=20=
=20=20=20=20=20=20=20|=20=206=20++++++=0A=20fs/nfs/write.c=20=20=20=20=20=
=20=20=20=20=20=20|=2028=20++++++++++++++--------------=0A=20=
include/linux/nfs_page.h=20|=20=201=20+=0A=203=20files=20changed,=2021=20=
insertions(+),=2014=20deletions(-)=0A=0Adiff=20--git=20=
a/fs/nfs/pagelist.c=20b/fs/nfs/pagelist.c=0Aindex=20e819b1b..67d95c6=20=
100644=0A---=20a/fs/nfs/pagelist.c=0A+++=20b/fs/nfs/pagelist.c=0A@@=20=
-239,6=20+239,12=20@@=20nfs_page_group_init(struct=20nfs_page=20*req,=20=
struct=20nfs_page=20*prev)=0A=20=09=09req->wb_head=20=3D=20=
prev->wb_head;=0A=20=09=09req->wb_this_page=20=3D=20prev->wb_this_page;=0A=
=20=09=09prev->wb_this_page=20=3D=20req;=0A+=0A+=09=09/*=20grab=20extra=20=
ref=20if=20head=20request=20has=20extra=20ref=20from=0A+=09=09=20*=20the=20=
write/commit=20path=20to=20handle=20handoff=20between=20write=0A+=09=09=20=
*=20and=20commit=20lists=20*/=0A+=09=09if=20(test_bit(PG_INODE_REF,=20=
&prev->wb_head->wb_flags))=0A+=09=09=09kref_get(&req->wb_kref);=0A=20=09=
}=0A=20}=0A=20=0Adiff=20--git=20a/fs/nfs/write.c=20b/fs/nfs/write.c=0A=
index=20cd24a14..c2990d0=20100644=0A---=20a/fs/nfs/write.c=0A+++=20=
b/fs/nfs/write.c=0A@@=20-487,6=20+487,8=20@@=20static=20void=20=
nfs_inode_add_request(struct=20inode=20*inode,=20struct=20nfs_page=20=
*req)=0A=20{=0A=20=09struct=20nfs_inode=20*nfsi=20=3D=20NFS_I(inode);=0A=20=
=0A+=09WARN_ON_ONCE(req->wb_this_page=20!=3D=20req);=0A+=0A=20=09/*=20=
Lock=20the=20request!=20*/=0A=20=09nfs_lock_request(req);=0A=20=0A@@=20=
-503,6=20+505,7=20@@=20static=20void=20nfs_inode_add_request(struct=20=
inode=20*inode,=20struct=20nfs_page=20*req)=0A=20=09=09=
set_page_private(req->wb_page,=20(unsigned=20long)req);=0A=20=09}=0A=20=09=
nfsi->npages++;=0A+=09set_bit(PG_INODE_REF,=20&req->wb_flags);=0A=20=09=
kref_get(&req->wb_kref);=0A=20=09spin_unlock(&inode->i_lock);=0A=20}=0A=
@@=20-516,22=20+519,19=20@@=20static=20void=20=
nfs_inode_remove_request(struct=20nfs_page=20*req)=0A=20=09struct=20=
nfs_inode=20*nfsi=20=3D=20NFS_I(inode);=0A=20=09struct=20nfs_page=20=
*head;=0A=20=0A-=09if=20(!nfs_page_group_sync_on_bit(req,=20PG_REMOVE))=0A=
-=09=09return;=0A-=0A-=09/*=20always=20operate=20on=20the=20*head*=20of=20=
the=20page=20group=20(it's=20what=20was=0A-=09=20=20=20referenced=20in=20=
_add_request)=20*/=0A-=09head=20=3D=20req->wb_head;=0A+=09if=20=
(nfs_page_group_sync_on_bit(req,=20PG_REMOVE))=20{=0A+=09=09head=20=3D=20=
req->wb_head;=0A=20=0A-=09spin_lock(&inode->i_lock);=0A-=09if=20=
(likely(!PageSwapCache(head->wb_page)))=20{=0A-=09=09=
set_page_private(head->wb_page,=200);=0A-=09=09=
ClearPagePrivate(head->wb_page);=0A-=09=09clear_bit(PG_MAPPED,=20=
&head->wb_flags);=0A+=09=09spin_lock(&inode->i_lock);=0A+=09=09if=20=
(likely(!PageSwapCache(head->wb_page)))=20{=0A+=09=09=09=
set_page_private(head->wb_page,=200);=0A+=09=09=09=
ClearPagePrivate(head->wb_page);=0A+=09=09=09clear_bit(PG_MAPPED,=20=
&head->wb_flags);=0A+=09=09}=0A+=09=09nfsi->npages--;=0A+=09=09=
spin_unlock(&inode->i_lock);=0A=20=09}=0A-=09nfsi->npages--;=0A-=09=
spin_unlock(&inode->i_lock);=0A-=09nfs_release_request(head);=0A+=09=
nfs_release_request(req);=0A=20}=0A=20=0A=20static=20void=0Adiff=20--git=20=
a/include/linux/nfs_page.h=20b/include/linux/nfs_page.h=0Aindex=20=
41ce262..710aa18=20100644=0A---=20a/include/linux/nfs_page.h=0A+++=20=
b/include/linux/nfs_page.h=0A@@=20-26,6=20+26,7=20@@=20enum=20{=0A=20=09=
PG_MAPPED,=09=09/*=20page=20private=20set=20for=20buffered=20io=20*/=0A=20=
=09PG_CLEAN,=09=09/*=20write=20succeeded=20*/=0A=20=09PG_COMMIT_TO_DS,=09=
/*=20used=20by=20pnfs=20layouts=20*/=0A+=09PG_INODE_REF,=09=09/*=20extra=20=
ref=20held=20by=20inode=20(head=20req=20only)=20*/=0A=20=09PG_HEADLOCK,=09=
=09/*=20page=20group=20lock=20of=20wb_head=20*/=0A=20=09PG_TEARDOWN,=09=09=
/*=20page=20group=20sync=20for=20destroy=20*/=0A=20=09PG_UNLOCKPAGE,=09=09=
/*=20page=20group=20sync=20bit=20in=20read=20path=20*/=0A--=20=0A1.8.5.2=20=
(Apple=20Git-48)=0A=0A=

--Apple-Mail=_882AA5BD-FB30-4828-87A6-8CA7F8605937
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=windows-1252





On Apr 22, 2014, at 5:40 PM, Weston Andros Adamson =
<dros@primarydata.com> wrote:

> Oh boy, I posted this with a =93cleanup=94 of page group reference =
counting,
> but this doesn=92t work with certain file layout stripe sizes :-/
>=20
> I=92ll post the older, clunky version (that works) tomorrow if I can=92t=
 figure this out quickly.
>=20
> -dros
>=20
>=20
>=20
> On Apr 22, 2014, at 5:29 PM, Weston Andros Adamson =
<dros@primarydata.com> wrote:
>=20
>> Add "page groups" - a circular list of nfs requests (struct nfs_page)
>> that all reference the same page. This gives nfs read and write paths
>> the ability to account for sub-page regions independently.  This
>> somewhat follows the design of struct buffer_head's sub-page
>> accounting.
>>=20
>> Only "head" requests are ever added/removed from the inode list in
>> the buffered write path. "head" and "sub" requests are treated the
>> same through the read path and the rest of the write/commit path.
>> Requests are given an extra reference across the life of the list.
>>=20
>> Page groups are never rejoined after being split. If the read/write
>> request fails and the client falls back to another path (ie revert
>> to MDS in PNFS case), the already split requests are pushed through
>> the recoalescing code again, which may split them further and then
>> coalesce them into properly sized requests on the wire. Fragmentation
>> shouldn't be a problem with the current design, because we flush all
>> requests in page group when a non-contiguous request is added, so
>> the only time resplitting should occur is on a resend of a read or
>> write.
>>=20
>> This patch lays the groundwork for sub-page splitting, but does not
>> actually do any splitting. For now all page groups have one request
>> as pg_test functions don't yet split pages. There are several related
>> patches that are needed support multiple requests per page group.
>>=20
>> Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
>> ---
>> fs/nfs/direct.c          |   7 +-
>> fs/nfs/pagelist.c        | 218 =
++++++++++++++++++++++++++++++++++++++++++++---
>> fs/nfs/read.c            |   4 +-
>> fs/nfs/write.c           |  12 ++-
>> include/linux/nfs_page.h |  12 ++-
>> 5 files changed, 231 insertions(+), 22 deletions(-)
>>=20
>> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
>> index a0c30c5..9d968ca 100644
>> --- a/fs/nfs/direct.c
>> +++ b/fs/nfs/direct.c
>> @@ -380,7 +380,7 @@ static ssize_t =
nfs_direct_read_schedule_segment(struct nfs_pageio_descriptor *de
>> 			struct nfs_page *req;
>> 			unsigned int req_len =3D min_t(size_t, bytes, =
PAGE_SIZE - pgbase);
>> 			/* XXX do we need to do the eof zeroing found in =
async_filler? */
>> -			req =3D nfs_create_request(dreq->ctx, =
pagevec[i],
>> +			req =3D nfs_create_request(dreq->ctx, =
pagevec[i], NULL,
>> 						 pgbase, req_len);
>> 			if (IS_ERR(req)) {
>> 				result =3D PTR_ERR(req);
>> @@ -749,7 +749,7 @@ static ssize_t =
nfs_direct_write_schedule_segment(struct nfs_pageio_descriptor *d
>> 			struct nfs_page *req;
>> 			unsigned int req_len =3D min_t(size_t, bytes, =
PAGE_SIZE - pgbase);
>>=20
>> -			req =3D nfs_create_request(dreq->ctx, =
pagevec[i],
>> +			req =3D nfs_create_request(dreq->ctx, =
pagevec[i], NULL,
>> 						 pgbase, req_len);
>> 			if (IS_ERR(req)) {
>> 				result =3D PTR_ERR(req);
>> @@ -827,6 +827,8 @@ static void nfs_direct_write_completion(struct =
nfs_pgio_header *hdr)
>> 	spin_unlock(&dreq->lock);
>>=20
>> 	while (!list_empty(&hdr->pages)) {
>> +		bool do_destroy =3D true;
>> +
>> 		req =3D nfs_list_entry(hdr->pages.next);
>> 		nfs_list_remove_request(req);
>> 		switch (bit) {
>> @@ -834,6 +836,7 @@ static void nfs_direct_write_completion(struct =
nfs_pgio_header *hdr)
>> 		case NFS_IOHDR_NEED_COMMIT:
>> 			kref_get(&req->wb_kref);
>> 			nfs_mark_request_commit(req, hdr->lseg, &cinfo);
>> +			do_destroy =3D false;
>> 		}
>> 		nfs_unlock_and_release_request(req);
>> 	}
>> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
>> index ac4fb64..8cb8e14 100644
>> --- a/fs/nfs/pagelist.c
>> +++ b/fs/nfs/pagelist.c
>> @@ -26,6 +26,8 @@
>>=20
>> static struct kmem_cache *nfs_page_cachep;
>>=20
>> +static void nfs_free_request(struct nfs_page *);
>> +
>> bool nfs_pgarray_set(struct nfs_page_array *p, unsigned int =
pagecount)
>> {
>> 	p->npages =3D pagecount;
>> @@ -133,10 +135,145 @@ nfs_iocounter_wait(struct nfs_io_counter *c)
>> 	return __nfs_iocounter_wait(c);
>> }
>>=20
>> +/*
>> + * nfs_page_group_lock - lock the head of the page group
>> + * @req - request in group that is to be locked
>> + *
>> + * this lock must be held if modifying the page group list
>> + */
>> +void
>> +nfs_page_group_lock(struct nfs_page *req)
>> +{
>> +	struct nfs_page *head =3D req->wb_head;
>> +	int err =3D -EAGAIN;
>> +
>> +	WARN_ON_ONCE(head !=3D head->wb_head);
>> +
>> +	while (err)
>> +		err =3D wait_on_bit_lock(&head->wb_flags, PG_HEADLOCK,
>> +			nfs_wait_bit_killable, TASK_KILLABLE);
>> +}
>> +
>> +/*
>> + * nfs_page_group_unlock - unlock the head of the page group
>> + * @req - request in group that is to be unlocked
>> + */
>> +void
>> +nfs_page_group_unlock(struct nfs_page *req)
>> +{
>> +	struct nfs_page *head =3D req->wb_head;
>> +
>> +	WARN_ON_ONCE(head !=3D head->wb_head);
>> +
>> +	smp_mb__before_clear_bit();
>> +	clear_bit(PG_HEADLOCK, &head->wb_flags);
>> +	smp_mb__after_clear_bit();
>> +	wake_up_bit(&head->wb_flags, PG_HEADLOCK);
>> +}
>> +
>> +/*
>> + * nfs_page_group_sync_on_bit_locked
>> + *
>> + * must be called with page group lock held
>> + */
>> +static bool
>> +nfs_page_group_sync_on_bit_locked(struct nfs_page *req, unsigned int =
bit)
>> +{
>> +	struct nfs_page *head =3D req->wb_head;
>> +	struct nfs_page *tmp;
>> +
>> +	WARN_ON_ONCE(!test_bit(PG_HEADLOCK, &head->wb_flags));
>> +	WARN_ON_ONCE(test_and_set_bit(bit, &req->wb_flags));
>> +
>> +	tmp =3D req->wb_this_page;
>> +	while (tmp !=3D req) {
>> +		if (!test_bit(bit, &tmp->wb_flags))
>> +			return false;
>> +		tmp =3D tmp->wb_this_page;
>> +	}
>> +
>> +	/* true! reset all bits */
>> +	tmp =3D req;
>> +	do {
>> +		clear_bit(bit, &tmp->wb_flags);
>> +		tmp =3D tmp->wb_this_page;
>> +	} while (tmp !=3D req);
>> +
>> +	return true;
>> +}
>> +
>> +/*
>> + * nfs_page_group_sync_on_bit - set bit on current request, but only
>> + *   return true if the bit is set for all requests in page group
>> + * @req - request in page group
>> + * @bit - PG_* bit that is used to sync page group
>> + */
>> +bool nfs_page_group_sync_on_bit(struct nfs_page *req, unsigned int =
bit)
>> +{
>> +	bool ret;
>> +
>> +	nfs_page_group_lock(req);
>> +	ret =3D nfs_page_group_sync_on_bit_locked(req, bit);
>> +	nfs_page_group_unlock(req);
>> +
>> +	return ret;
>> +}
>> +
>> +/*
>> + * nfs_page_group_init - Initialize the page group linkage for @req
>> + * @req - a new nfs request
>> + * @prev - the previous request in page group, or NULL if @req is =
the first
>> + *         or only request in the group (the head).
>> + */
>> +static inline void
>> +nfs_page_group_init(struct nfs_page *req, struct nfs_page *prev)
>> +{
>> +	WARN_ON_ONCE(prev =3D=3D req);
>> +
>> +	if (!prev) {
>> +		req->wb_head =3D req;
>> +		req->wb_this_page =3D req;
>> +	} else {
>> +		WARN_ON_ONCE(prev->wb_this_page !=3D prev->wb_head);
>> +		WARN_ON_ONCE(!test_bit(PG_HEADLOCK, =
&prev->wb_head->wb_flags));
>> +		req->wb_head =3D prev->wb_head;
>> +		req->wb_this_page =3D prev->wb_this_page;
>> +		prev->wb_this_page =3D req;
>> +	}
>> +}
>> +
>> +/*
>> + * nfs_page_group_destroy - sync the destruction of page groups
>> + * @req - request that no longer needs the page group
>> + *
>> + * releases the page group reference from each member once all
>> + * members have called this function.
>> + */
>> +static void
>> +nfs_page_group_destroy(struct kref *kref)
>> +{
>> +	struct nfs_page *req =3D container_of(kref, struct nfs_page, =
wb_kref);
>> +	struct nfs_page *tmp, *next;
>> +
>> +	if (!nfs_page_group_sync_on_bit(req, PG_TEARDOWN))
>> +		return;
>> +
>> +	tmp =3D req;
>> +	do {
>> +		next =3D tmp->wb_this_page;
>> +		/* unlink and free */
>> +		tmp->wb_this_page =3D tmp;
>> +		tmp->wb_head =3D tmp;
>> +		nfs_free_request(tmp);
>> +		tmp =3D next;
>> +	} while (tmp !=3D req);
>> +}
>> +
>> /**
>> * nfs_create_request - Create an NFS read/write request.
>> * @ctx: open context to use
>> * @page: page to write
>> + * @last: last nfs request created for this page group or NULL if =
head
>> * @offset: starting offset within the page for the write
>> * @count: number of bytes to read/write
>> *
>> @@ -146,7 +283,8 @@ nfs_iocounter_wait(struct nfs_io_counter *c)
>> */
>> struct nfs_page *
>> nfs_create_request(struct nfs_open_context *ctx, struct page *page,
>> -		   unsigned int offset, unsigned int count)
>> +		   struct nfs_page *last, unsigned int offset,
>> +		   unsigned int count)
>> {
>> 	struct nfs_page		*req;
>> 	struct nfs_lock_context *l_ctx;
>> @@ -178,6 +316,7 @@ nfs_create_request(struct nfs_open_context *ctx, =
struct page *page,
>> 	req->wb_bytes   =3D count;
>> 	req->wb_context =3D get_nfs_open_context(ctx);
>> 	kref_init(&req->wb_kref);
>> +	nfs_page_group_init(req, last);
>> 	return req;
>> }
>>=20
>> @@ -235,16 +374,22 @@ static void nfs_clear_request(struct nfs_page =
*req)
>> 	}
>> }
>>=20
>> -
>> /**
>> * nfs_release_request - Release the count on an NFS read/write =
request
>> * @req: request to release
>> *
>> * Note: Should never be called with the spinlock held!
>> */
>> -static void nfs_free_request(struct kref *kref)
>> +static void nfs_free_request(struct nfs_page *req)
>> {
>> -	struct nfs_page *req =3D container_of(kref, struct nfs_page, =
wb_kref);
>> +	WARN_ON_ONCE(req->wb_this_page !=3D req);
>> +
>> +	/* extra debug: make sure no sync bits are still set */
>> +	WARN_ON_ONCE(test_bit(PG_TEARDOWN, &req->wb_flags));
>> +	WARN_ON_ONCE(test_bit(PG_UNLOCKPAGE, &req->wb_flags));
>> +	WARN_ON_ONCE(test_bit(PG_UPTODATE, &req->wb_flags));
>> +	WARN_ON_ONCE(test_bit(PG_WB_END, &req->wb_flags));
>> +	WARN_ON_ONCE(test_bit(PG_REMOVE, &req->wb_flags));
>>=20
>> 	/* Release struct file and open context */
>> 	nfs_clear_request(req);
>> @@ -253,7 +398,7 @@ static void nfs_free_request(struct kref *kref)
>>=20
>> void nfs_release_request(struct nfs_page *req)
>> {
>> -	kref_put(&req->wb_kref, nfs_free_request);
>> +	kref_put(&req->wb_kref, nfs_page_group_destroy);
>> }
>>=20
>> static int nfs_wait_bit_uninterruptible(void *word)
>> @@ -439,21 +584,66 @@ static void nfs_pageio_doio(struct =
nfs_pageio_descriptor *desc)
>> * @desc: destination io descriptor
>> * @req: request
>> *
>> + * This may split a request into subrequests which are all part of =
the
>> + * same page group.
>> + *
>> * Returns true if the request 'req' was successfully coalesced into =
the
>> * existing list of pages 'desc'.
>> */
>> static int __nfs_pageio_add_request(struct nfs_pageio_descriptor =
*desc,
>> 			   struct nfs_page *req)
>> {
>> -	while (!nfs_pageio_do_add_request(desc, req)) {
>> -		desc->pg_moreio =3D 1;
>> -		nfs_pageio_doio(desc);
>> -		if (desc->pg_error < 0)
>> -			return 0;
>> -		desc->pg_moreio =3D 0;
>> -		if (desc->pg_recoalesce)
>> -			return 0;
>> -	}
>> +	struct nfs_page *subreq;
>> +	unsigned int bytes_left =3D 0;
>> +	unsigned int offset, pgbase;
>> +
>> +	nfs_page_group_lock(req);
>> +
>> +	subreq =3D req;
>> +	bytes_left =3D subreq->wb_bytes;
>> +	offset =3D subreq->wb_offset;
>> +	pgbase =3D subreq->wb_pgbase;
>> +
>> +	do {
>> +		if (!nfs_pageio_do_add_request(desc, subreq)) {
>> +			/* make sure pg_test call(s) did nothing */
>> +			WARN_ON_ONCE(subreq->wb_bytes !=3D bytes_left);
>> +			WARN_ON_ONCE(subreq->wb_offset !=3D offset);
>> +			WARN_ON_ONCE(subreq->wb_pgbase !=3D pgbase);
>> +
>> +			nfs_page_group_unlock(req);
>> +			desc->pg_moreio =3D 1;
>> +			nfs_pageio_doio(desc);
>> +			if (desc->pg_error < 0)
>> +				return 0;
>> +			desc->pg_moreio =3D 0;
>> +			if (desc->pg_recoalesce)
>> +				return 0;
>> +			/* retry add_request for this subreq */
>> +			nfs_page_group_lock(req);
>> +			continue;
>> +		}
>> +
>> +		/* check for buggy pg_test call(s) */
>> +		WARN_ON_ONCE(subreq->wb_bytes + subreq->wb_pgbase > =
PAGE_SIZE);
>> +		WARN_ON_ONCE(subreq->wb_bytes > bytes_left);
>> +		WARN_ON_ONCE(subreq->wb_bytes =3D=3D 0);
>> +
>> +		bytes_left -=3D subreq->wb_bytes;
>> +		offset +=3D subreq->wb_bytes;
>> +		pgbase +=3D subreq->wb_bytes;
>> +
>> +		if (bytes_left) {
>> +			subreq =3D nfs_create_request(req->wb_context,
>> +					req->wb_page,
>> +					subreq, pgbase, bytes_left);
>> +			nfs_lock_request(subreq);
>> +			subreq->wb_offset  =3D offset;
>> +			subreq->wb_index =3D req->wb_index;
>> +		}
>> +	} while (bytes_left > 0);
>> +
>> +	nfs_page_group_unlock(req);
>> 	return 1;
>> }
>>=20
>> diff --git a/fs/nfs/read.c b/fs/nfs/read.c
>> index 95a0855..ee0a3cd 100644
>> --- a/fs/nfs/read.c
>> +++ b/fs/nfs/read.c
>> @@ -139,7 +139,7 @@ int nfs_readpage_async(struct nfs_open_context =
*ctx, struct inode *inode,
>> 	len =3D nfs_page_length(page);
>> 	if (len =3D=3D 0)
>> 		return nfs_return_empty_page(page);
>> -	new =3D nfs_create_request(ctx, page, 0, len);
>> +	new =3D nfs_create_request(ctx, page, NULL, 0, len);
>> 	if (IS_ERR(new)) {
>> 		unlock_page(page);
>> 		return PTR_ERR(new);
>> @@ -600,7 +600,7 @@ readpage_async_filler(void *data, struct page =
*page)
>> 	if (len =3D=3D 0)
>> 		return nfs_return_empty_page(page);
>>=20
>> -	new =3D nfs_create_request(desc->ctx, page, 0, len);
>> +	new =3D nfs_create_request(desc->ctx, page, NULL, 0, len);
>> 	if (IS_ERR(new))
>> 		goto out_error;
>>=20
>> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
>> index ca20ec7..d1453f2 100644
>> --- a/fs/nfs/write.c
>> +++ b/fs/nfs/write.c
>> @@ -461,7 +461,7 @@ static void nfs_inode_remove_request(struct =
nfs_page *req)
>> 	}
>> 	nfsi->npages--;
>> 	spin_unlock(&inode->i_lock);
>> -	nfs_release_request(req);
>> +	nfs_release_request(head);
>> }
>>=20
>> static void
>> @@ -625,6 +625,7 @@ static void nfs_write_completion(struct =
nfs_pgio_header *hdr)
>> {
>> 	struct nfs_commit_info cinfo;
>> 	unsigned long bytes =3D 0;
>> +	bool do_destroy;
>>=20
>> 	if (test_bit(NFS_IOHDR_REDO, &hdr->flags))
>> 		goto out;
>> @@ -654,6 +655,7 @@ remove_req:
>> next:
>> 		nfs_unlock_request(req);
>> 		nfs_end_page_writeback(req->wb_page);
>> +		do_destroy =3D !test_bit(NFS_IOHDR_NEED_COMMIT, =
&hdr->flags);
>> 		nfs_release_request(req);
>> 	}
>> out:
>> @@ -758,6 +760,10 @@ static struct nfs_page =
*nfs_try_to_update_request(struct inode *inode,
>> 		if (req =3D=3D NULL)
>> 			goto out_unlock;
>>=20
>> +		/* should be handled by nfs_flush_incompatible */
>> +		WARN_ON_ONCE(req->wb_head !=3D req);
>> +		WARN_ON_ONCE(req->wb_this_page !=3D req);
>> +
>> 		rqend =3D req->wb_offset + req->wb_bytes;
>> 		/*
>> 		 * Tell the caller to flush out the request if
>> @@ -819,7 +825,7 @@ static struct nfs_page * =
nfs_setup_write_request(struct nfs_open_context* ctx,
>> 	req =3D nfs_try_to_update_request(inode, page, offset, bytes);
>> 	if (req !=3D NULL)
>> 		goto out;
>> -	req =3D nfs_create_request(ctx, page, offset, bytes);
>> +	req =3D nfs_create_request(ctx, page, NULL, offset, bytes);
>> 	if (IS_ERR(req))
>> 		goto out;
>> 	nfs_inode_add_request(inode, req);
>> @@ -863,6 +869,8 @@ int nfs_flush_incompatible(struct file *file, =
struct page *page)
>> 			return 0;
>> 		l_ctx =3D req->wb_lock_context;
>> 		do_flush =3D req->wb_page !=3D page || req->wb_context =
!=3D ctx;
>> +		/* for now, flush if more than 1 request in page_group =
*/
>> +		do_flush |=3D req->wb_this_page !=3D req;
>> 		if (l_ctx && ctx->dentry->d_inode->i_flock !=3D NULL) {
>> 			do_flush |=3D l_ctx->lockowner.l_owner !=3D =
current->files
>> 				|| l_ctx->lockowner.l_pid !=3D =
current->tgid;
>> diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
>> index 214e098..1fb161b 100644
>> --- a/include/linux/nfs_page.h
>> +++ b/include/linux/nfs_page.h
>> @@ -26,6 +26,8 @@ enum {
>> 	PG_MAPPED,		/* page private set for buffered io */
>> 	PG_CLEAN,		/* write succeeded */
>> 	PG_COMMIT_TO_DS,	/* used by pnfs layouts */
>> +	PG_HEADLOCK,		/* page group lock of wb_head */
>> +	PG_TEARDOWN,		/* page group sync for destroy */
>> };
>>=20
>> struct nfs_inode;
>> @@ -41,6 +43,8 @@ struct nfs_page {
>> 	struct kref		wb_kref;	/* reference count */
>> 	unsigned long		wb_flags;
>> 	struct nfs_write_verifier	wb_verf;	/* Commit cookie =
*/
>> +	struct nfs_page		*wb_this_page;  /* list of reqs for this =
page */
>> +	struct nfs_page		*wb_head;       /* head pointer for req =
list */
>> };
>>=20
>> struct nfs_pageio_descriptor;
>> @@ -75,9 +79,10 @@ struct nfs_pageio_descriptor {
>>=20
>> extern	struct nfs_page *nfs_create_request(struct =
nfs_open_context *ctx,
>> 					    struct page *page,
>> +					    struct nfs_page *last,
>> 					    unsigned int offset,
>> 					    unsigned int count);
>> -extern	void nfs_release_request(struct nfs_page *req);
>> +extern	void nfs_release_request(struct nfs_page *);
>>=20
>>=20
>> extern	void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
>> @@ -95,7 +100,10 @@ extern size_t nfs_generic_pg_test(struct =
nfs_pageio_descriptor *desc,
>> 				struct nfs_page *req);
>> extern  int nfs_wait_on_request(struct nfs_page *);
>> extern	void nfs_unlock_request(struct nfs_page *req);
>> -extern	void nfs_unlock_and_release_request(struct nfs_page =
*req);
>> +extern	void nfs_unlock_and_release_request(struct nfs_page *);
>> +extern void nfs_page_group_lock(struct nfs_page *);
>> +extern void nfs_page_group_unlock(struct nfs_page *);
>> +extern bool nfs_page_group_sync_on_bit(struct nfs_page *, unsigned =
int);
>>=20
>> /*
>> * Lock the page of an asynchronous request
>> --=20
>> 1.8.5.2 (Apple Git-48)
>>=20
>=20


--Apple-Mail=_882AA5BD-FB30-4828-87A6-8CA7F8605937--
