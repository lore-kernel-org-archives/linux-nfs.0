Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57702 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752633Ab1DKDFI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 10 Apr 2011 23:05:08 -0400
Message-ID: <4DA2703B.8070300@cn.fujitsu.com>
Date: Mon, 11 Apr 2011 11:06:35 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: Re: [PATCH 1/5] nfsd: distinguish functions of NFSD_MAY_* flags
References: <20110410162536.GC26233@fieldses.org> <1302452973-27272-1-git-send-email-bfields@redhat.com>
In-Reply-To: <1302452973-27272-1-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset=Shift_JIS
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



J. Bruce Fields ŽÊ“¹:
> Most of the NFSD_MAY_* flags actually request permissions, but over the
> years we've accreted a few that modify the behavior of the permission or
> open code in other ways.
> 
> Distinguish the two cases a little more.  In particular, allow the
> shortcut at the start of nfsd_permission to ignore the
> non-permission-requesting bits.
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/nfsd/vfs.c |    2 +-
>  fs/nfsd/vfs.h |    3 +++
>  2 files changed, 4 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 2e1cebd..ac4f0b4 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -2027,7 +2027,7 @@ nfsd_permission(struct svc_rqst *rqstp, struct svc_export *exp,
>  	struct inode	*inode = dentry->d_inode;
>  	int		err;
>  
> -	if (acc == NFSD_MAY_NOP)
> +	if (acc & NFSD_MAY_MASK == NFSD_MAY_NOP)
>  		return 0;

  Maybe there is a problem, the priority of '==' is higher than '&', 
  this line equal to "if (acc & (NFSD_MAY_MASK == NFSD_MAY_NOP))",
  "return 0" will appears every time, I think it's not we really want.

  "if ((acc & NFSD_MAY_MASK) == NFSD_MAY_NOP)" is we need,
  do you think so?

-- 
----
thanks
Mi Jinlong

>  #if 0
>  	dprintk("nfsd: permission 0x%x%s%s%s%s%s%s%s mode 0%o%s%s%s\n",
> diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
> index 9a370a5..1036913 100644
> --- a/fs/nfsd/vfs.h
> +++ b/fs/nfsd/vfs.h
> @@ -17,6 +17,9 @@
>  #define NFSD_MAY_SATTR		8
>  #define NFSD_MAY_TRUNC		16
>  #define NFSD_MAY_LOCK		32
> +#define NFSD_MAY_MASK		63
> +
> +/* extra hints to permission and open routines: */
>  #define NFSD_MAY_OWNER_OVERRIDE	64
>  #define NFSD_MAY_LOCAL_ACCESS	128 /* IRIX doing local access check on device special file*/
>  #define NFSD_MAY_BYPASS_GSS_ON_ROOT 256

-- 
----
thanks
Mi Jinlong

