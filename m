Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:35716 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753890AbaJ1IhW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Oct 2014 04:37:22 -0400
Date: Tue, 28 Oct 2014 01:37:20 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna.Schumaker@netapp.com
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH v2 0/2] NFSD: Add ALLOCATE and DEALLOCATE support
Message-ID: <20141028083720.GB25532@infradead.org>
References: <1414161705-26617-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1414161705-26617-1-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 24, 2014 at 10:41:43AM -0400, Anna.Schumaker@netapp.com wrote:
> From: Anna Schumaker <Anna.Schumaker@Netapp.com>
> 
> These patches add server support for the ALLOCATE and DEALLOCATE operations
> part of NFS v4.2.
> 
> I submitted my do_fallocate() -> vfs_fallocate() change as a separate patch,
> so it has been removed from this submission.  However, this code still depends
> on this patch being applied first.

Please inlude the patch to make everyones life easier.   Al, can you
please ack the patch so that we can move forward with this series?

