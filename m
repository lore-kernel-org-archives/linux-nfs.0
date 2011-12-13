Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:65198 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753883Ab1LMOfQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Dec 2011 09:35:16 -0500
Date: Tue, 13 Dec 2011 09:34:46 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, roel <roel.kluin@gmail.com>,
        LKML <linux-kernel@vger.kernel.org>, sage@newdream.net,
        Steve French <sfrench@samba.org>, linux-cifs@vger.kernel.org,
        Miklos Szeredi <miklos@szeredi.hu>, fuse-devel@lists.sourceforge.net,
        linux-nfs@vger.kernel.org, josef@redhat.com
Subject: Re: ceph, cifs, nfs, fuse: boolean and / or confusion
Message-ID: <20111213093446.02de1df1@tlielax.poochiereds.net>
In-Reply-To: <1323733153.13849.17.camel@lade.trondhjem.org>
References: <4EE688FC.8090606@gmail.com>
	<20111212152856.871a8301.akpm@linux-foundation.org>
	<1323733153.13849.17.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 12 Dec 2011 18:39:13 -0500
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> On Mon, 2011-12-12 at 15:28 -0800, Andrew Morton wrote: 
> > On Tue, 13 Dec 2011 00:06:36 +0100
> > roel <roel.kluin@gmail.com> wrote:
> > 
> > > The test not SEEK_CUR or not SEEK_SET always evaluates to true
> > > 
> > > Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> > > ---
> > >  fs/ceph/file.c   |    2 +-
> > >  fs/cifs/cifsfs.c |    2 +-
> > >  fs/fuse/file.c   |    2 +-
> > >  fs/nfs/file.c    |    2 +-
> > >  4 files changed, 4 insertions(+), 4 deletions(-)
> > > 
> <snip> 
> > > diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> > > index eca56d4..606ef0f 100644
> > > --- a/fs/nfs/file.c
> > > +++ b/fs/nfs/file.c
> > > @@ -147,7 +147,7 @@ static loff_t nfs_file_llseek(struct file *filp, loff_t offset, int origin)
> > >  	 * origin == SEEK_END || SEEK_DATA || SEEK_HOLE => we must revalidate
> > >  	 * the cached file length
> > >  	 */
> > > -	if (origin != SEEK_SET || origin != SEEK_CUR) {
> > > +	if (origin != SEEK_SET && origin != SEEK_CUR) {
> > >  		struct inode *inode = filp->f_mapping->host;
> > >  
> > >  		int retval = nfs_revalidate_file_size(inode, filp);
> > 
> > This fix will cause changed runtime behaviour, such as NFS no longer
> > running nfs_revalidate_file_size() for all seek modes.
> 
> As far as NFS is concerned, it reverts a regression. NFS only used to
> run revalidate_file_size() for SEEK_END prior to commit
> 06222e491e663dac939f04b125c9dc52126a75c4. I accept that we now also need
> to run it for SEEK_HOLE and SEEK_DATA, but we've never had to do so for
> SEEK_SET and SEEK_CUR.
> 
> I suspect the same is true of ceph, cifs etc...
> 

(cc'ing Josef Bacik on this too, since he made this change originally)

Agreed. The patch looks correct to me for NFS and CIFS at at least.

-- 
Jeff Layton <jlayton@redhat.com>
