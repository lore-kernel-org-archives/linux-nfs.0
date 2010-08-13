Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:37836 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761352Ab0HMIjm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Aug 2010 04:39:42 -0400
Date: Fri, 13 Aug 2010 04:39:39 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] NFS: Fix up the fsync code
Message-ID: <20100813083939.GA29132@infradead.org>
References: <20100712220932.20019.21170.stgit@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100712220932.20019.21170.stgit@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Jul 12, 2010 at 06:09:32PM -0400, Trond Myklebust wrote:
> Christoph points out that the VFS will always flush out data before calling
> nfs_fsync(), so we can dispense with a full call to nfs_wb_all(), and
> replace that with a simpler call to nfs_commit_inode().

Btw, shouldn't nfs_file_write and nfs_file_splice_write use
vfs_fsync_range to just sync the range previously written?
