Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:54956 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753498AbaJXGsH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Oct 2014 02:48:07 -0400
Date: Thu, 23 Oct 2014 23:48:00 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Christoph Hellwig <hch@lst.de>, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        bfields@fieldses.org, Trond.Myklebust@primarydata.com
Subject: Re: [PATCH] VFS: Rename do_fallocate() to vfs_fallocate()
Message-ID: <20141024064800.GA10811@infradead.org>
References: <1412190907-30307-1-git-send-email-Anna.Schumaker@Netapp.com>
 <20141001210451.GB6680@lst.de>
 <544971CE.9090808@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <544971CE.9090808@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 23, 2014 at 05:23:26PM -0400, Anna Schumaker wrote:
> I'm curious what the status of this patch is?

Looks like nothing :)

Al, are you ok with Anna just submitting this via the nfsd tree for
the NFS fallocate support?

