Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f179.google.com ([209.85.192.179]:65407 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750932AbaDOFDR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Apr 2014 01:03:17 -0400
Received: by mail-pd0-f179.google.com with SMTP id w10so8896180pde.24
        for <linux-nfs@vger.kernel.org>; Mon, 14 Apr 2014 22:03:17 -0700 (PDT)
Message-ID: <534CBD76.1030109@gmail.com>
Date: Tue, 15 Apr 2014 13:02:46 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: linux-nfs@vger.kernel.org, Dr Fields James Bruce <bfields@fieldses.org>
Subject: Re: [PATCH] NFS: add FATTR4_WORD1_MODE flags for cache_consistency_bitmask
References: <534A8CEF.6000609@gmail.com>		 <505345D4-4F7C-4970-9EBF-7CFC367575B2@primarydata.com>		 <534AA4FD.3060202@gmail.com> <1397402659.6306.5.camel@leira.trondhjem.org>	 <534BDBB6.5030306@gmail.com>	 <4B0A3D7E-5DD0-47A2-B1C8-A2F64E37D781@primarydata.com>	 <534BE338.2030001@gmail.com> <1397487639.7280.4.camel@leira.trondhjem.org>
In-Reply-To: <1397487639.7280.4.camel@leira.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



于 2014/4/14 23:00, Trond Myklebust 写道:
> On Mon, 2014-04-14 at 21:31 +0800, Kinglong Mee wrote:
>>
>> 于 2014/4/14 21:12, Trond Myklebust 写道:
>>>
>>> On Apr 14, 2014, at 8:59, Kinglong Mee <kinglongmee@gmail.com> wrote:
>>>
>>>>
>>>>
>>>> 于 2014/4/13 23:24, Trond Myklebust 写道:
>>>>> On Sun, 2014-04-13 at 22:53 +0800, Kinglong Mee wrote:
>>>>>>
>>>>>> 于 2014/4/13 22:28, Trond Myklebust 写道:
>>>>>>>
>>>>>>> On Apr 13, 2014, at 9:11, Kinglong Mee <kinglongmee@gmail.com> wrote:
>>>>>>>
>>>>>>>> After writing data at NFS client, file's access mode is inconsistent
>>>>>>>> with server.
>>>>>>>> Because WRITE proceduce changes the S_ISUID and S_ISGID bits,
>>>>>>>> but client don't get it.
>>>>>>>>
>>>>>>>> #touch hello; chmod 06777 hello; stat hello;
>>>>>>>>     File: ‘hello’
>>>>>>>>     Size: 0               Blocks: 0          IO Block: 262144 regular
>>>>>>>> empty file
>>>>>>>> Device: 24h/36d Inode: 786434      Links: 1
>>>>>>>> Access: (6777/-rwsrwsrwx)  Uid: (    0/    root)   Gid: (    0/    root)
>>>>>>>> Context: system_u:object_r:nfs_t:s0
>>>>>>>> Access: 2014-04-13 21:00:44.996908708 +0800
>>>>>>>> Modify: 2014-04-13 21:00:44.996908708 +0800
>>>>>>>> Change: 2014-04-13 21:00:45.033908705 +0800
>>>>>>>> Birth: -
>>>>>>>>
>>>>>>>> #echo 12324 > hello; stat hello; stat /nfstest/hello
>>>>>>>>     File: ‘hello’
>>>>>>>>     Size: 6               Blocks: 0          IO Block: 262144 regular file
>>>>>>>> Device: 24h/36d Inode: 786434      Links: 1
>>>>>>>> Access: (6777/-rwsrwsrwx)  Uid: (    0/    root)   Gid: (    0/    root)
>>>>>>>>            ^^^^^ it should be 0777
>>>>>>>> Context: system_u:object_r:nfs_t:s0
>>>>>>>> Access: 2014-04-13 21:00:44.996908708 +0800
>>>>>>>> Modify: 2014-04-13 21:00:45.061908703 +0800
>>>>>>>> Change: 2014-04-13 21:00:45.061908703 +0800
>>>>>>>> Birth: -
>>>>>>>>     File: ‘/nfstest/hello’
>>>>>>>>     Size: 6               Blocks: 8          IO Block: 4096   regular file
>>>>>>>> Device: 803h/2051d      Inode: 786434      Links: 1
>>>>>>>> Access: (0777/-rwxrwxrwx)  Uid: (    0/    root)   Gid: (    0/    root)
>>>>>>>>            ^^^^^ bits on the server
>>>>>>>> Context: system_u:object_r:default_t:s0
>>>>>>>> Access: 2014-04-13 21:00:44.996908708 +0800
>>>>>>>> Modify: 2014-04-13 21:00:45.061908703 +0800
>>>>>>>> Change: 2014-04-13 21:00:45.061908703 +0800
>>>>>>>> Birth: -
>>>>>>>>
>>>>> <snip>
>>>>>>>
>>>>>>> Instead of requesting a new attribute on each and every operation just in order to deal with an extremely rare corner case, is there any reason why we can’t just do this by checking should_remove_suid(), clearing the mode bits ourselves, and then marking the attributes for revalidation?
>>>>>>
>>>>> <snip>
>>>>>> IMO, client shoulds get all metadatas from server, so, adds the flag.
>>>>>> I think should_remove_suid() should be called by nfsd, not NFS client
>>>>>
>>>>> I agree with 50% of that statement. Please see below.
>>>>>
>>>>> 8<---------------------------------------------------------------------
>>>>>>   From a7b05fc5fcb433e8cfca577c9275f2012b523ee8 Mon Sep 17 00:00:00 2001
>>>>> From: Trond Myklebust <trond.myklebust@primarydata.com>
>>>>> Date: Sun, 13 Apr 2014 11:11:31 -0400
>>>>> Subject: [PATCH] NFS: Don't ignore suid/sgid bit changes after a successful
>>>>>    write
>>>>>
>>>>> If we suspect that the server may have cleared the suid/sgid bit,
>>>>> then mark the inode for revalidation.
>>>>
>>>> When testing with this patch, should_remove_suid() always return false
>>>> at client, but return true at NFS server.
>>>>
>>>> So that, NFS server clears the suid/sgid bit, but client also remains.
>>>
>>> Are you running the test as root? The only explanation I can see for should_remove_suid() failing is if the ‘CAP_FSETID’ capability is set.
>>
>> I test it with non-root user, should_remove_suid() also return 0.
>
> OK. Let's make a version that ignores the capabilities, and just tests
> the SUID/SGID bits.

Due to another problem, test failed again using commands
"echo xxxdsf > testfile; stat testfile".

In nfs_writeback_done(), nfs_mark_for_revalidate() set cache_validity's
NFS_INO_INVALID_ATTR flag, but nfs4_close_done() will refresh
inode from cache (old mode, not update from server ) and clear
NFS_INO_INVALID_ATTR flags.

Next, the "stat testfile" gets data from cache,
because NFS_INO_INVALID_ATTR flags is cleared below.

Calltrace,
[ 4883.997254] nfs4_proc_write_setup
[ 4884.006885] NFS:  1365 nfs_writeback_done (status 11)
[ 4884.008215] nfs4_write_done
[ 4884.009273] nfs4_write_done_cb
[ 4884.010013] nfs_post_op_update_inode_force_wcc
[ 4884.011221] nfs_update_inode
[ 4884.012001] nfs_update_inode
[ 4884.012952] nfs_writeback_done: before nfs_should_remove_suid
[ 4884.014722] nfs_writeback_done: in nfs_should_remove_suid
[ 4884.016549] nfs4_close_done
[ 4884.017614] nfs_refresh_inode
[ 4884.018645] nfs_update_inode
[ 4884.019693] nfs_update_inode

But, if getting status before close, the mode can be update to latest.

thanks,
Kinglong Mee

> 8<--------------------------------------------------------------------
>>From 2e068b62316b2fa5738a8b730bcb5f2f8e7cbdb1 Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> Date: Sun, 13 Apr 2014 11:11:31 -0400
> Subject: [PATCH v2] NFS: Don't ignore suid/sgid bit changes after a successful
>   write
>
> If we suspect that the server may have cleared the suid/sgid bit,
> then mark the inode for revalidation.
>
> Reported-by: Kinglong Mee <kinglongmee@gmail.com>
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>   fs/nfs/write.c | 35 +++++++++++++++++++++++++++++++++--
>   1 file changed, 33 insertions(+), 2 deletions(-)
>
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 9a3b6a4cd6b9..cd7c651f9b84 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -1353,6 +1353,30 @@ static const struct rpc_call_ops nfs_write_common_ops = {
>   	.rpc_release = nfs_writeback_release_common,
>   };
>
> +/*
> + * Special version of should_remove_suid() that ignores capabilities.
> + */
> +static int nfs_should_remove_suid(const struct inode *inode)
> +{
> +	umode_t mode = inode->i_mode;
> +	int kill = 0;
> +
> +	/* suid always must be killed */
> +	if (unlikely(mode & S_ISUID))
> +		kill = ATTR_KILL_SUID;
> +
> +	/*
> +	 * sgid without any exec bits is just a mandatory locking mark; leave
> +	 * it alone.  If some exec bits are set, it's a real sgid; kill it.
> +	 */
> +	if (unlikely((mode & S_ISGID) && (mode & S_IXGRP)))
> +		kill |= ATTR_KILL_SGID;
> +
> +	if (unlikely(kill && S_ISREG(mode)))
> +		return kill;
> +
> +	return 0;
> +}
>
>   /*
>    * This function is called when the WRITE call is complete.
> @@ -1401,9 +1425,16 @@ void nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
>   		}
>   	}
>   #endif
> -	if (task->tk_status < 0)
> +	if (task->tk_status < 0) {
>   		nfs_set_pgio_error(data->header, task->tk_status, argp->offset);
> -	else if (resp->count < argp->count) {
> +		return;
> +	}
> +
> +	/* Deal with the suid/sgid bit corner case */
> +	if (nfs_should_remove_suid(inode))
> +		nfs_mark_for_revalidate(inode);
> +
> +	if (resp->count < argp->count) {
>   		static unsigned long    complain;
>
>   		/* This a short write! */
>
