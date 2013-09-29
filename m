Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:60020 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751227Ab3I2MPS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 Sep 2013 08:15:18 -0400
Date: Sun, 29 Sep 2013 05:15:17 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Benny Halevy <bhalevy@primarydata.com>
Cc: " J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 11/49] NFSD: introduce exp_xdr.h
Message-ID: <20130929121517.GC21083@infradead.org>
References: <52447EA0.7070004@primarydata.com>
 <1380220835-13182-1-git-send-email-bhalevy@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1380220835-13182-1-git-send-email-bhalevy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 26, 2013 at 02:40:35PM -0400, Benny Halevy wrote:
> From: Benny Halevy <bhalevy@panasas.com>
> 
> Containing xdr encoding helpers to be used by the layout type library functions
> or by the file system to encode/decode layout-type specific device and layout
> information.

Any reason why pnfs would use this, but not the rest of nfsd?  Maybe
this should go in as part of a separate series cleaning up the xdr
encoding and decoding?

