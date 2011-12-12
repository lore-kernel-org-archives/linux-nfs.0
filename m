Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:24413 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752023Ab1LLXja convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Dec 2011 18:39:30 -0500
Message-ID: <1323733153.13849.17.camel@lade.trondhjem.org>
Subject: Re: ceph, cifs, nfs, fuse: boolean and / or confusion
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: roel <roel.kluin@gmail.com>, LKML <linux-kernel@vger.kernel.org>,
        sage@newdream.net, Steve French <sfrench@samba.org>,
        linux-cifs@vger.kernel.org, Miklos Szeredi <miklos@szeredi.hu>,
        fuse-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org
Date: Mon, 12 Dec 2011 18:39:13 -0500
In-Reply-To: <20111212152856.871a8301.akpm@linux-foundation.org>
References: <4EE688FC.8090606@gmail.com>
	 <20111212152856.871a8301.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2011-12-12 at 15:28 -0800, Andrew Morton wrote: 
> On Tue, 13 Dec 2011 00:06:36 +0100
> roel <roel.kluin@gmail.com> wrote:
> 
> > The test not SEEK_CUR or not SEEK_SET always evaluates to true
> > 
> > Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> > ---
> >  fs/ceph/file.c   |    2 +-
> >  fs/cifs/cifsfs.c |    2 +-
> >  fs/fuse/file.c   |    2 +-
> >  fs/nfs/file.c    |    2 +-
> >  4 files changed, 4 insertions(+), 4 deletions(-)
> > 
<snip> 
> > diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> > index eca56d4..606ef0f 100644
> > --- a/fs/nfs/file.c
> > +++ b/fs/nfs/file.c
> > @@ -147,7 +147,7 @@ static loff_t nfs_file_llseek(struct file *filp, loff_t offset, int origin)
> >  	 * origin == SEEK_END || SEEK_DATA || SEEK_HOLE => we must revalidate
> >  	 * the cached file length
> >  	 */
> > -	if (origin != SEEK_SET || origin != SEEK_CUR) {
> > +	if (origin != SEEK_SET && origin != SEEK_CUR) {
> >  		struct inode *inode = filp->f_mapping->host;
> >  
> >  		int retval = nfs_revalidate_file_size(inode, filp);
> 
> This fix will cause changed runtime behaviour, such as NFS no longer
> running nfs_revalidate_file_size() for all seek modes.

As far as NFS is concerned, it reverts a regression. NFS only used to
run revalidate_file_size() for SEEK_END prior to commit
06222e491e663dac939f04b125c9dc52126a75c4. I accept that we now also need
to run it for SEEK_HOLE and SEEK_DATA, but we've never had to do so for
SEEK_SET and SEEK_CUR.

I suspect the same is true of ceph, cifs etc...

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

