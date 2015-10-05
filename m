Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:34356 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751534AbbJEPDM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Oct 2015 11:03:12 -0400
Received: by wicfx3 with SMTP id fx3so124493467wic.1
        for <linux-nfs@vger.kernel.org>; Mon, 05 Oct 2015 08:03:11 -0700 (PDT)
Subject: Re: [PATCH] svcrdma: Fix NFS server crash triggered by 1MB NFS WRITE
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        linux-rdma@vger.kernel.org
References: <20151005025022.5074.89318.stgit@klimt.1015granger.net>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <5612912B.7080105@dev.mellanox.co.il>
Date: Mon, 5 Oct 2015 18:03:07 +0300
MIME-Version: 1.0
In-Reply-To: <20151005025022.5074.89318.stgit@klimt.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/5/2015 6:03 AM, Chuck Lever wrote:
> Now that the NFS server advertises a maximum payload size of 1MB
> for RPC/RDMA again, it crashes in svc_process_common() when NFS
> client sends a 1MB NFS WRITE on an NFS/RDMA mount.
>
> The server has set up a 259 element array of struct page pointers
> in rq_pages[] for each incoming request. The last element of the
> array is NULL.
>
> When an incoming request has been completely received,
> rdma_read_complete() attempts to set the starting page of the
> incoming page vector:
>
>    rqstp->rq_arg.pages = &rqstp->rq_pages[head->hdr_count];
>
> and the page to use for the reply:
>
>    rqstp->rq_respages = &rqstp->rq_arg.pages[page_no];
>
> But the value of page_no has already accounted for head->hdr_count.
> Thus rq_respages now points past the end of the incoming pages. For
> NFS WRITE operations smaller than the maximum, this is harmless.
>
> But when the NFS WRITE operation is as large as the server's max
> payload size, rq_respages now points at the last entry in rq_pages,
> which is NULL.
>
> Fixes: cc9a903d915c ('svcrdma: Change maximum server payload . . .')
> BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=270
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---

Looks correct,

Reviewed-by: Sagi Grimberg <sagig@mellanox.com>
