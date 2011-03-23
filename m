Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:26964 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754220Ab1CWVPR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Mar 2011 17:15:17 -0400
Subject: Re: [PATCH 11/12] NFSv4.1: layoutcommit
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
In-Reply-To: <20110323210028.GA31040@infradead.org>
References: <1300886875-5016-1-git-send-email-iisaman@netapp.com>
	 <1300886875-5016-12-git-send-email-iisaman@netapp.com>
	 <20110323210028.GA31040@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 23 Mar 2011 17:15:15 -0400
Message-ID: <1300914915.11677.88.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-03-23 at 17:00 -0400, Christoph Hellwig wrote:
> > @@ -326,6 +326,9 @@ nfs_file_fsync(struct file *file, int datasync)
> >  		ret = xchg(&ctx->error, 0);
> >  	if (!ret && status < 0)
> >  		ret = status;
> > +	if (!ret && !datasync)
> > +		/* application has asked for meta-data sync */
> > +		ret = pnfs_layoutcommit_inode(inode, 1);
> 
> I don't think that is correct.  AFAIK the layoutcommit is needed to
> get back to the data after a crash - basically the only thing a
> !datasync fsync can skip is dirty timestamps.

Hi Christoph,

We had a spec clarification about this recently. The result is that for
'files' layout types:

1) DATA_SYNC writes and unstable writes with COMMIT must store enough
data to disk to allow the server to recover the data if it crashes (i.e.
it provides the equivalent of O_DSYNC and/or fdatasync()). FILE_SYNC
writes must commit all data + metadata (i.e. they do the equivalent of
O_SYNC writes).
2) This means that layoutcommit is only needed when the layout specifies
COMMIT to the data servers, or if the writes to the data servers return
a DATA_SYNC. All it does is commit the time stamps + file size to disk
on the metadata server (and so you avoid the need to do an expensive
recovery process on crash).

IOW: the above should be correct.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

