Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:43490 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751208AbaJAVEz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Oct 2014 17:04:55 -0400
Date: Wed, 1 Oct 2014 23:04:51 +0200
From: Christoph Hellwig <hch@lst.de>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, hch@lst.de, bfields@fieldses.org,
        Trond.Myklebust@primarydata.com
Subject: Re: [PATCH] VFS: Rename do_fallocate() to vfs_fallocate()
Message-ID: <20141001210451.GB6680@lst.de>
References: <1412190907-30307-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1412190907-30307-1-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 01, 2014 at 03:15:07PM -0400, Anna Schumaker wrote:
> From: Anna Schumaker <Anna.Schumaker@netapp.com>
> 
> This function needs to be exported so it can be used by the NFSD module
> when responding to the new ALLOCATE and DEALLOCATE operations in NFS
> v4.2.  Christoph Hellwig suggested renaming the function to stay
> consistent with how other vfs functions are named.
> 
> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>

Acked-by: Christoph Hellwig <hch@lst.de>
