Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51912 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752640AbbCZP3z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Mar 2015 11:29:55 -0400
Message-ID: <551425EC.5050509@RedHat.com>
Date: Thu, 26 Mar 2015 11:29:48 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Kinglong Mee <kinglongmee@gmail.com>
CC: rees@umich.edu, Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] blkmapd: Make sure device root contains valid device
 id
References: <550EC233.9090908@gmail.com>
In-Reply-To: <550EC233.9090908@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/22/2015 09:22 AM, Kinglong Mee wrote:
> When testing pnfs in virtual linux based on VirtualBox,
> blkmapd gets dev_root->len == 0, which causes it Segmentation fault.
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
Committed...

steved.

> ---
>  utils/blkmapd/device-inq.c | 10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/utils/blkmapd/device-inq.c b/utils/blkmapd/device-inq.c
> index eabc70c..c5bf71f 100644
> --- a/utils/blkmapd/device-inq.c
> +++ b/utils/blkmapd/device-inq.c
> @@ -179,6 +179,7 @@ struct bl_serial *bldev_read_serial(int fd, const char *filename)
>  	char *buffer;
>  	struct bl_dev_id *dev_root, *dev_id;
>  	unsigned int pos, len, current_id = 0;
> +	size_t devid_len = sizeof(struct bl_dev_id) - sizeof(unsigned char);
>  
>  	status = bldev_inquire_pages(fd, 0x83, &buffer);
>  	if (status)
> @@ -189,7 +190,11 @@ struct bl_serial *bldev_read_serial(int fd, const char *filename)
>  	pos = 0;
>  	current_id = 0;
>  	len = dev_root->len;
> -	while (pos < (len - sizeof(struct bl_dev_id) + sizeof(unsigned char))) {
> +
> +	if (len < devid_len)
> +		goto out;
> +
> +	while (pos < (len - devid_len)) {
>  		dev_id = (struct bl_dev_id *)&(dev_root->data[pos]);
>  		if ((dev_id->ids & 0xf) < current_id)
>  			continue;
> @@ -221,8 +226,7 @@ struct bl_serial *bldev_read_serial(int fd, const char *filename)
>  		}
>  		if (current_id == 3)
>  			break;
> -		pos += (dev_id->len + sizeof(struct bl_dev_id) -
> -			sizeof(unsigned char));
> +		pos += (dev_id->len + devid_len);
>  	}
>   out:
>  	if (!serial_out)
> 
