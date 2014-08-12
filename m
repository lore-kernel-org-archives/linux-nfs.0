Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:43544 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751613AbaHLMV7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Aug 2014 08:21:59 -0400
Date: Tue, 12 Aug 2014 14:21:56 +0200
From: Christoph Hellwig <hch@lst.de>
To: Boaz Harrosh <openosd@gmail.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/4] pnfs: factor GETDEVICEINFO implementations
Message-ID: <20140812122156.GA16362@lst.de>
References: <1407787617-26050-1-git-send-email-hch@lst.de> <1407787617-26050-2-git-send-email-hch@lst.de> <53E9FC57.9010806@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <53E9FC57.9010806@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[Can you please trim your quotes?  Quoting 700+ lines of a patch for
 a 30 line reply is completely unreasonable, and placing the reply in
 the middle of it is even worse.  I will ignore mails ignoring the
 netiquette this blatantly in the future]

On Tue, Aug 12, 2014 at 02:36:55PM +0300, Boaz Harrosh wrote:
> > +	/*
> > +	 * Use the session max response size as the basis for setting
> > +	 * GETDEVICEINFO's maxcount
> > +	 */
> > +	max_resp_sz = server->nfs_client->cl_session->fc_attrs.max_resp_sz;
> > +	max_pages = nfs_page_array_len(0, max_resp_sz);
> > +	dprintk("%s: server %p max_resp_sz %u max_pages %d\n",
> > +		__func__, server, max_resp_sz, max_pages);
> > +
> 
> This is an extremely too big an allocation for obj-lo (which has
> a couple of embedded strings here). The all RPC can fit a single
> page
> 
> Should we put like a flag in struct pnfs_layoutdriver_type:
> 
> 	if (server->pnfs_curr_ld->flags & PNFS_DEVINFO_SINGLE_PAGE) {
> 		max_pages = 1;
> 		max_resp_sz = PAGE_SIZE;
> 	}
> 
> This gives us so many extra allocation for storing one page pointer but for
> the simplicity of the cleanup we can live with it.

Sounds fine to me, but do you really have that many GETDEVICEINFO calls
in object layout setups that it's worth the effort?

Another slightly cleaner option would be to have a max_deviceinfo_size
field in the layout driver and cap the size by it.

