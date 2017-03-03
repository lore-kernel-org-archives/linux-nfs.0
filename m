Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50090 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751970AbdCCUs2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 3 Mar 2017 15:48:28 -0500
Date: Fri, 3 Mar 2017 15:47:47 -0500
To: Christoph Hellwig <hch@infradead.org>
Cc: Olga Kornievskaia <kolga@netapp.com>, Trond.Myklebust@primarydata.com,
        linux-nfs@vger.kernel.org
Subject: Re: [RFC v1 01/19] fs: Don't copy beyond the end of the file
Message-ID: <20170303204747.GE13877@fieldses.org>
References: <20170302160123.30375-1-kolga@netapp.com>
 <20170302160123.30375-2-kolga@netapp.com>
 <20170302162221.GA6854@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170302162221.GA6854@infradead.org>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 02, 2017 at 08:22:21AM -0800, Christoph Hellwig wrote:
> On Thu, Mar 02, 2017 at 11:01:05AM -0500, Olga Kornievskaia wrote:
> > +	if (pos_in >= i_size_read(inode_in))
> > +		return -EINVAL;
> 
> That's not how the syscall is supposed to work, we'd rather do a
> short read^^^^^copy.

That's what I think too, but then is COPY(2) wrong?:

	EINVAL Requested  range  extends beyond the end of the source
	  file; or the flags argument is not 0.

Also, copy_file_range can be implemented by ->clone_file_range, where
these kinds of checks make more sense, I think; e.g. from btrfs:

	ret = -EINVAL;
	if (off + len > src->i_size || off + len < off)
		goto out_unlock;

Well, so the caller just has to be prepared for either behavior, I
guess, but that may make it more complicated to use.

--b.
