Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f173.google.com ([209.85.213.173]:42717 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932277AbaFIOiM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jun 2014 10:38:12 -0400
Received: by mail-ig0-f173.google.com with SMTP id r2so1946578igi.0
        for <linux-nfs@vger.kernel.org>; Mon, 09 Jun 2014 07:38:11 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Subject: Re: [PATCH v2 3/6] nfs: merge nfs_pgio_data into _header
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <20140607143406.GC9469@infradead.org>
Date: Mon, 9 Jun 2014 10:38:11 -0400
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <3D24A7F6-E98E-4A87-BD5E-3BA2C6217638@primarydata.com>
References: <1401995791-40213-1-git-send-email-dros@primarydata.com> <1401995791-40213-4-git-send-email-dros@primarydata.com> <20140607143406.GC9469@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun 7, 2014, at 10:34 AM, Christoph Hellwig <hch@infradead.org> wrote:

> On Thu, Jun 05, 2014 at 03:16:28PM -0400, Weston Andros Adamson wrote:
>> struct nfs_pgio_data only exists as a member of nfs_pgio_header, but is
>> passed around everywhere, because there used to be multiple _data structs
>> per _header. Many of these functions then use the _data to find a pointer
>> to the _header.  This patch cleans this up by merging the nfs_pgio_data
>> structure into nfs_pgio_header and passing nfs_pgio_header around instead.
>> 
>> Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
> 
> Looks good,
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> 
> But now that we only have a _header and no _data should we just
> call this struct nfs_pgio?

That sounds reasonable.  I’ll give it a shot when I rename nfs_page.

-dros