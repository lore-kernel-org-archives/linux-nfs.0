Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f42.google.com ([209.85.128.42]:38500 "EHLO
	mail-qe0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751534Ab3HUN2f (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Aug 2013 09:28:35 -0400
Received: by mail-qe0-f42.google.com with SMTP id w7so223092qeb.29
        for <linux-nfs@vger.kernel.org>; Wed, 21 Aug 2013 06:28:35 -0700 (PDT)
Message-ID: <5214C080.5050902@gmail.com>
Date: Wed, 21 Aug 2013 09:28:32 -0400
From: Bryan Schumaker <bjschuma@gmail.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Christoph Hellwig <hch@infradead.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 00/16] NFS add tracepoints
References: <1377027312-45957-1-git-send-email-Trond.Myklebust@netapp.com>  <5213D689.3030103@gmail.com> <1377033113.21393.1.camel@leira.trondhjem.org>  <20130821063958.GA3382@infradead.org> <1377091004.21393.12.camel@leira.trondhjem.org>
In-Reply-To: <1377091004.21393.12.camel@leira.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/21/2013 09:16 AM, Myklebust, Trond wrote:
> On Tue, 2013-08-20 at 23:39 -0700, Christoph Hellwig wrote:
>> On Tue, Aug 20, 2013 at 09:11:52PM +0000, Myklebust, Trond wrote:
>>> Hmm... Does the following patch fix the problem?
>>
>> I think you just need to add this line to fs/nfs/Makefile:
>>
>> ccflags-y += -I$(src)                   # needed for trace events
>>
>> (stolen from XFS :))
> 
> Thanks Christoph! After searching around a little last night, I found
> the same device described in the samples/trace_events directory.
> 
> Bryan, can you please see if the patchset in my 'testing' branch now
> works for you?

It's working now.  Thanks!

> 
> Thanks!
>   Trond
> 

