Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:51574 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932768Ab3CUV7l (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Mar 2013 17:59:41 -0400
Message-ID: <514B82C0.2020401@panasas.com>
Date: Thu, 21 Mar 2013 23:59:28 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Peng Tao <bergwolf@gmail.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, <linux-nfs@vger.kernel.org>,
        Benny Halevy <bhalevy@tonian.com>
Subject: Re: [PATCH v2 2/3] NFSv4.1: Always clear the NFS_INO_LAYOUTCOMMIT
 in layoutreturn
References: <1363875181-7147-1-git-send-email-Trond.Myklebust@netapp.com> <1363875181-7147-2-git-send-email-Trond.Myklebust@netapp.com> <20130321170614.GA4581@X61>
In-Reply-To: <20130321170614.GA4581@X61>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/21/2013 07:06 PM, Peng Tao wrote:
> On Thu, Mar 21, 2013 at 10:13:00AM -0400, Trond Myklebust wrote:
> <snip>
>> @@ -1458,7 +1479,6 @@ static void pnfs_ld_handle_write_error(struct nfs_write_data *data)
>>  	dprintk("pnfs write error = %d\n", hdr->pnfs_error);
>>  	if (NFS_SERVER(hdr->inode)->pnfs_curr_ld->flags &
>>  	    PNFS_LAYOUTRET_ON_ERROR) {
>> -		clear_bit(NFS_INO_LAYOUTCOMMIT, &NFS_I(hdr->inode)->flags);
> Hi Trond and Boaz,
> 
> If object layout requires layout being committed before returned (as fixed in
> the 3/3 patch), is it a potential problem to directly return layout here as
> well? e.g., if one lseg is successfully written and pending layoutcommit,
> then another lseg of the same file failed read/write, then layout will be
> returned w/o layoutcommit. For blocklayout, it is a potential data corruption
> and that's why block layout doesn't set PNFS_LAYOUTRET_ON_ERROR bit. So
> I'm wondering if object will suffer from the same issue?
> 

Hi Tao

No, not at all. The objects layout has error reported as part of the
layout_return OPT. With exact devices that failed and why. In fact the
data should not be "committed" per ce, but a recovery process must be
preformed because we know that not all data of a stripe was committed
including parity, and the raid5 check-some is surly wrong. This is why
there is an error bit in layout_commit OPT to denote that this is not
a true commit and that there is an Error report on the way, for those
clients that must always lo_commit before lo_return even on Error.

(I know that 4.2 has plans for error-report RETURNs for other layout
 types as well, this is part of why)

> Thanks,
> Tao
> 

Cheers
Boaz

