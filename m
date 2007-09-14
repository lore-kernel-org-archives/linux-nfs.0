From: Greg Banks <gnb@sgi.com>
Subject: Re: [NFS] [PATH 18/19] exportfs: update documentation
Date: Sat, 15 Sep 2007 01:24:24 +1000
Message-ID: <20070914152424.GJ21965@sgi.com>
References: <20070830131724.GS6834@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070830131724.GS6834@lst.de>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Thu, Aug 30, 2007 at 03:17:24PM +0200, Christoph Hellwig wrote:
> + encode_fh  (optinonal)
                ^^^^^^^^^
> +    Takes a dentry and creates a filehandle fragment which can later be used
> +    to find/create a dentry for the same object.  The default implementation
> +    creates a filehandle fragment that encodes a 32bit inode and generation
> +    number for the inode encoded, and if nessecary the same information for
                                            ^^^^^^^^^
> +    the parent.
> +
> +  fh_to_dentry (mandatory)
> +    Given a filehandle fragment, this should find the implied object and
> +    create a dentry for it (possibly with d_alloc_anon).
> +
> +  fh_to_parent (optional but strongly recommended)
> +    Given a filehandle fragment, this should find the parent of the
> +    implied object and create a dentry for it (possibly with d_alloc_anon).
> +    May simplify fail if the filehandle fragment is too small.
           ^^^^^^^^

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.
