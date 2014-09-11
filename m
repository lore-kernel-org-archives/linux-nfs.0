Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:32929 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754899AbaIKULt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Sep 2014 16:11:49 -0400
Date: Thu, 11 Sep 2014 13:11:48 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Peng Tao <tao.peng@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@lst.de>,
        Boaz Harrosh <boaz@plexistor.com>
Subject: Re: [PATCH] nfs41: change PNFS_LAYOUTRET_ON_SETATTR to only return
 on chown/truncate
Message-ID: <20140911201148.GA6623@infradead.org>
References: <1410447752-11288-1-git-send-email-tao.peng@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1410447752-11288-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 11, 2014 at 11:02:32PM +0800, Peng Tao wrote:
> Both blocks layout and objects layout want to use it to avoid CB_LAYOUTRECALL
> but that should only happen if client is doing chown or truncate. So change
> PNFS_LAYOUTRET_ON_SETATTR to follow the logic and not to send layoutreturn
> unnecessarily.

We should defintively reduce the amount of returns, but why do we even
bother and chown and a truncate to a larger size?

