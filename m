Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:25113 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753391Ab0IWHqw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Sep 2010 03:46:52 -0400
Message-ID: <4C9B05E9.5080303@panasas.com>
Date: Thu, 23 Sep 2010 09:46:49 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Fred Isaman <iisaman@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] SQUASHME: pnfs: get layout in proper segments.
References: <1285095654-32401-1-git-send-email-bhalevy@panasas.com> <AANLkTi=mSWun+tEOrjGUsuc2gs_79K2+NCUOrXJoaMeW@mail.gmail.com>
In-Reply-To: <AANLkTi=mSWun+tEOrjGUsuc2gs_79K2+NCUOrXJoaMeW@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-09-21 21:25, Fred Isaman wrote:
> On Tue, Sep 21, 2010 at 3:00 PM, Benny Halevy <bhalevy@panasas.com> wrote:
>> Base the LAYOUTGET arguments on the actual required byte ranges
>> rather than asking for the whole file layout.
>>
>> Add a check in readpage_async_filler that the layout segment
>> retrieved in pnfs_pageio_init_read still covers the current page
>> and if not, try getting a new one.
>>
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfs/file.c |    2 +-
>>  fs/nfs/pnfs.c |   13 ++++++-------
>>  fs/nfs/pnfs.h |   21 ++++++++-------------
>>  fs/nfs/read.c |   17 ++++++++++++++++-
>>  4 files changed, 31 insertions(+), 22 deletions(-)
>>
>> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
>> index b05c1ff..228f41e 100644
>> --- a/fs/nfs/file.c
>> +++ b/fs/nfs/file.c
>> @@ -390,7 +390,7 @@ static int nfs_write_begin(struct file *file, struct address_space *mapping,
>>
>>        pnfs_update_layout(mapping->host,
>>                           nfs_file_open_context(file),
>> -                          0, NFS4_MAX_UINT64, IOMODE_RW,
>> +                          pos, len, IOMODE_RW,
>>                           &lseg);
>>  start:
>>        /*
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index e6261a3..de716f6 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -600,11 +600,10 @@ send_layoutget(struct inode *ino,
>>                pnfs_layout_release(lo, NULL);
>>                return -ENOMEM;
>>        }
>> -       lgp->args.minlength = NFS4_MAX_UINT64;
>> +       lgp->args.minlength = PAGE_CACHE_SIZE -
>> +                               (range->offset & (PAGE_CACHE_SIZE-1));
>>        lgp->args.maxcount = PNFS_LAYOUT_MAXSIZE;
>> -       lgp->args.range.iomode = range->iomode;
>> -       lgp->args.range.offset = 0;
>> -       lgp->args.range.length = NFS4_MAX_UINT64;
>> +       lgp->args.range = *range;
>>        lgp->args.type = server->pnfs_curr_ld->id;
>>        lgp->args.inode = ino;
>>        lgp->lsegpp = lsegpp;
>> @@ -1028,8 +1027,8 @@ _pnfs_update_layout(struct inode *ino,
>>  {
>>        struct pnfs_layout_range arg = {
>>                .iomode = iomode,
>> -               .offset = 0,
>> -               .length = NFS4_MAX_UINT64,
>> +               .offset = pos,
>> +               .length = count,
>>        };
>>        struct nfs_inode *nfsi = NFS_I(ino);
>>        struct pnfs_layout_hdr *lo;
>> @@ -1330,7 +1329,7 @@ pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
>>        readahead_range(inode, pages, &loff, &count);
>>
>>        if (count > 0) {
>> -               _pnfs_update_layout(inode, ctx, loff, count, IOMODE_READ,
>> +               pnfs_update_layout(inode, ctx, loff, count, IOMODE_READ,
> 
> 
> Why this change?  the pnfs_enabled_sb check has already been done at
> the top of the function, hasn't it?
> 

Actually, it's for the dprintk, but this is not crucial.

> 
>>                                    &pgio->pg_lseg);
>>                if (!pgio->pg_lseg)
>>                        return;
>> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
>> index 81534aa..b666f53 100644
>> --- a/fs/nfs/pnfs.h
>> +++ b/fs/nfs/pnfs.h
>> @@ -188,19 +188,14 @@ static inline int pnfs_return_layout(struct inode *ino,
>>        return 0;
>>  }
>>
>> -static inline void pnfs_update_layout(struct inode *ino,
>> -       struct nfs_open_context *ctx,
>> -       loff_t pos, u64 count, enum pnfs_iomode access_type,
>> -       struct pnfs_layout_segment **lsegpp)
>> -{
>> -       struct nfs_server *nfss = NFS_SERVER(ino);
>> -
>> -       if (pnfs_enabled_sb(nfss))
>> -               _pnfs_update_layout(ino, ctx, pos, count, access_type, lsegpp);
>> -       else {
>> -               if (lsegpp)
>> -                       *lsegpp = NULL;
>> -       }
>> +#define pnfs_update_layout(ino, ctx, pos, count, access_type, lsegpp) { \
>> +       if (pnfs_enabled_sb(NFS_SERVER(ino))) { \
>> +               dprintk("%s: updating %s layout pos %llu count %llu\n", __func__, \
>> +                       (access_type) == IOMODE_READ ? "READ" : "WRITE", \
>> +                       (unsigned long long)(pos), (unsigned long long)(count)); \
>> +               _pnfs_update_layout(ino, ctx, pos, count, access_type, lsegpp); \
>> +       } else \
>> +               *lsegpp = NULL; \
>>  }
> 
> 
> Why this change?  I much prefer the inline version to the define, and
> I thought that this was generally being pushed.
> 

dprintk again.
I think I'll just do this as a debug-only patch, just so we have the extra debugging
in the development tree.

> 
>>
>>  static inline int pnfs_get_write_status(struct nfs_write_data *data)
>> diff --git a/fs/nfs/read.c b/fs/nfs/read.c
>> index dde7996..36eef5e 100644
>> --- a/fs/nfs/read.c
>> +++ b/fs/nfs/read.c
>> @@ -121,12 +121,14 @@ int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
>>        LIST_HEAD(one_request);
>>        struct nfs_page *new;
>>        unsigned int len;
>> +       loff_t pgoffs;
>>        struct pnfs_layout_segment *lseg;
>>
>>        len = nfs_page_length(page);
>>        if (len == 0)
>>                return nfs_return_empty_page(page);
>> -       pnfs_update_layout(inode, ctx, 0, NFS4_MAX_UINT64, IOMODE_READ, &lseg);
>> +       pgoffs = (loff_t)page->index << PAGE_CACHE_SHIFT;
>> +       pnfs_update_layout(inode, ctx, pgoffs, len, IOMODE_READ, &lseg);
>>        new = nfs_create_request(ctx, inode, page, 0, len, lseg);
>>        put_lseg(lseg);
>>        if (IS_ERR(new)) {
>> @@ -603,14 +605,27 @@ readpage_async_filler(void *data, struct page *page)
>>  {
>>        struct nfs_readdesc *desc = (struct nfs_readdesc *)data;
>>        struct inode *inode = page->mapping->host;
>> +       struct pnfs_layout_range *range;
>>        struct nfs_page *new;
>>        unsigned int len;
>> +       loff_t pgoff;
>>        int error;
>>
>>        len = nfs_page_length(page);
>>        if (len == 0)
>>                return nfs_return_empty_page(page);
>>
>> +       pgoff = (loff_t)page->index << PAGE_CACHE_SHIFT;
>> +       range = desc->pgio->pg_lseg ? &desc->pgio->pg_lseg->range : NULL;
>> +       if (!range ||
>> +           (range->offset > pgoff + len) ||
>> +           (range->offset + range->length < pgoff)) {
>> +               put_lseg(desc->pgio->pg_lseg);
>> +               desc->pgio->pg_lseg = NULL;
>> +               pnfs_update_layout(inode, desc->ctx, pgoff, len, IOMODE_READ,
>> +                                  &desc->pgio->pg_lseg);
>> +       }
>> +
>>        new = nfs_create_request(desc->ctx, inode, page, 0, len,
>>                                 desc->pgio->pg_lseg);
>>        if (IS_ERR(new))
>> --
> 
> 
> Wouldn't it be easier to just trim any returned layout to page
> boundaries, and then pnfs_can_coalesce_requests will handle this
> automatically.

Trimming the returned layout to page boundaries sounds like a good idea,
but in this case it's not the page alignment I'm worried about, but
working in layout segments in general.  The first segment we end with
after pnfs_pageio_init_read and that we store in desc->pgio->pg_lseg
may cover only part of the whole I/O so we need this check to see if
it's exhausted and we need another layout segment to continue, otherwise
we'll be using a layout segment that does not cover the page in hand.

Benny

> 
> Fred
> 
>> 1.7.2.3
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
