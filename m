Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f176.google.com ([209.85.223.176]:65283 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754695AbaDGX2C convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Apr 2014 19:28:02 -0400
Received: by mail-ie0-f176.google.com with SMTP id rd18so144032iec.7
        for <linux-nfs@vger.kernel.org>; Mon, 07 Apr 2014 16:28:01 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH] NFS-RDMA: fix qp pointer validation checks
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <d4afd436-8e14-4729-9bc1-71ab9079a246@CMEXHTCAS1.ad.emulex.com>
Date: Mon, 7 Apr 2014 19:27:57 -0400
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Message-Id: <61E8946F-3722-4707-A948-065D395C365A@primarydata.com>
References: <d4afd436-8e14-4729-9bc1-71ab9079a246@CMEXHTCAS1.ad.emulex.com>
To: devesh.sharma@emulex.com
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 7, 2014, at 18:30, devesh.sharma@emulex.com wrote:

> From: Devesh Sharma <devesh.sharma@emulex.com>
> 
> If the rdma_create_qp fails to create qp due to device firmware being in invalid state
> xprtrdma still tries to destroy the non-existant qp and ends up in a NULL pointer reference
> crash.
> Adding proper checks for vaidating QP pointer avoids this to happen.
> 

As far as I can see, rdma_create_qp() only sets id->qp on success. Otherwise it is left with the same value as it had on entry (i.e. NULL). What am I missing?

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

