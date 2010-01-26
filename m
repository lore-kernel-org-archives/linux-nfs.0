Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:45008 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752056Ab0AZLV4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jan 2010 06:21:56 -0500
Date: Tue, 26 Jan 2010 06:21:48 -0500
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>,
        Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>,
        Steve Rago <sar@nec-labs.com>, Jens Axboe <jens.axboe@oracle.com>,
        Peter Staubach <staubach@redhat.com>,
        Arjan van de Ven <arjan@infradead.org>, Ingo Molnar <mingo@elte.hu>,
        linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>,
        Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 09/12] NFS: Replace __nfs_write_mapping with
	sync_inode()
Message-ID: <20100126112148.GA25170@infradead.org>
References: <20100125221544.16750.70574.stgit@localhost.localdomain> <20100125221545.16750.63968.stgit@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100125221545.16750.63968.stgit@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Jan 25, 2010 at 05:15:45PM -0500, Trond Myklebust wrote:
>  int nfs_wb_nocommit(struct inode *inode)
>  {
> -	return nfs_write_mapping(inode->i_mapping, FLUSH_NOCOMMIT);
> +	return filemap_write_and_wait(inode->i_mapping);

Any point in keeping this as a wrapper for a single well-documented
caller?  Also taking i_mutex around it seems a bit questionable these
days given that filemap_write_and_wait avoids lifelocks with writing
applications okay and we use it without i_mutex all over the place.

