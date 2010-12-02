Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:34108 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757606Ab0LBN7o (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Dec 2010 08:59:44 -0500
Message-ID: <4CF7A64D.8040802@panasas.com>
Date: Thu, 02 Dec 2010 15:59:41 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Jim Rees <rees@umich.edu>
CC: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH 4/5] various minor cleanups
References: <cover.1291142529.git.rees@umich.edu> <55dae19c431eeee6d4fabf18550fdf976646a9a5.1291142529.git.rees@umich.edu>
In-Reply-To: <55dae19c431eeee6d4fabf18550fdf976646a9a5.1291142529.git.rees@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-11-30 21:14, Jim Rees wrote:
> Signed-off-by: Jim Rees <rees@umich.edu>
> ---
>  utils/blkmapd/device-discovery.c |    1 +
>  utils/blkmapd/device-discovery.h |   11 +--
>  utils/blkmapd/device-inq.c       |    7 +-
>  utils/blkmapd/device-process.c   |   31 ++++---
>  utils/blkmapd/dm-device.c        |  164 +++++++++++++++++--------------------
>  5 files changed, 103 insertions(+), 111 deletions(-)
> 
> diff --git a/utils/blkmapd/device-discovery.c b/utils/blkmapd/device-discovery.c
> index 0497a11..c2675b8 100644
> --- a/utils/blkmapd/device-discovery.c
> +++ b/utils/blkmapd/device-discovery.c
> @@ -39,6 +39,7 @@
>  #include <stdlib.h>
>  #include <stdio.h>
>  #include <string.h>
> +#include <syslog.h>
>  #include <dirent.h>
>  #include <ctype.h>
>  #include <fcntl.h>
> diff --git a/utils/blkmapd/device-discovery.h b/utils/blkmapd/device-discovery.h
> index 8cf88b8..a0937b1 100644
> --- a/utils/blkmapd/device-discovery.h
> +++ b/utils/blkmapd/device-discovery.h
> @@ -28,11 +28,10 @@
>  #define BL_DEVICE_DISCOVERY_H
>  
>  #include <stdint.h>
> -#include <syslog.h>
>  
>  enum blk_vol_type {
>  	BLOCK_VOLUME_SIMPLE = 0,	/* maps to a single LU */
> -	BLOCK_VOLUME_SLICE = 1,	/* slice of another volume */
> +	BLOCK_VOLUME_SLICE = 1,		/* slice of another volume */
>  	BLOCK_VOLUME_CONCAT = 2,	/* concatenation of multiple volumes */
>  	BLOCK_VOLUME_STRIPE = 3,	/* striped across multiple volumes */
>  	BLOCK_VOLUME_PSEUDO = 4,
> @@ -45,15 +44,15 @@ struct bl_volume {
>  	struct bl_volume **bv_vols;
>  	int bv_vol_n;
>  	union {
> -		dev_t bv_dev;	/* for BLOCK_VOLUME_SIMPLE(PSEUDO) */
> +		dev_t bv_dev;		/* for BLOCK_VOLUME_SIMPLE(PSEUDO) */
>  		off_t bv_stripe_unit;	/* for BLOCK_VOLUME_STRIPE(CONCAT) */
>  		off_t bv_offset;	/* for BLOCK_VOLUME_SLICE */
>  	} param;
>  };
>  
>  struct bl_sig_comp {
> -	int64_t bs_offset;	/* In bytes */
> -	uint32_t bs_length;	/* In bytes */
> +	uint64_t bs_offset;		/* In bytes */
> +	uint32_t bs_length;		/* In bytes */
>  	char *bs_string;
>  };
>  
> @@ -107,7 +106,7 @@ struct pipefs_hdr {
>  	uint32_t msgid;
>  	uint8_t type;
>  	uint8_t flags;
> -	uint16_t totallen;	/* length of entire message, including hdr */
> +	uint16_t totallen;		/* length of entire message, including hdr */
>  	uint32_t status;
>  };
>  
> diff --git a/utils/blkmapd/device-inq.c b/utils/blkmapd/device-inq.c
> index e1c0128..eabc70c 100644
> --- a/utils/blkmapd/device-inq.c
> +++ b/utils/blkmapd/device-inq.c
> @@ -39,11 +39,12 @@
>  
>  #include <stdlib.h>
>  #include <stdio.h>
> +#include <unistd.h>
>  #include <string.h>
> +#include <syslog.h>
>  #include <dirent.h>
>  #include <ctype.h>
>  #include <fcntl.h>
> -#include <unistd.h>
>  #include <libgen.h>
>  #include <errno.h>
>  
> @@ -174,10 +175,10 @@ extern enum bl_path_state_e bldev_read_ap_state(int fd)
>  struct bl_serial *bldev_read_serial(int fd, const char *filename)
>  {
>  	struct bl_serial *serial_out = NULL;
> -	int status = 0, pos, len;
> +	int status = 0;
>  	char *buffer;
>  	struct bl_dev_id *dev_root, *dev_id;
> -	unsigned int current_id = 0;
> +	unsigned int pos, len, current_id = 0;
>  
>  	status = bldev_inquire_pages(fd, 0x83, &buffer);
>  	if (status)
> diff --git a/utils/blkmapd/device-process.c b/utils/blkmapd/device-process.c
> index 4482bd5..4ce47e1 100644
> --- a/utils/blkmapd/device-process.c
> +++ b/utils/blkmapd/device-process.c
> @@ -33,29 +33,33 @@
>   * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
>   */
>  
> -#include <libdevmapper.h>
> +#include <sys/types.h>
> +#include <sys/stat.h>
> +#include <sys/user.h>
> +#include <arpa/inet.h>
> +#include <linux/kdev_t.h>
> +
>  #include <stdio.h>
>  #include <stdlib.h>
>  #include <string.h>
>  #include <unistd.h>
> -#include <sys/types.h>
> -#include <sys/stat.h>
> -#include <sys/user.h>
> +#include <syslog.h>
>  #include <fcntl.h>
>  #include <errno.h>
> -#include <arpa/inet.h>
> -#include <linux/kdev_t.h>
> +
>  #include "device-discovery.h"
>  
> -static char *pretty_sig(char *sig, int siglen)
> +static char *pretty_sig(char *sig, uint32_t siglen)
>  {
>  	static char rs[100];
> -	unsigned int i;
> +	unsigned long i;
>  
> -	if (siglen <= 4) {
> +	if (siglen <= sizeof i) {
>  		memcpy(&i, sig, sizeof i);
> -		sprintf(rs, "0x%0x", i);
> +		sprintf(rs, "0x%0lx", i);

What about machine endianess?
The MDS and clients may be of different gender, no?
Also, on 64 bit machines, you may copy 8 bytes while the signature
is 4-bytes long so you may copy junk into i.

Benny

>  	} else {
> +		if (siglen > sizeof rs - 1)
> +			siglen = sizeof rs - 1;
>  		memcpy(rs, sig, siglen);
>  		rs[siglen] = '\0';
>  	}
> @@ -65,6 +69,7 @@ static char *pretty_sig(char *sig, int siglen)
>  uint32_t *blk_overflow(uint32_t * p, uint32_t * end, size_t nbytes)
>  {
>  	uint32_t *q = p + ((nbytes + 3) >> 2);
> +
>  	if (q > end || q < p)
>  		return NULL;
>  	return p;
> @@ -73,8 +78,8 @@ uint32_t *blk_overflow(uint32_t * p, uint32_t * end, size_t nbytes)
>  static int decode_blk_signature(uint32_t ** pp, uint32_t * end,
>  				struct bl_sig *sig)
>  {
> -	int i, siglen;
> -	uint32_t *p = *pp;
> +	int i;
> +	uint32_t siglen, *p = *pp;
>  
>  	BLK_READBUF(p, end, 4);
>  	READ32(sig->si_num_comps);
> @@ -288,7 +293,7 @@ static int decode_blk_volume(uint32_t **pp, uint32_t *end,
>  		off_t chunksize = vol->param.bv_stripe_unit;
>  		if ((chunksize == 0) ||
>  		    ((chunksize & (chunksize - 1)) != 0) ||
> -		    (chunksize < (PAGE_SIZE >> 9)))
> +		    (chunksize < (off_t)(PAGE_SIZE >> 9)))
>  			return -EIO;
>  		BLK_READBUF(p, end, 4);
>  		READ32(vol->bv_vol_n);
> diff --git a/utils/blkmapd/dm-device.c b/utils/blkmapd/dm-device.c
> index 14ad131..5a9f5ec 100644
> --- a/utils/blkmapd/dm-device.c
> +++ b/utils/blkmapd/dm-device.c
> @@ -24,15 +24,19 @@
>   * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
>   * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
>   */
> -#include <libdevmapper.h>
> +
> +#include <sys/types.h>
> +#include <sys/stat.h>
> +#include <linux/kdev_t.h>
> +
>  #include <stdio.h>
>  #include <stdlib.h>
>  #include <string.h>
> -#include <sys/types.h>
> -#include <sys/stat.h>
> +#include <syslog.h>
>  #include <fcntl.h>
>  #include <errno.h>
> -#include <linux/kdev_t.h>
> +#include <libdevmapper.h>
> +
>  #include "device-discovery.h"
>  
>  #define DM_DEV_NAME_LEN		256
> @@ -66,9 +70,10 @@ static inline struct bl_dm_table *bl_dm_table_alloc(void)
>  	return (struct bl_dm_table *)calloc(1, sizeof(struct bl_dm_table));
>  }
>  
> -void bl_dm_table_free(struct bl_dm_table *bl_table_head)
> +static void bl_dm_table_free(struct bl_dm_table *bl_table_head)
>  {
> -	struct bl_dm_table *p = bl_table_head;
> +	struct bl_dm_table *p;
> +
>  	while (bl_table_head) {
>  		p = bl_table_head->next;
>  		free(bl_table_head);
> @@ -76,41 +81,39 @@ void bl_dm_table_free(struct bl_dm_table *bl_table_head)
>  	}
>  }
>  
> -void add_to_bl_dm_table(struct bl_dm_table **bl_table_head,
> +static void add_to_bl_dm_table(struct bl_dm_table **bl_table_head,
>  			struct bl_dm_table *table)
>  {
> -	struct bl_dm_table *pre;
> +	struct bl_dm_table *p;
> +
>  	if (!*bl_table_head) {
>  		*bl_table_head = table;
>  		return;
>  	}
> -	pre = *bl_table_head;
> -	while (pre->next)
> -		pre = pre->next;
> -	pre->next = table;
> -	return;
> +	p = *bl_table_head;
> +	while (p->next)
> +		p = p->next;
> +	p->next = table;
>  }
>  
>  struct bl_dm_tree *bl_tree_head;
>  
> -struct bl_dm_tree *find_bl_dm_tree(uint64_t dev)
> +static struct bl_dm_tree *find_bl_dm_tree(uint64_t dev)
>  {
> -	struct bl_dm_tree *p = bl_tree_head;
> -	while (p) {
> +	struct bl_dm_tree *p;
> +
> +	for (p = bl_tree_head; p; p = p->next) {
>  		if (p->dev == dev)
> -			return p;
> -		p = p->next;
> +		    break;
>  	}
> -	return NULL;
> +	return p;
>  }
>  
> -void del_from_bl_dm_tree(uint64_t dev)
> +static void del_from_bl_dm_tree(uint64_t dev)
>  {
> -	struct bl_dm_tree *pre = bl_tree_head;
> -	struct bl_dm_tree *p;
> +	struct bl_dm_tree *p, *pre = bl_tree_head;
>  
> -	p = pre;
> -	while (p) {
> +	for (p = pre; p; p = p->next) {
>  		if (p->dev == dev) {
>  			pre->next = p->next;
>  			if (p == bl_tree_head)
> @@ -119,29 +122,31 @@ void del_from_bl_dm_tree(uint64_t dev)
>  			break;
>  		}
>  		pre = p;
> -		p = pre->next;
>  	}
>  }
>  
> -void add_to_bl_dm_tree(struct bl_dm_tree *tree)
> +static void add_to_bl_dm_tree(struct bl_dm_tree *tree)
>  {
> -	struct bl_dm_tree *pre;
> +	struct bl_dm_tree *p;
> +
>  	if (!bl_tree_head) {
>  		bl_tree_head = tree;
>  		return;
>  	}
> -	pre = bl_tree_head;
> -	while (pre->next)
> -		pre = pre->next;
> -	pre->next = tree;
> +	p = bl_tree_head;
> +	while (p->next)
> +		p = p->next;
> +	p->next = tree;
>  	return;
>  }
>  
> -/* Create device via device mapper
> +/*
> + * Create device via device mapper
>   * return 0 when creation failed
>   * return dev no for created device
>   */
> -uint64_t dm_single_device_create(const char *dev_name, struct bl_dm_table * p)
> +static uint64_t
> +dm_single_device_create(const char *dev_name, struct bl_dm_table * p)
>  {
>  	struct dm_task *dmt;
>  	struct dm_info dminfo;
> @@ -182,21 +187,19 @@ uint64_t dm_single_device_create(const char *dev_name, struct bl_dm_table * p)
>  	return MKDEV(dminfo.major, dminfo.minor);
>  }
>  
> -int dm_device_remove_byname(const char *dev_name)
> +static int dm_device_remove_byname(const char *dev_name)
>  {
>  	struct dm_task *dmt;
>  	int ret = 0;
>  
>  	dmt = dm_task_create(DM_DEVICE_REMOVE);
>  	if (!dmt)
> -		return -ENODEV;
> +		return 0;
>  
>  	ret = dm_task_set_name(dmt, dev_name) && dm_task_run(dmt);
>  
>  	dm_task_update_nodes();
> -
> -	if (dmt)
> -		dm_task_destroy(dmt);
> +	dm_task_destroy(dmt);
>  
>  	return ret;
>  }
> @@ -205,61 +208,64 @@ int dm_device_remove(uint64_t dev)
>  {
>  	struct dm_task *dmt;
>  	struct dm_names *dmnames;
> -	char *names = NULL;
> -	int ret = -1;
> +	char *name = NULL;
> +	int ret = 0;
>  
>  	/* Look for dev_name via dev, if dev_name could be transferred here,
>  	   we could jump to DM_DEVICE_REMOVE directly */
> +
>  	dmt = dm_task_create(DM_DEVICE_LIST);
>  	if (!dmt) {
>  		BL_LOG_ERR("dm_task creation failed\n");
> -		return -ENODEV;
> +		goto out;
>  	}
>  
>  	ret = dm_task_run(dmt);
>  	if (!ret) {
>  		BL_LOG_ERR("dm_task_run failed\n");
> -		goto error;
> +		goto out;
>  	}
>  
>  	dmnames = dm_task_get_names(dmt);
>  	if (!dmnames || !dmnames->dev) {
>  		BL_LOG_ERR("dm_task_get_names failed\n");
> -		goto error;
> +		goto out;
>  	}
>  
> -	do {
> +	while (dmnames) {
>  		if (dmnames->dev == dev) {
> -			names = dmnames->name;
> +			name = dmnames->name;
>  			break;
>  		}
>  		dmnames = (void *)dmnames + dmnames->next;
> -	} while (dmnames);
> +	}
>  
> -	if (!names) {
> +	if (!name) {
>  		BL_LOG_ERR("Could not find device\n");
> -		goto error;
> +		goto out;
>  	}
>  
>  	dm_task_update_nodes();
>  
> - error:
> -	dm_task_destroy(dmt);
> + out:
> +	if (dmt)
> +		dm_task_destroy(dmt);
>  
>  	/* Start to remove device */
> -	if (names)
> -		ret = dm_device_remove_byname(names);
> +	if (name)
> +		ret = dm_device_remove_byname(name);
> +
>  	return ret;
>  }
>  
>  static unsigned long dev_count;
>  
> -void dm_devicelist_remove(unsigned long start, unsigned long end)
> +static void dm_devicelist_remove(unsigned long start, unsigned long end)
>  {
>  	char dev_name[DM_DEV_NAME_LEN];
>  	unsigned long count;
>  
> -	if ((start >= dev_count) || (end <= 1) || (start >= end - 1))
> +	if (start >= dev_count || end <= 1 || start >= end - 1)
>  		return;
>  
>  	for (count = end - 1; count > start; count--) {
> @@ -270,7 +276,7 @@ void dm_devicelist_remove(unsigned long start, unsigned long end)
>  	return;
>  }
>  
> -void bl_dm_remove_tree(uint64_t dev)
> +static void bl_dm_remove_tree(uint64_t dev)
>  {
>  	struct bl_dm_tree *p;
>  
> @@ -282,28 +288,28 @@ void bl_dm_remove_tree(uint64_t dev)
>  	del_from_bl_dm_tree(dev);
>  }
>  
> -void bl_dm_create_tree(uint64_t dev)
> +static int bl_dm_create_tree(uint64_t dev)
>  {
>  	struct dm_tree *tree;
>  	struct bl_dm_tree *bl_tree;
>  
>  	bl_tree = find_bl_dm_tree(dev);
>  	if (bl_tree)
> -		return;		/* XXX: error? */
> +		return 1;
>  
>  	tree = dm_tree_create();
>  	if (!tree)
> -		return;
> +		return 0;
>  
>  	if (!dm_tree_add_dev(tree, MAJOR(dev), MINOR(dev))) {
>  		dm_tree_free(tree);
> -		return;
> +		return 0;
>  	}
>  
>  	bl_tree = malloc(sizeof(struct bl_dm_tree));
>  	if (!bl_tree) {
>  		dm_tree_free(tree);
> -		return;
> +		return 0;
>  	}
>  
>  	bl_tree->dev = dev;
> @@ -311,29 +317,7 @@ void bl_dm_create_tree(uint64_t dev)
>  	bl_tree->next = NULL;
>  	add_to_bl_dm_tree(bl_tree);
>  
> -	return;
> -}
> -
> -uint64_t dm_device_nametodev(char *dev_name)
> -{
> -	struct dm_task *dmt;
> -	int ret = 0;
> -	struct dm_info dminfo;
> -
> -	dmt = dm_task_create(DM_DEVICE_INFO);
> -	if (!dmt)
> -		return -ENODEV;
> -
> -	ret = dm_task_set_name(dmt, dev_name) &&
> -	    dm_task_run(dmt) && dm_task_get_info(dmt, &dminfo);
> -
> -	if (dmt)
> -		dm_task_destroy(dmt);
> -
> -	if (!ret)
> -		return 0;
> -
> -	return MKDEV(dminfo.major, dminfo.minor);
> +	return 1;
>  }
>  
>  int dm_device_remove_all(uint64_t *dev)
> @@ -364,6 +348,7 @@ int dm_device_remove_all(uint64_t *dev)
>  	ret = dm_tree_deactivate_children(node, uuid, strlen(uuid));
>  	dm_task_update_nodes();
>  	bl_dm_remove_tree(bl_dev);
> +
>  	return ret;
>  }
>  
> @@ -372,7 +357,7 @@ uint64_t dm_device_create(struct bl_volume *vols, int num_vols)
>  {
>  	uint64_t size, dev = 0;
>  	unsigned long count = dev_count;
> -	int number = 0, i, pos;
> +	int volnum, i, pos;
>  	struct bl_volume *node;
>  	char *tmp;
>  	struct bl_dm_table *table = NULL;
> @@ -381,8 +366,8 @@ uint64_t dm_device_create(struct bl_volume *vols, int num_vols)
>  	char *dev_name = NULL;
>  
>  	/* Create pseudo device here */
> -	while (number < num_vols) {
> -		node = &vols[number];
> +	for (volnum = 0; volnum < num_vols; volnum++) {
> +		node = &vols[volnum];
>  		switch (node->bv_type) {
>  		case BLOCK_VOLUME_SIMPLE:
>  			/* Do not need to create device here */
> @@ -492,16 +477,17 @@ uint64_t dm_device_create(struct bl_volume *vols, int num_vols)
>  		node->param.bv_dev = dev;
>  		/* TODO: extend use with PSEUDO later */
>  		node->bv_type = BLOCK_VOLUME_PSEUDO;
> +
>   continued:
> -		number++;
>  		if (bl_table_head)
>  			bl_dm_table_free(bl_table_head);
>  		bl_table_head = NULL;
>  	}
>   out:
> -	if (bl_table_head)
> +	if (bl_table_head) {
>  		bl_dm_table_free(bl_table_head);
> -	bl_table_head = NULL;
> +		bl_table_head = NULL;
> +	}
>  	if (dev)
>  		bl_dm_create_tree(dev);
>  	if (dev_name)
