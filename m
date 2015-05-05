Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa09-09.prod.phx3.secureserver.net ([173.201.193.238]:39950
	"EHLO p3plsmtpa09-09.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762703AbbEESOg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 May 2015 14:14:36 -0400
Message-ID: <55490886.4070502@talpey.com>
Date: Tue, 05 May 2015 14:14:30 -0400
From: Tom Talpey <tom@talpey.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>,
        Chuck Lever <chuck.lever@oracle.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org
Subject: Re: [PATCH v1 00/16] NFS/RDMA patches proposed for 4.1
References: <20150313211124.22471.14517.stgit@manet.1015granger.net> <20150505154411.GA16729@infradead.org> <5E1B32EA-9803-49AA-856D-BF0E1A5DFFF4@oracle.com> <20150505172540.GA19442@infradead.org>
In-Reply-To: <20150505172540.GA19442@infradead.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/5/2015 1:25 PM, Christoph Hellwig wrote:
> On Tue, May 05, 2015 at 12:04:00PM -0400, Chuck Lever wrote:
>> IMO FRWR is the only registration mode that has legs for the long term,
>> and is specifically designed for storage.
>>
>> If you are not working on a legacy piece of code that has to support
>> older HCAs, why not stay with FRWR?
>
> The raw FRWR API seems like an absolute nightmare, and I'm bound to
> get it wrong at first :)  This is only half joking, but despite that
> it's the first target for sure.  It's just very frustrating that there
> is no usable common API.

Memory registration is quite subtle with dependencies on the memory
being registered (user, kernel, physical), the requirements of the
upper layer (storage, etc) and the scope of the registration (scatter/
gather, memory protection, etc). I don't think you *want* a common API.

As you might guess, I can go on at length about this. :-) But, if
you have a kernel service, the ability to pin memory, and you
want it to go fast, you want FRWR.

Tom.
