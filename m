Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:56604 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753093AbbDHSQw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Apr 2015 14:16:52 -0400
Date: Wed, 8 Apr 2015 14:16:51 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: xfs@oss.sgi.com, viro@zeniv.linux.org.uk, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] xfs: unlock i_mutex in xfs_break_layouts
Message-ID: <20150408181651.GA3916@fieldses.org>
References: <1428420944-20965-1-git-send-email-hch@lst.de>
 <20150407210747.GD3363@fieldses.org>
 <20150408162104.GC16052@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150408162104.GC16052@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 08, 2015 at 06:21:04PM +0200, Christoph Hellwig wrote:
> On Tue, Apr 07, 2015 at 05:07:47PM -0400, J. Bruce Fields wrote:
> > On Tue, Apr 07, 2015 at 05:35:44PM +0200, Christoph Hellwig wrote:
> > > We want to drop all I/O path locks when recalling layouts, and that includes
> > > i_mutex for the write path.  Without this we get stuck processe when recalls
> > > take too long.
> > 
> > Also if the writer is an nfsd thread than we'd rather just error out
> > than wait.

(To be clear: ACK to this patch as far as I'm concerned, I've got
another concern but we need this fix regardless.)

> We have no way to know we are called by nfsd here unfortunately.

I was imagining the possible deadlock here as mostly theoretical, but
now that I think of it it doesn't sound unlikely at all:

	- file is under heavy write load
	- conflicting operation breaks layout
	- nfsd threads all block in writes to that file
	- no nfsd threads available to service layout return
	- recall times out, client fenced.

Ugh.

--b.
