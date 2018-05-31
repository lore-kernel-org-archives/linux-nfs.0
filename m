Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:45969 "EHLO
        out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750711AbeEaU5X (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 31 May 2018 16:57:23 -0400
From: ebiederm@xmission.com (Eric W. Biederman)
To: Casey Schaufler <casey@schaufler-ca.com>
Cc: CHANDAN VN <chandan.vn@samsung.com>, gregkh@linuxfoundation.org,
        tj@kernel.org, bfields@fieldses.org, jlayton@kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        cpgs@samsung.com, sireesha.t@samsung.com
References: <CGME20180531092848epcas1p24b638ccd6da00f1e039bdb64de7e1a5b@epcas1p2.samsung.com>
        <1527758911-18610-1-git-send-email-chandan.vn@samsung.com>
        <cae274dd-e9e5-39b1-8b7b-aec1b3e76fe9@schaufler-ca.com>
Date: Thu, 31 May 2018 15:57:00 -0500
In-Reply-To: <cae274dd-e9e5-39b1-8b7b-aec1b3e76fe9@schaufler-ca.com> (Casey
        Schaufler's message of "Thu, 31 May 2018 08:26:23 -0700")
Message-ID: <87po1ba6hv.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [PATCH 1/1] Fix memory leak in kernfs_security_xattr_set and kernfs_security_xattr_set
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Casey Schaufler <casey@schaufler-ca.com> writes:

> On 5/31/2018 2:28 AM, CHANDAN VN wrote:
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
>
> Why not:
>
>  static int smack_inode_getsecctx(struct inode *inode, void **ctx, u32 *ctxlen)
>  {
> -	int len = 0;
> -	len = smack_inode_getsecurity(inode, XATTR_SMACK_SUFFIX, ctx, true);
> +	int len = smack_inode_getsecurity(inode, XATTR_SMACK_SUFFIX, ctx, false);
>
The practical difference here is the true vs the false in the call
to smack_inode_getsecurity?

>  	if (len < 0)
>  		return len;
>

Eric
