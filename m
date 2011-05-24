Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:19250 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757190Ab1EXQVv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 May 2011 12:21:51 -0400
Subject: Re: [PATCHSET v6 0/26] pnfs for 2.6.40
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
Date: Tue, 24 May 2011 12:21:46 -0400
In-Reply-To: <4DDBD53A.6030706@panasas.com>
References: <4DDA8C3D.5080706@panasas.com> <4DDAAC64.6050807@panasas.com>
	 <4DDBCBBA.5040700@panasas.com>
	 <2E1EB2CF9ED1CB4AA966F0EB76EAB443080D6E54@SACMVEXC2-PRD.hq.netapp.com>
	 <4DDBD53A.6030706@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1306254106.4162.9.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2011-05-24 at 18:56 +0300, Boaz Harrosh wrote: 
> In the nfs_pageio_descriptor passed to pg_test() together with the two pages:
> Which member means the current byte_size (or page_count?) and what is the
> meaning of some of these fields
> 
> struct nfs_pageio_descriptor {
>         ....
> 	unsigned long		pg_bytes_written;
> 		Is this for result after read/write?

This is the total number of bytes we successfully called
nfs_pageio_doio() for. In other words, it should represent the total
number of bytes we put on the wire.

> 	size_t			pg_count;
> 		Is this the number of pages added up to now?
> 		Do we also have the start of the first page?

This is the number of bytes we have successfully coalesced into the
current i/o.

> 	size_t			pg_bsize;
> 		So I understand this is the max allowed pages. Does
> 		that mean also the allocated size or Just the negotiated
> 		size with the server? (Really bad name if you ask me)

It means the 'block size'. In ordinary NFS parlance that will be the
'rsize' or the 'wsize'.

> 	unsigned int		pg_base;
> 		Is that the index of the first page? That cannot be, the page->index
> 		needs to be 64bit. So what is this then?

It is used when dealing with I/O requests that are not page aligned.

If you consider the pages that we are to write out in the current I/O as
a single buffer, then the pg_base is the offset of the first byte to
write out/read in.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

