From: Greg Banks <gnb@sgi.com>
Subject: Re: [PATCH 2/2] nfsstat: Add --list flag
Date: Wed, 18 Mar 2009 13:43:20 +1100
Message-ID: <49C05FC8.6010503@sgi.com>
References: <49BF2478.8080600@sgi.com> <1237275989-16421-1-git-send-email-kevin.constantine@disneyanimation.com> <1237275989-16421-2-git-send-email-kevin.constantine@disneyanimation.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, steved@redhat.com,
	Kevin Constantine <Kevin.Constantine-P5ys19MLBK/QT0dZR+AlfA@public.gmane.org>
To: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:41335 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753241AbZCRCdy (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Tue, 17 Mar 2009 22:33:54 -0400
In-Reply-To: <1237275989-16421-2-git-send-email-kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Kevin Constantine wrote:
> nfsstat.c: Adds the --list flag to print information in a list format instead of the standard multi-column format
> nfsstat.man: Updates the manpage to include the --list flag.
>
> Signed-off-by: Kevin Constantine <kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
> ---
>  utils/nfsstat/nfsstat.c   |   80 +++++++++++++++++++++++++++++++++++++++++++--
>  utils/nfsstat/nfsstat.man |    3 ++
>  2 files changed, 80 insertions(+), 3 deletions(-)
>   
Acked-by: Greg Banks <gnb@sgi.com>

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.

