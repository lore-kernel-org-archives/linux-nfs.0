Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:42806 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751884AbeENRAn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 14 May 2018 13:00:43 -0400
Date: Mon, 14 May 2018 18:00:41 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Jeff Layton <jlayton@kernel.org>
Subject: Re: [RFC][PATCH] nfsd: vfs_mkdir() might succeed leaving dentry
 negative unhashed
Message-ID: <20180514170041.GJ30522@ZenIV.linux.org.uk>
References: <20180511211339.GG30522@ZenIV.linux.org.uk>
 <20180514153216.GC7160@fieldses.org>
 <20180514154550.GH30522@ZenIV.linux.org.uk>
 <20180514162704.GE7160@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180514162704.GE7160@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 14, 2018 at 12:27:04PM -0400, J. Bruce Fields wrote:
> > > 	if (!err)
> > > 		err = fh_update(reshp);
> > > 
> > > at the end of nfsd_create_locked.
> > 
> > Might be too late for that, though - the trouble hits when we hit
> > nfsd_create_setattr().
> 
> Oh, got it.  Could move the bottom fh_update to just above the
> nfsd_create_setattr(), though?

Probably, but I'm not comfortable enough with the nfsd guts wrt in-core
fhandle and assumptions made by users of such, so I'd rather bounce that
question to nfsd maintainers ;-)
