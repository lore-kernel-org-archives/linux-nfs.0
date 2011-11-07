Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:58271 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751060Ab1KGPNC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Nov 2011 10:13:02 -0500
Message-ID: <1320678780.6667.3.camel@lade.trondhjem.org>
Subject: Re: write_inode_now in nfs_unlink
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Date: Mon, 07 Nov 2011 10:13:00 -0500
In-Reply-To: <20111107110248.GA11688@infradead.org>
References: <20111107110248.GA11688@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2011-11-07 at 06:02 -0500, Christoph Hellwig wrote: 
> Does anyone have an explanation why nfs calls write_inode_now before
> doing a sillrename?  The comment above claims that we want to start
> an asynchronous writeout, but given that NFS doesn't have dirty
> inode metadata that needs to be written back from ->write_inode
> this only starts data writeback.  And that should be done using
> filemap_fdatawrite or filemap_flush.

filemap_fdatawrite() is never sufficient for writing out data, since it
does nothing to ensure that the COMMIT gets sent: we have do that
through the ->write_inode() callback.
With pNFS there can also be the issue of sending the layoutcommit...

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

