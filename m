Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:53304 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757219AbaIIPzT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Sep 2014 11:55:19 -0400
Date: Tue, 9 Sep 2014 08:55:18 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna.Schumaker@netapp.com
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/3] nfsd: Add ALLOCATE support
Message-ID: <20140909155518.GB21928@infradead.org>
References: <1410274182-30740-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1410274182-30740-3-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1410274182-30740-3-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 09, 2014 at 10:49:41AM -0400, Anna.Schumaker@netapp.com wrote:
> From: Anna Schumaker <Anna.Schumaker@Netapp.com>
> 
> The ALLOCATE operation is used to preallocate space in a file.  I use
> vfs_fallocate() to do the actual preallocation.
> 
> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>

Looks largely good, but can you do an audit how the error codes match
the spec?  E.g. We return -ENODEV in do_fallocate if it's called on
a special file, but that doesn't translate to any valid error codes
for ALLOCATE in the NFSv4.2.

I guess it should be NFSERR_NOTSUPP, and I'll work with Tom to actually
define this case in the spec.
