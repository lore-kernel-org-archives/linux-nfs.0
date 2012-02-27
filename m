Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:33052 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752517Ab2B0Nzn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Feb 2012 08:55:43 -0500
Message-ID: <4F4B8B4E.7090307@parallels.com>
Date: Mon, 27 Feb 2012 17:55:26 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Isaman, Fred" <Fred.Isaman@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: fix use-after-free of rpc pipes
References: <1330019288-13031-1-git-send-email-iisaman@netapp.com>		 <4F47D37D.2080409@parallels.com>	 <1330300376.18817.0.camel@lade.trondhjem.org>	 <4F4B7C4B.5000901@parallels.com> <1330350288.5541.3.camel@lade.trondhjem.org>
In-Reply-To: <1330350288.5541.3.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

27.02.2012 17:44, Myklebust, Trond пишет:
> On Mon, 2012-02-27 at 16:51 +0400, Stanislav Kinsbursky wrote:
>> Frankly, I don't like the idea of put'ing pipe data on dentry unlink. IOW, I
>> don't like that this data will be controlled somehow in PipeFS.
>> I'll send my version soon.
>>
>
> I don't understand that objection. The lifetime of that data needs to be
> bounded by the lifetime of the pipe itself, which means that it _has_ to
> be controlled by the pipefs.
>
> BTW: it isn't being put on dentry unlink. It is being put on dentry
> _destruction_. Those are two different events (which is why we have a
> problem today).
>

Please, have a look at "SUNRPC: several fixes around PipeFS objects" patch set.
Briefly, pipe data is created on some kernel event (mount or module install), 
while PipeFS dentry/inode is created on user-space event (PipeFS mount/umount 
request). Thus this two objects are created independently.
And I believe, that they have to be destroyed independently too.

-- 
Best regards,
Stanislav Kinsbursky
