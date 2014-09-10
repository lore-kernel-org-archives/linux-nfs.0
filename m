Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:35151 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752241AbaIJW0K (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Sep 2014 18:26:10 -0400
Date: Wed, 10 Sep 2014 15:26:08 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Anna.Schumaker@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/3] nfsd: Add ALLOCATE support
Message-ID: <20140910222608.GA10579@infradead.org>
References: <1410274182-30740-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1410274182-30740-3-git-send-email-Anna.Schumaker@Netapp.com>
 <20140910201812.GG4210@fieldses.org>
 <20140910221150.GA29452@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140910221150.GA29452@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 10, 2014 at 03:11:50PM -0700, Christoph Hellwig wrote:
> On Wed, Sep 10, 2014 at 04:18:12PM -0400, J. Bruce Fields wrote:
> > This checks that the stateid's openmode is write but not that the caller
> > has permission to write.  I think you want an nfsd_permission() check in
> > nfsd4_vfs_allocate.
> > 
> > (Incidentally, the spec doesn't say anything about checking either, I
> > wonder if it should?)
> 
> Yes, it probably should.

Turns out the spec (at least 4.1) doesn't mention anything about
requiring a writeable stateid or permissions for WRITE either as
far as I can tell..
