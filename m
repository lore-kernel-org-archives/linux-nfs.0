Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:44593 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753214Ab1BOOlO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Feb 2011 09:41:14 -0500
Received: by eye27 with SMTP id 27so101603eye.19
        for <linux-nfs@vger.kernel.org>; Tue, 15 Feb 2011 06:41:13 -0800 (PST)
In-Reply-To: <1297725252.23841.45.camel@heimdal.trondhjem.org>
References: <1297711116-3139-1-git-send-email-andros@netapp.com>
	<1297711116-3139-10-git-send-email-andros@netapp.com>
	<1297725252.23841.45.camel@heimdal.trondhjem.org>
Date: Tue, 15 Feb 2011 09:41:12 -0500
Message-ID: <AANLkTinxqbmWvWXeaPnw7oNtL_zfCYOTB=KjZFJQaKFn@mail.gmail.com>
Subject: Re: [PATCH 09/16] pnfs: wave 3: shift pnfs_update_layout locations
From: Fred Isaman <iisaman@netapp.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: andros@netapp.com, linux-nfs@vger.kernel.org,
        Andy Adamon <andros@citi.umich.edu>,
        Dean Hildebrand <dhildeb@us.ibm.com>,
        Benny Halevy <bhalevy@panasas.com>,
        Boaz Harrosh <bharrosh@panasas.com>,
        Oleg Drokin <green@linuxhacker.ru>, Tao Guo <guotao@nrchpc.ac.cn>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Feb 14, 2011 at 6:14 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> On Mon, 2011-02-14 at 14:18 -0500, andros@netapp.com wrote:
>> From: Fred Isaman <iisaman@netapp.com>
>>
>> Move the pnfs_update_layout call location to nfs_pageio_do_add_request().
>> Grab the lseg sent in the doio function to nfs_read_rpcsetup and attach
>> it to each nfs_read_data so it can be sent to the layout driver.
>>
>> Signed-off-by: Andy Adamon <andros@netapp.com>
>> Signed-off-by: Andy Adamon <andros@citi.umich.edu>
>> Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
>> Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
>> Signed-off-by: Fred Isaman <iisaman@netapp.com>
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
>> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
>> Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
>> ---
>>  fs/nfs/file.c            |    4 ----
>>  fs/nfs/pagelist.c        |   15 ++++++++++++---
>>  fs/nfs/pnfs.c            |    4 ++--
>>  fs/nfs/pnfs.h            |    1 +
>>  fs/nfs/read.c            |   28 ++++++++++++++++------------
>>  fs/nfs/write.c           |    4 ++--
>>  include/linux/nfs_page.h |    5 +++--
>>  include/linux/nfs_xdr.h  |    1 +
>>  8 files changed, 37 insertions(+), 25 deletions(-)
>>
>> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
>> index 7bf029e..d85a534 100644
>> --- a/fs/nfs/file.c
>> +++ b/fs/nfs/file.c
>> @@ -387,10 +387,6 @@ static int nfs_write_begin(struct file *file, struct address_space *mapping,
>>               file->f_path.dentry->d_name.name,
>>               mapping->host->i_ino, len, (long long) pos);
>>
>> -     pnfs_update_layout(mapping->host,
>> -                        nfs_file_open_context(file),
>> -                        IOMODE_RW);
>> -
>>  start:
>>       /*
>>        * Prevent starvation issues if someone is doing a consistency
>> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
>> index e1164e3..e0a0cb4 100644
>> --- a/fs/nfs/pagelist.c
>> +++ b/fs/nfs/pagelist.c
>> @@ -20,6 +20,7 @@
>>  #include <linux/nfs_mount.h>
>>
>>  #include "internal.h"
>> +#include "pnfs.h"
>>
>>  static struct kmem_cache *nfs_page_cachep;
>>
>> @@ -213,7 +214,7 @@ nfs_wait_on_request(struct nfs_page *req)
>>   */
>>  void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
>>                    struct inode *inode,
>> -                  int (*doio)(struct inode *, struct list_head *, unsigned int, size_t, int),
>> +                  int (*doio)(struct inode *, struct list_head *, unsigned int, size_t, int, struct pnfs_layout_segment *),
>>                    size_t bsize,
>>                    int io_flags)
>>  {
>> @@ -226,6 +227,7 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
>>       desc->pg_doio = doio;
>>       desc->pg_ioflags = io_flags;
>>       desc->pg_error = 0;
>> +     desc->pg_lseg = NULL;
>>  }
>>
>>  /**
>> @@ -288,8 +290,13 @@ static int nfs_pageio_do_add_request(struct nfs_pageio_descriptor *desc,
>>               prev = nfs_list_entry(desc->pg_list.prev);
>>               if (!nfs_can_coalesce_requests(prev, req))
>>                       return 0;
>> -     } else
>> +     } else {
>> +             put_lseg(desc->pg_lseg);
>>               desc->pg_base = req->wb_pgbase;
>> +             desc->pg_lseg = pnfs_update_layout(desc->pg_inode,
>> +                                                req->wb_context,
>> +                                                IOMODE_READ);
>
> Looking at this afresh after a week of vacation. Isn't it more natural
> to do this as part of the pg_doio() callback?
>
> Your only reason for introducing the ->pg_lseg pointer is to be able to
> pass it to the ->pg_doio() in the first place. Why not do that by simply
> passing the 'desc' pointer to ->pg_doio(), and then having it call
> pnfs_update_layout() instead of 'get_layout()'?
>

The problem is that it is not the only reason.  Passing the lseg into
the nfs_can_coalesce_requests is another.  Calling pnfs_update_layout
in ->pg_doio would be eliminate the opportunity to have a say in
coalescing based on the layout.


>> +     }
>>       nfs_list_remove_request(req);
>>       nfs_list_add_request(req, &desc->pg_list);
>>       desc->pg_count = newlen;
>> @@ -307,7 +314,8 @@ static void nfs_pageio_doio(struct nfs_pageio_descriptor *desc)
>>                                         nfs_page_array_len(desc->pg_base,
>>                                                            desc->pg_count),
>>                                         desc->pg_count,
>> -                                       desc->pg_ioflags);
>> +                                       desc->pg_ioflags,
>> +                                       desc->pg_lseg);
>>               if (error < 0)
>>                       desc->pg_error = error;
>>               else
>> @@ -345,6 +353,7 @@ int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
>>  void nfs_pageio_complete(struct nfs_pageio_descriptor *desc)
>>  {
>>       nfs_pageio_doio(desc);
>> +     put_lseg(desc->pg_lseg);
>>  }
>>
>>  /**
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index f0a9578..dcd4356 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -264,7 +264,7 @@ put_lseg_locked(struct pnfs_layout_segment *lseg,
>>       return 0;
>>  }
>>
>> -static void
>> +void
>>  put_lseg(struct pnfs_layout_segment *lseg)
>>  {
>>       struct inode *ino;
>> @@ -285,6 +285,7 @@ put_lseg(struct pnfs_layout_segment *lseg)
>>               pnfs_free_lseg_list(&free_me);
>>       }
>>  }
>> +EXPORT_SYMBOL_GPL(put_lseg);
>
> Why is this needed here?
>

That looks like an artifact left over from older code.  It is not needed.

>
>> static bool
>>  should_free_lseg(u32 lseg_iomode, u32 recall_iomode)
>> @@ -797,7 +798,6 @@ pnfs_update_layout(struct inode *ino,
>>  out:
>>       dprintk("%s end, state 0x%lx lseg %p\n", __func__,
>>               nfsi->layout ? nfsi->layout->plh_flags : -1, lseg);
>> -     put_lseg(lseg); /* STUB - callers currently ignore return value */
>>       return lseg;
>>  out_unlock:
>>       spin_unlock(&ino->i_lock);
>> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
>> index 9a994bc..121d6a3 100644
>> --- a/fs/nfs/pnfs.h
>> +++ b/fs/nfs/pnfs.h
>> @@ -146,6 +146,7 @@ extern int nfs4_proc_layoutget(struct nfs4_layoutget *lgp);
>>
>>  /* pnfs.c */
>>  void get_layout_hdr(struct pnfs_layout_hdr *lo);
>> +void put_lseg(struct pnfs_layout_segment *lseg);
>>  struct pnfs_layout_segment *
>>  pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
>>                  enum pnfs_iomode access_type);
>> diff --git a/fs/nfs/read.c b/fs/nfs/read.c
>> index aedcaa7..c453164 100644
>> --- a/fs/nfs/read.c
>> +++ b/fs/nfs/read.c
>> @@ -20,17 +20,17 @@
>>  #include <linux/nfs_page.h>
>>
>>  #include <asm/system.h>
>> +#include "pnfs.h"
>>
>>  #include "nfs4_fs.h"
>>  #include "internal.h"
>>  #include "iostat.h"
>>  #include "fscache.h"
>> -#include "pnfs.h"
>>
>>  #define NFSDBG_FACILITY              NFSDBG_PAGECACHE
>>
>> -static int nfs_pagein_multi(struct inode *, struct list_head *, unsigned int, size_t, int);
>> -static int nfs_pagein_one(struct inode *, struct list_head *, unsigned int, size_t, int);
>> +static int nfs_pagein_multi(struct inode *, struct list_head *, unsigned int, size_t, int, struct pnfs_layout_segment *);
>> +static int nfs_pagein_one(struct inode *, struct list_head *, unsigned int, size_t, int, struct pnfs_layout_segment *);
>>  static const struct rpc_call_ops nfs_read_partial_ops;
>>  static const struct rpc_call_ops nfs_read_full_ops;
>>
>> @@ -70,6 +70,7 @@ void nfs_readdata_free(struct nfs_read_data *p)
>>  static void nfs_readdata_release(struct nfs_read_data *rdata)
>>  {
>>       put_nfs_open_context(rdata->args.context);
>> +     put_lseg(rdata->lseg);
>
> Shouldn't you be calling put_lseg() _before_ put_nfs_open_context()? You
> are not guaranteed that the inode still exists after that call.
>

Yes.

Fred
