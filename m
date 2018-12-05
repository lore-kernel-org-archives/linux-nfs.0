Return-Path: <SRS0=3CSe=OO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B48F8C04EB9
	for <linux-nfs@archiver.kernel.org>; Wed,  5 Dec 2018 17:28:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 86D11205C9
	for <linux-nfs@archiver.kernel.org>; Wed,  5 Dec 2018 17:28:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86D11205C9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728249AbeLER2K (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 5 Dec 2018 12:28:10 -0500
Received: from fieldses.org ([173.255.197.46]:50580 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727242AbeLER2K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 5 Dec 2018 12:28:10 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id BCF921C1F; Wed,  5 Dec 2018 12:28:09 -0500 (EST)
Date:   Wed, 5 Dec 2018 12:28:09 -0500
To:     Dave Chinner <david@fromorbit.com>
Cc:     "Darrick J. Wong" <darrick.wong@oracle.com>,
        linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org,
        olga.kornievskaia@gmail.com, linux-nfs@vger.kernel.org,
        linux-unionfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org
Subject: Re: [PATCH 05/11] vfs: use inode_permission in copy_file_range()
Message-ID: <20181205172809.GC5182@fieldses.org>
References: <20181203083416.28978-1-david@fromorbit.com>
 <20181203083416.28978-6-david@fromorbit.com>
 <20181203181803.GX8125@magnolia>
 <20181203235517.GN6311@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181203235517.GN6311@dastard>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Dec 04, 2018 at 10:55:17AM +1100, Dave Chinner wrote:
> On Mon, Dec 03, 2018 at 10:18:03AM -0800, Darrick J. Wong wrote:
> > On Mon, Dec 03, 2018 at 07:34:10PM +1100, Dave Chinner wrote:
> > > From: Dave Chinner <dchinner@redhat.com>
> > > 
> > > Similar to FI_DEDUPERANGE, make copy_file_range() check that we have
> > 
> > TLDR: No, it's not similar to FIDEDUPERANGE -- the use of
> > inode_permission() in allow_file_dedupe() is to enable callers to dedupe
> > into a file for which the caller has write permissions but opened the
> > file O_RDONLY.
> 
> What a grotty, nasty hack.
> 
> > [Please keep reading...]
> > 
> > > write permissions to the destination inode.
> > > 
> > > Signed-off-by: Dave Chinner <dchinner@redhat.com>
> > > ---
> > >  mm/filemap.c | 5 +++++
> > >  1 file changed, 5 insertions(+)
> > > 
> > > diff --git a/mm/filemap.c b/mm/filemap.c
> > > index 0a170425935b..876df5275514 100644
> > > --- a/mm/filemap.c
> > > +++ b/mm/filemap.c
> > > @@ -3013,6 +3013,11 @@ int generic_copy_file_checks(struct file *file_in, loff_t pos_in,
> > >  	    (file_out->f_flags & O_APPEND))
> > >  		return -EBADF;
> > >  
> > > +	/* may sure we really are allowed to write to the destination inode */
> > > +	ret = inode_permission(inode_out, MAY_WRITE);
> > 
> > What's the difference between security_file_permission and
> > inode_permission, and when do we call them for a regular
> > open-write-close sequence?  Hmmm, let me take a look:
> .....
> > We also cannot dedupe into a file that becomes immutable after we open
> > it for write, but we can dedupe into a file that loses its write
> > permissions after we open it.
> 
> It's more nuanced than that - dedupe will proceed after write
> permissions have been removed only if you are root or own the file,
> otherwise it will fail.
> 
> Updated summary:
> 
> > op:		after +immutable?	after chmod a-w?
> > write		yes			yes
> > clonerange	no			yes
> > dedupe	no			maybe
> > newcopyrange	no			no
> >
> > My reaction: I don't think that writes should be allowed after an
> > administrator marks a file immutable (but that's a separate issue) but I
> > do think we should be consistent in allowing copying into a file that
> > has lost its write permissions after we opened the file for write, like
> > we do for write() and the remap ioct....
> 
> If we want to allow copying to files we don't actually have
> permission to write to anymore, then I'll remove this from the test,
> the man page and the code. But, quite frankly, I don't trust remote
> server side copies to follow the same permission models as the
> client side OS, so I think we have to treat copy_file_range
> differently to a normal write syscall....

The NFS COPY command takes references to the protocol's equivalent to
open files, and I'd expect permission checks should depend on the open
mode, not the current file permissions.

But server behavior may vary.  I'm not sure that's a good guide for what
to do locally.

In general I'm more comfortable the closer copy is to read & write.

--b.
