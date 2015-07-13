Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:50182 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751337AbbGMHlj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 03:41:39 -0400
Date: Mon, 13 Jul 2015 00:41:39 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Peng Tao <tao.peng@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, Zach Brown <zab@zabbo.net>,
        "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 0/7] nfs: minor cleanups and NFSv42 CLONE support
Message-ID: <20150713074139.GB23338@infradead.org>
References: <1436766655-10696-1-git-send-email-tao.peng@primarydata.com>
 <20150713065851.GD26245@infradead.org>
 <CAKVebiXYYzL=yhMBUjxKk=7p+Aunm1UFPRCzXsqYi5R7Fj7=gg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAKVebiXYYzL=yhMBUjxKk=7p+Aunm1UFPRCzXsqYi5R7Fj7=gg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 13, 2015 at 03:36:22PM +0800, Peng Tao wrote:
> So the main change is .copy_file_range syscall. Was it rejected before
> or can we just push it forward as it is?

It wasn't rejected, but we kept bikeshedding over the semantics insted
of moving it forward.

> If there are objections against a new syscall, we can drop it and move
> on with vfs helper and the new copy_file_range file operation, in
> order to just make nfsd clone work.

I think everyone wants the syscall, but people don't agree on the
semantics.  For now maybe we should just add the method and move the
btrfs/xfs ioctl to common code.
