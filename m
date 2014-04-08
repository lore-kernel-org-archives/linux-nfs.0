Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:47441 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755174AbaDHAAy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Apr 2014 20:00:54 -0400
Received: by mail-ie0-f177.google.com with SMTP id rl12so168253iec.8
        for <linux-nfs@vger.kernel.org>; Mon, 07 Apr 2014 17:00:53 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH] NFS-RDMA: fix qp pointer validation checks
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <EE7902D3F51F404C82415C4803930ACD3FDE9AE4@CMEXMB1.ad.emulex.com>
Date: Mon, 7 Apr 2014 20:00:50 -0400
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>
Message-Id: <20CBB511-EB06-485E-A2F9-B8D66806D5B6@primarydata.com>
References: <d4afd436-8e14-4729-9bc1-71ab9079a246@CMEXHTCAS1.ad.emulex.com> <61E8946F-3722-4707-A948-065D395C365A@primarydata.com> <EE7902D3F51F404C82415C4803930ACD3FDE9AE4@CMEXMB1.ad.emulex.com>
To: Devesh Sharma <Devesh.Sharma@Emulex.Com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 7, 2014, at 19:45, Devesh Sharma <Devesh.Sharma@Emulex.Com> wrote:

> Hi
> Inline Below:
> 
> -----Original Message-----
> From: Trond Myklebust [mailto:trond.myklebust@primarydata.com] 
> Sent: Tuesday, April 08, 2014 4:58 AM
> To: Devesh Sharma
> Cc: linux-nfs@vger.kernel.org; linux-rdma@vger.kernel.org
> Subject: Re: [PATCH] NFS-RDMA: fix qp pointer validation checks
> 
> 
> On Apr 7, 2014, at 18:30, devesh.sharma@emulex.com wrote:
> 
>> From: Devesh Sharma <devesh.sharma@emulex.com>
>> 
>> If the rdma_create_qp fails to create qp due to device firmware being 
>> in invalid state xprtrdma still tries to destroy the non-existant qp 
>> and ends up in a NULL pointer reference crash.
>> Adding proper checks for vaidating QP pointer avoids this to happen.
>> 
> 
> As far as I can see, rdma_create_qp() only sets id->qp on success. Otherwise it is left with the same value as it had on entry (i.e. NULL). What am I missing?
> [DS]: If you focus on rpcrdma_ep_connect() function and assume that rdma_create_qp() has failed with some valid error code, then this callback function will return ep->rep_connected = some non-zero.
> Eventually xprt_rdma_connect_worker() will call rpcrdma_ep_connect() again and rpcrdma_ep_connect will try to free-up all the resources, now rdma_destroy_qp() will be called with invalid QP (which is NULL) pointer
> And hence kernel will panic. Please correct me if I am worng.
> 

AFAICS your patch does nothing to address that problem. Instead it adds tests for IS_ERR(ia->ri_id->qp), which can never happen because ia->ri_id->qp is either NULL or points to a valid structure.

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

