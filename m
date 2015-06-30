Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38624 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751253AbbF3SSW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Jun 2015 14:18:22 -0400
Message-ID: <5592DD6C.5010705@RedHat.com>
Date: Tue, 30 Jun 2015 14:18:20 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Kinglong Mee <kinglongmee@gmail.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] blkmapd: Fix infinite loop when reading serial
References: <556693B7.6040501@gmail.com>
In-Reply-To: <556693B7.6040501@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/28/2015 12:04 AM, Kinglong Mee wrote:
> If (dev_id->ids & 0xf) < current_id, must updates pos when continue.
> Otherwise an infinite loop.
> 
> No other places use the pos value, just move to the top of while.
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
Sorry for the delay.... Committed! 

steved.
> ---
>  utils/blkmapd/device-inq.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/utils/blkmapd/device-inq.c b/utils/blkmapd/device-inq.c
> index c5bf71f..6b56b67 100644
> --- a/utils/blkmapd/device-inq.c
> +++ b/utils/blkmapd/device-inq.c
> @@ -196,6 +196,8 @@ struct bl_serial *bldev_read_serial(int fd, const char *filename)
>  
>  	while (pos < (len - devid_len)) {
>  		dev_id = (struct bl_dev_id *)&(dev_root->data[pos]);
> +		pos += (dev_id->len + devid_len);
> +
>  		if ((dev_id->ids & 0xf) < current_id)
>  			continue;
>  		switch (dev_id->ids & 0xf) {
> @@ -226,7 +228,6 @@ struct bl_serial *bldev_read_serial(int fd, const char *filename)
>  		}
>  		if (current_id == 3)
>  			break;
> -		pos += (dev_id->len + devid_len);
>  	}
>   out:
>  	if (!serial_out)
> 
