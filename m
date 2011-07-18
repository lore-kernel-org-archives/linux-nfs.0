Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:49441 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753216Ab1GRJNW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Jul 2011 05:13:22 -0400
Received: by wwe5 with SMTP id 5so2976506wwe.1
        for <linux-nfs@vger.kernel.org>; Mon, 18 Jul 2011 02:13:21 -0700 (PDT)
Message-ID: <4E23F92D.1010705@tonian.com>
Date: Mon, 18 Jul 2011 12:13:17 +0300
From: Benny Halevy <bhalevy@tonian.com>
To: Jim Rees <rees@umich.edu>
CC: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] blkmapd: use new sunrpc pipefs interface
References: <1310947592-12653-1-git-send-email-rees@umich.edu>
In-Reply-To: <1310947592-12653-1-git-send-email-rees@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I submitted both patches to
git://linux-nfs.org/~bhalevy/pnfs-nfs-utils.git

tag pnfs-nfs-utils-1-2-4-2011-07-18

Benny

On 2011-07-18 03:06, Jim Rees wrote:
> From: Peng Tao <bergwolf@gmail.com>
> 
> Signed-off-by: Peng Tao <peng_tao@emc.com>
> ---
>  utils/blkmapd/device-discovery.c |   48 +++++++++++--------------------------
>  utils/blkmapd/device-discovery.h |   12 +++++----
>  2 files changed, 21 insertions(+), 39 deletions(-)
> 
> diff --git a/utils/blkmapd/device-discovery.c b/utils/blkmapd/device-discovery.c
> index b4cb8a4..c21de3e 100644
> --- a/utils/blkmapd/device-discovery.c
> +++ b/utils/blkmapd/device-discovery.c
> @@ -50,7 +50,7 @@
>  
>  #include "device-discovery.h"
>  
> -#define BL_PIPE_FILE	"/var/lib/nfs/rpc_pipefs/bl_device_pipe"
> +#define BL_PIPE_FILE	"/var/lib/nfs/rpc_pipefs/nfs/blocklayout"
>  #define PID_FILE	"/var/run/blkmapd.pid"
>  
>  struct bl_disk *visible_disk_list;
> @@ -265,20 +265,14 @@ int bl_discover_devices(void)
>  int bl_disk_inquiry_process(int fd)
>  {
>  	int ret = 0;
> -	struct pipefs_hdr *head = NULL, *tmp;
> +	struct bl_pipemsg_hdr head;
>  	char *buf = NULL;
>  	uint32_t major, minor;
>  	uint16_t buflen;
> -	unsigned int len = 0;
> -
> -	head = calloc(1, sizeof(struct pipefs_hdr));
> -	if (!head) {
> -		BL_LOG_ERR("%s: Out of memory!\n", __func__);
> -		return -ENOMEM;
> -	}
> +	struct bl_dev_msg reply;
>  
>  	/* read request */
> -	if (atomicio(read, fd, head, sizeof(*head)) != sizeof(*head)) {
> +	if (atomicio(read, fd, &head, sizeof(head)) != sizeof(head)) {
>  		/* Note that an error in this or the next read is pretty
>  		 * catastrophic, as there is no good way to resync into
>  		 * the pipe's stream.
> @@ -288,7 +282,7 @@ int bl_disk_inquiry_process(int fd)
>  		goto out;
>  	}
>  
> -	buflen = head->totallen - sizeof(*head);
> +	buflen = head.totallen;
>  	buf = malloc(buflen);
>  	if (!buf) {
>  		BL_LOG_ERR("%s: Out of memory!\n", __func__);
> @@ -302,9 +296,9 @@ int bl_disk_inquiry_process(int fd)
>  		goto out;
>  	}
>  
> -	head->status = BL_DEVICE_REQUEST_PROC;
> +	reply.status = BL_DEVICE_REQUEST_PROC;
>  
> -	switch (head->type) {
> +	switch (head.type) {
>  	case BL_DEVICE_MOUNT:
>  		/*
>  		 * It shouldn't be necessary to discover devices here, since
> @@ -316,36 +310,24 @@ int bl_disk_inquiry_process(int fd)
>  		 */
>  		bl_discover_devices();
>  		if (!process_deviceinfo(buf, buflen, &major, &minor)) {
> -			head->status = BL_DEVICE_REQUEST_ERR;
> +			reply.status = BL_DEVICE_REQUEST_ERR;
>  			break;
>  		}
> -		tmp = realloc(head, sizeof(major) + sizeof(minor) +
> -			      sizeof(struct pipefs_hdr));
> -		if (!tmp) {
> -			BL_LOG_ERR("%s: Out of memory!\n", __func__);
> -			ret = -ENOMEM;
> -			goto out;
> -		}
> -		head = tmp;
> -		memcpy((void *)head + sizeof(struct pipefs_hdr),
> -		       &major, sizeof(major));
> -		memcpy((void *)head + sizeof(struct pipefs_hdr) + sizeof(major),
> -		       &minor, sizeof(minor));
> -		len = sizeof(major) + sizeof(minor);
> +		reply.major = major;
> +		reply.minor = minor;
>  		break;
>  	case BL_DEVICE_UMOUNT:
>  		if (!dm_device_remove_all((uint64_t *) buf))
> -			head->status = BL_DEVICE_REQUEST_ERR;
> +			reply.status = BL_DEVICE_REQUEST_ERR;
>  		break;
>  	default:
> -		head->status = BL_DEVICE_REQUEST_ERR;
> +		reply.status = BL_DEVICE_REQUEST_ERR;
>  		break;
>  	}
>  
> -	head->totallen = sizeof(struct pipefs_hdr) + len;
>  	/* write to pipefs */
> -	if (atomicio((void *)write, fd, head, head->totallen)
> -	    != head->totallen) {
> +	if (atomicio((void *)write, fd, &reply, sizeof(reply))
> +	    != sizeof(reply)) {
>  		BL_LOG_ERR("Write pipefs error!\n");
>  		ret = -EIO;
>  	}
> @@ -353,8 +335,6 @@ int bl_disk_inquiry_process(int fd)
>   out:
>  	if (buf)
>  		free(buf);
> -	if (head)
> -		free(head);
>  	return ret;
>  }
>  
> diff --git a/utils/blkmapd/device-discovery.h b/utils/blkmapd/device-discovery.h
> index e25dd44..a86eed9 100644
> --- a/utils/blkmapd/device-discovery.h
> +++ b/utils/blkmapd/device-discovery.h
> @@ -102,12 +102,14 @@ struct bl_dev_id {
>  	char data[0];
>  };
>  
> -struct pipefs_hdr {
> -	uint32_t msgid;
> +struct bl_dev_msg {
> +	int status;
> +	uint32_t major, minor;
> +};
> +
> +struct bl_pipemsg_hdr {
>  	uint8_t type;
> -	uint8_t flags;
> -	uint16_t totallen;		/* length of message including hdr */
> -	uint32_t status;
> +	uint16_t totallen;		/* length of message excluding hdr */
>  };
>  
>  #define BL_DEVICE_UMOUNT                0x0	/* Umount--delete devices */
