Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f45.google.com ([209.85.214.45]:37088 "EHLO
	mail-bw0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750909Ab0LUPml convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Dec 2010 10:42:41 -0500
Received: by bwz16 with SMTP id 16so4689822bwz.4
        for <linux-nfs@vger.kernel.org>; Tue, 21 Dec 2010 07:42:40 -0800 (PST)
In-Reply-To: <20101221152104.GB30248@infradead.org>
References: <1292898046-7336-1-git-send-email-iisaman@netapp.com>
	<1292898046-7336-4-git-send-email-iisaman@netapp.com>
	<20101221152104.GB30248@infradead.org>
Date: Tue, 21 Dec 2010 10:42:40 -0500
Message-ID: <AANLkTinztYQU5XJ9ybzybbBirGbmJPt7McJK51YacBPp@mail.gmail.com>
Subject: Re: [PATCH 03/14] pnfs: wave 2: rename lo->state to lo->plh_flags
From: Fred Isaman <iisaman@netapp.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Dec 21, 2010 at 10:21 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Mon, Dec 20, 2010 at 09:20:35PM -0500, Fred Isaman wrote:
>> Preparing for change in stateid code, and want to avoid name confusion.
>
> None of the other fields in struct pnfs_layout_hdr has a prefix.  Either
> do it for all of them or none, but this version is rather inconsistant.
>

I was trying to minimize change, but I would be happy to change them all.
Any complaints about this from any of the other pnfs developers?

Fred

> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
