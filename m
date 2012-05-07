Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:58088
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932131Ab2EGRTy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 May 2012 13:19:54 -0400
Date: Mon, 7 May 2012 13:19:51 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: Ensure that setattr and getattr wait for O_DIRECT
 write completion
Message-ID: <20120507171951.GA19045@infradead.org>
References: <1336402112-9227-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1336402112-9227-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 07, 2012 at 10:48:32AM -0400, Trond Myklebust wrote:
> Use the same mechanism as the block devices are using, but define
> our own copy of those functions if !CONFIG_BLOCK.

Yikes.  Just move that code to inode.c so that it's always available
and be done with it.

