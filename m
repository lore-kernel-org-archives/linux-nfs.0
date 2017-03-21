Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:51972 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757993AbdCUSox (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Mar 2017 14:44:53 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v1 03/14] svcrdma: Eliminate RPCRDMA_SQ_DEPTH_MULT
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <46eb6195-a542-b35c-4902-a2bebb38feba@grimberg.me>
Date: Tue, 21 Mar 2017 14:44:45 -0400
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <391F0D90-2A46-4B2F-BCF0-B3BE7D48A3EF@oracle.com>
References: <20170316154132.4482.56769.stgit@klimt.1015granger.net> <20170316155250.4482.49638.stgit@klimt.1015granger.net> <46eb6195-a542-b35c-4902-a2bebb38feba@grimberg.me>
To: Sagi Grimberg <sagi@grimberg.me>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Mar 21, 2017, at 1:58 PM, Sagi Grimberg <sagi@grimberg.me> wrote:
> 
> 
>> The Send Queue depth is temporarily reduced to 1 SQE per credit. The
>> new rdma_rw API does an internal computation, during QP creation, to
>> increase the depth of the Send Queue to handle RDMA Read and Write
>> operations.
>> 
>> This change has to come before the NFSD code paths are updated to
>> use the rdma_rw API. Without this patch, rdma_rw_init_qp() increases
>> the size of the SQ too much, resulting in memory allocation failures
>> during QP creation.
> 
> I agree this needs to happen, but turns out you don't have any
> guarantees of the maximum size of the sq depending on your max_sge
> parameter.

That's true. However, this is meant to be temporary while I'm
working out details of the rdma_rw API conversion. More work
in this area comes in the next series:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfsd-rdma-rw-api


> I'd recommend having a fall-back shrinked size sq allocation
> impllemented like srpt does.

Agree it should be done. Would it be OK to wait until the dust
settles here, or do you think it's a hard requirement for
accepting this series?


> We don't have it in nvmet-rdma nor iser, but its a good thing to have...


--
Chuck Lever



