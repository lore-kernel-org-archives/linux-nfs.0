From: Marc Eshel <eshel@almaden.ibm.com>
Subject: Re: [NFS] [PATCH 10/10] gfs2: nfs lock support for gfs2
Date: Thu, 7 Dec 2006 07:43:48 -0800
Message-ID: <OF3AAB0892.7839D917-ON8825723D.0055EEC9-8825723D.00563276@us.ibm.com>
References: <20061207152359.GB13613@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	David Teigland <teigland@redhat.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20061207152359.GB13613@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

nfs-bounces@lists.sourceforge.net wrote on 12/07/2006 07:23:59 AM:

> On Wed, Dec 06, 2006 at 10:47:46PM -0800, Marc Eshel wrote:
> > Here is a rewrite of gdlm_plock_callback(). We still need to add the 
> > lock cancel.
> > Marc.
> > 
> > int gdlm_plock_callback(struct plock_op *op)
> > {
> >     struct file *file;
> >     struct file_lock *fl;
> >     int (*notify)(void *, void *, int) = NULL;
> >     int rv;
> > 
> >    spin_lock(&ops_lock);
> >    if (!list_empty(&op->list)) {
> >        printk(KERN_INFO "plock op on list\n");
> >        list_del(&op->list);
> >    }
> >    spin_unlock(&ops_lock);
> > 
> >    rv = op->info.rv;
> > 
> >    /* check if the following 2 are still valid or make a copy */
> >    file = op->info.file;
> >    fl = op->info.fl;
> >    notify = op->info.callback;
> > 
> >    if (!rv) { /* got fs lock */
> >        rv = posix_lock_file(file, fl);
> >        if (rv) { /* did not get posix lock */
> 
> If we never request the local lock until after we've gotten the lock
> from GFS, then this should never happen.  So I think this could just be
> a BUG_ON(rv)--except that would mean a failure in the lock manager could
> oops the kernel, so maybe it'd be better just to printk.

It can happen if you can not allocate memory. 
Marc.

> 
> --b.
> 
> 
-------------------------------------------------------------------------
> Take Surveys. Earn Cash. Influence the Future of IT
> Join SourceForge.net's Techsay panel and you'll get the chance to share 
your
> opinions on IT & business topics through brief surveys - and earn cash
> 
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

