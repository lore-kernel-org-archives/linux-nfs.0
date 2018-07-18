Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55904 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1730382AbeGRPEb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 18 Jul 2018 11:04:31 -0400
Subject: Re: [PATCH] rpc.gssd: truncates 32-bit UIDs/GIDs to 16 bits
 architectures.
To: Christoph Hellwig <hch@infradead.org>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20180718121107.16838-1-steved@redhat.com>
 <20180718123303.GA2749@infradead.org>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <87811b66-7a83-ac25-43b0-8166a7b8abfa@RedHat.com>
Date: Wed, 18 Jul 2018 10:26:18 -0400
MIME-Version: 1.0
In-Reply-To: <20180718123303.GA2749@infradead.org>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/18/2018 08:33 AM, Christoph Hellwig wrote:
>> -	if (syscall(SYS_setresgid, pw->pw_gid, pw->pw_gid, pw->pw_gid) != 0) {
>> +#ifdef __NR_setresuid32
>> +	res = syscall(SYS_setresgid32, pw->pw_gid, pw->pw_gid, pw->pw_gid);
>> +#else 
>> +	res = syscall(SYS_setresgid, pw->pw_gid, pw->pw_gid, pw->pw_gid);
>> +#endif
> 
> I think you want to simply call setresuid/setresgid from glibcs, which
> will do the right thing instead of doing hand crafted syscalls.
Here is the comment above these calls 

    /* Switch the UIDs and GIDs. */
    /* For the threaded version we have to set uid,gid per thread instead
     * of per process. glibc setresuid() when called from a thread, it'll
     * send a signal to all other threads to synchronize the uid in all
     * other threads. To bypass this, we have to call syscall() directly.
     */

steved.
