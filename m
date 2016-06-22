Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:22901 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751398AbcFVSIG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jun 2016 14:08:06 -0400
Subject: Re: [PATCH v2 11/12] NFS: Remove inode->i_dio_count from the NFS
 O_DIRECT code
To: Trond Myklebust <trondmy@primarydata.com>
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
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <795f5e87-2c43-0e6e-2f1c-322a5a928b39@Netapp.com>
Date: Wed, 22 Jun 2016 14:08:02 -0400
MIME-Version: 1.0
In-Reply-To: <BD2F73AF-8547-4198-A937-0C6EDBF079FA@primarydata.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/22/2016 02:06 PM, Trond Myklebust wrote:
> 
>> On Jun 22, 2016, at 13:58, Anna Schumaker <Anna.Schumaker@netapp.com> wrote:
>>
>> Hi Trond,
>>
>> On 06/21/2016 05:34 PM, Trond Myklebust wrote:
>>> Now that we can serialise O_DIRECT and write/truncate using the
>>> inode->i_rwsem, we no longer need inode->i_dio_count.
>>
>> I'm seeing cthon basic tests fail on all NFS versions after applying this patch:
>>
>> ./test5: read and write
>>        ./test5: (/nfs/basic) 'bigfile' has size 8192, should be 1048576
>> basic tests failed
>>
> 
> ???? Connectathon doesn’t use O_DIRECT. Are you sure it is this patch?
> 

Pretty sure.  Cthon worked for me at patch #10, but it failed after adding this one.

Anna
