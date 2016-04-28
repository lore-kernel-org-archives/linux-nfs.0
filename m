Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:35111 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750923AbcD1K7i (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Apr 2016 06:59:38 -0400
Subject: Re: Removing NFS/RDMA client support for PHYSICAL memory registration
To: Chuck Lever <chuck.lever@oracle.com>
References: <20160425185956.3566.64142.stgit@manet.1015granger.net>
 <20160425192259.3566.58807.stgit@manet.1015granger.net>
 <571FCF03.4060406@grimberg.me>
 <1B0B3E47-05C0-4134-B486-0869628B453C@oracle.com>
 <C0D8DC78-C6AB-4926-AF27-5D51E16FD447@oracle.com>
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Sagi Grimberg <sagi@grimberg.me>
Message-ID: <5721ED15.7030206@grimberg.me>
Date: Thu, 28 Apr 2016 13:59:33 +0300
MIME-Version: 1.0
In-Reply-To: <C0D8DC78-C6AB-4926-AF27-5D51E16FD447@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


>>> It's an awful lot of maintenance on what looks to be a esoteric (at
>>> best) code path.
>>
>> It's never chosen by falling back to that mode.
>>
>> physical has long been on the chopping block. Last time
>> I suggested removing it I got a complaint. But there's no
>> in-kernel device that requires this mode, so seems like
>> it should go sooner rather than later.
>
> I'm planning to add support for NFS/RDMA with Kerberos
> in v4.8. That seems like a very appropriate time to
> remove PHYSICAL, which is not secure.
>
> Is there any objection to removing PHYSICAL in v4.8?

Please do :)
