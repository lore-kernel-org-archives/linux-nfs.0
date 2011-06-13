Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:48195 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751752Ab1FMOoZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jun 2011 10:44:25 -0400
Received: by yia27 with SMTP id 27so998904yia.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Jun 2011 07:44:25 -0700 (PDT)
In-Reply-To: <ea5e2bf59d726fbfec6f63af9eda83dbc15cb96d.1307921137.git.rees@umich.edu>
References: <cover.1307921137.git.rees@umich.edu>
	<ea5e2bf59d726fbfec6f63af9eda83dbc15cb96d.1307921137.git.rees@umich.edu>
Date: Mon, 13 Jun 2011 10:44:24 -0400
Message-ID: <BANLkTimtiDZNZPnBK6864Rwh-XhDAkcHVQ@mail.gmail.com>
Subject: Re: [PATCH 04/34] pnfs: hook nfs_write_begin/end to allow layout
 driver manipulation
From: Fred Isaman <iisaman@netapp.com>
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, Jun 12, 2011 at 7:43 PM, Jim Rees <rees@umich.edu> wrote:
> From: Peng Tao <bergwolf@gmail.com>
>
> Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> Reported-by: Alexandros Batsakis <batsakis@netapp.com>
> Signed-off-by: Andy Adamson <andros@netapp.com>
> Signed-off-by: Fred Isaman <iisaman@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> Signed-off-by: Peng Tao <bergwolf@gmail.com>
> ---
>  fs/nfs/file.c          |   26 ++++++++++-
>  fs/nfs/pnfs.c          |   41 +++++++++++++++++
>  fs/nfs/pnfs.h          |  115 ++++++++++++++++++++++++++++++++++++++++++++++++
>  fs/nfs/write.c         |   12 +++--
>  include/linux/nfs_fs.h |    3 +-
>  5 files changed, 189 insertions(+), 8 deletions(-)
>
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index 2f093ed..1768762 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -384,12 +384,15 @@ static int nfs_write_begin(struct file *file, struct address_space *mapping,
>        pgoff_t index = pos >> PAGE_CACHE_SHIFT;
>        struct page *page;
>        int once_thru = 0;
> +       struct pnfs_layout_segment *lseg;
>
>        dfprintk(PAGECACHE, "NFS: write_begin(%s/%s(%ld), %u@%lld)\n",
>                file->f_path.dentry->d_parent->d_name.name,
>                file->f_path.dentry->d_name.name,
>                mapping->host->i_ino, len, (long long) pos);
> -
> +       lseg = pnfs_update_layout(mapping->host,
> +                                 nfs_file_open_context(file),
> +                                 pos, len, IOMODE_RW, GFP_NOFS);


This looks like it is left over from before the rearrangements done to
where pnfs_update_layout.
In particular, we don't want to hold the reference on the lseg from
here until flush time.  And there
seems to be no reason to.  If the client needs a layout to deal with
read-in here, it should instead
trigger the nfs_want_read_modify_write clause.

Fred

>  start:
>        /*
>         * Prevent starvation issues if someone is doing a consistency
> @@ -409,6 +412,9 @@ start:
>        if (ret) {
>                unlock_page(page);
>                page_cache_release(page);
> +               *pagep = NULL;
> +               *fsdata = NULL;
> +               goto out;
>        } else if (!once_thru &&
>                   nfs_want_read_modify_write(file, page, pos, len)) {
>                once_thru = 1;
> @@ -417,6 +423,12 @@ start:
>                if (!ret)
>                        goto start;
>        }
> +       ret = pnfs_write_begin(file, page, pos, len, lseg, fsdata);
> + out:
> +       if (ret) {
> +               put_lseg(lseg);
> +               *fsdata = NULL;
> +       }
>        return ret;
>  }
>
> @@ -426,6 +438,7 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
>  {
>        unsigned offset = pos & (PAGE_CACHE_SIZE - 1);
>        int status;
> +       struct pnfs_layout_segment *lseg;
>
>        dfprintk(PAGECACHE, "NFS: write_end(%s/%s(%ld), %u@%lld)\n",
>                file->f_path.dentry->d_parent->d_name.name,
> @@ -452,10 +465,17 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
>                        zero_user_segment(page, pglen, PAGE_CACHE_SIZE);
>        }
>
> -       status = nfs_updatepage(file, page, offset, copied);
> +       lseg = nfs4_pull_lseg_from_fsdata(file, fsdata);
> +       status = pnfs_write_end(file, page, pos, len, copied, lseg);
> +       if (status)
> +               goto out;
> +       status = nfs_updatepage(file, page, offset, copied, lseg, fsdata);
>
> +out:
>        unlock_page(page);
>        page_cache_release(page);
> +       pnfs_write_end_cleanup(file, fsdata);
> +       put_lseg(lseg);
>
>        if (status < 0)
>                return status;
> @@ -577,7 +597,7 @@ static int nfs_vm_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
>
>        ret = VM_FAULT_LOCKED;
>        if (nfs_flush_incompatible(filp, page) == 0 &&
> -           nfs_updatepage(filp, page, 0, pagelen) == 0)
> +           nfs_updatepage(filp, page, 0, pagelen, NULL, NULL) == 0)
>                goto out;
>
>        ret = VM_FAULT_SIGBUS;
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index f03a5e0..e693718 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1138,6 +1138,41 @@ pnfs_try_to_write_data(struct nfs_write_data *wdata,
>  }
>
>  /*
> + * This gives the layout driver an opportunity to read in page "around"
> + * the data to be written.  It returns 0 on success, otherwise an error code
> + * which will either be passed up to user, or ignored if
> + * some previous part of write succeeded.
> + * Note the range [pos, pos+len-1] is entirely within the page.
> + */
> +int _pnfs_write_begin(struct inode *inode, struct page *page,
> +                     loff_t pos, unsigned len,
> +                     struct pnfs_layout_segment *lseg,
> +                     struct pnfs_fsdata **fsdata)
> +{
> +       struct pnfs_fsdata *data;
> +       int status = 0;
> +
> +       dprintk("--> %s: pos=%llu len=%u\n",
> +               __func__, (unsigned long long)pos, len);
> +       data = kzalloc(sizeof(struct pnfs_fsdata), GFP_KERNEL);
> +       if (!data) {
> +               status = -ENOMEM;
> +               goto out;
> +       }
> +       data->lseg = lseg; /* refcount passed into data to be managed there */
> +       status = NFS_SERVER(inode)->pnfs_curr_ld->write_begin(
> +                                               lseg, page, pos, len, data);
> +       if (status) {
> +               kfree(data);
> +               data = NULL;
> +       }
> +out:
> +       *fsdata = data;
> +       dprintk("<-- %s: status=%d\n", __func__, status);
> +       return status;
> +}
> +
> +/*
>  * Called by non rpc-based layout drivers
>  */
>  int
> @@ -1237,6 +1272,12 @@ pnfs_set_layoutcommit(struct nfs_write_data *wdata)
>  }
>  EXPORT_SYMBOL_GPL(pnfs_set_layoutcommit);
>
> +void pnfs_free_fsdata(struct pnfs_fsdata *fsdata)
> +{
> +       /* lseg refcounting handled directly in nfs_write_end */
> +       kfree(fsdata);
> +}
> +
>  /*
>  * For the LAYOUT4_NFSV4_1_FILES layout type, NFS_DATA_SYNC WRITEs and
>  * NFS_UNSTABLE WRITEs with a COMMIT to data servers must store enough
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index a3fc0f2..525ec55 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -54,6 +54,12 @@ enum pnfs_try_status {
>        PNFS_NOT_ATTEMPTED = 1,
>  };
>
> +struct pnfs_fsdata {
> +       struct pnfs_layout_segment *lseg;
> +       int bypass_eof;
> +       void *private;
> +};
> +
>  #ifdef CONFIG_NFS_V4_1
>
>  #define LAYOUT_NFSV4_1_MODULE_PREFIX "nfs-layouttype4"
> @@ -106,6 +112,14 @@ struct pnfs_layoutdriver_type {
>         */
>        enum pnfs_try_status (*read_pagelist) (struct nfs_read_data *nfs_data);
>        enum pnfs_try_status (*write_pagelist) (struct nfs_write_data *nfs_data, int how);
> +       int (*write_begin) (struct pnfs_layout_segment *lseg, struct page *page,
> +                           loff_t pos, unsigned count,
> +                           struct pnfs_fsdata *fsdata);
> +       int (*write_end)(struct inode *inode, struct page *page, loff_t pos,
> +                        unsigned count, unsigned copied,
> +                        struct pnfs_layout_segment *lseg);
> +       void (*write_end_cleanup)(struct file *filp,
> +                                 struct pnfs_fsdata *fsdata);
>
>        void (*free_deviceid_node) (struct nfs4_deviceid_node *);
>
> @@ -175,6 +189,7 @@ enum pnfs_try_status pnfs_try_to_write_data(struct nfs_write_data *,
>  enum pnfs_try_status pnfs_try_to_read_data(struct nfs_read_data *,
>                                            const struct rpc_call_ops *);
>  bool pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev, struct nfs_page *req);
> +void pnfs_free_fsdata(struct pnfs_fsdata *fsdata);
>  int pnfs_layout_process(struct nfs4_layoutget *lgp);
>  void pnfs_free_lseg_list(struct list_head *tmp_list);
>  void pnfs_destroy_layout(struct nfs_inode *);
> @@ -186,6 +201,10 @@ void pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
>  int pnfs_choose_layoutget_stateid(nfs4_stateid *dst,
>                                  struct pnfs_layout_hdr *lo,
>                                  struct nfs4_state *open_state);
> +int _pnfs_write_begin(struct inode *inode, struct page *page,
> +                     loff_t pos, unsigned len,
> +                     struct pnfs_layout_segment *lseg,
> +                     struct pnfs_fsdata **fsdata);
>  int mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
>                                struct list_head *tmp_list,
>                                struct pnfs_layout_range *recall_range);
> @@ -287,6 +306,13 @@ static inline void pnfs_clear_request_commit(struct nfs_page *req)
>                put_lseg(req->wb_commit_lseg);
>  }
>
> +static inline int pnfs_grow_ok(struct pnfs_layout_segment *lseg,
> +                              struct pnfs_fsdata *fsdata)
> +{
> +       return !fsdata  || ((struct pnfs_layout_segment *)fsdata == lseg) ||
> +               !fsdata->bypass_eof;
> +}
> +
>  /* Should the pNFS client commit and return the layout upon a setattr */
>  static inline bool
>  pnfs_ld_layoutret_on_setattr(struct inode *inode)
> @@ -297,6 +323,49 @@ pnfs_ld_layoutret_on_setattr(struct inode *inode)
>                PNFS_LAYOUTRET_ON_SETATTR;
>  }
>
> +static inline int pnfs_write_begin(struct file *filp, struct page *page,
> +                                  loff_t pos, unsigned len,
> +                                  struct pnfs_layout_segment *lseg,
> +                                  void **fsdata)
> +{
> +       struct inode *inode = filp->f_dentry->d_inode;
> +       struct nfs_server *nfss = NFS_SERVER(inode);
> +       int status = 0;
> +
> +       *fsdata = lseg;
> +       if (lseg && nfss->pnfs_curr_ld->write_begin)
> +               status = _pnfs_write_begin(inode, page, pos, len, lseg,
> +                                          (struct pnfs_fsdata **) fsdata);
> +       return status;
> +}
> +
> +/* CAREFUL - what happens if copied < len??? */
> +static inline int pnfs_write_end(struct file *filp, struct page *page,
> +                                loff_t pos, unsigned len, unsigned copied,
> +                                struct pnfs_layout_segment *lseg)
> +{
> +       struct inode *inode = filp->f_dentry->d_inode;
> +       struct nfs_server *nfss = NFS_SERVER(inode);
> +
> +       if (nfss->pnfs_curr_ld && nfss->pnfs_curr_ld->write_end)
> +               return nfss->pnfs_curr_ld->write_end(inode, page, pos, len,
> +                                                    copied, lseg);
> +       else
> +               return 0;
> +}
> +
> +static inline void pnfs_write_end_cleanup(struct file *filp, void *fsdata)
> +{
> +       struct nfs_server *nfss = NFS_SERVER(filp->f_dentry->d_inode);
> +
> +       if (fsdata && nfss->pnfs_curr_ld) {
> +               if (nfss->pnfs_curr_ld->write_end_cleanup)
> +                       nfss->pnfs_curr_ld->write_end_cleanup(filp, fsdata);
> +               if (nfss->pnfs_curr_ld->write_begin)
> +                       pnfs_free_fsdata(fsdata);
> +       }
> +}
> +
>  static inline int pnfs_return_layout(struct inode *ino)
>  {
>        struct nfs_inode *nfsi = NFS_I(ino);
> @@ -317,6 +386,19 @@ static inline void pnfs_pageio_init(struct nfs_pageio_descriptor *pgio,
>                pgio->pg_test = ld->pg_test;
>  }
>
> +static inline struct pnfs_layout_segment *
> +nfs4_pull_lseg_from_fsdata(struct file *filp, void *fsdata)
> +{
> +       if (fsdata) {
> +               struct nfs_server *nfss = NFS_SERVER(filp->f_dentry->d_inode);
> +
> +               if (nfss->pnfs_curr_ld && nfss->pnfs_curr_ld->write_begin)
> +                       return ((struct pnfs_fsdata *) fsdata)->lseg;
> +               return (struct pnfs_layout_segment *)fsdata;
> +       }
> +       return NULL;
> +}
> +
>  #else  /* CONFIG_NFS_V4_1 */
>
>  static inline void pnfs_destroy_all_layouts(struct nfs_client *clp)
> @@ -345,6 +427,12 @@ pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
>        return NULL;
>  }
>
> +static inline int pnfs_grow_ok(struct pnfs_layout_segment *lseg,
> +                              struct pnfs_fsdata *fsdata)
> +{
> +       return 1;
> +}
> +
>  static inline enum pnfs_try_status
>  pnfs_try_to_read_data(struct nfs_read_data *data,
>                      const struct rpc_call_ops *call_ops)
> @@ -364,6 +452,26 @@ static inline int pnfs_return_layout(struct inode *ino)
>        return 0;
>  }
>
> +static inline int pnfs_write_begin(struct file *filp, struct page *page,
> +                                  loff_t pos, unsigned len,
> +                                  struct pnfs_layout_segment *lseg,
> +                                  void **fsdata)
> +{
> +       *fsdata = NULL;
> +       return 0;
> +}
> +
> +static inline int pnfs_write_end(struct file *filp, struct page *page,
> +                                loff_t pos, unsigned len, unsigned copied,
> +                                struct pnfs_layout_segment *lseg)
> +{
> +       return 0;
> +}
> +
> +static inline void pnfs_write_end_cleanup(struct file *filp, void *fsdata)
> +{
> +}
> +
>  static inline bool
>  pnfs_ld_layoutret_on_setattr(struct inode *inode)
>  {
> @@ -435,6 +543,13 @@ static inline int pnfs_layoutcommit_inode(struct inode *inode, bool sync)
>  static inline void nfs4_deviceid_purge_client(struct nfs_client *ncl)
>  {
>  }
> +
> +static inline struct pnfs_layout_segment *
> +nfs4_pull_lseg_from_fsdata(struct file *filp, void *fsdata)
> +{
> +       return NULL;
> +}
> +
>  #endif /* CONFIG_NFS_V4_1 */
>
>  #endif /* FS_NFS_PNFS_H */
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index e268e3b..75e2a6b 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -673,7 +673,9 @@ out:
>  }
>
>  static int nfs_writepage_setup(struct nfs_open_context *ctx, struct page *page,
> -               unsigned int offset, unsigned int count)
> +               unsigned int offset, unsigned int count,
> +               struct pnfs_layout_segment *lseg, void *fsdata)
> +
>  {
>        struct nfs_page *req;
>
> @@ -681,7 +683,8 @@ static int nfs_writepage_setup(struct nfs_open_context *ctx, struct page *page,
>        if (IS_ERR(req))
>                return PTR_ERR(req);
>        /* Update file length */
> -       nfs_grow_file(page, offset, count);
> +       if (pnfs_grow_ok(lseg, fsdata))
> +               nfs_grow_file(page, offset, count);
>        nfs_mark_uptodate(page, req->wb_pgbase, req->wb_bytes);
>        nfs_mark_request_dirty(req);
>        nfs_clear_page_tag_locked(req);
> @@ -734,7 +737,8 @@ static int nfs_write_pageuptodate(struct page *page, struct inode *inode)
>  * things with a page scheduled for an RPC call (e.g. invalidate it).
>  */
>  int nfs_updatepage(struct file *file, struct page *page,
> -               unsigned int offset, unsigned int count)
> +               unsigned int offset, unsigned int count,
> +               struct pnfs_layout_segment *lseg, void *fsdata)
>  {
>        struct nfs_open_context *ctx = nfs_file_open_context(file);
>        struct inode    *inode = page->mapping->host;
> @@ -759,7 +763,7 @@ int nfs_updatepage(struct file *file, struct page *page,
>                offset = 0;
>        }
>
> -       status = nfs_writepage_setup(ctx, page, offset, count);
> +       status = nfs_writepage_setup(ctx, page, offset, count, lseg, fsdata);
>        if (status < 0)
>                nfs_set_pageerror(page);
>
> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
> index 1b93b9c..be1ac1d 100644
> --- a/include/linux/nfs_fs.h
> +++ b/include/linux/nfs_fs.h
> @@ -510,7 +510,8 @@ extern int  nfs_congestion_kb;
>  extern int  nfs_writepage(struct page *page, struct writeback_control *wbc);
>  extern int  nfs_writepages(struct address_space *, struct writeback_control *);
>  extern int  nfs_flush_incompatible(struct file *file, struct page *page);
> -extern int  nfs_updatepage(struct file *, struct page *, unsigned int, unsigned int);
> +extern int  nfs_updatepage(struct file *, struct page *, unsigned int, unsigned int,
> +                       struct pnfs_layout_segment *, void *);
>  extern void nfs_writeback_done(struct rpc_task *, struct nfs_write_data *);
>
>  /*
> --
> 1.7.4.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
