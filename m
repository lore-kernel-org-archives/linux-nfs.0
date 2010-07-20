Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:27605 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754727Ab0GTOHL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 10:07:11 -0400
Message-ID: <4C45AD8B.3070802@panasas.com>
Date: Tue, 20 Jul 2010 17:07:07 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/3] SQUASHME: pnfs-submit: filelayout: add nr_pages back
 	to write_pagelist api
References: <4C453A50.7070009@panasas.com>	<1279605456-7349-1-git-send-email-bhalevy@panasas.com> <AANLkTinv670aR9NSYb7O=KdJAhhsRHo3gZTcSrj0MHY_@mail.gmail.com>
In-Reply-To: <AANLkTinv670aR9NSYb7O=KdJAhhsRHo3gZTcSrj0MHY_@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-07-20 16:50, William A. (Andy) Adamson wrote:
> The file layout does not use nr_pages. The calculation is easy. No

True, but we should strive for a coherent interface IMO,
even if it's not the absolute minimal one.

> need to pass the extra parameter. Why not just call
> nfs_page_array_len() in the layout drivers that need it?

It's defined in fs/nfs/internal.h, so to use it officially
it should be moved to a public header file or exported as
a public function.

Benny

> 
> -->Andy
> 
> On Tue, Jul 20, 2010 at 1:57 AM, Benny Halevy <bhalevy@panasas.com> wrote:
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfs/nfs4filelayout.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
>> index 9b6ba8d..b2ce478 100644
>> --- a/fs/nfs/nfs4filelayout.c
>> +++ b/fs/nfs/nfs4filelayout.c
>> @@ -244,7 +244,7 @@ filelayout_read_pagelist(struct nfs_read_data *data, unsigned nr_pages)
>>
>>  /* Perform async writes. */
>>  static enum pnfs_try_status
>> -filelayout_write_pagelist(struct nfs_write_data *data, int sync)
>> +filelayout_write_pagelist(struct nfs_write_data *data, unsigned nr_pages, int sync)
>>  {
>>        struct pnfs_layout_segment *lseg = data->pdata.lseg;
>>        struct nfs4_pnfs_ds *ds;
>> --
>> 1.7.1.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>


-- 
Benny Halevy
Software Architect
Panasas, Inc.
bhalevy@panasas.com
Tel/Fax: +972-3-647-8340
Mobile: +972-54-802-8340

Panasas: The Leader in Parallel Storage
www.panasas.com
