Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:48837 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750988AbaGJMFY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 08:05:24 -0400
Date: Thu, 10 Jul 2014 05:05:22 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 012/100] nfsd: remove nfs4_file_put_fd
Message-ID: <20140710120522.GA1197@infradead.org>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
 <1404842668-22521-13-git-send-email-jlayton@primarydata.com>
 <20140710080336.GB6226@infradead.org>
 <20140710074952.20e97f70@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140710074952.20e97f70@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 10, 2014 at 07:49:52AM -0400, Jeff Layton wrote:
> 
> AFAIU, the fi_access counters tell us when we're able to zero out the
> fi_fds slot. fput returns void so we don't have a way to know whether
> we're putting the last reference to a file or not. Without that,
> find_*_file become quite problematic -- how would we know whether the
> pointers they return are still good?

Oh right, that's defintively a good reason to keep the counters.

> > Note that the comment explaining fi_access also seems wrong, as it
> > suggest contributing 0-4 to the counts, but at best we increment each
> > one by 1 in a single operation.
> > 
> 
> Right, we only increment by one for each operation, but open stateids
> can be upgraded and downgraded. If we do:
> 
> OPEN for NFS4_SHARE_ACCESS_READ
> OPEN for NFS4_SHARE_ACCESS_WRITE
> OPEN for NFS4_SHARE_ACCESS_BOTH
> 
> ...then we will have incremented the fi_access counts by a total of 4.
> 
> The big pain in the ass with this code is explained in the comment over
> bmap_to_share_mode. We have to keep track of what share bits have been
> previously used in order to comply with the RFC, so you can easily end
> up with "extra" references.

I've read both the comment, and the section in the RFC, but I still
don't understand how they explain this convoluted code.

Assume we'd have three members in fi_access instead, indexed by
(oflags & (O_RDONLY|O_WRONLY|O_RDWR):

static void nfs4_file_get_access(struct nfs4_file *fp, u32 access)
{
	int oflags = nfs4_access_to_omode(access);

	WARN_ON_ONCE(fp->fi_fds[oflag] == NULL);
	atomic_inc(&fp->fi_access[oflag]);
}

static void nfs4_file_put_access(struct nfs4_file *fp, u32 access)
{
	int oflags = nfs4_access_to_omode(access);

	if (atomic_dec_and_test(&fp->fi_access[oflag]))
		nfs4_file_put_fd(fp, oflag);
}

nfsd4_open_downgrade would become a little more complicated because it
would have to check if an FD for the downgraded access is around before
dropping the reference to the r/w one it currently holds. And as far as
I can tell O_RDWR to O_RDONLY or O_WRONLY is the only possible case for
it, feel free to correct me.

Or we could simply not bother with downgrading the underlying file here
at all, just like it's done for the case where only a O_RDWR file is
open in the current code, which probably is a fairly common case.
