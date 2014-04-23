Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f178.google.com ([74.125.82.178]:61734 "EHLO
	mail-we0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756442AbaDWKYj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Apr 2014 06:24:39 -0400
Received: by mail-we0-f178.google.com with SMTP id u56so632796wes.23
        for <linux-nfs@vger.kernel.org>; Wed, 23 Apr 2014 03:24:38 -0700 (PDT)
Message-ID: <535794E3.1020201@dev.mellanox.co.il>
Date: Wed, 23 Apr 2014 13:24:35 +0300
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>,
        Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Subject: Re: [PATCH V2 10/17] xprtrdma: Add CONFIG setting that can disable
 ALLPHYSICAL
References: <20140421214442.12569.8950.stgit@manet.1015granger.net> <20140421220214.12569.23157.stgit@manet.1015granger.net> <20140422062338.GA23311@infradead.org>
In-Reply-To: <20140422062338.GA23311@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 4/22/2014 9:23 AM, Christoph Hellwig wrote:
> On Mon, Apr 21, 2014 at 06:02:14PM -0400, Chuck Lever wrote:
>> ALLPHYSICAL is not a safe memory registration mode because it
>> permits NFS servers to write anywhere in a client's memory.  NFS
>> server bugs could result in client memory being overwritten.
>>
>> This can be useful for embedded systems which do not support more
>> surgical RDMA memory registration and protection methods, or for
>> bring-up of new HCA hardware.
>>
>> However, enterprise Linux distributions have expressed a desire to
>> disable it in production environments.
> It's just as unsafe in embedded devices.  I think it should go

For small IOs pattern, ALLPHYSICAL should outperform any registration method
in terms of IOP rate (simply because it doesn't do it).

Generally speaking, deployments that may prefer higher IOP rate in the cost
of a security do exist out there...

Sagi.
