Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:50913 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756604Ab2HNR2F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Aug 2012 13:28:05 -0400
Date: Tue, 14 Aug 2012 13:28:02 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "bjschuma@gmail.com" <bjschuma@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] NFS: Alias the nfs module to nfs4
Message-ID: <20120814132802.616b718a@tlielax.poochiereds.net>
In-Reply-To: <CAMFXNOyz7iC45dd+9XWONXSxkL-XZHWb_W3rYrvP+QmLH39b5Q@mail.gmail.com>
References: <CAMFXNOxxP=+u37Ju_-15RViFrVtmAAufsGiYRQoE87QurFBphw@mail.gmail.com>
	<CAMFXNOyz7iC45dd+9XWONXSxkL-XZHWb_W3rYrvP+QmLH39b5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 8 Aug 2012 14:01:42 -0400
"bjschuma@gmail.com" <bjschuma@gmail.com> wrote:

> I forgot to CC the mailing list... oops.
> 
> 
> ---------- Forwarded message ----------
> From: bjschuma@gmail.com <bjschuma@gmail.com>
> Date: Wed, Aug 8, 2012 at 1:57 PM
> Subject: [PATCH 2/2] NFS: Alias the nfs module to nfs4
> To: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: "J. Bruce Fields" <bfields@fieldses.org>, jlayton@redhat.com
> 
> 
> This allows distros to remove the line from their modprobe
> configuration.
> 
> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> ---
>  fs/nfs/super.c  | 2 ++
>  1 files changed, 2 insertions(+)
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index c4a15c5..239aff7 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -2680,4 +2680,6 @@ MODULE_PARM_DESC(max_session_slots, "Maximum
> number of outstanding NFSv4.1 "
>  module_param(send_implementation_id, ushort, 0644);
>  MODULE_PARM_DESC(send_implementation_id,
>                 "Send implementation ID with NFSv4.1 exchange_id");
> +MODULE_ALIAS("nfs4");
> +
>  #endif /* CONFIG_NFS_V4 */
> --
> 1.7.11.4
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

ACK...

Should this also go to stable?
-- 
Jeff Layton <jlayton@redhat.com>
