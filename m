Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:42230 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753173Ab1CDQ6y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Mar 2011 11:58:54 -0500
Date: Fri, 4 Mar 2011 11:58:52 -0500
From: Christoph Hellwig <hch@infradead.org>
To: Neil Horman <nhorman@tuxdriver.com>
Cc: linux-nfs@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>,
        security@kernel.org, Jeff Layton <jlayton@redhat.com>,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] nfs4: Ensure that ACL pages sent over NFS were not
 allocated from the slab
Message-ID: <20110304165852.GA2679@infradead.org>
References: <1299257053-13175-1-git-send-email-nhorman@tuxdriver.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1299257053-13175-1-git-send-email-nhorman@tuxdriver.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> It occurs, because an skb with a fraglist was freed from the tcp retransmit
> queue when it was acked, but a page on that fraglist had PG_Slab set (indicating
> it was allocated from the Slab allocator (which means the free path above can't
> safely free it via put_page)
> 
> We tracked this back to an nfsv4 setacl operation, in which the nfs code
> attempted to fill convert the passed in buffer to an array of pages in
> __nfs4_proc_set_acl, which gets used by the skb->frags list in xs_sendpages.
> __nfs4_proc_set_acl just converts each page in the buffer to a page struct via
> virt_to_page, but the vfs allocates the buffer via kmalloc, meaning the PG_slab
> bit is set.  We can't create a buffer with kmalloc and free it later in the tcp
> ack path with put_page, so we need to either:

Note that the same thing can also happen with ext4 sending kmalloc'ed
buffers through network based block storage.  Long time ago we had the
same issue with XFS and went to great length to avoid sending down
kmalloc'ed pages, but recently we (fs developers) were told that's just
fine.  Consequently ext4 now actually uses slab pages for I/O, and we
are planning to make use of that fact soon again in XFS, too.

