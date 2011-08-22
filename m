Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:36380 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754288Ab1HVXWC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Aug 2011 19:22:02 -0400
Date: Tue, 23 Aug 2011 09:21:50 +1000
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jamie Lokier <jamie@shareable.org>, Al Viro <viro@ZenIV.linux.org.uk>,
        Sylvain Rochet <gradator@gradator.net>, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: PROBLEM: 2.6.35.7 to 3.0 Inotify events missing
Message-ID: <20110823092150.366d8899@notabene.brown>
In-Reply-To: <20110822172239.GA15960@fieldses.org>
References: <20101018223540.GA20730@gradator.net>
	<20110819230344.GA24784@gradator.net>
	<20110819233756.GI11512@jl-vm1.vm.bytemark.co.uk>
	<20110820012943.GD2203@ZenIV.linux.org.uk>
	<20110820030335.GA14899@jl-vm1.vm.bytemark.co.uk>
	<20110821170714.GB9296@fieldses.org>
	<20110821202058.GF14899@jl-vm1.vm.bytemark.co.uk>
	<20110822090751.029de688@notabene.brown>
	<20110822172239.GA15960@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 22 Aug 2011 13:22:39 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Mon, Aug 22, 2011 at 09:07:51AM +1000, NeilBrown wrote:
> > One is to use bind mounts. i.e. I effectively do
> >     mount --bind $HOME/.config $HOME/.config
> > and ask for events from the newly created vfsmnt.
> > This will not catch changes made through file descriptors that were opened
> > before I did the mount, or through hard links from some other directory
> > tree.  But for a particular use-case that might not be a problem.
> 
> I'm missing what the extra vfsmount gets you here.  The problems seem
> just the same as if you don't have one.
> 
> Oh, wait, I see, it's that the file descriptors are associated with
> vfsmounts, not just dentries.  Hm.

"Hm" might be right.  writes have a 'struct file', but mkdir and rename etc
just get an inode.
So to be able to notify based on vfsmnt, mkdirat - for examine - would need
to pass the path to vfs_mkdir rather than path.dentry->d_inode, and vfs_mkdir
would have to pass that path to fsnotify_mkdir.  So more intrusive that I
imagined, but still quite do-able.... if it were thought to be useful.

NeilBrown

