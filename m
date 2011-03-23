Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:45843 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751326Ab1CWVV6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Mar 2011 17:21:58 -0400
Date: Wed, 23 Mar 2011 17:21:57 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Christoph Hellwig <hch@infradead.org>, Fred Isaman <iisaman@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 11/12] NFSv4.1: layoutcommit
Message-ID: <20110323212157.GA14281@infradead.org>
References: <1300886875-5016-1-git-send-email-iisaman@netapp.com>
 <1300886875-5016-12-git-send-email-iisaman@netapp.com>
 <20110323210028.GA31040@infradead.org>
 <1300914915.11677.88.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1300914915.11677.88.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Mar 23, 2011 at 05:15:15PM -0400, Trond Myklebust wrote:
> We had a spec clarification about this recently. The result is that for
> 'files' layout types:
> 
> 1) DATA_SYNC writes and unstable writes with COMMIT must store enough
> data to disk to allow the server to recover the data if it crashes (i.e.
> it provides the equivalent of O_DSYNC and/or fdatasync()). FILE_SYNC
> writes must commit all data + metadata (i.e. they do the equivalent of
> O_SYNC writes).
> 2) This means that layoutcommit is only needed when the layout specifies
> COMMIT to the data servers, or if the writes to the data servers return
> a DATA_SYNC. All it does is commit the time stamps + file size to disk
> on the metadata server (and so you avoid the need to do an expensive
> recovery process on crash).
> 
> IOW: the above should be correct.

Okay, care to add a comment explaining this fact?  The name layoutcommit
doesn't quite suggest that it doesn't commit anything but timestamps
and size.

Can you recover the size from the data servers with the code above?  The
size should also be on disk for an fdatasync.

