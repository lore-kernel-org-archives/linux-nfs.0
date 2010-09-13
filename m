Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:37122 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751414Ab0IMOsJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Sep 2010 10:48:09 -0400
Date: Mon, 13 Sep 2010 10:48:08 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 08/13] RFC: pnfs: filelayout: introduce minimal file
 layout driver
Message-ID: <20100913144808.GB31105@infradead.org>
References: <1283450419-5648-1-git-send-email-iisaman@netapp.com>
 <1283450419-5648-9-git-send-email-iisaman@netapp.com>
 <1284147111.10062.74.camel@heimdal.trondhjem.org>
 <AANLkTi=6vcQC1k28B=aKJbN=jRBipoff3+79BpgLxtXw@mail.gmail.com>
 <1284158223.14078.78.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1284158223.14078.78.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Sep 10, 2010 at 06:37:03PM -0400, Trond Myklebust wrote:
>       struct module *owner = THIS_MODULE;
> 
> > }
> 
> ...although the struct module could probably indeed be part of
> pnfs_layoutdriver_type too.

If we only ever have one instances of the ops per type that's absolutely
the way to go.  const ops structures are nice to have, but if means
making the code more complex just for that there's no point.

Take a look at e.g. struct file_system_type.

