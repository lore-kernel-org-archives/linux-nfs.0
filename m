Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qw0-f42.google.com ([209.85.216.42]:62318 "EHLO
	mail-qw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754760Ab1IKPPH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Sep 2011 11:15:07 -0400
Received: by qwi4 with SMTP id 4so2950551qwi.1
        for <linux-nfs@vger.kernel.org>; Sun, 11 Sep 2011 08:15:05 -0700 (PDT)
Message-ID: <4E6CD076.6050607@tonian.com>
Date: Sun, 11 Sep 2011 08:15:02 -0700
From: Benny Halevy <bhalevy@tonian.com>
To: Jim Rees <rees@umich.edu>, Peng Tao <bergwolf@gmail.com>
CC: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH 2/3] pNFS: introduce pnfs private workqueue
References: <1315676495-3689-1-git-send-email-rees@umich.edu> <1315676495-3689-3-git-send-email-rees@umich.edu> <4E6CCAFB.6070506@tonian.com>
In-Reply-To: <4E6CCAFB.6070506@tonian.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-09-11 07:51, Benny Halevy wrote:
> On 2011-09-10 10:41, Jim Rees wrote:
>> From: Peng Tao <bergwolf@gmail.com>
> 
> Hi, I have a few comments inline below.
> Otherwise, the direction and the patch looks good.
> 
>>
>> For layoutdriver io done functions, default workqueue is not a good place as
>> the code is executed in IO path. So add a pnfs private workqueue to handle
>> them.
>>
>> Also change block and object layout code to make use of this private
>> workqueue.
>>
>> Signed-off-by: Peng Tao <peng_tao@emc.com>
>> Signed-off-by: Jim Rees <rees@umich.edu>
>> ---
>>  fs/nfs/blocklayout/blocklayout.c |   17 ++++++++---
>>  fs/nfs/objlayout/objio_osd.c     |    8 ++++++
>>  fs/nfs/objlayout/objlayout.c     |    4 +-
>>  fs/nfs/pnfs.c                    |   52 +++++++++++++++++++++++++++++++++++++-
>>  fs/nfs/pnfs.h                    |    4 +++
>>  5 files changed, 77 insertions(+), 8 deletions(-)
>>
>> diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
>> index dc23833..51f70f0 100644
>> --- a/fs/nfs/blocklayout/blocklayout.c
>> +++ b/fs/nfs/blocklayout/blocklayout.c
>> @@ -228,7 +228,7 @@ bl_end_par_io_read(void *data)
>>  	struct nfs_read_data *rdata = data;
>>  
>>  	INIT_WORK(&rdata->task.u.tk_work, bl_read_cleanup);
>> -	schedule_work(&rdata->task.u.tk_work);
>> +	pnfsiod_queue_work(&rdata->task.u.tk_work);
>>  }
>>  
>>  /* We don't want normal .rpc_call_done callback used, so we replace it
>> @@ -418,7 +418,7 @@ static void bl_end_par_io_write(void *data)
>>  	wdata->task.tk_status = 0;
>>  	wdata->verf.committed = NFS_FILE_SYNC;
>>  	INIT_WORK(&wdata->task.u.tk_work, bl_write_cleanup);
>> -	schedule_work(&wdata->task.u.tk_work);
>> +	pnfsiod_queue_work(&wdata->task.u.tk_work);
>>  }
>>  
>>  /* FIXME STUB - mark intersection of layout and page as bad, so is not
>> @@ -981,29 +981,35 @@ static int __init nfs4blocklayout_init(void)
>>  	if (ret)
>>  		goto out;
>>  
>> +	ret = pnfsiod_start();
>> +	if (ret)
>> +		goto out_remove;
>> +
>>  	init_waitqueue_head(&bl_wq);
>>  
>>  	mnt = rpc_get_mount();
>>  	if (IS_ERR(mnt)) {
>>  		ret = PTR_ERR(mnt);
>> -		goto out_remove;
>> +		goto out_stop;
>>  	}
>>  
>>  	ret = vfs_path_lookup(mnt->mnt_root,
>>  			      mnt,
>>  			      NFS_PIPE_DIRNAME, 0, &path);
>>  	if (ret)
>> -		goto out_remove;
>> +		goto out_stop;
>>  
>>  	bl_device_pipe = rpc_mkpipe(path.dentry, "blocklayout", NULL,
>>  				    &bl_upcall_ops, 0);
>>  	if (IS_ERR(bl_device_pipe)) {
>>  		ret = PTR_ERR(bl_device_pipe);
>> -		goto out_remove;
>> +		goto out_stop;
>>  	}
>>  out:
>>  	return ret;
>>  
>> +out_stop:
>> +	pnfsiod_stop();
>>  out_remove:
>>  	pnfs_unregister_layoutdriver(&blocklayout_type);
>>  	return ret;
>> @@ -1015,6 +1021,7 @@ static void __exit nfs4blocklayout_exit(void)
>>  	       __func__);
>>  
>>  	pnfs_unregister_layoutdriver(&blocklayout_type);
>> +	pnfsiod_stop();
>>  	rpc_unlink(bl_device_pipe);
>>  }
>>  
>> diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
>> index d0cda12..f28013f 100644
>> --- a/fs/nfs/objlayout/objio_osd.c
>> +++ b/fs/nfs/objlayout/objio_osd.c
>> @@ -1042,7 +1042,14 @@ static int __init
>>  objlayout_init(void)
>>  {
>>  	int ret = pnfs_register_layoutdriver(&objlayout_type);
>> +	if (ret)
>> +		goto out;
>>  
>> +	ret = pnfsiod_start();
>> +	if (ret)
>> +		pnfs_unregister_layoutdriver(&objlayout_type);
>> +
>> +out:

Also, it makes more sense to init the workqueue before registering the
layout driver since it's a prerequisite.

>>  	if (ret)
>>  		printk(KERN_INFO
>>  			"%s: Registering OSD pNFS Layout Driver failed: error=%d\n",
>> @@ -1057,6 +1064,7 @@ static void __exit
>>  objlayout_exit(void)
>>  {
>>  	pnfs_unregister_layoutdriver(&objlayout_type);
>> +	pnfsiod_stop();
>>  	printk(KERN_INFO "%s: Unregistered OSD pNFS Layout Driver\n",
>>  	       __func__);
>>  }
>> diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
>> index 1d06f8e..f7c6c21 100644
>> --- a/fs/nfs/objlayout/objlayout.c
>> +++ b/fs/nfs/objlayout/objlayout.c
>> @@ -305,7 +305,7 @@ objlayout_read_done(struct objlayout_io_state *state, ssize_t status, bool sync)
>>  		pnfs_ld_read_done(rdata);
>>  	else {
>>  		INIT_WORK(&rdata->task.u.tk_work, _rpc_read_complete);
>> -		schedule_work(&rdata->task.u.tk_work);
>> +		pnfsiod_queue_work(&rdata->task.u.tk_work);
>>  	}
>>  }
>>  
>> @@ -396,7 +396,7 @@ objlayout_write_done(struct objlayout_io_state *state, ssize_t status,
>>  		pnfs_ld_write_done(wdata);
>>  	else {
>>  		INIT_WORK(&wdata->task.u.tk_work, _rpc_write_complete);
>> -		schedule_work(&wdata->task.u.tk_work);
>> +		pnfsiod_queue_work(&wdata->task.u.tk_work);
>>  	}
>>  }
>>  
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index e550e88..5ac7a78 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -38,7 +38,7 @@
>>  /* Locking:
>>   *
>>   * pnfs_spinlock:
>> - *      protects pnfs_modules_tbl.
>> + *      protects pnfs_modules_tbl, pnfsiod_workqueue and pnfsiod_users.
>>   */
>>  static DEFINE_SPINLOCK(pnfs_spinlock);
>>  
>> @@ -47,6 +47,9 @@ static DEFINE_SPINLOCK(pnfs_spinlock);
>>   */
>>  static LIST_HEAD(pnfs_modules_tbl);
>>  
>> +static struct workqueue_struct *pnfsiod_workqueue;
>> +static int pnfsiod_users = 0;
> 
> There's no need to initialize static variables to zero.
> 
>> +
>>  /* Return the registered pnfs layout driver module matching given id */
>>  static struct pnfs_layoutdriver_type *
>>  find_pnfs_driver_locked(u32 id)
>> @@ -1478,3 +1481,50 @@ out:
>>  	dprintk("<-- %s status %d\n", __func__, status);
>>  	return status;
>>  }
>> +
>> +/*
>> + * start up the pnfsiod workqueue
>> + */
>> +int pnfsiod_start(void)
>> +{
>> +	struct workqueue_struct *wq;
>> +	dprintk("RPC:       creating workqueue pnfsiod\n");
> 
> hmm, s/RPC/NFS/ this is not the RPC module any more :)
> looks like a cut'n'paste from rpciod_start...
> 
>> +	wq = alloc_workqueue("pnfsiod", WQ_MEM_RECLAIM, 0);
>> +	if (wq == NULL)
>> +		return -ENOMEM;
>> +	spin_lock(&pnfs_spinlock);
>> +	pnfsiod_users++;
>> +	if (pnfsiod_workqueue == NULL) {
>> +		pnfsiod_workqueue = wq;
>> +	} else {
>> +		destroy_workqueue(wq);
>> +	}
> 
> The curly braces in this statement are an overkill
> (and deviation from CodingStyle)
> 
>> +	spin_unlock(&pnfs_spinlock);
>> +	return 0;
> 
> although this way of accounting is ultimately simple
> it's wasteful and since we're not really expecting any concurrent
> calls to this function. I'd consider coding this it as follows:
> 
> 	atomic_inc(&pnfsiod_users);
> 	if (pnfsiod_workqueue == NULL) {
> 		wq = alloc_workqueue("pnfsiod", WQ_MEM_RECLAIM, 0);
> 		if (wq == NULL)

sorry, we need to call nfsiod_stop here.
I'll send a SQUASHME patch with my proposed changes
to this one to make it clearer...

Benny

> 			return -ENOMEM;
> 		spin_lock(&pnfs_spinlock);
> 		if (pnfsiod_workqueue == NULL)
> 			pnfsiod_workqueue = wq;
> 		else
> 			destroy_workqueue(wq);
> 		spin_unlock(&pnfs_spinlock);
> 	}
> 
> 	return 0;
> 
>> +}
>> +EXPORT_SYMBOL_GPL(pnfsiod_start);
>> +
>> +/*
>> + * Destroy the pnfsiod workqueue
>> + */
>> +void pnfsiod_stop(void)
>> +{
>> +	struct workqueue_struct *wq = NULL;
>> +
>> +	spin_lock(&pnfs_spinlock);
>> +	pnfsiod_users--;
>> +	if (pnfsiod_users == 0) {
>> +		wq = pnfsiod_workqueue;
>> +		pnfsiod_workqueue = NULL;
>> +	}
>> +	spin_unlock(&pnfs_spinlock);
>> +	if (wq)
>> +		destroy_workqueue(wq);
> 
> and continuing my proposal from above:
> 
> 	if (atomic_dec_and_lock(&pnfsiod_users)) {
> 		wq = pnfsiod_workqueue;
> 		pnfsiod_workqueue = NULL;
> 		spin_unlock(&pnfs_spinlock);
> 	}
> 	if (wq)
> 		destroy_workqueue(wq);
> 
> Benny
> 
>> +}
>> +EXPORT_SYMBOL_GPL(pnfsiod_stop);
>> +
>> +void pnfsiod_queue_work(struct work_struct* work)
>> +{
>> +	queue_work(pnfsiod_workqueue, work);
>> +}
>> +EXPORT_SYMBOL_GPL(pnfsiod_queue_work);
>> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
>> index 01cbfd5..bc1eed5 100644
>> --- a/fs/nfs/pnfs.h
>> +++ b/fs/nfs/pnfs.h
>> @@ -165,6 +165,10 @@ extern int nfs4_proc_layoutget(struct nfs4_layoutget *lgp);
>>  extern int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp);
>>  
>>  /* pnfs.c */
>> +int pnfsiod_start(void);
>> +void pnfsiod_stop(void);
>> +void pnfsiod_queue_work(struct work_struct* work);
>> +
>>  void get_layout_hdr(struct pnfs_layout_hdr *lo);
>>  void put_lseg(struct pnfs_layout_segment *lseg);
>>  
