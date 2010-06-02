From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 1/1] nfsiostat.man: Add linebreak before --version option
Date: Wed, 02 Jun 2010 08:36:56 -0400
Message-ID: <4C065068.5040603@RedHat.com>
References: <1274923700-18972-1-git-send-email-kevin.constantine@disneyanimation.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, chuck.lever@oracle.com,
	Kevin Constantine <Kevin.Constantine-P5ys19MLBK/QT0dZR+AlfA@public.gmane.org>
To: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31705 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751457Ab0FBMhP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Jun 2010 08:37:15 -0400
In-Reply-To: <1274923700-18972-1-git-send-email-kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/26/2010 09:28 PM, Kevin Constantine wrote:
> The nfsiostat man file was missing a linebreak before the --verbose option
> 
> Signed-off-by: Kevin Constantine <kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
> ---
>  tools/nfs-iostat/nfsiostat.man |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/tools/nfs-iostat/nfsiostat.man b/tools/nfs-iostat/nfsiostat.man
> index 7b1e0a8..99e04fb 100644
> --- a/tools/nfs-iostat/nfsiostat.man
> +++ b/tools/nfs-iostat/nfsiostat.man
> @@ -57,6 +57,7 @@ displays statistics related to the page cache
>  .TP
>  .B \-s " or " \-\-sort
>  Sort NFS mount points by ops/second
> +.TP
>  .B \-\-version
>  show program's version number and exit
>  .SH FILES
Committed...

steved.
