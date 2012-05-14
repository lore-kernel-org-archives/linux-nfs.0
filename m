Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35686 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756124Ab2ENPXg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 May 2012 11:23:36 -0400
Date: Mon, 14 May 2012 11:23:34 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andreas Dilger <adilger@dilger.ca>
Cc: "Theodore Ts'o" <tytso@mit.edu>,
        "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH] ext4: turn on i_version updates by default
Message-ID: <20120514152334.GB29902@fieldses.org>
References: <20120514140618.GA29902@fieldses.org>
 <9124E59E-2479-4C32-A528-3237B48DEC01@dilger.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <9124E59E-2479-4C32-A528-3237B48DEC01@dilger.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 14, 2012 at 09:02:12AM -0600, Andreas Dilger wrote:
> On 2012-05-14, at 8:06, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > knfsd needs i_version updates on, as will userspace nfs servers and
> > probably others.
> > 
> > The only effects are that inode->i_version is bumped (under the i_lock)
> > in more places, and that ->dirty_inode(I_DIRTY_DATASYNC) may be called
> > more frequently than once per jiffy on write (see file_update_time).
> > However the latter appears to be mostly a no-op in that case.
> 
> I thought this can have noticeable performance impact, since ext4_mark_inode_dirty() is quite heavyweight?

There's no reason it should be, should it, if we already just dirtied
the inode a moment ago?

> This is one of the reasons that the i_version update is conditional.
> If someone is exporting a filesystem from userspace the should be able
> to turn this on as a mount option, and knfsd could do it from inside
> the kernel. Why add overhead when it is not needed?

Any user of the change attribute also wants it to function correctly
while they're away.

And if it at all possible I'd rather have it be something that Just
Works rather than something that requires extra configuration.

--b.
