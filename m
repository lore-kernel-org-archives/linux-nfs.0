Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:36260 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751760AbaF1LAx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Jun 2014 07:00:53 -0400
Date: Sat, 28 Jun 2014 04:00:51 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Christoph Hellwig <hch@infradead.org>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 001/117] nfsd: fix file access refcount leak when
 nfsd4_truncate fails
Message-ID: <20140628110051.GA8474@infradead.org>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
 <1403810017-16062-2-git-send-email-jlayton@primarydata.com>
 <20140626152412.7c27c03e@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140626152412.7c27c03e@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 26, 2014 at 03:24:12PM -0400, Jeff Layton wrote:
> On Thu, 26 Jun 2014 15:11:41 -0400
> Jeff Layton <jlayton@primarydata.com> wrote:
> 
> > From: Christoph Hellwig <hch@infradead.org>
> > 
> > nfsd4_process_open2 will currently will get access to the file, and then
> > call nfsd4_truncate to (possibly) truncate it. If that operation fails
> > though, then the access references will never be released as the
> > nfs4_ol_stateid is never initialized.
> > 
> > Fix by moving the nfsd4_truncate call into nfs4_get_vfs_file, ensuring
> > that the refcounts are properly put if the truncate fails.
> > 
> > Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> > Signed-off-by: Christoph Hellwig <hch@infradead.org>
> 
> Christoph, I took the liberty of composing a commit log and adding your
> SOB line here. Let me know if you have any objections.

Thanks, I should have done that myself earlier.

