Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50178 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752041AbdCCVdV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 3 Mar 2017 16:33:21 -0500
Date: Fri, 3 Mar 2017 16:32:30 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: Christoph Hellwig <hch@infradead.org>, Trond.Myklebust@primarydata.com,
        linux-nfs@vger.kernel.org
Subject: Re: [RFC v1 01/19] fs: Don't copy beyond the end of the file
Message-ID: <20170303213230.GF13877@fieldses.org>
References: <20170302160123.30375-1-kolga@netapp.com>
 <20170302160123.30375-2-kolga@netapp.com>
 <20170302162221.GA6854@infradead.org>
 <20170303204747.GE13877@fieldses.org>
 <4B2A2E86-AFC8-49EA-9D53-7A53AD824CF1@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <4B2A2E86-AFC8-49EA-9D53-7A53AD824CF1@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 03, 2017 at 04:08:19PM -0500, Olga Kornievskaia wrote:
> 
> > On Mar 3, 2017, at 3:47 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > 
> > On Thu, Mar 02, 2017 at 08:22:21AM -0800, Christoph Hellwig wrote:
> >> On Thu, Mar 02, 2017 at 11:01:05AM -0500, Olga Kornievskaia wrote:
> >>> +	if (pos_in >= i_size_read(inode_in))
> >>> +		return -EINVAL;
> >> 
> >> That's not how the syscall is supposed to work, we'd rather do a
> >> short read^^^^^copy.
> > 
> > That's what I think too, but then is COPY(2) wrong?:
> > 
> > 	EINVAL Requested  range  extends beyond the end of the source
> > 	  file; or the flags argument is not 0.
> > 
> > Also, copy_file_range can be implemented by ->clone_file_range, where
> > these kinds of checks make more sense, I think; e.g. from btrfs:
> > 
> > 	ret = -EINVAL;
> > 	if (off + len > src->i_size || off + len < off)
> > 		goto out_unlock;
> > 
> > Well, so the caller just has to be prepared for either behavior, I
> > guess, but that may make it more complicated to use.
> > 
> 
> I’m still rather very confused again by the comment and what it is proposing.
> 
> There are two checks to consider for the validity of the arguments
> 
> 1. If the offset of the source file is beyond the end of the source file.
> 2. If the offset + len is beyond the end of the file.
> 
> I read that the man page is talking about #2.  This is actually what the NFSv4.2 spec required for the COPY too but we’ve been discussing that it should be a short read instead.
> 
> This patch address is to address case #1. As far as I can tell it applies to all file systems.
> 
> Are you suggesting that the checks for the validity of the arguments do not belong in VFS but instead should be in each of the underlying file systems?
> 
> Not all vfs_copy_file_range() are implemented via clone_file_range(). At least I hope that “inter” NFSv4.2 COPY will also use vfs_file_copy_range() and it would not be calling clone().

I think it'd be acceptable for copy_file_range() to just return 0 even
in your case 1.  I believe that's what ordinary read and pread does.

You probably can't perform it atomically with the copy, so it's possible
that the size will change right after you check it.

I don't see a benefit to the check.

--b.
