Return-Path: <bfields@fieldses.org>
Date: Thu, 23 Jul 2015 15:21:19 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>, linux-nfs@vger.kernel.org,
        Benjamin Coddington <bcodding@redhat.com>
Subject: Re: [PATCH] NFSv4.2: handle NFS-specific llseek errors
Message-ID: <20150723192119.GD14362@fieldses.org>
References: <20150723150843.GA12894@fieldses.org>
 <55B10763.3020203@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55B10763.3020203@Netapp.com>
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 23, 2015 at 11:25:23AM -0400, Anna Schumaker wrote:
> Hi Bruce,
> 
> On 07/23/2015 11:08 AM, J. Bruce Fields wrote:
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > Handle NFS-specific llseek errors instead of letting them leak out to
> > userspace.
> > 
> > Reported-by: Benjamin Coddington <bcodding@redhat.com>
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > ---
> >  fs/nfs/nfs42proc.c | 19 ++++++++++++++++++-
> >  1 file changed, 18 insertions(+), 1 deletion(-)
> > 
> > I don't actually have a test case for this, but it looks right....
> > 
> > diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
> > index f486b80f927a..2fec410bc50f 100644
> > --- a/fs/nfs/nfs42proc.c
> > +++ b/fs/nfs/nfs42proc.c
> > @@ -135,7 +135,7 @@ int nfs42_proc_deallocate(struct file *filep, loff_t offset, loff_t len)
> >  	return err;
> >  }
> >  
> > -loff_t nfs42_proc_llseek(struct file *filep, loff_t offset, int whence)
> > +loff_t _nfs42_proc_llseek(struct file *filep, loff_t offset, int whence)
> >  {
> >  	struct inode *inode = file_inode(filep);
> >  	struct nfs42_seek_args args = {
> > @@ -171,6 +171,23 @@ loff_t nfs42_proc_llseek(struct file *filep, loff_t offset, int whence)
> >  	return vfs_setpos(filep, res.sr_offset, inode->i_sb->s_maxbytes);
> >  }
> >  
> > +loff_t nfs42_proc_llseek(struct file *filep, loff_t offset, int whence)
> > +{
> > +	struct nfs_server *server = NFS_SERVER(file_inode(filep));
> > +	struct nfs4_exception exception = { };
> > +	int err;
> 
> Can you move the nfs_server_capable() check to before the do {} while loop?  I think it's cleaner if we check for support before ever trying to call _nfs42_proc_llseek().

I believe the results of that check can change on subsequent iterations,
due to a concurrent SEEK returning NOTSUPP.

The code would be correct either way, because the nfs_server_capable()
check is really just an optimization--it should always be OK just to
send the SEEK and then handle the NOTSUPP reply.

But accidentally sending an unnecessary rpc is much more expensive than
checking a flag, so the code's probably best left as is.

(Also, this is the way it's done elsewhere in nfs{4,42}proc.c, so if
there's some reason to change we'd want to do that everywhere.)

--b.
