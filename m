Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52774 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754587Ab3FKTvl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Jun 2013 15:51:41 -0400
Date: Tue, 11 Jun 2013 15:51:41 -0400
To: Sandeep Joshi <sanjos100@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: why does nfsd write not use splice
Message-ID: <20130611195140.GA29634@fieldses.org>
References: <CAEfL3KnfRWof4-6UAWTwXcH7XWSQuUR5ry_pg4qdyhBB6dt+5g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAEfL3KnfRWof4-6UAWTwXcH7XWSQuUR5ry_pg4qdyhBB6dt+5g@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jun 09, 2013 at 01:05:16PM +0530, Sandeep Joshi wrote:
> Is there a reason as to why the nfsd server does not use splice in the
> write calls - nfsd_vfs_write() ?  Is there some structural limitation
> or is it just something nobody got around to implementing ?
> 
> I have looked at the source back to the 2.6.x kernels and it seems
> only nfsd_vfs_read() has ever used splice/sendfile.
> http://lxr.linux.no/linux+v3.9.5/fs/nfsd/vfs.c

I don't actually know how splice_write works.... I assume to avoid a
copy we'd have to place the incoming write data into pages already
correctly aligned.  That would be an interesting trick.

--b.
