Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from sonic310-27.consmr.mail.gq1.yahoo.com ([98.137.69.153]:46218
        "EHLO sonic310-27.consmr.mail.gq1.yahoo.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755573AbeEaQEa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 31 May 2018 12:04:30 -0400
Subject: Re: [PATCH 1/1] Fix memory leak in kernfs_security_xattr_set and
 kernfs_security_xattr_set
To: Tejun Heo <tj@kernel.org>, CHANDAN VN <chandan.vn@samsung.com>
Cc: gregkh@linuxfoundation.org, bfields@fieldses.org,
        jlayton@kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, cpgs@samsung.com,
        sireesha.t@samsung.com, Chris Wright <chrisw@sous-sol.org>,
        linux-security-module@vger.kernel.org
References: <CGME20180531092848epcas1p24b638ccd6da00f1e039bdb64de7e1a5b@epcas1p2.samsung.com>
 <1527758911-18610-1-git-send-email-chandan.vn@samsung.com>
 <20180531153943.GR1351649@devbig577.frc2.facebook.com>
From: Casey Schaufler <casey@schaufler-ca.com>
Message-ID: <4f00f9ae-3302-83b9-c083-d21ade380eb2@schaufler-ca.com>
Date: Thu, 31 May 2018 09:04:25 -0700
MIME-Version: 1.0
In-Reply-To: <20180531153943.GR1351649@devbig577.frc2.facebook.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/31/2018 8:39 AM, Tejun Heo wrote:
> (cc'ing more security folks and copying whole body)
>
> So, I'm sure the patch fixes the memory leak but API wise it looks
> super confusing.  Can security folks chime in here?  Is this the right
> fix?

security_inode_getsecctx() provides a security context. Technically,
this is a data blob, although both provider provide a null terminated
string. security_inode_getsecurity(), on the other hand, provides a
string to match an attribute name. The former releases the security
context with security_release_secctx(), where the later releases the
string with kfree().

When the Smack hook smack_inode_getsecctx() was added in 2009
for use by labeled NFS the alloc value passed to
smack_inode_getsecurity() was set incorrectly. This wasn't a
major issue, since labeled NFS is a fringe case. When kernfs
started using the hook, it became the issue you discovered.

The reason that we have all this confusion is that SELinux
generates security contexts as needed, while Smack keeps them
around all the time. Releasing an SELinux context frees memory,
while releasing a Smack context is a null operation.

>
> Thanks.
>
> On Thu, May 31, 2018 at 02:58:31PM +0530, CHANDAN VN wrote:
>> From: "sireesha.t" <sireesha.t@samsung.com>
>>
>> Leak is caused because smack_inode_getsecurity() is allocating memory
>> using kstrdup(). Though the security_release_secctx() is called, it
>> would not free the allocated memory. Calling security_release_secctx is
>> not relevant for this scenario as inode_getsecurity() does not provide a
>> "secctx".
>>
>> Similar fix has been mainlined:
>> https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git/commit/?id=57e7ba04d422c3d41c8426380303ec9b7533ded9
>>
>> The fix is to replace the security_release_secctx() with a kfree()
>>
>> Below is the KMEMLEAK dump:
>> unreferenced object 0xffffffc025e11c80 (size 64):
>>   comm "systemd-tmpfile", pid 2452, jiffies 4294894464 (age 235587.492s)
>>   hex dump (first 32 bytes):
>>     53 79 73 74 65 6d 3a 3a 53 68 61 72 65 64 00 00  System::Shared..
>>     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>>   backtrace:
>>     [<ffffff80081be770>] __save_stack_trace+0x28/0x34
>>     [<ffffff80081bedb8>] create_object+0x130/0x25c
>>     [<ffffff80088c82f8>] kmemleak_alloc+0x30/0x5c
>>     [<ffffff80081b3ef0>] __kmalloc_track_caller+0x1cc/0x2a8
>>     [<ffffff800818673c>] kstrdup+0x3c/0x6c
>>     [<ffffff80082d78b0>] smack_inode_getsecurity+0xcc/0xec
>>     [<ffffff80082d78f4>] smack_inode_getsecctx+0x24/0x44
>>     [<ffffff80082d5ea0>] security_inode_getsecctx+0x50/0x70
>>     [<ffffff800823bbcc>] kernfs_security_xattr_set+0x74/0xe0
>>     [<ffffff80081eafec>] __vfs_setxattr+0x74/0x90
>>     [<ffffff80081eb088>] __vfs_setxattr_noperm+0x80/0x1ac
>>     [<ffffff80081eb238>] vfs_setxattr+0x84/0xac
>>     [<ffffff80081eb374>] setxattr+0x114/0x178
>>     [<ffffff80081eb44c>] path_setxattr+0x74/0xb8
>>     [<ffffff80081ebdcc>] SyS_lsetxattr+0x10/0x1c
>>     [<ffffff800808310c>] __sys_trace_return+0x0/0x4
>>
>> Signed-off-by: sireesha.t <sireesha.t@samsung.com>
>> Signed-off-by: CHANDAN VN <chandan.vn@samsung.com>
>> ---
>>  fs/kernfs/inode.c | 3 ++-
>>  fs/nfsd/nfs4xdr.c | 2 +-
>>  2 files changed, 3 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/kernfs/inode.c b/fs/kernfs/inode.c
>> index a343039..53befb8 100644
>> --- a/fs/kernfs/inode.c
>> +++ b/fs/kernfs/inode.c
>> @@ -369,7 +369,8 @@ static int kernfs_security_xattr_set(const struct xattr_handler *handler,
>>  	mutex_unlock(&kernfs_mutex);
>>  
>>  	if (secdata)
>> -		security_release_secctx(secdata, secdata_len);
>> +		kfree(secdata);
>> +
>>  	return error;
>>  }
>>  
>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>> index aaa88c1..1e0dbe9 100644
>> --- a/fs/nfsd/nfs4xdr.c
>> +++ b/fs/nfsd/nfs4xdr.c
>> @@ -2911,7 +2911,7 @@ static int get_parent_attributes(struct svc_export *exp, struct kstat *stat)
>>  out:
>>  #ifdef CONFIG_NFSD_V4_SECURITY_LABEL
>>  	if (context)
>> -		security_release_secctx(context, contextlen);
>> +		kfree(context);
>>  #endif /* CONFIG_NFSD_V4_SECURITY_LABEL */
>>  	kfree(acl);
>>  	if (tempfh) {
>> -- 
>> 1.9.1
>>

