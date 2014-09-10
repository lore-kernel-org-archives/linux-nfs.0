Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:33265 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751754AbaIJWNE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Sep 2014 18:13:04 -0400
Date: Wed, 10 Sep 2014 15:13:03 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Anna.Schumaker@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] nfsd: Add DEALLOCATE support
Message-ID: <20140910221303.GC29452@infradead.org>
References: <1410274182-30740-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1410274182-30740-4-git-send-email-Anna.Schumaker@Netapp.com>
 <20140910201905.GH4210@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140910201905.GH4210@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 10, 2014 at 04:19:05PM -0400, J. Bruce Fields wrote:
> Same comment as in allocate case.

The nfsd_permission check probably should go into nfsd_vfs_fallocate
to avoid duplication.
