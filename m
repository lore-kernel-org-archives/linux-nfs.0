Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:52851 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751665AbaIKPVC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Sep 2014 11:21:02 -0400
Date: Thu, 11 Sep 2014 17:20:58 +0200
From: Christoph Hellwig <hch@lst.de>
To: Peng Tao <bergwolf@primarydata.com>
Cc: Christoph Hellwig <hch@lst.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/9] pnfs: add return_range method
Message-ID: <20140911152058.GA6690@lst.de>
References: <1410362617-28018-1-git-send-email-hch@lst.de> <1410362617-28018-4-git-send-email-hch@lst.de> <CAKVebiVvenTsjwBTB1=-HO1w5=7WEKEpj6hQkQP9XQJcuWMgag@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAKVebiVvenTsjwBTB1=-HO1w5=7WEKEpj6hQkQP9XQJcuWMgag@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 11, 2014 at 09:54:42PM +0800, Peng Tao wrote:
> It looks better to put return_range inside
> pnfs_mark_matching_lsegs_invalid() to have it called every time a
> range of layout segments all get freed. So that ld is sure to free
> things up.

Actually we specificly want to avoid that for cases like the internal
new stateid handling in pnfs_layout_process, where we might allocate
a new layout that overlaps an existing one, and where we need to keep
the extents around.

