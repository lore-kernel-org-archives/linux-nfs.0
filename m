Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:39662
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758872Ab2EOQJB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 May 2012 12:09:01 -0400
Date: Tue, 15 May 2012 12:08:55 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Peng Tao <bergwolf@gmail.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        Peng Tao <tao.peng@emc.com>
Subject: Re: [PATCH 1/2] NFS: call block plug around direct write
Message-ID: <20120515160855.GA5911@infradead.org>
References: <1337096303-2516-1-git-send-email-bergwolf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1337096303-2516-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 15, 2012 at 11:38:22PM +0800, Peng Tao wrote:
> We bypass generic_file_aio_write() but would want to call block plug.

We in this case is the pnfs block driver at most.  Thus these should
be pnfs block code.

