Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:46328 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757977Ab0BCX6f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Feb 2010 18:58:35 -0500
Subject: Re: [RFC PATCH 0/4] wsync export option
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Ben Myers <bpm@sgi.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20100203233755.17677.96582.stgit@case>
References: <20100203233755.17677.96582.stgit@case>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 03 Feb 2010 18:58:31 -0500
Message-ID: <1265241511.2632.12.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-02-03 at 17:44 -0600, Ben Myers wrote: 
> In April I did some research on why synchronous NFSv3 performance on XFS is so
> rotten when compared to local filesystem performance.  The workload I chose to
> work with is tar.
> 
> After taking some measurements I came to the conclusion that one of the big
> problems is that we're not treating the log as stable storage.  By calling
> write_inode_now() we've written the changes to the log first and then gone and
> also written them out to the inode on disk.
> 
> In a short discussion of this issue on the xfs-oss list it was suggested that I
> post the patches here for discussion.
> 
> The following series is adds a 'wsync' export option to nfsd.  It is intended
> to be used on XFS with the wsync mount option.  When you already have a
> synchronous log there is no need to sync metadata separately.

Why should the administrator have to both change /etc/fstab
and /etc/exports? That will be an immediate source of trouble if someone
changes one without changing the other.

Why not rather add an optional operation to the export_ops to let the
filesystem specify exactly what kind of synchronisation policy is
optimal for it?

Trond

