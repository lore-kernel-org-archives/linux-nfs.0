Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:40300 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751738Ab1BUVet (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Feb 2011 16:34:49 -0500
Message-ID: <4D62D8C4.3030004@parallels.com>
Date: Tue, 22 Feb 2011 00:27:32 +0300
From: Konstantin Khlebnikov <khlebnikov@parallels.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] NFS: account direct-io into task io accounting
References: <20110221191546.5920.96947.stgit@localhost6> <CE953B49-D775-4A61-942B-4B2F5DE9D7BF@oracle.com>
In-Reply-To: <CE953B49-D775-4A61-942B-4B2F5DE9D7BF@oracle.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Chuck Lever wrote:
>
> On Feb 21, 2011, at 11:15 AM, Konstantin Khlebnikov wrote:
>
>> Account complete NFS direct-io reads and writes into Task I/O Accounting.
>>
>> NFS have unusual direct-io implementation,
>> thus accounting in generic code does not work.
>>
>> Signed-off-by: Konstantin Khlebnikov<khlebnikov@openvz.org>
>> ---
>> fs/nfs/direct.c |    9 +++++++--
>> 1 files changed, 7 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
>> index 9943a75..bab4185 100644
>> --- a/fs/nfs/direct.c
>> +++ b/fs/nfs/direct.c
>> @@ -45,6 +45,7 @@
>> #include<linux/pagemap.h>
>> #include<linux/kref.h>
>> #include<linux/slab.h>
>> +#include<linux/task_io_accounting_ops.h>
>>
>> #include<linux/nfs_fs.h>
>> #include<linux/nfs_page.h>
>> @@ -939,8 +940,10 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, const struct iovec *iov,
>> 		goto out;
>>
>> 	retval = nfs_direct_read(iocb, iov, nr_segs, pos);
>> -	if (retval>  0)
>> +	if (retval>  0) {
>> 		iocb->ki_pos = pos + retval;
>> +		task_io_account_read(retval);
>> +	}
>>
>> out:
>> 	return retval;
>> @@ -1001,8 +1004,10 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, const struct iovec *iov,
>>
>> 	retval = nfs_direct_write(iocb, iov, nr_segs, pos, count);
>>
>> -	if (retval>  0)
>> +	if (retval>  0) {
>> 		iocb->ki_pos = pos + retval;
>> +		task_io_account_write(retval);
>> +	}
>
> The async path always returns -EIOCBQUEUED.  How are those bytes accounted for?
>

Oh, thanks. I forget about aio.
So, there only one option -- always account whole requiest before completion.

>>
>> out:
>> 	return retval;
>
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>
>
>

