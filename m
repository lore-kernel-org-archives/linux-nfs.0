From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 05/39] whiteout/NFSD: Don't return information about
 whiteouts to userspace
Date: Fri, 7 May 2010 07:18:08 +1000
Message-ID: <20100507071808.20028458@notabene.brown>
References: <1272928358-20854-1-git-send-email-vaurora@redhat.com>
	<1272928358-20854-6-git-send-email-vaurora@redhat.com>
	<20100504093731.3a45ff5f@notabene.brown>
	<20100506180151.GA21062@shell>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	Christoph Hellwig <hch@infradead.org>,
	Jan Blunck <jblunck@suse.de>,
	David Woodhouse <dwmw2@infradead.org>,
	linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>
To: Valerie Aurora <vaurora@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:50249 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751026Ab0EFVSU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 May 2010 17:18:20 -0400
In-Reply-To: <20100506180151.GA21062@shell>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 6 May 2010 14:01:51 -0400
Valerie Aurora <vaurora@redhat.com> wrote:

> On Tue, May 04, 2010 at 09:37:31AM +1000, Neil Brown wrote:
> > On Mon,  3 May 2010 16:12:04 -0700
> > Valerie Aurora <vaurora@redhat.com> wrote:
> > 
> > > From: Jan Blunck <jblunck@suse.de>
> > > 
> > > Userspace isn't ready for handling another file type, so silently drop
> > > whiteout directory entries before they leave the kernel.
> > 
> > Feels very intrusive doesn't it....
> > 
> > Have you considered something like the following?
> 
> Hrm, I see how that could be more elegant, but I'd rather avoid yet
> another layer of function pointer passing around.  This code is
> already hard enough to review...

 Yes, the extra indirection is a bit of a negative, but I don't think this
 patch is harder to review than the alternate.
 From a numerical perspective, with this patch you only need to look at the
 various places that ->readdir is called to be sure it is always correct.
 There are about 3.  With the original you need to look at ever filldir
 function.  Jan has found 9.  

 And from a maintainability perspective, I think my approach is safer.  Given
 that there are 9 filldir functions already, the chance that a need will be
 found for another seems good, and the chance that the coder will know to
 check for DT_WHT is a best even.  Conversely if another call to ->readdir
 were added it is likely that nothing would need to be done.

 Of course just counting things doesn't give a completely picture but I think
 it can be indicative.

NeilBrown


> 
> -VAL
> 
> > NeilBrown
> > 
> > diff --git a/fs/readdir.c b/fs/readdir.c
> > index 7723401..4c5b347 100644
> > --- a/fs/readdir.c
> > +++ b/fs/readdir.c
> > @@ -19,10 +19,26 @@
> >  
> >  #include <asm/uaccess.h>
> >  
> > +struct readdir_info {
> > +	filldir_t filler;
> > +	void *data;
> > +};
> > +
> > +static int white_out(void *vrdi, const char *name, int namlen,
> > +		     loff_t offset, u64 ino, unsigned int d_type)
> > +{
> > +	struct readdir_info *rdi = vrdi;
> > +	if (d_type == DT_WHT)
> > +		return 0;
> > +	return rdi->filler(rdi->data, name, namlen, offset, info, d_type);
> > +}
> > +
> >  int vfs_readdir(struct file *file, filldir_t filler, void *buf)
> >  {
> >  	struct inode *inode = file->f_path.dentry->d_inode;
> >  	int res = -ENOTDIR;
> > +	struct readir_info rdi = { filler, buf };
> > +
> >  	if (!file->f_op || !file->f_op->readdir)
> >  		goto out;
> >  
> > @@ -36,7 +52,7 @@ int vfs_readdir(struct file *file, filldir_t filler, void *buf)
> >  
> >  	res = -ENOENT;
> >  	if (!IS_DEADDIR(inode)) {
> > -		res = file->f_op->readdir(file, buf, filler);
> > +		res = file->f_op->readdir(file, &rdi, white_out);
> >  		file_accessed(file);
> >  	}
> >  	mutex_unlock(&inode->i_mutex);

