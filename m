Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:46827 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752662AbdLEPKg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Dec 2017 10:10:36 -0500
Received: by mail-wm0-f65.google.com with SMTP id r78so1894013wme.5
        for <linux-nfs@vger.kernel.org>; Tue, 05 Dec 2017 07:10:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171204191330.18629.77069.stgit@manet.1015granger.net>
References: <20171204190904.18629.70341.stgit@manet.1015granger.net> <20171204191330.18629.77069.stgit@manet.1015granger.net>
From: Devesh Sharma <devesh.sharma@broadcom.com>
Date: Tue, 5 Dec 2017 20:39:54 +0530
Message-ID: <CANjDDBg3qsn5oWzmTSi5e3eKJKkdEceh0GUTe+pFDAGCxkDqGg@mail.gmail.com>
Subject: Re: [PATCH v1 1/4] nfs: Define NFS_RDMA_PORT
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

Will this change avoid the "echo rdma 20049" on the nfs server during
nfs server start?

-Regards
Devesh

On Tue, Dec 5, 2017 at 12:43 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
> The NFS/RDMA port assignment is specified in Section 9 of RFC 8267.
>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  include/uapi/linux/nfs.h |    1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/include/uapi/linux/nfs.h b/include/uapi/linux/nfs.h
> index 057d22a..946cb62 100644
> --- a/include/uapi/linux/nfs.h
> +++ b/include/uapi/linux/nfs.h
> @@ -12,6 +12,7 @@
>
>  #define NFS_PROGRAM    100003
>  #define NFS_PORT       2049
> +#define NFS_RDMA_PORT  20049
>  #define NFS_MAXDATA    8192
>  #define NFS_MAXPATHLEN 1024
>  #define NFS_MAXNAMLEN  255
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
