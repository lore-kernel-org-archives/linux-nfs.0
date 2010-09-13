Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:57315 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750821Ab0IMO2z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Sep 2010 10:28:55 -0400
Date: Mon, 13 Sep 2010 10:28:51 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Benny Halevy <bhalevy@panasas.com>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
        Christoph Hellwig <hch@infradead.org>,
        Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 07/13] RFC: pnfs: full mount/umount infrastructure
Message-ID: <20100913142851.GA10170@infradead.org>
References: <1283450419-5648-1-git-send-email-iisaman@netapp.com>
 <1283450419-5648-8-git-send-email-iisaman@netapp.com>
 <20100910235858.GB11231@infradead.org>
 <1284163679.14078.106.camel@heimdal.trondhjem.org>
 <4C8E0A03.3020500@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4C8E0A03.3020500@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Sep 13, 2010 at 01:24:51PM +0200, Benny Halevy wrote:
> However, on the longer run I'd like us to consider formalizing
> the kABI for non-GPLed layout drivers.

No.  Non-GPLed drivers will have a very hard way to stand against the
derived work clauses for some specificly written new code anyway, and
if you haven't noticed yet there's no kABI in mainline anyway.  

> I think that this is a great selling point as it fully materializes the
> extensibility of the layout-type / layout-driver design model.

Drinking again?

