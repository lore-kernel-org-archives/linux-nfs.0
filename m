Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:57462 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753230Ab1DAIaq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Apr 2011 04:30:46 -0400
Received: by qwk3 with SMTP id 3so1997172qwk.19
        for <linux-nfs@vger.kernel.org>; Fri, 01 Apr 2011 01:30:45 -0700 (PDT)
Message-ID: <4D958D31.6030507@panasas.com>
Date: Fri, 01 Apr 2011 04:30:41 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Christoph Hellwig <hch@lst.de>
CC: Rees <rees@citi.umich.edu>, linux-nfs@vger.kernel.org
Subject: Re: [RFC] spnfs-block: restore i_op->fallocate
References: <1301500460-16467-1-git-send-email-bhalevy@panasas.com> <20110330155811.GA21931@lst.de> <4D936453.2070501@panasas.com> <20110330173344.GA24631@lst.de> <4D942506.1020505@panasas.com> <20110331135338.GA20235@lst.de>
In-Reply-To: <20110331135338.GA20235@lst.de>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-03-31 09:53, Christoph Hellwig wrote:

> Btw, how is the spnfs-block support supposed to work at all?
>
> fallocate creates unwritten extents, and I can't actually
> spot a place that would later convert them to regular extents.

It's supposed to work by committing the extents on
layoutcommit. It's supposed to happen in the spnfs-block
but it doesn't. Currently, the generic layer calls write_inode_now
if the size changes and the fs is exported "sync" so my guess is that
it works now only when the file is extended but not when writing
in-place into holes.

> And how does it work for filesystems without ->fallocate like
> ext3?

It doesn't.  spnfs-block requires fs support for fallocate and fiemap.

> And how do we prevent clients from reading uninitialized
> blocks in areas allocated on the server but not written
> to yet.  Is there anything like unwritten extents in the
> on the write protocol?

Yes, there is, yet spnfs-block does not implement it
as it was implemented essentially as a reference/testing tool.

The protocol allows the server to provisionally allocate space
on layoutget that the client can write into, privately.
The clients changes only become visible to other clients
when they are committed to the file on LAYOUTCOMMIT.
This also allows implementing copy-on-write as the client
can be given in the layout separate extents describing the
readable copy of the block and the writeable one and the
client participates in the copy-on-write process by copying
the contents of the block before modifying it (or zeroing it out
if it's just invalid).  This is done at write_begin time on
the client side.

Benny

> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

