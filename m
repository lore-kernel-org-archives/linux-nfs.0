Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f181.google.com ([209.85.213.181]:42381 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752965AbaESRLU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 May 2014 13:11:20 -0400
Received: by mail-ig0-f181.google.com with SMTP id h3so3815339igd.2
        for <linux-nfs@vger.kernel.org>; Mon, 19 May 2014 10:11:19 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Subject: Re: [PATCH 8/8] pnfs: merge identical functions
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <20140519165732.GB663@infradead.org>
Date: Mon, 19 May 2014 13:11:14 -0400
Cc: Christoph Hellwig <hch@infradead.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <B6564628-6BE0-4430-B8BE-06D8E7D1CF95@primarydata.com>
References: <1400512508-7530-1-git-send-email-dros@primarydata.com> <1400512508-7530-9-git-send-email-dros@primarydata.com> <20140519153402.GB21345@infradead.org> <537A2D32.1020701@gmail.com> <20140519165732.GB663@infradead.org>
To: Anna Schumaker <schumaker.anna@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 19, 2014, at 12:57 PM, Christoph Hellwig <hch@infradead.org> wrote:

> On Mon, May 19, 2014 at 12:11:30PM -0400, Anna Schumaker wrote:
>>> I think it should also be mossible to simply call pnfs_put_lseg
>>> from nfs_pgio_header_free.  pnfs_put_lseg handles a NULL argument fine,
>>> is stubbed out for the non-pnfs case, and the other callers should never
>>> have it set.
>> 
>> Every function in this area is identical to each other :).  I'm already working on a patch series that combines these functions (and more!).  It also needs more testing before I can submit, but I can update against these patches first to see if this unlocks other cleanups.
> 
> Yes, pnfs.c has lots of duplication of the classic I/O path.  I don't
> think we need to rush out your patches, but it would be good to get them
> out in the not too far future.
> 

I say we add them to the pgio branch (or some other public branch) as soon as
you’re ready, so we can combine testing efforts.

-dros

