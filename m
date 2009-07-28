From: Jan Kara <jack@suse.cz>
Subject: Re: 2.6.28.9: EXT3/NFS inodes corruption
Date: Tue, 28 Jul 2009 15:52:26 +0200
Message-ID: <20090728135226.GA21682@duck.suse.cz>
References: <20090420162017.GA28079@gradator.net> <20090716172749.GC3740@atrey.karlin.mff.cuni.cz> <20090725151751.GA6419@gradator.net> <20090727154253.GB8332@duck.suse.cz> <20090728112715.GA8442@gradator.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org,
	linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org
To: Sylvain Rochet <gradator-XWGZPxRNpGHk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:50039 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754063AbZG1Nw1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Jul 2009 09:52:27 -0400
In-Reply-To: <20090728112715.GA8442-XWGZPxRNpGHk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue 28-07-09 13:27:15, Sylvain Rochet wrote:
> On Mon, Jul 27, 2009 at 05:42:53PM +0200, Jan Kara wrote:
> > On Sat 25-07-09 17:17:52, Sylvain Rochet wrote:
> > > > 
> > > > Can you still see the corruption with 2.6.30 kernel?
> > > 
> > > Not upgraded yet, we'll give a try.
> 
> Done, now featuring 2.6.30.3 ;)
  OK, drop me an email if you will see corruption also with this kernel.

> > > > If you can still see this problem, could you run: debugfs /dev/md10
> > > > and send output of the command:
> > > > stat <40420228>
> > > > (or whatever the corrupted inode number will be)
> > > > and also:
> > > > dump <40420228> /tmp/corrupted_dir
> > > 
> > > One inode get corrupted recently, here is the output:
> > > 
> > > root@bazooka:/data/web/ed/90/48/walotux.walon.org/htdocs/tmp/cache/e# ls -lai
> > > total 64
> > > 88539836 drwxr-sr-x  2 18804 23084  4096 2009-07-25 07:53 .
> > > 88539821 drwxr-sr-x 20 18804 23084  4096 2008-08-20 10:14 ..
> > > 88541578 -rw-rw-rw-  1 18804 23084   471 2009-07-25 04:55 -inc_forum-10-wa.3cb1921f
> > > 88541465 -rw-rw-rw-  1 18804 23084  6693 2009-07-25 07:53 -inc_rss_item-32-wa.23d91cc2
> > > 88541471 -rw-rw-rw-  1 18804 23084  1625 2009-07-25 07:53 -inc_rubriques-17-wa.f2f152f0
> > > 88541549 -rw-rw-rw-  1 18804 23084  2813 2009-07-25 03:04 INDEX-.edfac52c
> > > 88541366 -rw-rw-rw-  1 18804 23084     0 2008-08-17 20:44 .ok
> > >        ? ?---------  ? ?     ?         ?                ? spip%3Farticle19.f8740dca
> > > 88541671 -rw-rw-rw-  1 18804 23084  5619 2009-07-24 21:07 spip%3Fauteur1.c64f7f7e
> > > 88541460 -rw-rw-rw-  1 18804 23084  5636 2009-07-24 19:30 spip%3Fmot5.f3e9adda
> > > 88540284 -rw-rw-rw-  1 18804 23084  3802 2009-07-25 16:10 spip%3Fpage%3Dforum-30.63b2c1b1
> > > 88541539 -rw-rw-rw-  1 18804 23084 12972 2009-07-25 11:14 spip%3Fpage%3Djquery.cce608b6.gz
> >   OK, so we couldn't stat a directory...
> > 
> > > root@bazooka:/data/web/ed/90/48/walotux.walon.org/htdocs/tmp/cache/e# cat spip%3Farticle19.f8740dca
> > > cat: spip%3Farticle19.f8740dca: Stale NFS file handle
> >   This is probably the misleading output from ext3_iget(). It should give
> > you EIO in the latest kernel.
> 
> root@bazooka:/data/web/ed/90/48/walotux.walon.org/htdocs/tmp/cache/e# cat spip%3Farticle19.f8740dca 
> cat: spip%3Farticle19.f8740dca: Input/output error
> 
> It has much more sense now. We thought the problem was around NFS due 
> the the previous error message, actually this is probably not the best 
> looking path.
  Yes, EIO makes more sence. I think the problem is NFS connected anyway
though :). But I don't have a clue how it can happen yet. Maybe I can try
adding some low-cost debugging checks if you'd be willing to run such
kernel...
  I'm adding to CC linux-nfs just in case someone has an idea.

> > > root@bazooka:~# debugfs /dev/md10
> > > debugfs 1.40-WIP (14-Nov-2006)
> > > 
> > >     debugfs:  stat <88539836>
> > > 
> > > Inode: 88539836   Type: directory    Mode:  0755   Flags: 0x0   Generation: 791796957
> > > User: 18804   Group: 23084   Size: 4096
> > > File ACL: 0    Directory ACL: 0
> > > Links: 2   Blockcount: 8
> > > Fragment:  Address: 0    Number: 0    Size: 0
> > > ctime: 0x4a6a9dd5 -- Sat Jul 25 07:53:25 2009
> > > atime: 0x4a0de585 -- Fri May 15 23:58:29 2009
> > > mtime: 0x4a6a9dd5 -- Sat Jul 25 07:53:25 2009
> > > Size of extra inode fields: 4
> > > BLOCKS:
> > > (0):177096928
> > > TOTAL: 1
> > > 
> > > 
> > >     debugfs:  ls <88539836>
> > > 
> > >  88539836  (12) .    88539821  (32) ..    88541366  (12) .ok
> > >  88541465  (56) -inc_rss_item-32-wa.23d91cc2
> > >  88541539  (40) spip%3Fpage%3Djquery.cce608b6.gz
> > >  88540284  (40) spip%3Fpage%3Dforum-30.63b2c1b1
> > >  88541460  (28) spip%3Fmot5.f3e9adda
> > >  88541471  (160) -inc_rubriques-17-wa.f2f152f0
> > >  88541549  (24) INDEX-.edfac52c    88541578  (284) -inc_forum-10-wa.3cb1921f
> > >  88541562  (36) spip%3Farticle19.f8740dca
> > >  88541671  (3372) spip%3Fauteur1.c64f7f7e
> >   The directory itself looks fine...
> > 
> > >     debugfs:  stat <88541562>
> > > 
> > > Inode: 88541562   Type: regular    Mode:  0666   Flags: 0x0   Generation: 860068541
> > > User: 18804   Group: 23084   Size: 0
> > > File ACL: 0    Directory ACL: 0
> > > Links: 0   Blockcount: 0
> > > Fragment:  Address: 0    Number: 0    Size: 0
> > > ctime: 0x4a6a8fac -- Sat Jul 25 06:53:00 2009
> > > atime: 0x4a6a612f -- Sat Jul 25 03:34:39 2009
> > > mtime: 0x4a6a8fac -- Sat Jul 25 06:53:00 2009
> > > dtime: 0x4a6a8fac -- Sat Jul 25 06:53:00 2009
> > > Size of extra inode fields: 4
> > > BLOCKS:
> > 
> >   Ah, OK, here's the problem. The directory points to a file which is
> > obviously deleted (note the "Links: 0"). All the content of the inode seems
> > to indicate that the file was correctly deleted (you might check that the
> > corresponding bit in the bitmap is cleared via: "icheck 88541562").
> 
> root@bazooka:~# debugfs /dev/md10
> debugfs 1.40-WIP (14-Nov-2006)
> debugfs:  icheck 88541562
> Block   Inode number
> 88541562        <block not found>
  Ah, wrong debugfs command. I should have written:
testi <88541562>

> >   The question is how it could happen the directory still points to the
> > inode. Really strange. It looks as if we've lost a write to the directory
> > but I don't see how. Are there any suspitious kernel messages in this case?
> 
> There were nothing for a while, but since the reboot there are some 
> about this inode: 
> 
> EXT3-fs error (device md10): ext3_lookup: deleted inode referenced: 88541562
  Yes, that's to be expected given the corruption any NFS error messages?

> > > We'll try.
> > 
> >   It probably won't help. This particular directory had just one block so
> > DIR_INDEX had no effect on it.
> 
> Let's keep dir_index for now, then.
  OK.

> >   OK, so it's probably not a storage device problem. Good to know.
> 
> We also thought about motherboard, CPU, or chassis issues, but 
> everything has been replaced.
> 
> 
> The check of the MD raid6 array always ends happily:
> 
> Jul  5 01:06:01 bazooka kernel: md: data-check of RAID array md10
> Jul  5 01:06:01 bazooka kernel: md: minimum _guaranteed_  speed: 1000 KB/sec/disk.
> Jul  5 01:06:01 bazooka kernel: md: using maximum available idle IO bandwidth (but not more than 200000 KB/sec) for data-check.
> Jul  5 01:06:01 bazooka kernel: md: using 128k window, over a total of 143373888 blocks.
> Jul  5 04:28:28 bazooka kernel: md: md10: data-check done.
> 
> 
> We never saw modification to the data of files themselves, maybe it 
> happened, but we never saw any evidence of that. Of course, due to the 
> modification of the filesystem structure, we saw files replaced by other 
> files ;)

								Honza

-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR
