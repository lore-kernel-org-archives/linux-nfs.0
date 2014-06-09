Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f179.google.com ([209.85.213.179]:59242 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754702AbaFIOlB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jun 2014 10:41:01 -0400
Received: by mail-ig0-f179.google.com with SMTP id r2so1961689igi.0
        for <linux-nfs@vger.kernel.org>; Mon, 09 Jun 2014 07:41:00 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Subject: Re: [PATCH v2 5/6] nfs: remove pgio_header refcount, related cleanup
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <20140607143901.GE9469@infradead.org>
Date: Mon, 9 Jun 2014 10:40:59 -0400
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <D0C47686-740E-4DEB-9C37-AA0446AC7A4E@primarydata.com>
References: <1401995791-40213-1-git-send-email-dros@primarydata.com> <1401995791-40213-6-git-send-email-dros@primarydata.com> <20140607143901.GE9469@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun 7, 2014, at 10:39 AM, Christoph Hellwig <hch@infradead.org> wrote:

> On Thu, Jun 05, 2014 at 03:16:30PM -0400, Weston Andros Adamson wrote:
>> The refcounting on nfs_pgio_header was related to there being (possibly)
>> more than one nfs_pgio_data. Now that nfs_pgio_data has been merged into
>> nfs_pgio_header, there is no reason to do this ref counting.  Just call
>> the completion callback on nfs_pgio_release/nfs_pgio_error.
> 
> 
> I think nfs_generic_pgio_reset isn't an all that descriptive name, why
> not keep nfs_pgio_data_destroy?

That sounds reasonable - I renamed because struct nfs_pgio_data is gone, but
the name still makes sense.

-dros
