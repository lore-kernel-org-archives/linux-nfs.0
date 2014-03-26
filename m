Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:43908 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753544AbaCZTLu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Mar 2014 15:11:50 -0400
Message-ID: <53332656.2020301@RedHat.com>
Date: Wed, 26 Mar 2014 15:11:18 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSv4: Memory not being freed on memory allocation failure
References: <1395849036-6907-1-git-send-email-steved@redhat.com> <22F1169D-33AA-4B8F-ADE0-E8BEEE97E361@primarydata.com> <53331308.2000403@RedHat.com> <7F3F0CC3-C10F-4C43-9290-6A6C9B1FB53E@primarydata.com>
In-Reply-To: <7F3F0CC3-C10F-4C43-9290-6A6C9B1FB53E@primarydata.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/26/2014 02:39 PM, Trond Myklebust wrote:
>> Here is what I'm seeing:
>>
>> If rpc_alloc_task() fails, rpc_new_task() returns ERR_PTR(-ENOMEM)
> 
> Yes, but before returning ERR_PTR(-ENOMEM), it calls
> 
> rpc_release_calldata(setup_data->callback_ops, setup_data->callback_data);
> 
> which again calls rpc_ops->rpc_release(calldata)
Ah... I did miss that call... sorry or the noise... 

steved.


> 
> _________________________________
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
> 
