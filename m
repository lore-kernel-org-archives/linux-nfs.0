Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:17132 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751632AbbAIUk7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Jan 2015 15:40:59 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH v1 00/10] NFS/RDMA server for 3.20
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20150109203958.GB30452@fieldses.org>
Date: Fri, 9 Jan 2015 15:40:51 -0500
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <629A4CE4-ECB9-4A1D-9179-CFAD2FC7AD91@oracle.com>
References: <20150109191910.4901.29548.stgit@klimt.1015granger.net> <20150109203958.GB30452@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 9, 2015, at 3:39 PM, J. Bruce Fields <bfields@fieldses.org> wrote:

> On Fri, Jan 09, 2015 at 02:21:54PM -0500, Chuck Lever wrote:
>> In addition to miscellaneous clean up, the following series of
>> patches for the Linux NFS server introduces support in the
>> server’s RPC/RDMA transport implementation for RDMA_NOMSG type
>> messages, and fixes a bug that prevents the server from handling
>> RPC/RDMA messages with inline content following a read list.
>> 
>> These patches are contained in the branch "nfsd-rdma-for-3.20" at:
>> 
>>  git://git.linux-nfs.org/projects/cel/cel-2.6.git
> 
> They look OK to me; applying unless someone tells me otherwise.

I’d like to update the patch descriptions in several of these before
you apply the series.

> 
> --b.
> 
>> 
>> ---
>> 
>> Chuck Lever (10):
>>      svcrdma: Handle additional inline content
>>      Move read list XDR round-up logic
>>      svcrdma: Support RDMA_NOMSG requests
>>      svcrdma: rc_position sanity checking
>>      svcrdma: Plant reader function in struct svcxprt_rdma
>>      svcrdma: Find rmsgp more reliably
>>      svcrdma: Scrub BUG_ON() and WARN_ON() call sites
>>      svcrdma: Clean up read chunk counting
>>      svcrdma: Remove unused variable
>>      svcrdma: Clean up dprintk
>> 
>> 
>> include/linux/sunrpc/svc_rdma.h          |   13 +-
>> net/sunrpc/xprtrdma/svc_rdma_marshal.c   |   16 --
>> net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |  251 +++++++++++++++++++-----------
>> net/sunrpc/xprtrdma/svc_rdma_sendto.c    |   46 +++--
>> net/sunrpc/xprtrdma/svc_rdma_transport.c |   47 +++---
>> 5 files changed, 224 insertions(+), 149 deletions(-)
>> 
>> --
>> Chuck Lever
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



