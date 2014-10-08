Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f170.google.com ([209.85.220.170]:41924 "EHLO
	mail-vc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932137AbaJHMq1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Oct 2014 08:46:27 -0400
Received: by mail-vc0-f170.google.com with SMTP id hy10so6684428vcb.1
        for <linux-nfs@vger.kernel.org>; Wed, 08 Oct 2014 05:46:27 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: decode_device
From: Tom Haynes <thomas.haynes@primarydata.com>
In-Reply-To: <OF5715E76C.462C3FDF-ON88257D6B.00062E96-88257D6B.00088A0A@us.ibm.com>
Date: Wed, 8 Oct 2014 08:46:24 -0400
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Message-Id: <610954AB-462F-4755-A777-3F89E3CAD5E6@primarydata.com>
References: <OF5715E76C.462C3FDF-ON88257D6B.00062E96-88257D6B.00088A0A@us.ibm.com>
To: Marc Eshel <eshel@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 7, 2014, at 9:33 PM, Marc Eshel <eshel@us.ibm.com> wrote:

> I see that NFS4_PNFS_MAX_STRIPE_CNT is 4096 but when give the client a cnt 
> that is bigger than 1024 it fails, is that the limitation of kcalloc() ?
> 
> 366341.304362] <-- _nfs4_proc_getdeviceinfo status=0
> [366341.304364] filelayout_get_device_info getdevice info returns 0
> [366341.304368] decode_device stripe count  1512
> [366341.304370] decode_device ERROR: returning NULL
> [366341.304372] NFS: decode_and_add_device: Could not decode or add device
> [366341.304428] <-- filelayout_get_device_info dsaddr           (null)
> [366341.304430] --> filelayout_check_layout returns -22
> [366341.304433] pnfs_layout_process: Could not allocate layout: error -12
> 
> decode_device()
> 
> ...
>        dprintk("%s stripe count  %d\n", __func__, cnt);
>        if (cnt > NFS4_PNFS_MAX_STRIPE_CNT) {
>                printk(KERN_WARNING "NFS: %s: stripe count %d greater than 
> "
>                       "supported maximum %d\n", __func__,
>                        cnt, NFS4_PNFS_MAX_STRIPE_CNT);
>                goto out_err_free_scratch;
>        }
> 
>        /* read stripe indices */
>        stripe_indices = kcalloc(cnt, sizeof(u8), gfp_flags);
>        if (!stripe_indices)
>                goto out_err_free_scratch;
> 
> 
> Thanks, Marc.



Hi Marc,

You are asking for 1512 bytes of memory. That would be looking for a 2k slab.

What flags are being passed down in gfp_flags?

Are you experiencing any other memory issues?

Tom
