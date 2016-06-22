Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:53604 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750880AbcFVQ7H convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jun 2016 12:59:07 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 11/12] NFS: Remove inode->i_dio_count from the NFS
 O_DIRECT code
Date: Wed, 22 Jun 2016 16:58:05 +0000
Message-ID: <07829F3C-FCAA-42C0-8AFA-173370A55BDE@primarydata.com>
References: <1466544893-12058-2-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-3-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-4-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-5-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-6-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-7-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-8-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-9-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-10-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-11-git-send-email-trond.myklebust@primarydata.com>
 <20160622164240.GA9176@infradead.org>
In-Reply-To: <20160622164240.GA9176@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jun 22, 2016, at 12:42, Christoph Hellwig <hch@infradead.org> wrote:
> 
> On Tue, Jun 21, 2016 at 05:34:52PM -0400, Trond Myklebust wrote:
>> Now that we can serialise O_DIRECT and write/truncate using the
>> inode->i_rwsem, we no longer need inode->i_dio_count.
> 
> For the AIO case that's not true, we can't hold i_rwsem until
> aio completes.  So for something that does block allocations we'll
> need something like i_dio_count still.  This probably includes the
> block / scsi layout code.

Why can’t we hold the i_rwsem until aio completes? It is only a read lock, so we’re not blocking the aio engine from adding more requests. As long as notify_change() holds the i_rwsem for write, then we have exclusion.

Cheers
  Trond

