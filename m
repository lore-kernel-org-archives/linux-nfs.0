Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:17311 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752271AbaAXSe2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Jan 2014 13:34:28 -0500
Content-Type: text/plain; charset=US-ASCII
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH 0/3] NFS/RDMA bug fixes
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CABgxfbFbLKV98GavS0x_X_ZXw0hZXPEQCpfoJJi+uNp133qt2w@mail.gmail.com>
Date: Fri, 24 Jan 2014 13:34:18 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <18FE9D9E-F9E8-4E73-9B72-5829F356116A@oracle.com>
References: <20140117193555.3452.31437.stgit@manet.1015granger.net> <CABgxfbFbLKV98GavS0x_X_ZXw0hZXPEQCpfoJJi+uNp133qt2w@mail.gmail.com>
To: Wendy Cheng <s.wendy.cheng@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 24, 2014, at 1:26 PM, Wendy Cheng <s.wendy.cheng@gmail.com> wrote:

> On Fri, Jan 17, 2014 at 11:37 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
> This brief series fixes some long-standing regressions in our
> NFS/RDMA client implementation.  Comments / review?
> 
> ---
> 
> Chuck Lever (3):
>       SUNRPC: remove KERN_INFO from dprintk() call sites
>       SUNRPC: Fix large reads on NFS/RDMA
>       NFS: Fix READDIR oops with NFSv4 on RDMA
> 
> 
>  fs/nfs/nfs4xdr.c                |    3 +--
>  net/sunrpc/xprtrdma/rpc_rdma.c  |    4 +---
>  net/sunrpc/xprtrdma/transport.c |   10 +++++-----
>  3 files changed, 7 insertions(+), 10 deletions(-)
> 
> 
> We have an embedded system that is currently set at NFS V3 with kernel 2.6.38 (as NFS client). Could folks suggest a good kernel version (close to 2.6.38 or RHEL based) to pick up NFS v4 (in order to pick up NFS over RDMA) ? 

If NFS/RDMA is working in your kernel, I believe NFSv3 and NFSv4 should both work over RDMA.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



