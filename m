From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: splice read byte accounting
Date: Thu, 28 Jan 2010 10:15:34 -0500
Message-ID: <1264691734.7553.1.camel@localhost>
References: <39A11474-A44E-49FE-8135-54B384254311@oracle.com>
	 <1264634364.3788.177.camel@localhost>
	 <EAD3EA8D-52B9-43D4-8A35-B623270AF688@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:58437 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751828Ab0A1PPi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Jan 2010 10:15:38 -0500
In-Reply-To: <EAD3EA8D-52B9-43D4-8A35-B623270AF688@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2010-01-28 at 10:07 -0500, Chuck Lever wrote: 
> On Jan 27, 2010, at 6:19 PM, Trond Myklebust wrote:
> > On Wed, 2010-01-27 at 17:22 -0500, Chuck Lever wrote:
> >> Hi-
> >>
> >> nfs_file_splice_write() accounts for the bytes in the request in the
> >> "normal bytes written" counter, but nfs_file_splice_read() does not
> >> account for bytes read.
> >>
> >> Should the read path count these as normal bytes as well, or should
> >> the write path not account for these bytes?
> >>
> >
> > nfs_file_splice_read() should probably update NFSIOS_NORMALREADBYTES.
> >
> > That said, why do nfs_file_read(), nfs_file_write() and
> > nfs_file_splice_write() update the stats with the requested number of
> > bytes, irrespective of the number of bytes that were actually
> > read/write?
> 
> We're counting the number of bytes requested by applications.  I'm not  
> sure which is more useful here; number of bytes requested, or number  
> of bytes actually read/written.  For computing ratios of app bytes v.  
> otw bytes, I suppose the latter?
> 

Yes. Most apps will just be inputting the buffer size as the 'number of
bytes requested', which is not really a particularly useful number.


