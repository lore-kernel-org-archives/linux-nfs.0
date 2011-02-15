Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47805 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751201Ab1BOPAm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Feb 2011 10:00:42 -0500
Subject: Re: [PATCH 09/16] pnfs: wave 3: shift pnfs_update_layout locations
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Fred Isaman <iisaman@netapp.com>
Cc: andros@netapp.com, linux-nfs@vger.kernel.org,
        Andy Adamon <andros@citi.umich.edu>,
        Dean Hildebrand <dhildeb@us.ibm.com>,
        Benny Halevy <bhalevy@panasas.com>,
        Boaz Harrosh <bharrosh@panasas.com>,
        Oleg Drokin <green@linuxhacker.ru>, Tao Guo <guotao@nrchpc.ac.cn>
In-Reply-To: <AANLkTinxqbmWvWXeaPnw7oNtL_zfCYOTB=KjZFJQaKFn@mail.gmail.com>
References: <1297711116-3139-1-git-send-email-andros@netapp.com>
	 <1297711116-3139-10-git-send-email-andros@netapp.com>
	 <1297725252.23841.45.camel@heimdal.trondhjem.org>
	 <AANLkTinxqbmWvWXeaPnw7oNtL_zfCYOTB=KjZFJQaKFn@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 15 Feb 2011 10:00:40 -0500
Message-ID: <1297782040.10103.10.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2011-02-15 at 09:41 -0500, Fred Isaman wrote: 
> On Mon, Feb 14, 2011 at 6:14 PM, Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> > On Mon, 2011-02-14 at 14:18 -0500, andros@netapp.com wrote:
> >> From: Fred Isaman <iisaman@netapp.com>
> >>
> >> Move the pnfs_update_layout call location to nfs_pageio_do_add_request().
> >> Grab the lseg sent in the doio function to nfs_read_rpcsetup and attach
> >> it to each nfs_read_data so it can be sent to the layout driver.
> >>
> >> Signed-off-by: Andy Adamon <andros@netapp.com>
> >> Signed-off-by: Andy Adamon <andros@citi.umich.edu>
> >> Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
> >> Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
> >> Signed-off-by: Fred Isaman <iisaman@netapp.com>
> >> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> >> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> >> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
> >> Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
> >> ---
> >>  fs/nfs/file.c            |    4 ----
> >>  fs/nfs/pagelist.c        |   15 ++++++++++++---
> >>  fs/nfs/pnfs.c            |    4 ++--
> >>  fs/nfs/pnfs.h            |    1 +
> >>  fs/nfs/read.c            |   28 ++++++++++++++++------------
> >>  fs/nfs/write.c           |    4 ++--
> >>  include/linux/nfs_page.h |    5 +++--
> >>  include/linux/nfs_xdr.h  |    1 +
> >>  8 files changed, 37 insertions(+), 25 deletions(-)
> >>
> >> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> >> index 7bf029e..d85a534 100644
> >> --- a/fs/nfs/file.c
> >> +++ b/fs/nfs/file.c
> >> @@ -387,10 +387,6 @@ static int nfs_write_begin(struct file *file, struct address_space *mapping,
> >>               file->f_path.dentry->d_name.name,
> >>               mapping->host->i_ino, len, (long long) pos);
> >>
> >> -     pnfs_update_layout(mapping->host,
> >> -                        nfs_file_open_context(file),
> >> -                        IOMODE_RW);
> >> -
> >>  start:
> >>       /*
> >>        * Prevent starvation issues if someone is doing a consistency
> >> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
> >> index e1164e3..e0a0cb4 100644
> >> --- a/fs/nfs/pagelist.c
> >> +++ b/fs/nfs/pagelist.c
> >> @@ -20,6 +20,7 @@
> >>  #include <linux/nfs_mount.h>
> >>
> >>  #include "internal.h"
> >> +#include "pnfs.h"
> >>
> >>  static struct kmem_cache *nfs_page_cachep;
> >>
> >> @@ -213,7 +214,7 @@ nfs_wait_on_request(struct nfs_page *req)
> >>   */
> >>  void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
> >>                    struct inode *inode,
> >> -                  int (*doio)(struct inode *, struct list_head *, unsigned int, size_t, int),
> >> +                  int (*doio)(struct inode *, struct list_head *, unsigned int, size_t, int, struct pnfs_layout_segment *),
> >>                    size_t bsize,
> >>                    int io_flags)
> >>  {
> >> @@ -226,6 +227,7 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
> >>       desc->pg_doio = doio;
> >>       desc->pg_ioflags = io_flags;
> >>       desc->pg_error = 0;
> >> +     desc->pg_lseg = NULL;
> >>  }
> >>
> >>  /**
> >> @@ -288,8 +290,13 @@ static int nfs_pageio_do_add_request(struct nfs_pageio_descriptor *desc,
> >>               prev = nfs_list_entry(desc->pg_list.prev);
> >>               if (!nfs_can_coalesce_requests(prev, req))
> >>                       return 0;
> >> -     } else
> >> +     } else {
> >> +             put_lseg(desc->pg_lseg);
> >>               desc->pg_base = req->wb_pgbase;
> >> +             desc->pg_lseg = pnfs_update_layout(desc->pg_inode,
> >> +                                                req->wb_context,
> >> +                                                IOMODE_READ);
> >
> > Looking at this afresh after a week of vacation. Isn't it more natural
> > to do this as part of the pg_doio() callback?
> >
> > Your only reason for introducing the ->pg_lseg pointer is to be able to
> > pass it to the ->pg_doio() in the first place. Why not do that by simply
> > passing the 'desc' pointer to ->pg_doio(), and then having it call
> > pnfs_update_layout() instead of 'get_layout()'?
> >
> 
> The problem is that it is not the only reason.  Passing the lseg into
> the nfs_can_coalesce_requests is another.  Calling pnfs_update_layout
> in ->pg_doio would be eliminate the opportunity to have a say in
> coalescing based on the layout.

The point is that you are adding intimate knowledge of layouts to sites
like nfs_pageio_do_add_request and nfs_pageio_complete, and then on top
of that adding callbacks whose sole purpose is to support layouts.

A better approach is to keep the layouts in the callbacks (i.e. pg_test
and pg_doio). I don't care if you cache the layout in a pg_lseg field,
but I do object to the proliferation of layout knowledge in places where
we don't need it.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

