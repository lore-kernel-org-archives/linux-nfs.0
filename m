Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47554 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752647Ab2DJNHY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Apr 2012 09:07:24 -0400
Date: Tue, 10 Apr 2012 09:07:21 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] vfs: take i_mutex on renamed file
Message-ID: <20120410130721.GA18465@fieldses.org>
References: <20120305223847.GA16444@fieldses.org>
 <20120305224334.GB16444@fieldses.org>
 <20120309222114.GA22423@fieldses.org>
 <20120320192712.GA1431@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120320192712.GA1431@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 20, 2012 at 03:27:12PM -0400, J. Bruce Fields wrote:
> What are the chances of getting this reviewed for this merge cycle?  Is
> it on somebody's list?
> 
> If it would make it any simpler: the one that I think absolutely must get wider
> review, and get merged through Al's tree, is "vfs: take i_mutex on renamed
> file".
> 
> There aren't actually any dependencies between that and the rest;

Based on discussion at LSF, and absent any objections, I'm leaving "vfs:
take i_mutex on renamed file" for Al to take, and merging the rest
through the nfsd tree for 3.5.  (Al, assuming that's the correct thing
to do, should I add an acked-by/reviewed-by for you to the patches I
merge?)

--b.

> and
> the rest is mainly in nfsd/ and locks.c (changes to which have mostly
> been going through my tree anyway, I think); other than that:
> 
>  fs/attr.c           |    3 ++
>  fs/namei.c          |   18 +++++++++++++-
> 
> straightforward changes that tend to look like:
> 
> 	+	error = break_deleg(inode, O_WRONLY);
> 	+	if (error)
> 	+		return error;
> 
>  include/linux/fs.h  |   19 +++++++++++++--
> 
> and some definitions.
> 
> --b.
