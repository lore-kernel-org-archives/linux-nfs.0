Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f172.google.com ([209.85.223.172]:40410 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964837AbaESQWD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 May 2014 12:22:03 -0400
Received: by mail-ie0-f172.google.com with SMTP id tp5so2718073ieb.3
        for <linux-nfs@vger.kernel.org>; Mon, 19 May 2014 09:22:01 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Subject: Re: [PATCH 8/8] pnfs: merge identical functions
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <537A2D32.1020701@gmail.com>
Date: Mon, 19 May 2014 12:21:59 -0400
Cc: Christoph Hellwig <hch@infradead.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <6D481103-79C0-41F3-8F1C-B4C4F6022222@primarydata.com>
References: <1400512508-7530-1-git-send-email-dros@primarydata.com> <1400512508-7530-9-git-send-email-dros@primarydata.com> <20140519153402.GB21345@infradead.org> <537A2D32.1020701@gmail.com>
To: Anna Schumaker <schumaker.anna@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 19, 2014, at 12:11 PM, Anna Schumaker <schumaker.anna@gmail.com> wrote:

> On 05/19/2014 11:34 AM, Christoph Hellwig wrote:
>>> -static void pnfs_writehdr_free(struct nfs_pgio_header *hdr)
>>> +static void pnfs_pgio_header_free(struct nfs_pgio_header *hdr)
>>> {
>>> 	pnfs_put_lseg(hdr->lseg);
>>> 	nfs_pgio_header_free(hdr);
>>> }
>> I think it should also be mossible to simply call pnfs_put_lseg
>> from nfs_pgio_header_free.  pnfs_put_lseg handles a NULL argument fine,
>> is stubbed out for the non-pnfs case, and the other callers should never
>> have it set.

Great point.

> 
> Every function in this area is identical to each other :).  I'm already working on a patch series that combines these functions (and more!).  It also needs more testing before I can submit, but I can update against these patches first to see if this unlocks other cleanups.
> 
> Anna

OK, so maybe I’ll just remove this patch from v2 and let you take care of it?

-dros