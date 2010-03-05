Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:46995 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754669Ab0CES33 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Mar 2010 13:29:29 -0500
Date: Fri, 5 Mar 2010 18:29:24 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: Merge of the 'write_inode' branch from the VFS tree
Message-ID: <20100305182924.GY30031@ZenIV.linux.org.uk>
References: <1267802800.5174.6.camel@localhost.localdomain>
 <20100305154823.GV30031@ZenIV.linux.org.uk>
 <1267812155.5174.9.camel@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1267812155.5174.9.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Mar 05, 2010 at 01:02:35PM -0500, Trond Myklebust wrote:
> On Fri, 2010-03-05 at 15:48 +0000, Al Viro wrote:
> 
> > Or I can do a new branch, put updated pair of patches there (hch has sent
> > the updated variants my way) and ask you to rebuild NFS tree.  Which will
> > also suck, since it adds PITA for you and you are completely innocent in
> > that clusterfuck.
> > 
> > Suggestions?  I'd love to get out of that mess with minimal PITA for
> > everyone involved and minimally messed tree...
> 
> Hi Al,
> 
> I'd be fine with rebuilding the NFS tree. I have all the patches which
> depend on write_inode in their own separate branch anyway, so I'd only
> have to rebase that branch and then merge it with the main NFS client
> tree...

Ehh...  Just after I've sent a pull request for backmerge variant...
Anyway, I've put rebased variant in the same tree, branch called
write_inode2.  Same diffstat, same shortlog (sans merges).  Either
branch will do; write_inode2 obviously has cleaner history.
