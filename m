From: Fred Isaman <iisaman@netapp.com>
Subject: Re: [RFC 1/3] SQUASHME: Generalize the device cache so it can be used
 by all layouts
Date: Mon, 13 Sep 2010 05:16:10 -0700
Message-ID: <AANLkTinJXRe7QWhPD5OV9KA9uUribFXwSenmbJyqnzk1@mail.gmail.com>
References: <4C8D0759.6090201@panasas.com>
	<4C8D07D5.6010006@panasas.com>
	<1284320533.7880.131.camel@heimdal.trondhjem.org>
	<4C8DF3E5.4050108@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	NFS list <linux-nfs@vger.kernel.org>,
	Benny Halevy <bhalevy@panasas.com>,
	Andy Adamson <andros@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:60090 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755105Ab0IMMQP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Sep 2010 08:16:15 -0400
Received: by bwz11 with SMTP id 11so4395411bwz.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Sep 2010 05:16:14 -0700 (PDT)
In-Reply-To: <4C8DF3E5.4050108@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 13, 2010 at 2:50 AM, Boaz Harrosh <bharrosh@panasas.com> wr=
ote:
> On 09/12/2010 09:42 PM, Trond Myklebust wrote:
>> On Sun, 2010-09-12 at 19:03 +0200, Boaz Harrosh wrote:
>>> Current code thinks that there can be a single device_id per
>>> layout segment. Change that to assume no relations between segments
>>> and device_ids. It's now up to the layout-driver to make any relati=
ons.
>>>
>>> Files layout driver is fixed in next patch.
>>>
>>> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
>>> ---
>>> =A0fs/nfs/pnfs.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0 20 +++++------------=
---
>>> =A0include/linux/nfs4_pnfs.h | =A0 =A06 +-----
>>> =A02 files changed, 6 insertions(+), 20 deletions(-)
>>>
>>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>>> index eb4e092..f26abc0 100644
>>> --- a/fs/nfs/pnfs.c
>>> +++ b/fs/nfs/pnfs.c
>>> @@ -1892,26 +1892,16 @@ nfs4_init_deviceid_node(struct nfs4_devicei=
d *d)
>>> =A0}
>>> =A0EXPORT_SYMBOL(nfs4_init_deviceid_node);
>>>
>>> -/* Called from layoutdriver_io_operations->alloc_lseg */
>>> -void
>>> -nfs4_set_layout_deviceid(struct pnfs_layout_segment *l, struct nfs=
4_deviceid *d)
>>> -{
>>> - =A0 =A0dprintk("%s [%d]\n", __func__, atomic_read(&d->de_kref.ref=
count));
>>> - =A0 =A0l->deviceid =3D d;
>>> -}
>>> -EXPORT_SYMBOL(nfs4_set_layout_deviceid);
>>> -
>>> =A0/* Called from layoutdriver_io_operations->free_lseg */
>>> =A0void
>>> -nfs4_put_unset_layout_deviceid(struct pnfs_layout_segment *l,
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct nfs4_deviceid =
*d,
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 void (*free_callback)=
(struct kref *))
>>> +nfs4_put_deviceid(struct nfs4_deviceid_cache *c,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct nfs4_deviceid =
*d)
>>> =A0{
>>> =A0 =A0 =A0dprintk("%s [%d]\n", __func__, atomic_read(&d->de_kref.r=
efcount));
>>> - =A0 =A0l->deviceid =3D NULL;
>>> - =A0 =A0kref_put(&d->de_kref, free_callback);
>>> + =A0 =A0kref_put(&d->de_kref, c->dc_free_callback);
>>> + =A0 =A0/* Do we need to return the deviceid_cache ref */
>>> =A0}
>>> -EXPORT_SYMBOL(nfs4_put_unset_layout_deviceid);
>>> +EXPORT_SYMBOL(nfs4_put_deviceid);
>>>
>>> =A0/* Find and reference a deviceid */
>>> =A0struct nfs4_deviceid *
>>> diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
>>> index 577cd2b..dc3410e 100644
>>> --- a/include/linux/nfs4_pnfs.h
>>> +++ b/include/linux/nfs4_pnfs.h
>>> @@ -111,7 +111,6 @@ struct pnfs_layout_segment {
>>> =A0 =A0 =A0struct kref kref;
>>> =A0 =A0 =A0bool valid;
>>> =A0 =A0 =A0struct pnfs_layout_hdr *layout;
>>> - =A0 =A0struct nfs4_deviceid *deviceid;
>>> =A0 =A0 =A0u8 ld_data[]; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* lay=
out driver private data */
>>> =A0};
>>>
>>> @@ -287,11 +286,8 @@ extern struct nfs4_deviceid *nfs4_find_get_dev=
iceid(
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct p=
nfs_deviceid *);
>>> =A0extern struct nfs4_deviceid *nfs4_add_get_deviceid(struct nfs4_d=
eviceid_cache *,
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct n=
fs4_deviceid *);
>>> -extern void nfs4_set_layout_deviceid(struct pnfs_layout_segment *,
>>> +extern void nfs4_put_deviceid(struct nfs4_deviceid_cache *,
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct n=
fs4_deviceid *);
>>> -extern void nfs4_put_unset_layout_deviceid(struct pnfs_layout_segm=
ent *,
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct nfs=
4_deviceid *,
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0void (*fre=
e_callback)(struct kref *));
>>> =A0extern void nfs4_delete_device(struct nfs4_deviceid_cache *,
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct p=
nfs_deviceid *);
>>>
>>
>> This doesn't look like it needs to be part of the initial single-lay=
out
>> submission. Why is it being labelled as a squashme?
>>
>> Trond
>
> No, this is a device_id cache per nfs-client it is part of the initia=
l
> getdeviceinfo call. Many "single-layout" may refer to the same device=
_id
> therefor it is cached so the long getdeviceinfo call can be done only=
 once.
>
> Cheers
> Boaz
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>

I agree.  I'll roll it into the next submission.

=46red
