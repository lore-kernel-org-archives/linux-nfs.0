Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:52853 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750827AbaIKPVu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Sep 2014 11:21:50 -0400
Date: Thu, 11 Sep 2014 17:21:49 +0200
From: Christoph Hellwig <hch@lst.de>
To: Peng Tao <bergwolf@primarydata.com>
Cc: Christoph Hellwig <hch@lst.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 6/9] pnfs/blocklayout: rewrite extent tracking
Message-ID: <20140911152149.GB6690@lst.de>
References: <1410362617-28018-1-git-send-email-hch@lst.de> <1410362617-28018-7-git-send-email-hch@lst.de> <CAKVebiV==2PwNaHJY57sP4oFjUqAzPCLZgx+k9bRf+oiVSeXVw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAKVebiV==2PwNaHJY57sP4oFjUqAzPCLZgx+k9bRf+oiVSeXVw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 11, 2014 at 10:11:42PM +0800, Peng Tao wrote:
> The old code works in a way that mark_extents_written() always
> succeeds. Now that ext_tree_mark_written() may fail, it should check
> for the return value and resend to MDS if failed, otherwise there may
> be silent data corruption.

It can only fail for memory allocation erorrs, which can indeed happen in
theory although not in practice for the amount we do.  But I'll prepare
testing using error injection and will handle it, thanks!

