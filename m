From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 3/3] NFS: Use cached nlm_host when calling nlmclnt_proc()
Date: Tue, 8 Jan 2008 12:03:06 -0500
Message-ID: <8E9A424E-BB8E-411E-816E-3D7C9DF4D779@oracle.com>
References: <20080108153221.20097.13404.stgit@manray.1015granger.net> <20080108164251.GB20897@infradead.org>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:37355 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752935AbYAHREF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jan 2008 12:04:05 -0500
In-Reply-To: <20080108164251.GB20897@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Christoph-

On Jan 8, 2008, at 11:42 AM, Christoph Hellwig wrote:
> On Tue, Jan 08, 2008 at 10:32:22AM -0500, Chuck Lever wrote:
>> +int nlmclnt_proc(struct nlm_host *host, int cmd, struct file_lock  
>> *fl)
>>  {
>>  	struct nlm_rqst		*call;
>>  	sigset_t		oldset;
>>  	unsigned long		flags;
>> +	int			status;
>>
>>  	if (host == NULL)
>>  		return -ENOLCK;
>
> I think this check can just go away aswell.

Yeah, I guess that's right.  NFS_MOUNT_NONLM is set during mount  
processing if the NLM couldn't acquire an appropriate nlm_host for  
this mount point, and NFS_MOUNT_NONLM gates the call to the NFS  
version specific lock calls.

It should probably also dump a warning into the kernel log if the  
admin requested "lock" and got "nolock" instead.  That could  
certainly change application behavior unexpectedly!

>   Might be good to add kerneldoc comments for all the
> exported APIs you touch/add btw to make this entirely clear.

Yes, nlmclnt_proc() deserves a comment.  I usually add one in these  
cases, and just forgot here.

I'll repost with these changes.

>>  nfs3_proc_lock(struct file *filp, int cmd, struct file_lock *fl)
>>  {
>> +	struct inode *inode = filp->f_path.dentry->d_inode;
>> +	struct nlm_host *host = NFS_SERVER(inode)->nlm_host;
>> +
>> +	return nlmclnt_proc(host, cmd, fl);
>>  }
>>
>>  static int
>>  nfs_proc_lock(struct file *filp, int cmd, struct file_lock *fl)
>>  {
>> +	struct inode *inode = filp->f_path.dentry->d_inode;
>> +	struct nlm_host *host = NFS_SERVER(inode)->nlm_host;
>> +
>> +	return nlmclnt_proc(host, cmd, fl);
>>  }
>
> These two are completely identical, any reason there's two copies  
> here?

One is for NFS version 2, one for NFS version 3.

If we decide to fold these two together, we should review all of the  
NFS proc routines and construct a common proc source file.  I'm not  
sure it's worth the trouble.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
