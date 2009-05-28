From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH] nfsd: fix hung up of nfs client while sync write data
	to nfs server
Date: Thu, 28 May 2009 20:45:50 +0800
Message-ID: <4A1E877E.8080007@cn.fujitsu.com>
References: <4A122F83.4020606@cn.fujitsu.com>
	<20090527224845.GE29565@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20090527224845.GE29565@fieldses.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Tue, May 19, 2009 at 12:03:15PM +0800, Wei Yongjun wrote:
>   
>> Commit 'Short write in nfsd becomes a full write to the client'
>> (31dec2538e45e9fff2007ea1f4c6bae9f78db724) broken the sync write.
>> With the following commands to reproduce:
>>
>>   $ mount -t nfs -o sync 192.168.0.21:/nfsroot /mnt
>>   $ cd /mnt
>>   $ echo aaaa > temp.txt
>>
>> Then nfs client is hung up.
>>
>> In SYNC mode the server alaways return the write count 0 to the
>> client. This is because the value of host_err in nfsd_vfs_write()
>> will be overwrite in SYNC mode by 'host_err=nfsd_sync(file);',
>> and then we return host_err(which is now 0) as write count.
>>     
>
> Undoubtedly correct--applied, thanks!
>
> (But it bugs me that I can't reproduce this: I see the client (mounting
> with -osync, as above) send an unstable write followed by an immediate
> commit, instead of a stable write.  This is with 2.6.29.30-rc7 on client
> and server.)
>   

I used 2.6.29.30-rc7 on server and RHEL5GA as client.^_^

> --b.
>
>   
>> This patch fixed the problem.
>>
>> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
>> ---
>>  fs/nfsd/vfs.c |    6 +++---
>>  1 files changed, 3 insertions(+), 3 deletions(-)
>>
>> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
>> index 6c68ffd..b660435 100644
>> --- a/fs/nfsd/vfs.c
>> +++ b/fs/nfsd/vfs.c
>> @@ -1015,6 +1015,7 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
>>  	host_err = vfs_writev(file, (struct iovec __user *)vec, vlen, &offset);
>>  	set_fs(oldfs);
>>  	if (host_err >= 0) {
>> +		*cnt = host_err;
>>  		nfsdstats.io_write += host_err;
>>  		fsnotify_modify(file->f_path.dentry);
>>  	}
>> @@ -1060,10 +1061,9 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
>>  	}
>>  
>>  	dprintk("nfsd: write complete host_err=%d\n", host_err);
>> -	if (host_err >= 0) {
>> +	if (host_err >= 0)
>>  		err = 0;
>> -		*cnt = host_err;
>> -	} else
>> +	else
>>  		err = nfserrno(host_err);
>>  out:
>>  	return err;
>> -- 
>> 1.5.3.8
>>
>>
>>
>>     
>
>
>   
