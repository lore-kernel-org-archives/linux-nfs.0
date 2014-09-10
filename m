Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:33228 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751754AbaIJWLv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Sep 2014 18:11:51 -0400
Date: Wed, 10 Sep 2014 15:11:50 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Anna.Schumaker@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/3] nfsd: Add ALLOCATE support
Message-ID: <20140910221150.GA29452@infradead.org>
References: <1410274182-30740-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1410274182-30740-3-git-send-email-Anna.Schumaker@Netapp.com>
 <20140910201812.GG4210@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140910201812.GG4210@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 10, 2014 at 04:18:12PM -0400, J. Bruce Fields wrote:
> This checks that the stateid's openmode is write but not that the caller
> has permission to write.  I think you want an nfsd_permission() check in
> nfsd4_vfs_allocate.
> 
> (Incidentally, the spec doesn't say anything about checking either, I
> wonder if it should?)

Yes, it probably should.

