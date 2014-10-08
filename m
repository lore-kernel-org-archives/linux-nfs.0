Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e7.ny.us.ibm.com ([32.97.182.137]:47195 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932421AbaJHBdZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Oct 2014 21:33:25 -0400
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
	Tue, 7 Oct 2014 21:33:23 -0400
Received: from b01cxnp23032.gho.pok.ibm.com (b01cxnp23032.gho.pok.ibm.com [9.57.198.27])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 108BD38C803D
	for <linux-nfs@vger.kernel.org>; Tue,  7 Oct 2014 21:33:20 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp23032.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s981XJKF9568674
	for <linux-nfs@vger.kernel.org>; Wed, 8 Oct 2014 01:33:19 GMT
Received: from d01av02.pok.ibm.com (localhost [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s981XJVA028259
	for <linux-nfs@vger.kernel.org>; Tue, 7 Oct 2014 21:33:19 -0400
To: "Trond Myklebust" <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
MIME-Version: 1.0
Subject: decode_device
From: Marc Eshel <eshel@us.ibm.com>
Message-ID: <OF5715E76C.462C3FDF-ON88257D6B.00062E96-88257D6B.00088A0A@us.ibm.com>
Date: Tue, 7 Oct 2014 18:33:17 -0700
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I see that NFS4_PNFS_MAX_STRIPE_CNT is 4096 but when give the client a cnt 
that is bigger than 1024 it fails, is that the limitation of kcalloc() ?

366341.304362] <-- _nfs4_proc_getdeviceinfo status=0
[366341.304364] filelayout_get_device_info getdevice info returns 0
[366341.304368] decode_device stripe count  1512
[366341.304370] decode_device ERROR: returning NULL
[366341.304372] NFS: decode_and_add_device: Could not decode or add device
[366341.304428] <-- filelayout_get_device_info dsaddr           (null)
[366341.304430] --> filelayout_check_layout returns -22
[366341.304433] pnfs_layout_process: Could not allocate layout: error -12

decode_device()

...
        dprintk("%s stripe count  %d\n", __func__, cnt);
        if (cnt > NFS4_PNFS_MAX_STRIPE_CNT) {
                printk(KERN_WARNING "NFS: %s: stripe count %d greater than 
"
                       "supported maximum %d\n", __func__,
                        cnt, NFS4_PNFS_MAX_STRIPE_CNT);
                goto out_err_free_scratch;
        }

        /* read stripe indices */
        stripe_indices = kcalloc(cnt, sizeof(u8), gfp_flags);
        if (!stripe_indices)
                goto out_err_free_scratch;


Thanks, Marc.

