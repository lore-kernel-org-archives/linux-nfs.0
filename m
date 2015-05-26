Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:16384 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752249AbbEZPg4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 May 2015 11:36:56 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH v2 00/16] NFS/RDMA patches proposed for 4.2
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1432654106.28905.111.camel@redhat.com>
Date: Tue, 26 May 2015 11:37:37 -0400
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <46639D36-E0C0-4201-B1BE-9E1775F03277@oracle.com>
References: <20150511174401.31263.79596.stgit@manet.1015granger.net> <1432654106.28905.111.camel@redhat.com>
To: Doug Ledford <dledford@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 26, 2015, at 11:28 AM, Doug Ledford <dledford@redhat.com> wrote:

> On Mon, 2015-05-11 at 14:02 -0400, Chuck Lever wrote:
>> I'd like these patches to be considered for merging upstream. This
>> patch series includes:
>> 
>>  - JIT allocation of rpcrdma_mw structures
>>  - Break-up of rb_lock
>>  - Reduction of how many rpcrdma_mw structs are needed per transport
>> 
>> These are pre-requisites for increasing the RPC slot count and
>> r/wsize on RPC/RDMA transports, and provide scalability benefits
>> even on their own. And:
>> 
>>  - A generic transport fault injector
>> 
>> This is useful to discover regressions in logic that handles
>> transport reconnection.
>> 
>> You can find these in my git repo in the "nfs-rdma-for-4.2" topic
>> branch. See:
>> 
>>  git://git.linux-nfs.org/projects/cel/cel-2.6.git
> 
> I assume you are planning on this going in through the nfs tree.  As
> such, I'm planning on removing this patchset from the linux-rdma
> patchworks site.

Yes, patches to net/sunrpc/xprtrdma/ will typically go through
Anna or Bruce. I post to linux-rdma for review of RDMA-related
changes.

> However, I'll add this for the series:
> 
> Reviewed-by: Doug Ledford <dledford@redhat.com>

Thanks, I will post a refresh today.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



