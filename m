Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:24049 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754988AbaDGXpk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Apr 2014 19:45:40 -0400
From: Devesh Sharma <Devesh.Sharma@Emulex.Com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>
Subject: RE: [PATCH] NFS-RDMA: fix qp pointer validation checks
Date: Mon, 7 Apr 2014 23:45:38 +0000
Message-ID: <EE7902D3F51F404C82415C4803930ACD3FDE9AE4@CMEXMB1.ad.emulex.com>
References: <d4afd436-8e14-4729-9bc1-71ab9079a246@CMEXHTCAS1.ad.emulex.com>
 <61E8946F-3722-4707-A948-065D395C365A@primarydata.com>
In-Reply-To: <61E8946F-3722-4707-A948-065D395C365A@primarydata.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi
Inline Below:

-----Original Message-----
From: Trond Myklebust [mailto:trond.myklebust@primarydata.com] 
Sent: Tuesday, April 08, 2014 4:58 AM
To: Devesh Sharma
Cc: linux-nfs@vger.kernel.org; linux-rdma@vger.kernel.org
Subject: Re: [PATCH] NFS-RDMA: fix qp pointer validation checks


On Apr 7, 2014, at 18:30, devesh.sharma@emulex.com wrote:

> From: Devesh Sharma <devesh.sharma@emulex.com>
> 
> If the rdma_create_qp fails to create qp due to device firmware being 
> in invalid state xprtrdma still tries to destroy the non-existant qp 
> and ends up in a NULL pointer reference crash.
> Adding proper checks for vaidating QP pointer avoids this to happen.
> 

As far as I can see, rdma_create_qp() only sets id->qp on success. Otherwise it is left with the same value as it had on entry (i.e. NULL). What am I missing?
[DS]: If you focus on rpcrdma_ep_connect() function and assume that rdma_create_qp() has failed with some valid error code, then this callback function will return ep->rep_connected = some non-zero.
Eventually xprt_rdma_connect_worker() will call rpcrdma_ep_connect() again and rpcrdma_ep_connect will try to free-up all the resources, now rdma_destroy_qp() will be called with invalid QP (which is NULL) pointer
And hence kernel will panic. Please correct me if I am worng.

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData trond.myklebust@primarydata.com

