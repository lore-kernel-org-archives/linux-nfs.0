Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45133 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753143Ab2IJOfq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Sep 2012 10:35:46 -0400
Date: Mon, 10 Sep 2012 10:35:41 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Guo Chao <yan@linux.vnet.ibm.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [RFC PATCH 05/13] vfs: take i_mutex on renamed file
Message-ID: <20120910143541.GC30136@fieldses.org>
References: <1346878524-10585-1-git-send-email-bfields@redhat.com>
 <1346878524-10585-6-git-send-email-bfields@redhat.com>
 <20120906030526.GB6679@yanx>
 <20120906175118.GC21736@fieldses.org>
 <20120907022705.GA20453@yanx>
 <20120907213901.GA5927@fieldses.org>
 <20120910024051.GA10405@yanx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120910024051.GA10405@yanx>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 10, 2012 at 10:40:51AM +0800, Guo Chao wrote:
> On Fri, Sep 07, 2012 at 05:39:01PM -0400, J. Bruce Fields wrote:
> > On Fri, Sep 07, 2012 at 10:27:05AM +0800, Guo Chao wrote:
> > > One script ...
> > > 
> > > #!/bin/bash
> > > while true
> > > do
> > > 	mount -t sysfs nodev mnt && umount mnt
> > > done
> > > 
> > > 
> > > 
> > > The other ...
> > > 
> > > #!/bin/bash
> > > while true
> > > do
> > > 	mv mnt mnt2 && mv mnt2 mnt
> > > done
> > > 
> > > 
> > > 
> > > Run them simultaneously in two consoles. When mount keeps reporting 
> > > 'mount point mnt does not exist', stop them, then you will see the 
> > > familiar sysfs under mnt2.
> > 
> > Oh, thanks, for some reason I assumed it would be more difficult to
> > reproduce.
> > 
> > I think we can do this--I don't think it even requires any care to the
> > locking order of the renamed vs the victim directory, though I can't
> > completely convince myself of that.
> > 
> > Is it necessary to fix this, though?  Does it cause any problems other
> > than unexpected behavior?
> > 
> > --b.
> > --
> 
> Hard to say whether it's a bug or what's problems of being able to rename 
> mountpoint.
> 
> Anyway, this patch closes this race when mountpoint is a file. Thus we get 
> different behaviour when deal with files and directories. It's apparently 
> not well-defined, but again, is it a problem? Not sure ... ...

OK.  I'm not seeing a strong argument to change the current behavior, so
inclined to leave it alone for now.

--b.
