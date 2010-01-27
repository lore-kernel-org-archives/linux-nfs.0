From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: splice read byte accounting
Date: Wed, 27 Jan 2010 18:19:24 -0500
Message-ID: <1264634364.3788.177.camel@localhost>
References: <39A11474-A44E-49FE-8135-54B384254311@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:50219 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755077Ab0A0XT3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Jan 2010 18:19:29 -0500
In-Reply-To: <39A11474-A44E-49FE-8135-54B384254311@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2010-01-27 at 17:22 -0500, Chuck Lever wrote: 
> Hi-
> 
> nfs_file_splice_write() accounts for the bytes in the request in the  
> "normal bytes written" counter, but nfs_file_splice_read() does not  
> account for bytes read.
> 
> Should the read path count these as normal bytes as well, or should  
> the write path not account for these bytes?
> 

nfs_file_splice_read() should probably update NFSIOS_NORMALREADBYTES.

That said, why do nfs_file_read(), nfs_file_write() and
nfs_file_splice_write() update the stats with the requested number of
bytes, irrespective of the number of bytes that were actually
read/write?

Trond

