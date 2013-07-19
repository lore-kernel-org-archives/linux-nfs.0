Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:32544 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751368Ab3GSX5E convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Jul 2013 19:57:04 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Subject: Re: [PATCH 1/1] NFSv4.1 Increase NFS4_DEF_SLOT_TABLE_SIZE
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1374268191-4469-1-git-send-email-andros@netapp.com>
Date: Fri, 19 Jul 2013 19:56:55 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <D8BB2DCD-4166-4425-8C08-EF0CCA9B926D@oracle.com>
References: <1374268191-4469-1-git-send-email-andros@netapp.com>
To: andros@netapp.com
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Andy-

On Jul 19, 2013, at 5:09 PM, andros@netapp.com wrote:

> From: Andy Adamson <andros@netapp.com>
> 
> max_session_slots is a ushort. Bump NFS4_DEF_SLOT_TABLE_SIZE to the max ushort
> value: e.g. ask for 256 slots and let the server negotiate down if needed.

I don't have an objection to your patch, but the description is confusing.

In fs/nfs/super.c I see

   unsigned short max_session_slots = NFS4_DEF_SLOT_TABLE_SIZE;

but /usr/include/limits.h has

   #define USHRT_MAX 65535

The maximum value you can store in an unsigned octet is 255 (UCHAR_MAX).

Why did you choose 256 and not 65535?


> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
> fs/nfs/nfs4session.h | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/nfs4session.h b/fs/nfs/nfs4session.h
> index 3a153d8..8b7899f 100644
> --- a/fs/nfs/nfs4session.h
> +++ b/fs/nfs/nfs4session.h
> @@ -8,7 +8,7 @@
> #define __LINUX_FS_NFS_NFS4SESSION_H
> 
> /* maximum number of slots to use */
> -#define NFS4_DEF_SLOT_TABLE_SIZE (16U)
> +#define NFS4_DEF_SLOT_TABLE_SIZE (256U)
> #define NFS4_MAX_SLOT_TABLE (1024U)
> #define NFS4_NO_SLOT ((u32)-1)
> 
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




