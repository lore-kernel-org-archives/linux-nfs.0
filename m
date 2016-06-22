Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:14920 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751498AbcFVSwp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jun 2016 14:52:45 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH v2 11/12] NFS: Remove inode->i_dio_count from the NFS
 O_DIRECT code
To: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Trond Myklebust <trondmy@primarydata.com>
References: <1466544893-12058-1-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-2-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-3-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-4-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-5-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-6-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-7-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-8-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-9-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-10-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-11-git-send-email-trond.myklebust@primarydata.com>
 <74f8a81e-41c2-b28c-0227-780f3d26db75@Netapp.com>
 <BD2F73AF-8547-4198-A937-0C6EDBF079FA@primarydata.com>
 <795f5e87-2c43-0e6e-2f1c-322a5a928b39@Netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-ID: <22b9a7ea-771c-34b3-bb22-f109772d5da5@Netapp.com>
Date: Wed, 22 Jun 2016 14:51:32 -0400
MIME-Version: 1.0
In-Reply-To: <795f5e87-2c43-0e6e-2f1c-322a5a928b39@Netapp.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/22/2016 02:08 PM, Anna Schumaker wrote:
> On 06/22/2016 02:06 PM, Trond Myklebust wrote:
>>
>>> On Jun 22, 2016, at 13:58, Anna Schumaker <Anna.Schumaker@netapp.com> wrote:
>>>
>>> Hi Trond,
>>>
>>> On 06/21/2016 05:34 PM, Trond Myklebust wrote:
>>>> Now that we can serialise O_DIRECT and write/truncate using the
>>>> inode->i_rwsem, we no longer need inode->i_dio_count.
>>>
>>> I'm seeing cthon basic tests fail on all NFS versions after applying this patch:
>>>
>>> ./test5: read and write
>>>        ./test5: (/nfs/basic) 'bigfile' has size 8192, should be 1048576
>>> basic tests failed
>>>
>>
>> ???? Connectathon doesn’t use O_DIRECT. Are you sure it is this patch?
>>
> 
> Pretty sure.  Cthon worked for me at patch #10, but it failed after adding this one.

I retried the tests, and it's actually patch #10 where I start having problems.  Sorry for the confusion!

Anna

> 
> Anna
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

