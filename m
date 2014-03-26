Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:11274 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754664AbaCZRs6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Mar 2014 13:48:58 -0400
Message-ID: <53331308.2000403@RedHat.com>
Date: Wed, 26 Mar 2014 13:48:56 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSv4: Memory not being freed on memory allocation failure
References: <1395849036-6907-1-git-send-email-steved@redhat.com> <22F1169D-33AA-4B8F-ADE0-E8BEEE97E361@primarydata.com>
In-Reply-To: <22F1169D-33AA-4B8F-ADE0-E8BEEE97E361@primarydata.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/26/2014 01:25 PM, Trond Myklebust wrote:
> 
> On Mar 26, 2014, at 8:50, Steve Dickson <steved@redhat.com> wrote:
> 
>> nfs4_run_open_task() puts a ref count on the nfs4_opendata
>> data pointer, then tries to allocate the task pointer.
>> If that task allocation fails nfs4_run_open_task() returns
>> leaving the ref count on the data pointer.
>>
> 
> Hi Steve,
> 
> That should not be the case. rpc_run_task() will always call nfs4_open_release() even if it returns an error.
How can rpc_run_task() run without a task pointer? and I think 
you need a task allocated pointer to even call nfs4_open_release()

Here is what I'm seeing:

If rpc_alloc_task() fails, rpc_new_task() returns ERR_PTR(-ENOMEM)

In rpc_run_task() we do

task = rpc_new_task(task_setup_data);
if (IS_ERR(task))
   goto out;
:
:
:
out:    
    return task;

In nfs4_run_open_task() we do

kref_get(&data->kref);
:
:
:
task = rpc_run_task(&task_setup_data)
If (IS_ERR(task))
    return PTR_ERR(task);

What am I missing?

steved.
