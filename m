From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: 2.6.28.9: EXT3/NFS inodes corruption
Date: Tue, 28 Jul 2009 17:12:15 -0400
Message-ID: <20090728211215.GE28376@fieldses.org>
References: <20090420162017.GA28079@gradator.net> <20090716172749.GC3740@atrey.karlin.mff.cuni.cz> <20090725151751.GA6419@gradator.net> <20090727154253.GB8332@duck.suse.cz> <20090728112715.GA8442@gradator.net> <20090728135226.GA21682@duck.suse.cz> <20090728164142.GA13662@gradator.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org,
	linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org
To: Sylvain Rochet <gradator@gradator.net>
Return-path: <linux-ext4-owner@vger.kernel.org>
In-Reply-To: <20090728164142.GA13662@gradator.net>
Sender: linux-ext4-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 28, 2009 at 06:41:42PM +0200, Sylvain Rochet wrote:
> Hi,
> 
> 
> On Tue, Jul 28, 2009 at 03:52:26PM +0200, Jan Kara wrote:
> > On Tue 28-07-09 13:27:15, Sylvain Rochet wrote:
> > > On Mon, Jul 27, 2009 at 05:42:53PM +0200, Jan Kara wrote:
> > > > On Sat 25-07-09 17:17:52, Sylvain Rochet wrote:
> > > > > > 
> > > > > > Can you still see the corruption with 2.6.30 kernel?
> > > > > 
> > > > > Not upgraded yet, we'll give a try.
> > > 
> > > Done, now featuring 2.6.30.3 ;)
> > 
> > OK, drop me an email if you will see corruption also with this kernel.
> 
> Lets move out the corrupted directory ;)
> 
> root@bazooka:/data/web/ed/90/48/walotux.walon.org/htdocs/tmp/cache/e# rm -- * .ok 
> rm: cannot remove `spip%3Farticle19.f8740dca': Input/output error
> root@bazooka:/data/web/ed/90/48/walotux.walon.org/htdocs/tmp/cache/e# cd ..
> root@bazooka:/data/web/ed/90/48/walotux.walon.org/htdocs/tmp/cache# mv e/ /data/lost+found/wooops
> 
> 
> > > > This is probably the misleading output from ext3_iget(). It should give
> > > > you EIO in the latest kernel.
> > > 
> > > root@bazooka:/data/web/ed/90/48/walotux.walon.org/htdocs/tmp/cache/e# cat spip%3Farticle19.f8740dca 
> > > cat: spip%3Farticle19.f8740dca: Input/output error
> > > 
> > > It has much more sense now. We thought the problem was around NFS due 
> > > the the previous error message, actually this is probably not the best 
> > > looking path.
> > 
> > Yes, EIO makes more sence. I think the problem is NFS connected anyway
> > though :). But I don't have a clue how it can happen yet. Maybe I can try
> > adding some low-cost debugging checks if you'd be willing to run such
> > kernel...
> 
> Without any problem, we have 24/7/365 physical access and we don't need 
> to provide high-availability services.
> 
> Anyway, the data hosted aren't that important, there is little or even 
> no need for strict confidentiality, so we will be happy to provide ssh 
> access to whom would like to look deeper into this issue.
> 
> 
> > I'm adding to CC linux-nfs just in case someone has an idea.
> > 
> > > >   Ah, OK, here's the problem. The directory points to a file which is
> > > > obviously deleted (note the "Links: 0"). All the content of the inode seems
> > > > to indicate that the file was correctly deleted (you might check that the
> > > > corresponding bit in the bitmap is cleared via: "icheck 88541562").
> > > 
> > > root@bazooka:~# debugfs /dev/md10
> > > debugfs 1.40-WIP (14-Nov-2006)
> > > debugfs:  icheck 88541562
> > > Block   Inode number
> > > 88541562        <block not found>
> > 
> > Ah, wrong debugfs command. I should have written:
> > testi <88541562>
> 
> debugfs:  testi <88541562>
> Inode 88541562 is not in use
> 
> 
> > > >   The question is how it could happen the directory still points to the
> > > > inode. Really strange. It looks as if we've lost a write to the directory
> > > > but I don't see how. Are there any suspitious kernel messages in this case?
> > > 
> > > There were nothing for a while, but since the reboot there are some 
> > > about this inode: 
> > > 
> > > EXT3-fs error (device md10): ext3_lookup: deleted inode referenced: 88541562
> > 
> > Yes, that's to be expected given the corruption any NFS error messages?
> 
> There are some error messages on NFS clients, however they are quite old.
> 
> Apr 19 15:38:21 gin kernel: NFS: Buggy server - nlink == 0!
> May  3 20:00:52 gin kernel: NFS: Buggy server - nlink == 0!
> May  3 23:24:03 gin kernel: NFS: Buggy server - nlink == 0!
> May  7 11:40:57 gin kernel: NFS: Buggy server - nlink == 0!
> May  7 14:41:02 gin kernel: NFS: Buggy server - nlink == 0!
> May 26 11:10:42 cognac kernel: NFS: Buggy server - nlink == 0!
> May 26 11:13:28 cognac kernel: NFS: Buggy server - nlink == 0!
> May 26 12:34:39 cognac kernel: NFS: Buggy server - nlink == 0!
> May 26 12:39:43 cognac kernel: NFS: Buggy server - nlink == 0!
> 
> This is obviously related to the corruption.

It might be interesting to know whether the file that we returned to the
client with nlink 0 was the same that you later saw corruption on; maybe
adding a printk of the inode number there would help.

Googling around on that error message, a previous thread:

	http://marc.info/?t=107429333300004&r=1&w=4

seems to conclude it's a bug, but doesn't followup with a fix.  And I
don't see any mention of possible filesystem corruption.

Is NFSv4 involved here?  I wonder if something that might otherwise be
only a problem for the client could become a problem for the server if
it attempts to do further operations with an unlinked inode in a
compound operation that follows a lookup.

--b.
