Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:46889 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752160AbbAGO4J (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Jan 2015 09:56:09 -0500
Date: Wed, 7 Jan 2015 06:56:09 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Tom Haynes <thomas.haynes@primarydata.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 03/49] nfs41: pull data server cache from file layout
 to generic pnfs
Message-ID: <20150107145609.GA6019@infradead.org>
References: <1420590534-84063-1-git-send-email-loghyr@primarydata.com>
 <1420590534-84063-4-git-send-email-loghyr@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1420590534-84063-4-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 06, 2015 at 04:28:08PM -0800, Tom Haynes wrote:
> From: Peng Tao <tao.peng@primarydata.com>
> 
> Also pull nfs4_pnfs_ds_addr and nfs4_pnfs_ds to generic pnfs.
> 
> They can all be reused by flexfile layout as well.

Should this really go into pnfs_dev.c?  It's not as generic as
the other code handling the device cache.  Maybe there should be
a pnfs_nfs.c or similar for this code as well as the code moved to
pnfs_nfsio.c earlier?
