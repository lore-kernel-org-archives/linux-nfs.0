Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:39193 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751909AbaIFX2f (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 6 Sep 2014 19:28:35 -0400
Date: Sat, 6 Sep 2014 16:28:35 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: update time staps on truncate
Message-ID: <20140906232835.GA6249@infradead.org>
References: <1408633667-24177-1-git-send-email-hch@lst.de>
 <CAHQdGtTniQYMUpOnKnG8H8W5WJsAysZA-FYCy1SHGOpFUebJBg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtTniQYMUpOnKnG8H8W5WJsAysZA-FYCy1SHGOpFUebJBg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 21, 2014 at 11:31:24AM -0400, Trond Myklebust wrote:
> We shouldn't need to set attr->ia_ctime/ia_mtime above. We should set
> the file time to the server clock time.

True.

> Also note that instead of checking attr->ia_size !=
> i_size_read(inode), the above should check attr->ia_valid & ATTR_SIZE
> due to the optimisation above.

Or we could just make it an if/else clause.  I'll send out an updated
patch ASAP.
