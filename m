Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50313 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756192Ab2CTT1O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Mar 2012 15:27:14 -0400
Date: Tue, 20 Mar 2012 15:27:12 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] vfs: take i_mutex on renamed file
Message-ID: <20120320192712.GA1431@fieldses.org>
References: <20120305223847.GA16444@fieldses.org>
 <20120305224334.GB16444@fieldses.org>
 <20120309222114.GA22423@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120309222114.GA22423@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 09, 2012 at 05:21:14PM -0500, J. Bruce Fields wrote:
> On Mon, Mar 05, 2012 at 05:43:34PM -0500, J. Bruce Fields wrote:
> > Al, do you see any reason this won't work?
> > 
> > After this, all I need to make nfsd happy is a patch to locks.c to
> > implement delegations, and then a few one-liners to add break_deleg
> > calls in the right operations.  So this is the one non-trivial change I
> > have to core vfs code.
> > 
> > All of those patches are also ready, and I'd like to merge them for 3.4.
> 
> By the way, the following is the rest of the series.
> 
> (Compared to the last posting the deleg-breaking interface is
> simplified.)

What are the chances of getting this reviewed for this merge cycle?  Is
it on somebody's list?

If it would make it any simpler: the one that I think absolutely must get wider
review, and get merged through Al's tree, is "vfs: take i_mutex on renamed
file".

There aren't actually any dependencies between that and the rest; and
the rest is mainly in nfsd/ and locks.c (changes to which have mostly
been going through my tree anyway, I think); other than that:

 fs/attr.c           |    3 ++
 fs/namei.c          |   18 +++++++++++++-

straightforward changes that tend to look like:

	+	error = break_deleg(inode, O_WRONLY);
	+	if (error)
	+		return error;

 include/linux/fs.h  |   19 +++++++++++++--

and some definitions.

--b.
