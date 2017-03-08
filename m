Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:42756 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751657AbdCHRFj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 8 Mar 2017 12:05:39 -0500
Date: Wed, 8 Mar 2017 12:05:21 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Olga Kornievskaia <kolga@netapp.com>, Trond.Myklebust@primarydata.com,
        linux-nfs@vger.kernel.org
Subject: Re: [RFC v1 01/19] fs: Don't copy beyond the end of the file
Message-ID: <20170308170521.GA1020@fieldses.org>
References: <20170302160123.30375-1-kolga@netapp.com>
 <20170302160123.30375-2-kolga@netapp.com>
 <20170302162221.GA6854@infradead.org>
 <20170303204747.GE13877@fieldses.org>
 <20170307234051.GA29977@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170307234051.GA29977@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 07, 2017 at 03:40:51PM -0800, Christoph Hellwig wrote:
> On Fri, Mar 03, 2017 at 03:47:47PM -0500, J. Bruce Fields wrote:
> > That's what I think too, but then is COPY(2) wrong?:
> 
> Either the current kernel code or the man page is wrong..
> 
> > Also, copy_file_range can be implemented by ->clone_file_range, where
> > these kinds of checks make more sense, I think; e.g. from btrfs:
> > 
> > 	ret = -EINVAL;
> > 	if (off + len > src->i_size || off + len < off)
> > 		goto out_unlock;
> > 
> > Well, so the caller just has to be prepared for either behavior, I
> > guess, but that may make it more complicated to use.
> 
> We'll need to stick to one behavior.  So between the man page and
> the clone implementation I guess this patch is fine after all.

Ugh, please, let's not.

Since copy isn't atomic that check is never going to be reliable.

As long as we allow copy to have either copy-like or clone-like
implementations, callers have to be prepared to handle either behavior
when the range is past end of file, either a short copy or an EINVAL.

The difference is that if we add this check, then the "short copy"
behavior becomes something that only happens when the timing is just
right.

--b.
