Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f178.google.com ([209.85.213.178]:42422 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751544AbaESQLd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 May 2014 12:11:33 -0400
Received: by mail-ig0-f178.google.com with SMTP id hl10so3719237igb.17
        for <linux-nfs@vger.kernel.org>; Mon, 19 May 2014 09:11:33 -0700 (PDT)
Message-ID: <537A2D32.1020701@gmail.com>
Date: Mon, 19 May 2014 12:11:30 -0400
From: Anna Schumaker <schumaker.anna@gmail.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>,
        Weston Andros Adamson <dros@primarydata.com>
CC: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 8/8] pnfs: merge identical functions
References: <1400512508-7530-1-git-send-email-dros@primarydata.com> <1400512508-7530-9-git-send-email-dros@primarydata.com> <20140519153402.GB21345@infradead.org>
In-Reply-To: <20140519153402.GB21345@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/19/2014 11:34 AM, Christoph Hellwig wrote:
>> -static void pnfs_writehdr_free(struct nfs_pgio_header *hdr)
>> +static void pnfs_pgio_header_free(struct nfs_pgio_header *hdr)
>>  {
>>  	pnfs_put_lseg(hdr->lseg);
>>  	nfs_pgio_header_free(hdr);
>>  }
> I think it should also be mossible to simply call pnfs_put_lseg
> from nfs_pgio_header_free.  pnfs_put_lseg handles a NULL argument fine,
> is stubbed out for the non-pnfs case, and the other callers should never
> have it set.

Every function in this area is identical to each other :).  I'm already working on a patch series that combines these functions (and more!).  It also needs more testing before I can submit, but I can update against these patches first to see if this unlocks other cleanups.

Anna

>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

