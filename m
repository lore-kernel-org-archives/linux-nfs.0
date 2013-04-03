Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42011 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757693Ab3DCOUI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Apr 2013 10:20:08 -0400
Date: Wed, 3 Apr 2013 10:20:03 -0400
To: Simo Sorce <simo@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] Document new -z/-Z options
Message-ID: <20130403142003.GC13951@fieldses.org>
References: <515B2F8D.3030302@RedHat.com>
 <1364931149-18484-3-git-send-email-simo@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1364931149-18484-3-git-send-email-simo@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 02, 2013 at 03:32:29PM -0400, Simo Sorce wrote:
> Options are not in alphabetical order but -z/-Z clearly always come last.
> 
> Signed-off-by: Simo Sorce <simo@redhat.com>
> ---
>  utils/gssd/gssd.man |   13 ++++++++++++-
>  1 files changed, 12 insertions(+), 1 deletions(-)
> 
> diff --git a/utils/gssd/gssd.man b/utils/gssd/gssd.man
> index 79d9bf91ac6b976c57d167e60d07f828a3ff5b1f..7918c2a0ff76c3918449cf3e1420f0a289929ac1 100644
> --- a/utils/gssd/gssd.man
> +++ b/utils/gssd/gssd.man
> @@ -8,7 +8,7 @@
>  rpc.gssd \- RPCSEC_GSS daemon
>  .SH SYNOPSIS
>  .B rpc.gssd
> -.RB [ \-fMnlvr ]
> +.RB [ \-fMnlvrzZ ]
>  .RB [ \-k
>  .IR keytab ]
>  .RB [ \-p
> @@ -266,6 +266,17 @@ new kernel contexts to be negotiated after
>  seconds, which allows changing Kerberos tickets and identities frequently.
>  The default is no explicit timeout, which means the kernel context will live
>  the lifetime of the Kerberos service ticket used in its creation.
> +.TP
> +.B -z
> +This option tries to avoid DNS Reverse (PTR) lookups for determining the 
> +server name to pass to GSSAPI if the name passed at mount point is not an IP 
> +address. Currently off by default for compatibility reasons.
> +.TP
> +.B -Z
> +This is the inverse of 
> +.B -z
> +and forces the use of DNS Reverse resolution of the server's IP address to
> +retrieve the server name to use in GSAPI authentication.

By the way I think with the "new" upcall, gssd ignores whatever it got
out of the info file if the "target=" parameter is provided in the
upcall.

(But looking at the code I think that's only used in the nfsv4.0
callback case, and isn't worth mentioning here.)

--b.

>  .SH SEE ALSO
>  .BR rpc.svcgssd (8),
>  .BR kerberos (1),
> -- 
> 1.7.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
