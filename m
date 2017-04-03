Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:54073 "EHLO smtp-o-3.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751194AbdDCOKP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 3 Apr 2017 10:10:15 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
        by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 2E5E3280365
        for <linux-nfs@vger.kernel.org>; Mon,  3 Apr 2017 16:10:14 +0200 (CEST)
Date: Mon, 3 Apr 2017 16:10:11 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Weston Andros Adamson <dros@monkey.org>
Cc: linux-nfs list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Message-ID: <555419275.7370836.1491228611932.JavaMail.zimbra@desy.de>
In-Reply-To: <FB99D377-D3F4-4CA5-9900-7E3CCC1B8EAE@monkey.org>
References: <20170403121026.14142-1-tigran.mkrtchyan@desy.de> <FB99D377-D3F4-4CA5-9900-7E3CCC1B8EAE@monkey.org>
Subject: Re: [PATCH] nfs: flexfilelayout: remove v3-only data server
 limitation
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Dros,

----- Original Message -----
> From: "Weston Andros Adamson" <dros@monkey.org>
> To: "Tigran Mkrtchyan" <tigran.mkrtchyan@desy.de>
> Cc: "linux-nfs list" <linux-nfs@vger.kernel.org>, "Trond Myklebust" <trond.myklebust@primarydata.com>
> Sent: Monday, April 3, 2017 3:54:59 PM
> Subject: Re: [PATCH] nfs: flexfilelayout: remove v3-only data server limitation

> Hey Tigran!
> 
>> On Apr 3, 2017, at 8:10 AM, Tigran Mkrtchyan <tigran.mkrtchyan@desy.de> wrote:
>> 
>> Flexfilelayout supports data servers which talk NFS v3 and v4.{0,1}.
>> However, this code path is disabled and v3 only servers are accepted.
>> This change removes this limitation.
>> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
>> ---
>> fs/nfs/flexfilelayout/flexfilelayoutdev.c | 18 ++++++++++++------
>> 1 file changed, 12 insertions(+), 6 deletions(-)
>> 
>> diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
>> b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
>> index 457cfeb..fac0ef2 100644
>> --- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
>> +++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
>> @@ -119,12 +119,18 @@ nfs4_ff_alloc_deviceid_node(struct nfs_server *server,
>> struct pnfs_device *pdev,
>> 		if (ds_versions[i].wsize > NFS_MAX_FILE_IO_SIZE)
>> 			ds_versions[i].wsize = NFS_MAX_FILE_IO_SIZE;
>> 
>> -		if (ds_versions[i].version != 3 || ds_versions[i].minor_version != 0) {
>> -			dprintk("%s: [%d] unsupported ds version %d-%d\n", __func__,
>> -				i, ds_versions[i].version,
>> -				ds_versions[i].minor_version);
>> -			ret = -EPROTONOSUPPORT;
>> -			goto out_err_drain_dsaddrs;
>> +		/* check for valid major minor combination */
>> +		switch (ds_versions[i].version * 100 + ds_versions[i].minor_version) {
> 
> I'm not sure I love this method of matching

I didn't find a better way without flood of if-statements. Any suggestions?

> 
>> +			case 300: /* v3   */
>> +			case 400: /* v4.0 */
>> +			case 401: /* v4.1 */
>> +				break;
> 
> v4.2?

Right!

Tigran.
> 
> -dros
> 
>> +			default:
>> +				dprintk("%s: [%d] unsupported ds version %d-%d\n", __func__,
>> +					i, ds_versions[i].version,
>> +					ds_versions[i].minor_version);
>> +				ret = -EPROTONOSUPPORT;
>> +				goto out_err_drain_dsaddrs;
>> 		}
>> 
>> 		dprintk("%s: [%d] vers %u minor_ver %u rsize %u wsize %u coupled %d\n",
>> --
>> 2.9.3
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
