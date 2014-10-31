Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:52739 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758522AbaJaKgg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 31 Oct 2014 06:36:36 -0400
Date: Fri, 31 Oct 2014 10:36:30 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Christoph Hellwig <hch@infradead.org>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>, Christoph Hellwig <hch@lst.de>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        bfields@fieldses.org, Trond.Myklebust@primarydata.com
Subject: Re: [PATCH] VFS: Rename do_fallocate() to vfs_fallocate()
Message-ID: <20141031103630.GJ7996@ZenIV.linux.org.uk>
References: <1412190907-30307-1-git-send-email-Anna.Schumaker@Netapp.com>
 <20141001210451.GB6680@lst.de>
 <544971CE.9090808@Netapp.com>
 <20141024064800.GA10811@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141024064800.GA10811@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 23, 2014 at 11:48:00PM -0700, Christoph Hellwig wrote:
> On Thu, Oct 23, 2014 at 05:23:26PM -0400, Anna Schumaker wrote:
> > I'm curious what the status of this patch is?
> 
> Looks like nothing :)
> 
> Al, are you ok with Anna just submitting this via the nfsd tree for
> the NFS fallocate support?

Fine by me.
