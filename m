From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 2/3] nfs-utils: NULL-terminate buffer after read in
 read_service_info
Date: Mon, 9 Mar 2009 12:17:44 -0400
Message-ID: <20090309121744.7eb814ca@tleilax.poochiereds.net>
References: <1236429928-4680-1-git-send-email-jlayton@redhat.com>
	<1236429928-4680-3-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: steved@redhat.com, linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	chuck.lever@oracle.com
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:51230 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751373AbZCIQRx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Mar 2009 12:17:53 -0400
In-Reply-To: <1236429928-4680-3-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat,  7 Mar 2009 07:45:27 -0500
Jeff Layton <jlayton@redhat.com> wrote:

> Valgrind complains that we're passing an unintialized buffer to
> sscanf here. The main problem seems to be that we're not ensuring
> that the buffer is NULL terminated before we pass it off.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  utils/gssd/gssd_proc.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index d0d3f7f..0ebdfcd 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -133,6 +133,7 @@ read_service_info(char *info_file_name, char **servicename, char **servername,
>  	if ((nbytes = read(fd, buf, INFOBUFLEN)) == -1)
>  		goto fail;
>  	close(fd);
> +	buf[nbytes] = '\0';
>  
>  	numfields = sscanf(buf,"RPC server: %127s\n"
>  		   "service: %127s %15s version %15s\n"

This is not quite right....

We need to expand buf by 1 char in case nbytes == INFOBUFLEN. I'll
respin and resend...

Cheers,
-- 
Jeff Layton <jlayton@redhat.com>
