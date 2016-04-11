Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:33025 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755217AbcDKUiu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Apr 2016 16:38:50 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v1 05/18] xprtrdma: Avoid using Write list for small NFS READ requests
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <033901d19431$b3725d20$1a571760$@opengridcomputing.com>
Date: Mon, 11 Apr 2016 16:38:44 -0400
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <65CBC59F-3005-44FE-8C70-9DDBC8507C9E@oracle.com>
References: <20160411200323.20531.8893.stgit@manet.1015granger.net> <20160411201050.20531.53651.stgit@manet.1015granger.net> <033901d19431$b3725d20$1a571760$@opengridcomputing.com>
To: Steve Wise <swise@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Apr 11, 2016, at 4:35 PM, Steve Wise <swise@opengridcomputing.com> wrote:
> 
>> Avoid the latency and interrupt overhead of registering a Write
>> chunk when handling NFS READ requests of a few hundred bytes or
>> less.
>> 
>> This change does not interoperate with Linux NFS/RDMA servers
>> that do not have commit 9d11b51ce7c1 ('svcrdma: Fix send_reply()
>> scatter/gather set-up').
>> 
>> $ git describe 9d11b51ce7c1
>> v4.2-rc3-10-g9d11b51
>> 
> 
> Hey Chuck,
> 
> Is there any way to avoid breaking interoperability with older servers?

No, pre-4.2 Linux servers have a bug that can be fixed by
applying the above commit, which shouldn't be difficult to
backport.

Clients have always been allowed to send NFS READ this way.

--
Chuck Lever



