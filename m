Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yk0-f172.google.com ([209.85.160.172]:60498 "EHLO
	mail-yk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752412AbaHXKJe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Aug 2014 06:09:34 -0400
Received: by mail-yk0-f172.google.com with SMTP id 20so489654yks.31
        for <linux-nfs@vger.kernel.org>; Sun, 24 Aug 2014 03:09:33 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Sun, 24 Aug 2014 06:09:31 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, bfields@fieldses.org,
        cluster-devel@redhat.com, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 03/10] locks: generic_delete_lease doesn't need a
 file_lock at all
Message-ID: <20140824060931.30501a5b@synchrony.poochiereds.net>
In-Reply-To: <20140824012757.GA21609@infradead.org>
References: <1408804878-1331-1-git-send-email-jlayton@primarydata.com>
	<1408804878-1331-4-git-send-email-jlayton@primarydata.com>
	<20140824012757.GA21609@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 23 Aug 2014 18:27:57 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Sat, Aug 23, 2014 at 10:41:11AM -0400, Jeff Layton wrote:
> > +static int generic_delete_lease(struct file *filp)
> >  {
> >  	struct file_lock *fl, **before;
> >  	struct dentry *dentry = filp->f_path.dentry;
> >  	struct inode *inode = dentry->d_inode;
> >  
> > -	trace_generic_delete_lease(inode, *flp);
> > -
> 
> Can you keep the tracepoint and modify it to not need the file_lock
> pointer?  It really helped me with some debugging lately.
> 
> Otherwise looks fine,
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Doh! Yes, I meant to put that back. Will do on the next respin.

Thanks,
-- 
Jeff Layton <jlayton@primarydata.com>
