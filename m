From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 10/10] gfs2: nfs lock support for gfs2
Date: Thu, 7 Dec 2006 10:23:59 -0500
Message-ID: <20061207152359.GB13613@fieldses.org>
References: <8eb625184e6025f7f3d081dfe0a805abdd62a068.1165380892.git.bfields@citi.umich.edu> <70549752c06e54117024429649fd7aa813f21bec.1165380893.git.bfields@citi.umich.edu> <20061206154951.GB16378@redhat.com> <20061206195722.GH1714@fieldses.org> <20061206205822.GB25322@redhat.com> <4577B912.2030500@almaden.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Teigland <teigland@redhat.com>,
	linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Marc Eshel <eshel@almaden.ibm.com>
In-Reply-To: <4577B912.2030500@almaden.ibm.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Wed, Dec 06, 2006 at 10:47:46PM -0800, Marc Eshel wrote:
> Here is a rewrite of gdlm_plock_callback(). We still need to add the 
> lock cancel.
> Marc.
> 
> int gdlm_plock_callback(struct plock_op *op)
> {
>     struct file *file;
>     struct file_lock *fl;
>     int (*notify)(void *, void *, int) = NULL;
>     int rv;
> 
>    spin_lock(&ops_lock);
>    if (!list_empty(&op->list)) {
>        printk(KERN_INFO "plock op on list\n");
>        list_del(&op->list);
>    }
>    spin_unlock(&ops_lock);
> 
>    rv = op->info.rv;
> 
>    /* check if the following 2 are still valid or make a copy */
>    file = op->info.file;
>    fl = op->info.fl;
>    notify = op->info.callback;
> 
>    if (!rv) { /* got fs lock */
>        rv = posix_lock_file(file, fl);
>        if (rv) { /* did not get posix lock */

If we never request the local lock until after we've gotten the lock
from GFS, then this should never happen.  So I think this could just be
a BUG_ON(rv)--except that would mean a failure in the lock manager could
oops the kernel, so maybe it'd be better just to printk.

--b.
