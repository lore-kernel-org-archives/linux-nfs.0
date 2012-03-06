Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:7445 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932461Ab2CFCI0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Mar 2012 21:08:26 -0500
Date: Mon, 5 Mar 2012 21:08:19 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: "Ted Ts'o" <tytso@mit.edu>
Cc: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, yong.fan@whamcloud.com,
        sandeen@redhat.com, adilger@whamcloud.com
Subject: Re: [PATCH 5 3/4] nfsd_open(): rename 'int access' to 'int
 may_flags' in nfsd_open()
Message-ID: <20120306020819.GH31388@pad.fieldses.org>
References: <20120109132158.2616029.30467.stgit@localhost.localdomain>
 <20120109132153.2616029.26302.stgit@localhost.localdomain>
 <20120306000837.GA17164@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120306000837.GA17164@thunk.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 05, 2012 at 07:08:37PM -0500, Ted Ts'o wrote:
> On Mon, Jan 09, 2012 at 02:21:53PM +0100, Bernd Schubert wrote:
> > Just rename this variable, as the next patch will add a flag and
> > 'access' as variable name would not be correct any more.
> > 
> > Signed-off-by: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
> > Acked-by: J. Bruce Fields<bfields@redhat.com>
> > ---
> >  fs/nfsd/vfs.c |   18 ++++++++++--------
> >  1 files changed, 10 insertions(+), 8 deletions(-)
> 
> On Mon, Jan 09, 2012 at 02:21:58PM +0100, Bernd Schubert wrote:
> > Use 32-bit or 64-bit llseek() hashes for directory offsets depending on
> > the NFS version. NFSv2 gets 32-bit hashes only.
> > 
> > NOTE: This patch got rather complex as Christoph asked to set the
> > filp->f_mode flag in the open call or immediatly after dentry_open()
> > in nfsd_open() to avoid races.
> > Personally I still do not see a reason for that and in my opinion
> > FMODE_32BITHASH/FMODE_64BITHASH flags could be set nfsd_readdir(), as it
> > follows directly after nfsd_open() without a chance of races.
> > 
> > Signed-off-by: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
> > Acked-by: J. Bruce Fields<bfields@redhat.com>
> > ---
> >  fs/nfsd/vfs.c |   15 +++++++++++++--
> >  fs/nfsd/vfs.h |    2 ++
> >  2 files changed, 15 insertions(+), 2 deletions(-)
> 
> NFS folks,
> 
> Since Bruce has ack'ed these patches I assume it will be OK if I carry
> them in the ext4 tree for merging?  (They depend on changes in ext4
> found in the first two patches of these patch series.)

Yes, that would be fine.

(There may well be some conflict: simplest might be if you can get that
pushed out to a stable public branch somewhere, hopefully before the
merge window opens, and that'll give me a chance to pull it and handle
any merge conflicts.

Then as long as your initial pull request goes in early (so that the
ext4 changes don't get sucked in with mine), everything works.)

--b.
