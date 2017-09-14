Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38628 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751323AbdINRMF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Sep 2017 13:12:05 -0400
Subject: Re: [PATCH] nfsman: document minorversion
To: "Jianhong.Yin" <yin-jianhong@163.com>
Cc: linux-nfs@vger.kernel.org
References: <20170907065729.4636-1-yin-jianhong@163.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <558c70e5-c278-0a8c-5ed0-af7637dccd23@RedHat.com>
Date: Thu, 14 Sep 2017 13:12:05 -0400
MIME-Version: 1.0
In-Reply-To: <20170907065729.4636-1-yin-jianhong@163.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/07/2017 02:57 AM, Jianhong.Yin wrote:
> Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
> ---
>  utils/mount/nfs.man | 17 +++++++++++++++++
>  1 file changed, 17 insertions(+)
Committed....

steved.
> 
> diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
> index cc6e992..7d42f19 100644
> --- a/utils/mount/nfs.man
> +++ b/utils/mount/nfs.man
> @@ -779,6 +779,23 @@ so if this mount option is not specified, the NFS version 4 client
>  uses the TCP protocol.
>  Refer to the TRANSPORT METHODS section for more details.
>  .TP 1.5i
> +.BI minorversion= n
> +Specifies the protocol minor version number.
> +NFSv4 introduces "minor versioning," where NFS protocol enhancements can
> +be introduced without bumping the NFS protocol version number.
> +Before kernel 2.6.38, the minor version is always zero, and this
> +option is not recognized.
> +After this kernel, specifying "minorversion=1" enables a number of
> +advanced features, such as NFSv4 sessions.
> +.IP
> +Recent kernels allow the minor version to be specified using the
> +.B vers=
> +option.
> +For example, specifying
> +.B vers=4.1
> +is the same as specifying
> +.BR vers=4,minorversion=1 .
> +.TP 1.5i
>  .BI port= n
>  The numeric value of the server's NFS service port.
>  If the server's NFS service is not available on the specified port,
> 
