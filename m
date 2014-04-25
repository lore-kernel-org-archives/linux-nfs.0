Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:49674 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751333AbaDYMMF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Apr 2014 08:12:05 -0400
Date: Fri, 25 Apr 2014 05:12:00 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <schumaker.anna@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Trond.Myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 07/17] NFS: Create a common rw_header_alloc and
 rw_header_free function
Message-ID: <20140425121200.GA22948@infradead.org>
References: <1397768981-12856-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1397768981-12856-8-git-send-email-Anna.Schumaker@Netapp.com>
 <20140421133252.GA30954@infradead.org>
 <535522B2.9030401@gmail.com>
 <53554637.1080006@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <53554637.1080006@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 21, 2014 at 12:24:23PM -0400, Anna Schumaker wrote:
> > Okay.  I'll rework everything into the pageio_ops and see how it looks!  Maybe I'll see what I can do about updating the pnfs patches while I'm at it.
> I remember my issue with adding to the nfs_pageio_ops now.  The file, object and block layouts along with the generic pnfs code all have their own read and write pageio_ops.  Changing all of these seemed more tedious than adding a new struct  only in the read and write code.

Indeed, there's more instances in the pnfs code.  I was hoping your
pending pnfs patches were addressing that, and the general code
duplication between the pnfs and "classic" I/O code.

I guess it's best to put in your patches as-is for now, and maybe in the
future we can get rid of the pageio_ops once more code is shared with
the pnfs path.
