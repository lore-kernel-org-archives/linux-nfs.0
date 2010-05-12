Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:65452 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751113Ab0ELPJl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 May 2010 11:09:41 -0400
Received: by gwj19 with SMTP id 19so58116gwj.19
        for <linux-nfs@vger.kernel.org>; Wed, 12 May 2010 08:09:40 -0700 (PDT)
Date: Wed, 12 May 2010 11:09:40 -0400
Message-ID: <AANLkTimjtqmsCvwW7KIubWfXsSx4X9VzqQnLkjY7_liB@mail.gmail.com>
Subject: [PATCH 0/10] pnfs_submit:: Remove threshold calculations
From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
To: bhalevy@panasas.com
Cc: iisaman@netapp.com, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Oops, forgot the title

On Wed, May 12, 2010 at 10:44 AM,  <andros@netapp.com> wrote:
>
> All layout drivers returned -1 or 0 for both get_read_threshold and
> get_write_threshold policy operations. Remove the threshold policy ops and
> the related helper functions.
>
>
> 0001-SQUASHME-pnfs_submit-remove-filelayout-get-threshold.patch
> 0002-SQUASHME-pnfs_submit-don-t-use-pnfs_use_read.patch
> 0003-SQUASHME-pnfs_submit-don-t-use-pnfs_use_write.patch
> 0004-SQUASHME-pnfs_submit-don-t-use-pnfs_use_write-for-co.patch
> 0005-SQUASHME-pnfs_submit-don-t-use-pg_threshold.patch
> 0006-SQUASHME-pnfs_submit-remove-pg_threshold.patch
> 0007-SQUASHME-pnfs_submit-don-t-use-below_threshold-in-re.patch
> 0008-SQUASHME-pnfs_submit-don-t-use-below_threshold-in-di.patch
> 0009-SQUASHME-pnfs_submit-remove-unused-threshold-calcula.patch
> 0010-SQUASHME-pnfs_submit-cleanup-filelayout-pg_test.patch
>
> Note: these will not be restored.
>
> Testing:
> --------
> CONFIG_NFS4_V1 set:
> v4, v4.1, pNFS mounts Connectathon passes
>
> CONFIG_NFS4_V1 not set:
> v4 mount Connectathon passes
>
> -->Andy
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
