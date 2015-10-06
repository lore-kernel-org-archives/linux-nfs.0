Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:49030 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750897AbbJFJH4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Oct 2015 05:07:56 -0400
Date: Tue, 6 Oct 2015 11:07:46 +0200
From: Pavel Machek <pavel@ucw.cz>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-ext4@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org
Subject: Re: [PATCH v9 00/43] Richacls
Message-ID: <20151006090746.GA27791@xo-6d-61-c0.localdomain>
References: <1444073830-21854-1-git-send-email-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1444073830-21854-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon 2015-10-05 21:36:27, Andreas Gruenbacher wrote:
> Here is another update of the richacl patch queue.  I would like to ask for
> feedback so that the core and ext4 code (patches 1-21) can be merged in the
> 4.4 merge window.  Changes since the last posting
> (https://lkml.org/lkml/2015/9/27/148):
> 
>  * A set_richacl inode operation similar to set_acl for POSIX ACLs was
>    added.  The filesystem specific code needed for adding richacl support
>    has shrunk: ext4_richacl_chmod, ext4_xattr_{list,get,set}_richacl,
>    ext4_init_richacl, ext4_richacl_xattr_handler were all replaced by vfs
>    functions.
> 
> The complete patch queue is available here:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/agruen/linux-richacl.git \
> 	richacl-2015-10-05
> 
> 
> The richacl user-space utilitites and test suite are available here:
> 
>   https://github.com/andreas-gruenbacher/richacl/
> 
> 
> We still have two open issues in nfs (see the previous posting) which don't
> affect the core functionality.

Should there be file in Documentation/ explaining how this works?

									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
