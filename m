Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:56812 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753072Ab3BDKWu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Feb 2013 05:22:50 -0500
Message-ID: <510F8BE6.6030108@parallels.com>
Date: Mon, 4 Feb 2013 14:22:30 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>, <Trond.Myklebust@netapp.com>,
        <linux-kernel@vger.kernel.org>, <devel@openvz.org>
Subject: Re: [RFC PATCH 0/4] SUNRPC: rework cache upcall to avoid NFSd root
 swapping
References: <20130115080402.2996.74320.stgit@localhost.localdomain> <20130130230052.GB16158@fieldses.org>
In-Reply-To: <20130130230052.GB16158@fieldses.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce, there is a nfs_dns_upcall, which is not just a wrapper around sunrpc_cache_pipe_upcall().
So, please, drop this series. I'll send another one to replace soon.
BTW, there will be two more cleanup patches in the series for NFS DNS cache part.

31.01.2013 03:00, J. Bruce Fields пишет:
> On Tue, Jan 15, 2013 at 11:09:23AM +0300, Stanislav Kinsbursky wrote:
>> The main idea of this patch set is to call cache request not on kthread
>> upcall, but on userspace daemon cache_read call. This fixes the problem with
>> gaining of wrong dentry path after calling d_path() in kthread root context
>> (svc_export_request() callback), which always work in init root context, but
>> containers can work in "root jail" - i.e. have it's own nested root.
>
> Sorry for the delay.  This looks good to me--committing pending some
> testing.
>
> What's left now for basic containerized nfsd support?
>
> --b.
>
>>
>> The following series implements...
>>
>> ---
>>
>> Stanislav Kinsbursky (4):
>>        SUNRPC: introduce cache_detail->cache_request callback
>>        SUNRPC: remove cache_detail->cache_upcall callback
>>        SUNRPC: remove "cache_request" argument in sunrpc_cache_pipe_upcall() function
>>        SUNRPC: move cache_detail->cache_request callback call to cache_read()
>>
>>
>>   fs/nfs/dns_resolve.c              |    2 +-
>>   fs/nfsd/export.c                  |   14 ++----------
>>   fs/nfsd/nfs4idmap.c               |   16 ++-----------
>>   include/linux/sunrpc/cache.h      |   11 +++------
>>   net/sunrpc/auth_gss/svcauth_gss.c |    8 +------
>>   net/sunrpc/cache.c                |   44 ++++++++++++++++++++-----------------
>>   net/sunrpc/svcauth_unix.c         |   14 ++----------
>>   7 files changed, 36 insertions(+), 73 deletions(-)
>>


-- 
Best regards,
Stanislav Kinsbursky
