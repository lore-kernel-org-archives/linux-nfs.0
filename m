Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:35736 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751705Ab2EOKag (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 May 2012 06:30:36 -0400
Date: Tue, 15 May 2012 12:30:21 +0200
From: Jan Kara <jack@suse.cz>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Andreas Dilger <adilger@dilger.ca>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "Theodore Ts'o" <tytso@mit.edu>,
        "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH] ext4: turn on i_version updates by default
Message-ID: <20120515103021.GD22359@quack.suse.cz>
References: <20120514140618.GA29902@fieldses.org>
 <9124E59E-2479-4C32-A528-3237B48DEC01@dilger.ca>
 <1337036918.2522.32.camel@lade.trondhjem.org>
 <A0359961-B147-4343-BFA3-E82F38C6700B@dilger.ca>
 <20120514235432.GA3199@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120514235432.GA3199@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon 14-05-12 19:54:32, J. Bruce Fields wrote:
> On Mon, May 14, 2012 at 05:33:04PM -0600, Andreas Dilger wrote:
> > I said as much in another reply - that once i_version is used on
> > a filesystem, it should be made "sticky" (i.e. permanently enabled
> > for that filesystem).  However, until that time it shouldn't be
> > enabled just because it might one day be used.
> > 
> > Even better than just blindly bumping the i_version on every change,
> > it would be better to have users of i_version (i.e. knfsd) flag the
> > inode with "needs i_version update" then read the version.  When the
> > filesystem/VFS bumps i_version the next time it can clear this flag
> > and not update i_version again until after the next time i_version
> > is actually used.
> 
> I really don't want to do anything more complicated than necessary.
> 
> What would be the worst-case test for the extra inode dirtying, so we
> can see what the numbers actually are?
  Something like:

  int fd, i;
  struct timeval tv[2];

  fd = open("file", O_CREAT | O_RDWR, 0644);
  if (fd < 0)
    return 1;
  for (i = 0; i < 1000000; i++) {
    gettimeofday(tv);
    tv[1] = tv[0];
    if (futimes(fd, tv) < 0)
      return 1;
  }
  return 0;

  And see how long does it take with and without i_version?

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR
