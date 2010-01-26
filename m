Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:30907 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753760Ab0AZODM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jan 2010 09:03:12 -0500
Subject: Re: [PATCH 09/12] NFS: Replace __nfs_write_mapping with
 sync_inode()
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>,
        Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>,
        Steve Rago <sar@nec-labs.com>, Jens Axboe <jens.axboe@oracle.com>,
        Peter Staubach <staubach@redhat.com>,
        Arjan van de Ven <arjan@infradead.org>, Ingo Molnar <mingo@elte.hu>,
        linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>,
        Al Viro <viro@ZenIV.linux.org.uk>
In-Reply-To: <20100126112148.GA25170@infradead.org>
References: <20100125221544.16750.70574.stgit@localhost.localdomain>
	 <20100125221545.16750.63968.stgit@localhost.localdomain>
	 <20100126112148.GA25170@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 26 Jan 2010 09:02:52 -0500
Message-ID: <1264514573.3615.90.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-01-26 at 06:21 -0500, Christoph Hellwig wrote: 
> On Mon, Jan 25, 2010 at 05:15:45PM -0500, Trond Myklebust wrote:
> >  int nfs_wb_nocommit(struct inode *inode)
> >  {
> > -	return nfs_write_mapping(inode->i_mapping, FLUSH_NOCOMMIT);
> > +	return filemap_write_and_wait(inode->i_mapping);
> 
> Any point in keeping this as a wrapper for a single well-documented
> caller?  Also taking i_mutex around it seems a bit questionable these
> days given that filemap_write_and_wait avoids lifelocks with writing
> applications okay and we use it without i_mutex all over the place.
> 

Agreed, but just out of curiosity. Is there any reason why we shouldn't
use filemap_flush() + filemap_fdatawait() here instead? We're not really
interested in doing a full data integrity flush, but just want to make
sure that pages which were dirtied before the stat() syscall are flushed
to disk so that the server updates the c/mtime for us.

Cheers
  Trond
