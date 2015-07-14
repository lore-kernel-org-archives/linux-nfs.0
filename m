Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46570 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751644AbbGNOya (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Jul 2015 10:54:30 -0400
Message-ID: <55A522A5.40501@RedHat.com>
Date: Tue, 14 Jul 2015 10:54:29 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Kinglong Mee <kinglongmee@gmail.com>
CC: Christoph Hellwig <hch@infradead.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v4] blkmapd: Skip the SCSI ID if data length is zero
References: <55A2FEE4.6030201@gmail.com> <20150713064216.GA31842@infradead.org> <55A375A1.4000800@gmail.com> <20150713090142.GA28557@infradead.org> <55A380A5.20009@gmail.com> <55A38C1C.3030600@gmail.com> <20150714071537.GB31117@infradead.org> <55A51887.1050605@gmail.com>
In-Reply-To: <55A51887.1050605@gmail.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On 07/14/2015 10:11 AM, Kinglong Mee wrote:
> In vmware linux, the iscsi device contains more than one SCSI ID,
> and the second one's data length is zero.
> 
> If there are two iSCSI devices with the second SCSI ID's data length
> is zero, the first iSCSI device will record with an invalid SCSI ID
> as zero length, the second one will be treat as the first one for
> the SCSI ID is zero length too.
> 
> It means the only the first iSCSI device is exist in blkmapd's cache,
> the request for the second iSCSI device will failed as,
> 
> "blkmapd: Could not find disk for device" and,
> "bl_resolve_deviceid failed to decode device: 2".
> 
> v2, update comments
> v3, add a comment in the code
> v4, update comment as Christoph's suggestion
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  utils/blkmapd/device-inq.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/utils/blkmapd/device-inq.c b/utils/blkmapd/device-inq.c
> index 6b56b67..5c258bd 100644
> --- a/utils/blkmapd/device-inq.c
> +++ b/utils/blkmapd/device-inq.c
> @@ -198,6 +198,13 @@ struct bl_serial *bldev_read_serial(int fd, const char *filename)
>  		dev_id = (struct bl_dev_id *)&(dev_root->data[pos]);
>  		pos += (dev_id->len + devid_len);
>  
> +		/* Some buggy targets (e.g. VMWare) export zero length
> +		 * EVPD pages, skip them to not confuse the device id
> +		 * cache.
> +		 */
I'll take care of this comment... No need to re-post. 

steved.

> +		if (!dev_id->len)
> +			continue;
> +
>  		if ((dev_id->ids & 0xf) < current_id)
>  			continue;
>  		switch (dev_id->ids & 0xf) {
> 
