Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:58145 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756405Ab2CPGaX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Mar 2012 02:30:23 -0400
Message-ID: <4F62DDF1.9060000@panasas.com>
Date: Thu, 15 Mar 2012 23:30:09 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@tonian.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>,
        "Bhamare, Sachin" <sbhamare@panasas.com>,
        Steve Dickson <steved@redhat.com>, "Welch, Brent" <welch@panasas.com>
Subject: Re: [PATCH 1/4] pnfsd-exofs:  Add autologin support to exofs
References: <4F62DADD.3010502@panasas.com> <4F62DB6C.6040202@panasas.com>
In-Reply-To: <4F62DB6C.6040202@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/15/2012 11:19 PM, Boaz Harrosh wrote:
> 

Hi Benny I made a mistake with this one it is actually:

From: Sachin Bhamare <sbhamare@panasas.com>

Eventually we'll fix this. please also do so in your
tree.

Thanks
Boaz

> Introduce sysfs infrastructure for exofs cluster filesystem.
> 
> Each OSD target shows up as below in the sysfs hierarchy:
> 	/sys/fs/exofs/<osdname>_<partition_id>/devX
> 
> where in devX 0 <= X < device_table_size. They are ordered
> in device-table order as specified to the mkfs.exofs command
> 
> Each OSD device  devX has following attributes :
> 	osdname - ReadOnly
> 	systemid - ReadOnly
> 	uri - Read/Write
> 
> It is up to user-mode to update devX/uri for support of
> autologin.
> 
> Also fixed is the xdr encoding of device_info to support
> uri encoding.
> 
> Signed-off-by: Sachin Bhamare <sbhamare@panasas.com>
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> ---
>  fs/exofs/Kbuild                |    2 +-
>  fs/exofs/exofs.h               |    4 +
>  fs/exofs/export.c              |    8 ++-
>  fs/exofs/super.c               |   14 +++
>  fs/exofs/sys.c                 |  202 ++++++++++++++++++++++++++++++++++++++++
>  fs/exofs/sys.h                 |   41 ++++++++
>  fs/exportfs/pnfs_osd_xdr_srv.c |   45 ++++++++-
>  include/linux/pnfs_osd_xdr.h   |    5 +
>  8 files changed, 316 insertions(+), 5 deletions(-)
>  create mode 100644 fs/exofs/sys.c
>  create mode 100644 fs/exofs/sys.h
> 
> diff --git a/fs/exofs/Kbuild b/fs/exofs/Kbuild
> index 1118068..5f6f1eb 100644
> --- a/fs/exofs/Kbuild
> +++ b/fs/exofs/Kbuild
> @@ -16,6 +16,6 @@
>  libore-y := ore.o ore_raid.o
>  obj-$(CONFIG_ORE) += libore.o
>  
> -exofs-y := inode.o file.o symlink.o namei.o dir.o super.o
> +exofs-y := inode.o file.o symlink.o namei.o dir.o super.o sys.o
>  exofs-$(CONFIG_PNFSD) +=  export.o
>  obj-$(CONFIG_EXOFS_FS) += exofs.o
> diff --git a/fs/exofs/exofs.h b/fs/exofs/exofs.h
> index 94047b9..b298c7a 100644
> --- a/fs/exofs/exofs.h
> +++ b/fs/exofs/exofs.h
> @@ -56,6 +56,9 @@
>  struct exofs_dev {
>  	struct ore_dev ored;
>  	unsigned did;
> +	unsigned urilen;
> +	uint8_t *uri;
> +	struct kobject ed_kobj;
>  };
>  /*
>   * our extension to the in-memory superblock
> @@ -73,6 +76,7 @@ struct exofs_sb_info {
>  	struct ore_layout	layout;		/* Default files layout       */
>  	struct ore_comp one_comp;		/* id & cred of partition id=0*/
>  	struct ore_components oc;		/* comps for the partition    */
> +	struct kobject	s_kobj;			/* holds per-sbi kobject      */
>  };
>  
>  /*
> diff --git a/fs/exofs/export.c b/fs/exofs/export.c
> index 621bd11..a53f575 100644
> --- a/fs/exofs/export.c
> +++ b/fs/exofs/export.c
> @@ -321,6 +321,7 @@ int exofs_get_device_info(struct super_block *sb, struct exp_xdr_stream *xdr,
>  {
>  	struct exofs_sb_info *sbi = sb->s_fs_info;
>  	struct pnfs_osd_deviceaddr devaddr;
> +	struct exofs_dev *edev;
>  	const struct osd_dev_info *odi;
>  	u64 devno = devid->devid;
>  	__be32 *start;
> @@ -334,7 +335,8 @@ int exofs_get_device_info(struct super_block *sb, struct exp_xdr_stream *xdr,
>  		return -ENODEV;
>  	}
>  
> -	odi = osduld_device_info(sbi->oc.ods[devno]->od);
> +	edev = container_of(sbi->oc.ods[devno], typeof(*edev), ored);
> +	odi = osduld_device_info(edev->ored.od);
>  
>  	devaddr.oda_systemid.len = odi->systemid_len;
>  	devaddr.oda_systemid.data = (void *)odi->systemid; /* !const cast */
> @@ -342,6 +344,10 @@ int exofs_get_device_info(struct super_block *sb, struct exp_xdr_stream *xdr,
>  	devaddr.oda_osdname.len = odi->osdname_len ;
>  	devaddr.oda_osdname.data = (void *)odi->osdname;/* !const cast */
>  
> +	devaddr.oda_targetaddr.ota_available = OBJ_OTA_AVAILABLE;
> +	devaddr.oda_targetaddr.ota_netaddr.r_addr.data = (void *)edev->uri;
> +	devaddr.oda_targetaddr.ota_netaddr.r_addr.len = edev->urilen;
> +
>  	/* skip opaque size, will be filled-in later */
>  	start = exp_xdr_reserve_qwords(xdr, 1);
>  	if (!start) {
> diff --git a/fs/exofs/super.c b/fs/exofs/super.c
> index 3c0d83a..a4834f7 100644
> --- a/fs/exofs/super.c
> +++ b/fs/exofs/super.c
> @@ -39,6 +39,7 @@
>  #include <linux/exportfs.h>
>  #include <linux/slab.h>
>  
> +#include "sys.h"
>  #include "exofs.h"
>  
>  #define EXOFS_DBGMSG2(M...) do {} while (0)
> @@ -472,6 +473,7 @@ static void exofs_put_super(struct super_block *sb)
>  	_exofs_print_device("Unmounting", NULL, ore_comp_dev(&sbi->oc, 0),
>  			    sbi->one_comp.obj.partition);
>  
> +	exofs_sysfs_cluster_del(sbi);
>  	bdi_destroy(&sbi->bdi);
>  	exofs_free_sbi(sbi);
>  	sb->s_fs_info = NULL;
> @@ -632,6 +634,11 @@ static int exofs_read_lookup_dev_table(struct exofs_sb_info *sbi,
>  	memcpy(&sbi->oc.ods[numdevs], &sbi->oc.ods[0],
>  		(numdevs - 1) * sizeof(sbi->oc.ods[0]));
>  
> +	/* create sysfs entries to hold the current exofs cluster instance.
> +	 * There will be one sysfs dirent for cluster osdname per exofs mount
> +	 */
> +	exofs_sysfs_cluster_add(&dt->dt_dev_table[0], sbi);
> +
>  	for (i = 0; i < numdevs; i++) {
>  		struct exofs_fscb fscb;
>  		struct osd_dev_info odi;
> @@ -657,6 +664,7 @@ static int exofs_read_lookup_dev_table(struct exofs_sb_info *sbi,
>  			eds[i].ored.od = fscb_od;
>  			++sbi->oc.numdevs;
>  			fscb_od = NULL;
> +			exofs_sysfs_odev_add(&eds[i], sbi);
>  			continue;
>  		}
>  
> @@ -682,6 +690,7 @@ static int exofs_read_lookup_dev_table(struct exofs_sb_info *sbi,
>  				  odi.osdname);
>  			goto out;
>  		}
> +		exofs_sysfs_odev_add(&eds[i], sbi);
>  
>  		/* TODO: verify other information is correct and FS-uuid
>  		 *	 matches. Benny what did you say about device table
> @@ -845,6 +854,7 @@ static int exofs_fill_super(struct super_block *sb, void *data, int silent)
>  		goto free_sbi;
>  	}
>  
> +	exofs_sysfs_print();
>  	_exofs_print_device("Mounting", opts->dev_name,
>  			    ore_comp_dev(&sbi->oc, 0),
>  			    sbi->one_comp.obj.partition);
> @@ -1024,6 +1034,9 @@ static int __init init_exofs(void)
>  	if (err)
>  		goto out_d;
>  
> +	/* We don't fail if sysfs creation failed */
> +	exofs_sysfs_init();
> +
>  	return 0;
>  out_d:
>  	destroy_inodecache();
> @@ -1033,6 +1046,7 @@ out:
>  
>  static void __exit exit_exofs(void)
>  {
> +	exofs_sysfs_uninit();
>  	unregister_filesystem(&exofs_type);
>  	destroy_inodecache();
>  }
> diff --git a/fs/exofs/sys.c b/fs/exofs/sys.c
> new file mode 100644
> index 0000000..17c9c07
> --- /dev/null
> +++ b/fs/exofs/sys.c
> @@ -0,0 +1,202 @@
> +/*
> + * Copyright (C) 2012
> + * Sachin Bhamare <sbhamare@panasas.com>
> + *
> + * This file is part of exofs.
> + *
> + * exofs is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation.  Since it is based on ext2, and the only
> + * valid version of GPL for the Linux kernel is version 2, the only valid
> + * version of GPL for exofs is version 2.
> + *
> + * exofs is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with exofs; if not, write to the Free Software
> + * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
> + */
> +
> +#include <linux/kobject.h>
> +#include <linux/device.h>
> +
> +#include "sys.h"
> +#include "exofs.h"
> +
> +struct odev_attr {
> +	struct attribute attr;
> +	ssize_t (*show)(struct exofs_dev *, char *);
> +	ssize_t (*store)(struct exofs_dev *, const char *, size_t);
> +};
> +
> +static ssize_t odev_attr_show(struct kobject *kobj, struct attribute *attr,
> +		char *buf)
> +{
> +	struct exofs_dev *edp = container_of(kobj, struct exofs_dev, ed_kobj);
> +	struct odev_attr *a = container_of(attr, struct odev_attr, attr);
> +
> +	return a->show ? a->show(edp, buf) : 0;
> +}
> +
> +static ssize_t odev_attr_store(struct kobject *kobj, struct attribute *attr,
> +		const char *buf, size_t len)
> +{
> +	struct exofs_dev *edp = container_of(kobj, struct exofs_dev, ed_kobj);
> +	struct odev_attr *a = container_of(attr, struct odev_attr, attr);
> +
> +	return a->store ? a->store(edp, buf, len) : len;
> +}
> +
> +static const struct sysfs_ops odev_attr_ops = {
> +	.show  = odev_attr_show,
> +	.store = odev_attr_store,
> +};
> +
> +
> +static struct kset *exofs_kset;
> +
> +static ssize_t osdname_show(struct exofs_dev *edp, char *buf)
> +{
> +	struct osd_dev *odev = edp->ored.od;
> +	const struct osd_dev_info *odi = osduld_device_info(odev);
> +
> +	return snprintf(buf, odi->osdname_len + 1, "%s", odi->osdname);
> +}
> +
> +static ssize_t systemid_show(struct exofs_dev *edp, char *buf)
> +{
> +	struct osd_dev *odev = edp->ored.od;
> +	const struct osd_dev_info *odi = osduld_device_info(odev);
> +
> +	memcpy(buf, odi->systemid, odi->systemid_len);
> +	return odi->systemid_len;
> +}
> +
> +static ssize_t uri_show(struct exofs_dev *edp, char *buf)
> +{
> +	return snprintf(buf, edp->urilen, "%s", edp->uri);
> +}
> +
> +static ssize_t uri_store(struct exofs_dev *edp, const char *buf, size_t len)
> +{
> +	edp->urilen = strlen(buf) + 1;
> +	edp->uri = krealloc(edp->uri, edp->urilen, GFP_KERNEL);
> +	strncpy(edp->uri, buf, edp->urilen);
> +	return edp->urilen;
> +}
> +
> +#define OSD_ATTR(name, mode, show, store) \
> +	static struct odev_attr odev_attr_##name = \
> +					__ATTR(name, mode, show, store)
> +
> +OSD_ATTR(osdname, S_IRUGO, osdname_show, NULL);
> +OSD_ATTR(systemid, S_IRUGO, systemid_show, NULL);
> +OSD_ATTR(uri, S_IRWXU, uri_show, uri_store);
> +
> +static struct attribute *odev_attrs[] = {
> +	&odev_attr_osdname.attr,
> +	&odev_attr_systemid.attr,
> +	&odev_attr_uri.attr,
> +	NULL,
> +};
> +
> +static struct kobj_type odev_ktype = {
> +	.default_attrs	= odev_attrs,
> +	.sysfs_ops	= &odev_attr_ops,
> +};
> +
> +static struct kobj_type uuid_ktype = {
> +};
> +
> +void exofs_sysfs_print()
> +{
> +#ifdef CONFIG_EXOFS_DEBUG
> +	struct kobject *k_name, *k_tmp;
> +
> +	list_for_each_entry_safe(k_name, k_tmp, &exofs_kset->list, entry) {
> +		printk(KERN_INFO "%s: name %s ref %d\n",
> +			__func__, kobject_name(k_name),
> +			(int)atomic_read(&k_name->kref.refcount));
> +	}
> +#endif
> +}
> +/*
> + * This function removes all kobjects under exofs_kset
> + * At the end of it, exofs_kset kobject will have a refcount
> + * of 1 which gets decremented only on exofs module unload
> + */
> +void exofs_sysfs_cluster_del(struct exofs_sb_info *sbi)
> +{
> +	struct kobject *k_name, *k_tmp;
> +	struct kobject *s_kobj = &sbi->s_kobj;
> +
> +	list_for_each_entry_safe(k_name, k_tmp, &exofs_kset->list, entry) {
> +		/* Remove all that are children of this SBI */
> +		if (k_name->parent == s_kobj)
> +			kobject_put(k_name);
> +	}
> +	kobject_put(s_kobj);
> +}
> +
> +/*
> + * This function creates sysfs entries to hold the current exofs cluster
> + * instance (uniquely identified by osdname,pid tuple).
> + * This function gets called once per exofs mount instance.
> + */
> +int exofs_sysfs_cluster_add(struct exofs_dt_device_info *dt_dev,
> +		struct exofs_sb_info *sbi)
> +{
> +	struct kobject *s_kobj;
> +	int retval = 0;
> +	uint64_t pid = sbi->one_comp.obj.partition;
> +
> +	/* allocate new uuid dirent */
> +	s_kobj = &sbi->s_kobj;
> +	s_kobj->kset = exofs_kset;
> +	retval = kobject_init_and_add(s_kobj, &uuid_ktype,
> +			&exofs_kset->kobj,  "%s_%llx", dt_dev->osdname, pid);
> +	if (retval) {
> +		EXOFS_ERR("ERROR: Failed to create sysfs entry for "
> +			"uuid-%s_%llx => %d\n", dt_dev->osdname, pid, retval);
> +		return -ENOMEM;
> +	}
> +	return 0;
> +}
> +
> +int exofs_sysfs_odev_add(struct exofs_dev *edev, struct exofs_sb_info *sbi)
> +{
> +	struct kobject *d_kobj;
> +	int retval = 0;
> +
> +	/* create osd device group which contains following attributes
> +	 * osdname, systemid & uri
> +	 */
> +	d_kobj = &edev->ed_kobj;
> +	d_kobj->kset = exofs_kset;
> +	retval = kobject_init_and_add(d_kobj, &odev_ktype,
> +			&sbi->s_kobj, "dev%u", edev->did);
> +	if (retval) {
> +		EXOFS_ERR("ERROR: Failed to create sysfs entry for"
> +				" device dev%u\n", edev->did);
> +		return retval;
> +	}
> +	return 0;
> +}
> +
> +int exofs_sysfs_init(void)
> +{
> +	exofs_kset = kset_create_and_add("exofs", NULL, fs_kobj);
> +	if (!exofs_kset) {
> +		EXOFS_ERR("ERROR: kset_create_and_add exofs failed\n");
> +		return -ENOMEM;
> +	}
> +	return 0;
> +}
> +
> +void exofs_sysfs_uninit(void)
> +{
> +	kset_unregister(exofs_kset);
> +}
> diff --git a/fs/exofs/sys.h b/fs/exofs/sys.h
> new file mode 100644
> index 0000000..cfabc1d
> --- /dev/null
> +++ b/fs/exofs/sys.h
> @@ -0,0 +1,41 @@
> +/*
> + * Copyright (C) 2012
> + * Sachin Bhamare <sbhamare@panasas.com>
> + *
> + * This file is part of exofs.
> + *
> + * exofs is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation.  Since it is based on ext2, and the only
> + * valid version of GPL for the Linux kernel is version 2, the only valid
> + * version of GPL for exofs is version 2.
> + *
> + * exofs is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with exofs; if not, write to the Free Software
> + * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
> + */
> +
> +#ifndef __SYS_DOT_H__
> +#define __SYS_DOT_H__
> +
> +struct exofs_dev;
> +struct exofs_sb_info;
> +struct exofs_dt_device_info;
> +
> +int exofs_sysfs_odev_add(struct exofs_dev *edev,
> +			 struct exofs_sb_info *sbi);
> +int exofs_sysfs_cluster_add(struct exofs_dt_device_info *dt_dev,
> +		struct exofs_sb_info *sbi);
> +void exofs_sysfs_cluster_del(struct exofs_sb_info *sbi);
> +
> +void exofs_sysfs_print(void);
> +int exofs_sysfs_init(void);
> +void exofs_sysfs_uninit(void);
> +
> +#endif /* __SYS_DOT_H__ */
> +
> diff --git a/fs/exportfs/pnfs_osd_xdr_srv.c b/fs/exportfs/pnfs_osd_xdr_srv.c
> index 12a3bda..d0795c44 100644
> --- a/fs/exportfs/pnfs_osd_xdr_srv.c
> +++ b/fs/exportfs/pnfs_osd_xdr_srv.c
> @@ -179,6 +179,42 @@ static enum nfsstat4 _encode_string(struct exp_xdr_stream *xdr,
>  	return 0;
>  }
>  
> +/* struct pnfs_osd_targetaddr {
> + *	u32				ota_available;
> + *	struct pnfs_osd_net_addr	ota_netaddr;
> + * };
> + */
> +static inline enum nfsstat4 pnfs_osd_xdr_encode_targetaddr(
> +	struct exp_xdr_stream *xdr,
> +	struct pnfs_osd_targetaddr *taddr)
> +{
> +	__be32 *p;
> +
> +	/* ota_available */
> +	p = exp_xdr_reserve_space(xdr, 4);
> +	if (!p)
> +		return NFS4ERR_TOOSMALL;
> +	p = exp_xdr_encode_u32(p, taddr->ota_available);
> +
> +	/* encode r_netid */
> +	p = exp_xdr_reserve_space(xdr, 4 + taddr->ota_netaddr.r_netid.len);
> +	if (!p)
> +		return NFS4ERR_TOOSMALL;
> +
> +	p = exp_xdr_encode_opaque(p,
> +				taddr->ota_netaddr.r_netid.data,
> +				taddr->ota_netaddr.r_netid.len);
> +
> +	/* encode r_addr */
> +	p = exp_xdr_reserve_space(xdr, 4 + taddr->ota_netaddr.r_addr.len);
> +	if (!p)
> +		return NFS4ERR_TOOSMALL;
> +	p = exp_xdr_encode_opaque(p,
> +				taddr->ota_netaddr.r_addr.data,
> +				taddr->ota_netaddr.r_addr.len);
> +	return 0;
> +}
> +
>  /* struct pnfs_osd_deviceaddr {
>   *	struct pnfs_osd_targetid	oda_targetid;
>   *	struct pnfs_osd_targetaddr	oda_targetaddr;
> @@ -194,17 +230,20 @@ enum nfsstat4 pnfs_osd_xdr_encode_deviceaddr(
>  	__be32 *p;
>  	enum nfsstat4 err;
>  
> -	p = exp_xdr_reserve_space(xdr, 4 + 4 + sizeof(devaddr->oda_lun));
> +	p = exp_xdr_reserve_space(xdr, sizeof(u32));
>  	if (!p)
>  		return NFS4ERR_TOOSMALL;
>  
>  	/* Empty oda_targetid */
>  	p = exp_xdr_encode_u32(p, OBJ_TARGET_ANON);
>  
> -	/* Empty oda_targetaddr for now */
> -	p = exp_xdr_encode_u32(p, 0);
> +	/* oda_targetaddr */
> +	err = pnfs_osd_xdr_encode_targetaddr(xdr, &devaddr->oda_targetaddr);
> +	if (err)
> +		return err;
>  
>  	/* oda_lun */
> +	p = exp_xdr_reserve_space(xdr, sizeof(devaddr->oda_lun));
>  	exp_xdr_encode_bytes(p, devaddr->oda_lun, sizeof(devaddr->oda_lun));
>  
>  	err = _encode_string(xdr, &devaddr->oda_systemid);
> diff --git a/include/linux/pnfs_osd_xdr.h b/include/linux/pnfs_osd_xdr.h
> index e0557c1..eeedf73 100644
> --- a/include/linux/pnfs_osd_xdr.h
> +++ b/include/linux/pnfs_osd_xdr.h
> @@ -154,6 +154,11 @@ enum pnfs_osd_targetid_type {
>  	OBJ_TARGET_SCSI_DEVICE_ID = 3,
>  };
>  
> +enum pnfs_osd_target_ota {
> +	OBJ_OTA_UNAVAILABLE = 0,
> +	OBJ_OTA_AVAILABLE = 1,
> +};
> +
>  /*   union pnfs_osd_targetid4 switch (pnfs_osd_targetid_type4 oti_type) {
>   *       case OBJ_TARGET_SCSI_NAME:
>   *           string              oti_scsi_name<>;

