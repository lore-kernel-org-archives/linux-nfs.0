Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:26170 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756512Ab1EZQJv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 May 2011 12:09:51 -0400
Message-ID: <4DDE7B4B.6030703@panasas.com>
Date: Thu, 26 May 2011 19:09:47 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Boaz Harrosh <bharrosh@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v8 17/32] pnfs-obj: objio_osd device information retrieval
 and caching
References: <4DDD7392.6040505@panasas.com> <1306358914-17403-1-git-send-email-bhalevy@panasas.com> <4DDE5DF9.7010802@panasas.com>
In-Reply-To: <4DDE5DF9.7010802@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-05-26 17:04, Boaz Harrosh wrote:
> On 05/26/2011 12:28 AM, Benny Halevy wrote:
>> From: Boaz Harrosh <bharrosh@panasas.com>
>>
>> When a new layout is received in objio_alloc_lseg all device_ids
>> referenced are retrieved. The device information is queried for from MDS
>> and then the osd_device is looked-up from the osd-initiator library. The
>> devices are cached in a per-mount-point list, for later use. At unmount
>> all devices are "put" back to the library.
>>
>> objlayout_get_deviceinfo(), objlayout_put_deviceinfo() middleware
>> API for retrieving device information given a device_id.
>>
>> TODO: The device cache can get big. Cap its size. Keep an LRU and start
>>       to return devices which were not used, when list gets to big, or
>>       when new entries allocation fail.
>>
>> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
>> [gfp_flags]
>> [use global device cache]
>> [use layout driver in global device cache]
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfs/objlayout/objio_osd.c |  148 +++++++++++++++++++++++++++++++++++++++++-
>>  fs/nfs/objlayout/objlayout.c |   68 +++++++++++++++++++
>>  fs/nfs/objlayout/objlayout.h |    8 ++
>>  3 files changed, 223 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
>> index 725b1df..80d916b 100644
>> --- a/fs/nfs/objlayout/objio_osd.c
>> +++ b/fs/nfs/objlayout/objio_osd.c
>> @@ -46,6 +46,58 @@
>>  
>>  #define _LLU(x) ((unsigned long long)x)
>>  
>> +struct objio_dev_ent {
>> +	struct nfs4_deviceid_node id_node;
>> +	struct osd_dev *od;
>> +};
>> +
>> +static void
>> +objio_free_deviceid_node(struct nfs4_deviceid_node *d)
>> +{
>> +	struct objio_dev_ent *de = container_of(d, struct objio_dev_ent, id_node);
>> +
>> +	osduld_put_device(de->od);
>> +	kfree(de);
>> +}
>> +
>> +static struct objio_dev_ent *_dev_list_find(const struct nfs_server *nfss,
>> +	const struct nfs4_deviceid *d_id)
>> +{
>> +	struct nfs4_deviceid_node *d;
>> +
>> +	d = nfs4_find_get_deviceid(nfss->pnfs_curr_ld, nfss->nfs_client, d_id);
>> +	if (!d)
>> +		return NULL;
>> +	return container_of(d, struct objio_dev_ent, id_node);
>> +}
>> +
>> +static int _dev_list_add(const struct nfs_server *nfss,
>> +	const struct nfs4_deviceid *d_id, struct osd_dev *od,
>> +	gfp_t gfp_flags)
>> +{
>> +	struct nfs4_deviceid_node *d;
>> +	struct objio_dev_ent *de = kzalloc(sizeof(*de), gfp_flags);
>> +	struct objio_dev_ent *n;
>> +
>> +	if (!de)
>> +		return -ENOMEM;
>> +
>> +	nfs4_init_deviceid_node(&de->id_node,
>> +				nfss->pnfs_curr_ld,
>> +				nfss->nfs_client,
>> +				d_id);
>> +	de->od = od;
>> +
>> +	d = nfs4_insert_deviceid_node(&de->id_node);
>> +	n = container_of(d, struct objio_dev_ent, id_node);
>> +	if (n != de) {
>> +		BUG_ON(n->od != od);
> 
> Benny!!! I removed that BUG_ON why is it back?
> 
> You cannot compare these handles. If you called osduld_info_lookup
> twice You get two different handles. This is because osd_dev handles
> are a filehandle open on the device.
> 
>> +		objio_free_deviceid_node(&de->id_node);
>> +	}
>> +
> 
> Where is the extra ref taking
> 
>> +	return 0;
>> +}
>> +
>>  struct caps_buffers {
>>  	u8 caps_key[OSD_CRYPTO_KEYID_SIZE];
>>  	u8 creds[OSD_CAP_LEN];
>> @@ -65,7 +117,7 @@ struct objio_segment {
>>  	unsigned comps_index;
>>  	unsigned num_comps;
>>  	/* variable length */
>> -	struct osd_dev	*ods[1];
>> +	struct objio_dev_ent *ods[1];
>>  };
>>  
>>  static inline struct objio_segment *
>> @@ -74,6 +126,89 @@ OBJIO_LSEG(struct pnfs_layout_segment *lseg)
>>  	return container_of(lseg, struct objio_segment, lseg);
>>  }
>>  
>> +/* Send and wait for a get_device_info of devices in the layout,
>> +   then look them up with the osd_initiator library */
>> +static struct objio_dev_ent *_device_lookup(struct pnfs_layout_hdr *pnfslay,
>> +				struct objio_segment *objio_seg, unsigned comp,
>> +				gfp_t gfp_flags)
>> +{
>> +	struct pnfs_osd_deviceaddr *deviceaddr;
>> +	struct nfs4_deviceid *d_id;
>> +	struct objio_dev_ent *ode;
>> +	struct osd_dev *od;
>> +	struct osd_dev_info odi;
>> +	int err;
>> +
>> +	d_id = &objio_seg->comps[comp].oc_object_id.oid_device_id;
>> +
>> +	ode = _dev_list_find(NFS_SERVER(pnfslay->plh_inode), d_id);
>> +	if (ode)
>> +		return ode;
>> +
>> +	err = objlayout_get_deviceinfo(pnfslay, d_id, &deviceaddr, gfp_flags);
>> +	if (unlikely(err)) {
>> +		dprintk("%s: objlayout_get_deviceinfo dev(%llx:%llx) =>%d\n",
>> +			__func__, _DEVID_LO(d_id), _DEVID_HI(d_id), err);
>> +		return ERR_PTR(err);
>> +	}
>> +
>> +	odi.systemid_len = deviceaddr->oda_systemid.len;
>> +	if (odi.systemid_len > sizeof(odi.systemid)) {
>> +		err = -EINVAL;
>> +		goto out;
>> +	} else if (odi.systemid_len)
>> +		memcpy(odi.systemid, deviceaddr->oda_systemid.data,
>> +		       odi.systemid_len);
>> +	odi.osdname_len	 = deviceaddr->oda_osdname.len;
>> +	odi.osdname	 = (u8 *)deviceaddr->oda_osdname.data;
>> +
>> +	if (!odi.osdname_len && !odi.systemid_len) {
>> +		dprintk("%s: !odi.osdname_len && !odi.systemid_len\n",
>> +			__func__);
>> +		err = -ENODEV;
>> +		goto out;
>> +	}
>> +
>> +	od = osduld_info_lookup(&odi);
>> +	if (unlikely(IS_ERR(od))) {
>> +		err = PTR_ERR(od);
>> +		dprintk("%s: osduld_info_lookup => %d\n", __func__, err);
>> +		goto out;
>> +	}
>> +
>> +	_dev_list_add(NFS_SERVER(pnfslay->plh_inode), d_id, od, gfp_flags);
>> +
>> +out:
>> +	dprintk("%s: return=%d\n", __func__, err);
>> +	objlayout_put_deviceinfo(deviceaddr);
>> +	return err ? ERR_PTR(err) : od;
> 
> Why is that bug back in
> 
>> +}
>> +
> 
> OK I can see that this patch is back to all the bugs I fixed.
> What's going on?
> 
> (I'll stop reviewing here, I'll compare the all tree and see what else is missing)

Thanks!
I'm not sure, but apparently I dropped this fixes unintentionally.

Benny

> Boaz
>> +static int objio_devices_lookup(struct pnfs_layout_hdr *pnfslay,
>> +	struct objio_segment *objio_seg,
>> +	gfp_t gfp_flags)
>> +{
>> +	unsigned i;
>> +	int err;
>> +
>> +	/* lookup all devices */
>> +	for (i = 0; i < objio_seg->num_comps; i++) {
>> +		struct objio_dev_ent *ode;
>> +
>> +		ode = _device_lookup(pnfslay, objio_seg, i, gfp_flags);
>> +		if (unlikely(IS_ERR(ode))) {
>> +			err = PTR_ERR(ode);
>> +			goto out;
>> +		}
>> +		objio_seg->ods[i] = ode;
>> +	}
>> +	err = 0;
>> +
>> +out:
>> +	dprintk("%s: return=%d\n", __func__, err);
>> +	return err;
>> +}
>> +
>>  static int _verify_data_map(struct pnfs_osd_layout *layout)
>>  {
>>  	struct pnfs_osd_data_map *data_map = &layout->olo_map;
>> @@ -170,6 +305,9 @@ int objio_alloc_lseg(struct pnfs_layout_segment **outp,
>>  
>>  	objio_seg->num_comps = layout.olo_num_comps;
>>  	objio_seg->comps_index = layout.olo_comps_index;
>> +	err = objio_devices_lookup(pnfslay, objio_seg, gfp_flags);
>> +	if (err)
>> +		goto err;
>>  
>>  	objio_seg->mirrors_p1 = layout.olo_map.odm_mirror_cnt + 1;
>>  	objio_seg->stripe_unit = layout.olo_map.odm_stripe_unit;
>> @@ -198,8 +336,14 @@ err:
>>  
>>  void objio_free_lseg(struct pnfs_layout_segment *lseg)
>>  {
>> +	int i;
>>  	struct objio_segment *objio_seg = OBJIO_LSEG(lseg);
>>  
>> +	for (i = 0; i < objio_seg->num_comps; i++) {
>> +		if (!objio_seg->ods[i])
>> +			break;
>> +		nfs4_put_deviceid_node(&objio_seg->ods[i]->id_node);
>> +	}
>>  	kfree(objio_seg);
>>  }
>>  
>> @@ -210,6 +354,8 @@ static struct pnfs_layoutdriver_type objlayout_type = {
>>  
>>  	.alloc_lseg              = objlayout_alloc_lseg,
>>  	.free_lseg               = objlayout_free_lseg,
>> +
>> +	.free_deviceid_node	 = objio_free_deviceid_node,
>>  };
>>  
>>  MODULE_DESCRIPTION("pNFS Layout Driver for OSD2 objects");
>> diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
>> index 9465267..10e5fca 100644
>> --- a/fs/nfs/objlayout/objlayout.c
>> +++ b/fs/nfs/objlayout/objlayout.c
>> @@ -102,3 +102,71 @@ objlayout_free_lseg(struct pnfs_layout_segment *lseg)
>>  	objio_free_lseg(lseg);
>>  }
>>  
>> +/*
>> + * Get Device Info API for io engines
>> + */
>> +struct objlayout_deviceinfo {
>> +	struct page *page;
>> +	struct pnfs_osd_deviceaddr da; /* This must be last */
>> +};
>> +
>> +/* Initialize and call nfs_getdeviceinfo, then decode and return a
>> + * "struct pnfs_osd_deviceaddr *" Eventually objlayout_put_deviceinfo()
>> + * should be called.
>> + */
>> +int objlayout_get_deviceinfo(struct pnfs_layout_hdr *pnfslay,
>> +	struct nfs4_deviceid *d_id, struct pnfs_osd_deviceaddr **deviceaddr,
>> +	gfp_t gfp_flags)
>> +{
>> +	struct objlayout_deviceinfo *odi;
>> +	struct pnfs_device pd;
>> +	struct super_block *sb;
>> +	struct page *page, **pages;
>> +	u32 *p;
>> +	int err;
>> +
>> +	page = alloc_page(gfp_flags);
>> +	if (!page)
>> +		return -ENOMEM;
>> +
>> +	pages = &page;
>> +	pd.pages = pages;
>> +
>> +	memcpy(&pd.dev_id, d_id, sizeof(*d_id));
>> +	pd.layout_type = LAYOUT_OSD2_OBJECTS;
>> +	pd.pages = &page;
>> +	pd.pgbase = 0;
>> +	pd.pglen = PAGE_SIZE;
>> +	pd.mincount = 0;
>> +
>> +	sb = pnfslay->plh_inode->i_sb;
>> +	err = nfs4_proc_getdeviceinfo(NFS_SERVER(pnfslay->plh_inode), &pd);
>> +	dprintk("%s nfs_getdeviceinfo returned %d\n", __func__, err);
>> +	if (err)
>> +		goto err_out;
>> +
>> +	p = page_address(page);
>> +	odi = kzalloc(sizeof(*odi), gfp_flags);
>> +	if (!odi) {
>> +		err = -ENOMEM;
>> +		goto err_out;
>> +	}
>> +	pnfs_osd_xdr_decode_deviceaddr(&odi->da, p);
>> +	odi->page = page;
>> +	*deviceaddr = &odi->da;
>> +	return 0;
>> +
>> +err_out:
>> +	__free_page(page);
>> +	return err;
>> +}
>> +
>> +void objlayout_put_deviceinfo(struct pnfs_osd_deviceaddr *deviceaddr)
>> +{
>> +	struct objlayout_deviceinfo *odi = container_of(deviceaddr,
>> +						struct objlayout_deviceinfo,
>> +						da);
>> +
>> +	__free_page(odi->page);
>> +	kfree(odi);
>> +}
>> diff --git a/fs/nfs/objlayout/objlayout.h b/fs/nfs/objlayout/objlayout.h
>> index 066280a..0814271 100644
>> --- a/fs/nfs/objlayout/objlayout.h
>> +++ b/fs/nfs/objlayout/objlayout.h
>> @@ -56,6 +56,14 @@ extern int objio_alloc_lseg(struct pnfs_layout_segment **outp,
>>  extern void objio_free_lseg(struct pnfs_layout_segment *lseg);
>>  
>>  /*
>> + * callback API
>> + */
>> +extern int objlayout_get_deviceinfo(struct pnfs_layout_hdr *pnfslay,
>> +	struct nfs4_deviceid *d_id, struct pnfs_osd_deviceaddr **deviceaddr,
>> +	gfp_t gfp_flags);
>> +extern void objlayout_put_deviceinfo(struct pnfs_osd_deviceaddr *deviceaddr);
>> +
>> +/*
>>   * exported generic objects function vectors
>>   */
>>  extern struct pnfs_layout_segment *objlayout_alloc_lseg(
> 

