From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] nfs client: kill compile warning on NOMMU machine
Date: Thu, 05 Feb 2009 08:28:18 -0500
Message-ID: <1233840498.7161.97.camel@heimdal.trondhjem.org>
References: <1225962921-6424-1-git-send-email-cooloney@kernel.org>
	 <386072610902050102r3c3e41a3yfbb424411f2f40dc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Bryan Wu <cooloney@kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64934 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755376AbZBEN2k (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Feb 2009 08:28:40 -0500
In-Reply-To: <386072610902050102r3c3e41a3yfbb424411f2f40dc-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-02-05 at 17:02 +0800, Bryan Wu wrote:
> Hi guys,
> 
> Is it possible to merge this patch?

NACK. Although it would be nice to get rid of the warning, this patch
does so at the price of even further obfuscating the fact that we're
just returning -ENOSYS in the no MMU case, and by causing
nfs_file_vm_ops (which is currently optimised away) to be compiled in
for no good reason at all.

Trond

> Thanks
> -Bryan
> 
> On Thu, Nov 6, 2008 at 5:15 PM, Bryan Wu <cooloney@kernel.org> wrote:
> > On nommu machine such as Blackfin, when compling NFS we got an warning about
> > nfs_file_mmap() function defined but not used.
> >
> > This patch kills this warning.
> >
> > Signed-off-by: Bryan Wu <cooloney@kernel.org>
> > ---
> >  fs/nfs/file.c |   16 ++++++++++++----
> >  1 files changed, 12 insertions(+), 4 deletions(-)
> >
> > diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> > index d319b49..66b8b8e 100644
> > --- a/fs/nfs/file.c
> > +++ b/fs/nfs/file.c
> > @@ -64,11 +64,7 @@ const struct file_operations nfs_file_operations = {
> >        .write          = do_sync_write,
> >        .aio_read       = nfs_file_read,
> >        .aio_write      = nfs_file_write,
> > -#ifdef CONFIG_MMU
> >        .mmap           = nfs_file_mmap,
> > -#else
> > -       .mmap           = generic_file_mmap,
> > -#endif
> >        .open           = nfs_file_open,
> >        .flush          = nfs_file_flush,
> >        .release        = nfs_file_release,
> > @@ -294,6 +290,7 @@ nfs_file_splice_read(struct file *filp, loff_t *ppos,
> >        return res;
> >  }
> >
> > +#ifdef CONFIG_MMU
> >  static int
> >  nfs_file_mmap(struct file * file, struct vm_area_struct * vma)
> >  {
> > @@ -312,6 +309,17 @@ nfs_file_mmap(struct file * file, struct vm_area_struct * vma)
> >        }
> >        return status;
> >  }
> > +#else
> > +static int
> > +nfs_file_mmap(struct file *file, struct vm_area_struct *vma)
> > +{
> > +       /* Kill warning: 'nfs_file_vm_ops' defined but not used */
> > +       struct vm_operations_struct *vm_ops;
> > +       vm_ops = &nfs_file_vm_ops;
> > +
> > +       return generic_file_mmap(file, vma);
> > +}
> > +#endif
> >
> >  /*
> >  * Flush any dirty pages for this process, and check for write errors.
> > --
> > 1.5.6.3
> >
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
