Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:62383 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754021Ab1JKCcK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Oct 2011 22:32:10 -0400
Received: by ywb5 with SMTP id 5so6037713ywb.19
        for <linux-nfs@vger.kernel.org>; Mon, 10 Oct 2011 19:32:10 -0700 (PDT)
Message-ID: <4E8F31A4.6050504@tonian.com>
Date: Fri, 07 Oct 2011 13:06:44 -0400
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@panasas.com>, Brent Welch <welch@panasas.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: Re: [PATCH 14/19] pnfs-obj: Return PNFS_NOT_ATTEMPTED in case of
 read/write_pagelist
References: <4E8ADEDA.4050709@panasas.com> <1317724520-27734-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <1317724520-27734-1-git-send-email-bharrosh@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-10-04 06:35, Boaz Harrosh wrote:
> objlayout driver was always returning PNFS_ATTEMPTED from it's
> read/write_pagelist operations. Even on error. Fix that.
> 
> Start by establishing an error return API from io-engine, by
> not returning ssize_t (length-or-error) but returning "int"
> 0=OK, 0>Error. And clean up all return types in io-engine.
> 
> Then if io-engine returned error return PNFS_NOT_ATTEMPTED
> to generic layer. (With a dprint)
> 
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>

Looks good to me!

Reviewed-by: Benny Halevy <bhalevy@tonian.com>

> ---
>  fs/nfs/objlayout/objio_osd.c |   32 ++++++++++++++++----------------
>  fs/nfs/objlayout/objlayout.c |   36 +++++++++++++++++++-----------------
>  fs/nfs/objlayout/objlayout.h |    4 ++--
>  3 files changed, 37 insertions(+), 35 deletions(-)
> 
> diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
> index d0cda12..0c7c9ec 100644
> --- a/fs/nfs/objlayout/objio_osd.c
> +++ b/fs/nfs/objlayout/objio_osd.c
> @@ -142,7 +142,7 @@ OBJIO_LSEG(struct pnfs_layout_segment *lseg)
>  }
>  
>  struct objio_state;
> -typedef ssize_t (*objio_done_fn)(struct objio_state *ios);
> +typedef int (*objio_done_fn)(struct objio_state *ios);
>  
>  struct objio_state {
>  	/* Generic layer */
> @@ -720,7 +720,7 @@ out:
>  	return 0;
>  }
>  
> -static ssize_t _sync_done(struct objio_state *ios)
> +static int _sync_done(struct objio_state *ios)
>  {
>  	struct completion *waiting = ios->private;
>  
> @@ -742,10 +742,10 @@ static void _done_io(struct osd_request *or, void *p)
>  	kref_put(&ios->kref, _last_io);
>  }
>  
> -static ssize_t _io_exec(struct objio_state *ios)
> +static int _io_exec(struct objio_state *ios)
>  {
>  	DECLARE_COMPLETION_ONSTACK(wait);
> -	ssize_t status = 0; /* sync status */
> +	int ret = 0;
>  	unsigned i;
>  	objio_done_fn saved_done_fn = ios->done;
>  	bool sync = ios->ol_state.sync;
> @@ -771,16 +771,16 @@ static ssize_t _io_exec(struct objio_state *ios)
>  
>  	if (sync) {
>  		wait_for_completion(&wait);
> -		status = saved_done_fn(ios);
> +		ret = saved_done_fn(ios);
>  	}
>  
> -	return status;
> +	return ret;
>  }
>  
>  /*
>   * read
>   */
> -static ssize_t _read_done(struct objio_state *ios)
> +static int _read_done(struct objio_state *ios)
>  {
>  	ssize_t status;
>  	int ret = _io_check(ios, false);
> @@ -793,7 +793,7 @@ static ssize_t _read_done(struct objio_state *ios)
>  		status = ret;
>  
>  	objlayout_read_done(&ios->ol_state, status, ios->ol_state.sync);
> -	return status;
> +	return ret;
>  }
>  
>  static int _read_mirrors(struct objio_state *ios, unsigned cur_comp)
> @@ -833,7 +833,7 @@ err:
>  	return ret;
>  }
>  
> -static ssize_t _read_exec(struct objio_state *ios)
> +static int _read_exec(struct objio_state *ios)
>  {
>  	unsigned i;
>  	int ret;
> @@ -847,14 +847,14 @@ static ssize_t _read_exec(struct objio_state *ios)
>  	}
>  
>  	ios->done = _read_done;
> -	return _io_exec(ios); /* In sync mode exec returns the io status */
> +	return _io_exec(ios);
>  
>  err:
>  	_io_free(ios);
>  	return ret;
>  }
>  
> -ssize_t objio_read_pagelist(struct objlayout_io_state *ol_state)
> +int objio_read_pagelist(struct objlayout_io_state *ol_state)
>  {
>  	struct objio_state *ios = container_of(ol_state, struct objio_state,
>  					       ol_state);
> @@ -870,7 +870,7 @@ ssize_t objio_read_pagelist(struct objlayout_io_state *ol_state)
>  /*
>   * write
>   */
> -static ssize_t _write_done(struct objio_state *ios)
> +static int _write_done(struct objio_state *ios)
>  {
>  	ssize_t status;
>  	int ret = _io_check(ios, true);
> @@ -887,7 +887,7 @@ static ssize_t _write_done(struct objio_state *ios)
>  	}
>  
>  	objlayout_write_done(&ios->ol_state, status, ios->ol_state.sync);
> -	return status;
> +	return ret;
>  }
>  
>  static int _write_mirrors(struct objio_state *ios, unsigned cur_comp)
> @@ -955,7 +955,7 @@ err:
>  	return ret;
>  }
>  
> -static ssize_t _write_exec(struct objio_state *ios)
> +static int _write_exec(struct objio_state *ios)
>  {
>  	unsigned i;
>  	int ret;
> @@ -969,14 +969,14 @@ static ssize_t _write_exec(struct objio_state *ios)
>  	}
>  
>  	ios->done = _write_done;
> -	return _io_exec(ios); /* In sync mode exec returns the io->status */
> +	return _io_exec(ios);
>  
>  err:
>  	_io_free(ios);
>  	return ret;
>  }
>  
> -ssize_t objio_write_pagelist(struct objlayout_io_state *ol_state, bool stable)
> +int objio_write_pagelist(struct objlayout_io_state *ol_state, bool stable)
>  {
>  	struct objio_state *ios = container_of(ol_state, struct objio_state,
>  					       ol_state);
> diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
> index 1300736..99c807d 100644
> --- a/fs/nfs/objlayout/objlayout.c
> +++ b/fs/nfs/objlayout/objlayout.c
> @@ -315,16 +315,13 @@ objlayout_read_pagelist(struct nfs_read_data *rdata)
>  	loff_t offset = rdata->args.offset;
>  	size_t count = rdata->args.count;
>  	struct objlayout_io_state *state;
> -	ssize_t status = 0;
> +	int err;
>  	loff_t eof;
>  
> -	dprintk("%s: Begin inode %p offset %llu count %d\n",
> -		__func__, rdata->inode, offset, (int)count);
> -
>  	eof = i_size_read(rdata->inode);
>  	if (unlikely(offset + count > eof)) {
>  		if (offset >= eof) {
> -			status = 0;
> +			err = 0;
>  			rdata->res.count = 0;
>  			rdata->res.eof = 1;
>  			/*FIXME: do we need to call pnfs_ld_read_done() */
> @@ -341,14 +338,19 @@ objlayout_read_pagelist(struct nfs_read_data *rdata)
>  					 rdata->lseg, rdata,
>  					 GFP_KERNEL);
>  	if (unlikely(!state)) {
> -		status = -ENOMEM;
> +		err = -ENOMEM;
>  		goto out;
>  	}
> +	dprintk("%s: inode(%lx) offset 0x%llx count 0x%Zx eof=%d\n",
> +		__func__, rdata->inode->i_ino, offset, count, rdata->res.eof);
>  
> -	status = objio_read_pagelist(state);
> +	err = objio_read_pagelist(state);
>   out:
> -	dprintk("%s: Return status %Zd\n", __func__, status);
> -	rdata->pnfs_error = status;
> +	if (unlikely(err)) {
> +		rdata->pnfs_error = err;
> +		dprintk("%s: Returned Error %d\n", __func__, err);
> +		return PNFS_NOT_ATTEMPTED;
> +	}
>  	return PNFS_ATTEMPTED;
>  }
>  
> @@ -406,10 +408,7 @@ objlayout_write_pagelist(struct nfs_write_data *wdata,
>  			 int how)
>  {
>  	struct objlayout_io_state *state;
> -	ssize_t status;
> -
> -	dprintk("%s: Begin inode %p offset %llu count %u\n",
> -		__func__, wdata->inode, wdata->args.offset, wdata->args.count);
> +	int err;
>  
>  	state = objlayout_alloc_io_state(NFS_I(wdata->inode)->layout,
>  					 wdata->args.pages,
> @@ -419,16 +418,19 @@ objlayout_write_pagelist(struct nfs_write_data *wdata,
>  					 wdata->lseg, wdata,
>  					 GFP_NOFS);
>  	if (unlikely(!state)) {
> -		status = -ENOMEM;
> +		err = -ENOMEM;
>  		goto out;
>  	}
>  
>  	state->sync = how & FLUSH_SYNC;
>  
> -	status = objio_write_pagelist(state, how & FLUSH_STABLE);
> +	err = objio_write_pagelist(state, how & FLUSH_STABLE);
>   out:
> -	dprintk("%s: Return status %Zd\n", __func__, status);
> -	wdata->pnfs_error = status;
> +	if (unlikely(err)) {
> +		wdata->pnfs_error = err;
> +		dprintk("%s: Returned Error %d\n", __func__, err);
> +		return PNFS_NOT_ATTEMPTED;
> +	}
>  	return PNFS_ATTEMPTED;
>  }
>  
> diff --git a/fs/nfs/objlayout/objlayout.h b/fs/nfs/objlayout/objlayout.h
> index ffb884c..4edac9b 100644
> --- a/fs/nfs/objlayout/objlayout.h
> +++ b/fs/nfs/objlayout/objlayout.h
> @@ -115,8 +115,8 @@ extern int objio_alloc_io_state(
>  	gfp_t gfp_flags);
>  extern void objio_free_io_state(struct objlayout_io_state *state);
>  
> -extern ssize_t objio_read_pagelist(struct objlayout_io_state *ol_state);
> -extern ssize_t objio_write_pagelist(struct objlayout_io_state *ol_state,
> +extern int objio_read_pagelist(struct objlayout_io_state *ol_state);
> +extern int objio_write_pagelist(struct objlayout_io_state *ol_state,
>  				    bool stable);
>  
>  /*
