Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f44.google.com ([209.85.160.44]:61587 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751906AbaCZSjz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Mar 2014 14:39:55 -0400
Received: by mail-pb0-f44.google.com with SMTP id rp16so2311209pbb.31
        for <linux-nfs@vger.kernel.org>; Wed, 26 Mar 2014 11:39:55 -0700 (PDT)
Content-Type: text/plain; charset=US-ASCII
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH] NFSv4: Memory not being freed on memory allocation failure
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <53331308.2000403@RedHat.com>
Date: Wed, 26 Mar 2014 11:39:24 -0700
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-Id: <7F3F0CC3-C10F-4C43-9290-6A6C9B1FB53E@primarydata.com>
References: <1395849036-6907-1-git-send-email-steved@redhat.com> <22F1169D-33AA-4B8F-ADE0-E8BEEE97E361@primarydata.com> <53331308.2000403@RedHat.com>
To: Dickson Steve <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 26, 2014, at 10:48, Steve Dickson <SteveD@redhat.com> wrote:

> 
> 
> On 03/26/2014 01:25 PM, Trond Myklebust wrote:
>> 
>> On Mar 26, 2014, at 8:50, Steve Dickson <steved@redhat.com> wrote:
>> 
>>> nfs4_run_open_task() puts a ref count on the nfs4_opendata
>>> data pointer, then tries to allocate the task pointer.
>>> If that task allocation fails nfs4_run_open_task() returns
>>> leaving the ref count on the data pointer.
>>> 
>> 
>> Hi Steve,
>> 
>> That should not be the case. rpc_run_task() will always call nfs4_open_release() even if it returns an error.
> How can rpc_run_task() run without a task pointer? and I think 
> you need a task allocated pointer to even call nfs4_open_release()

No. nfs4_open_release() is called without an rpc task. This is how it is designed to work.

> 
> Here is what I'm seeing:
> 
> If rpc_alloc_task() fails, rpc_new_task() returns ERR_PTR(-ENOMEM)

Yes, but before returning ERR_PTR(-ENOMEM), it calls

rpc_release_calldata(setup_data->callback_ops, setup_data->callback_data);

which again calls rpc_ops->rpc_release(calldata)

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

