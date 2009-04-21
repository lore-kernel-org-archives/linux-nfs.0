From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [ltt-dev] [PATCH] nfs: add support for splice writes
Date: Tue, 21 Apr 2009 13:35:02 -0400
Message-ID: <1240335302.5390.20.camel@heimdal.trondhjem.org>
References: <49D45974.2060202@suse.de> <20090402063235.GB24846@Krystal>
	 <49D45E42.3050502@suse.de>
	 <91e0b5050904020542l6b38d7a6hab6d7ef8b4593425@mail.gmail.com>
	 <49EC0A83.8060802@suse.de> <1240230224.8073.6.camel@heimdal.trondhjem.org>
	 <49EC6CB3.8080800@suse.de> <1240237274.13636.9.camel@heimdal.trondhjem.org>
	 <49EC990B.1030007@suse.de>  <20090421144810.GA7036@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Suresh Jayaraman <sjayaraman@suse.de>,
	Masahiro Tamori <masahiro.tamori@gmail.com>,
	Mathieu Desnoyers <compudj-vdFpqfd5riKZ9vWoFJJngh2eb7JE58TQ@public.gmane.org>,
	linux-nfs@vger.kernel.org, ltt-dev-33AaDErTWvBVxDZ2/Zk0YoryAYyacSEB@public.gmane.org,
	LKML <linux-kernel@vger.kernel.org>,
	linux-embedded@vger.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:39686 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752330AbZDURfP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Apr 2009 13:35:15 -0400
In-Reply-To: <20090421144810.GA7036@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-04-21 at 10:48 -0400, Christoph Hellwig wrote:
> On Mon, Apr 20, 2009 at 09:17:23PM +0530, Suresh Jayaraman wrote:
> > +static ssize_t nfs_file_splice_write(struct pipe_inode_info *pipe,
> > +				     struct file *filp, loff_t *ppos,
> > +				     size_t count, unsigned int flags)
> > +{
> > +	struct dentry *dentry = filp->f_path.dentry;
> > +
> > +	dprintk("NFS splice_write(%s/%s, %lu@%Lu)\n",
> > +		dentry->d_parent->d_name.name, dentry->d_name.name,
> > +		(unsigned long) count, (unsigned long long) *ppos);
> > +
> > +	return generic_file_splice_write(pipe, filp, ppos, count, flags);
> > +}
> > +
> 
> You need all calls from nfs_file_write, too:
> 
>  - most importantly the nfs_revalidate_file_size for O_APPEND

Isn't O_APPEND illegal for splice_write()? It looks like it is from a
quick perusal of do_splice_from().

>  - the nfs_do_fsync for sync writes

generic_file_splice_write() calls generic_osync_inode(), which should
ensure sync writes even with NFS.
The one thing it won't do is propagate NFS write errors back to the
caller. If we do care about this, then we should certainly test for
nfs_need_sync_write() and then call nfs_do_fsync() (see
nfs_file_write()).

>  - probably the stats increment

We should talk to Chuck about this.

Cheers
  Trond

