Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:34245 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750821AbdAWQOI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jan 2017 11:14:08 -0500
Received: by mail-qt0-f194.google.com with SMTP id a29so18296516qtb.1
        for <linux-nfs@vger.kernel.org>; Mon, 23 Jan 2017 08:14:08 -0800 (PST)
Message-ID: <1485188045.2786.13.camel@poochiereds.net>
Subject: Re: [PATCH] nfsd: special case truncates some more
From: Jeff Layton <jlayton@poochiereds.net>
To: Christoph Hellwig <hch@lst.de>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Date: Mon, 23 Jan 2017 11:14:05 -0500
In-Reply-To: <20170123160559.GA786@lst.de>
References: <1485104060-15209-1-git-send-email-hch@lst.de>
         <1485104060-15209-2-git-send-email-hch@lst.de>
         <1485174116.2786.7.camel@poochiereds.net> <20170123123348.GA28102@lst.de>
         <20170123153615.GA32201@lst.de> <1485186729.2786.11.camel@poochiereds.net>
         <20170123160559.GA786@lst.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2017-01-23 at 17:05 +0100, Christoph Hellwig wrote:
> On Mon, Jan 23, 2017 at 10:52:09AM -0500, Jeff Layton wrote:
> > To be clear, the client is requesting to set the mtime to current server
> > time and not to a specific mtime, right?
> 
> Yes.  And I think it's mostly the Linux client being lazy - ATTR_MTIME
> is what it gets from the VFS for a truncate operation (but not ftrunate,
> so we probably won't see it on the wire in that case, but I need to verify
> that first).  Yet another reason for ->truncate :)
> 

Heh, ok. Makes sense.

> > I don't see where vfs_truncate will handle the times though. do_truncate
> > will, but you have to pass in a non-zero time_attrs and vfs_truncate
> > always sets that to 0.
> 
> This is the magic of the Linux VFS interface.  For a ATTR_SIZE operation
> the file system is expected to update mtime and ctime if the size changes
> even if ATTR_MTIME and ATTR_CTIME are not set.  See the comments
> in xfs_vn_setattr_size, which I wrote many years ago when I tripped
> over this interesting calling convention.
> 

Ick.

> > If we did want to do this, it seems like it might be better to just add
> > a new time_attrs arg to vfs_truncate that gets passed to do_truncate.
> > Most callers would set it to zero, but nfsd could set it to:
> > 
> >     iap->ia_valid & (ATTR_MTIME|ATTR_CTIME)
> > 
> > Would that work?
> 
> I'd hate it.  I'd rather spent my time on a real truncate operation
> which makes all the above magic explicit, and as a side effect would
> fix the Linux client sending spurious mtime update requests that
> the procotol already requires to be done implicitly.

Fair enough. In that case, I wouldn't try to optimize away the second
notify_change if the client sets ATTR_MTIME/ATTR_CTIME for now

 We might have to dip down into the fs twice for a truncate, but so be
it. If it becomes a problem then we can consider that more reason to add
a real ->truncate operation.

-- 
Jeff Layton <jlayton@poochiereds.net>
