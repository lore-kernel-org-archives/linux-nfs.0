Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f179.google.com ([209.85.216.179]:36771 "EHLO
        mail-qt0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935481AbdGTKcs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Jul 2017 06:32:48 -0400
Received: by mail-qt0-f179.google.com with SMTP id 21so18092637qtx.3
        for <linux-nfs@vger.kernel.org>; Thu, 20 Jul 2017 03:32:47 -0700 (PDT)
Message-ID: <1500546765.4840.0.camel@redhat.com>
Subject: Re: [PATCH 11/11] nfsdcltrack.c: remove a warning
From: Jeff Layton <jlayton@redhat.com>
To: Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Date: Thu, 20 Jul 2017 06:32:45 -0400
In-Reply-To: <20170719205354.10006-12-steved@redhat.com>
References: <20170719205354.10006-1-steved@redhat.com>
         <20170719205354.10006-12-steved@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2017-07-19 at 16:53 -0400, Steve Dickson wrote:
> nfsdcltrack.c:581:4: warning: this statement may fall through [-Wimplicit-fallthrough=]
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  utils/nfsdcltrack/nfsdcltrack.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/utils/nfsdcltrack/nfsdcltrack.c b/utils/nfsdcltrack/nfsdcltrack.c
> index 124c923..0baaa3e 100644
> --- a/utils/nfsdcltrack/nfsdcltrack.c
> +++ b/utils/nfsdcltrack/nfsdcltrack.c
> @@ -579,6 +579,7 @@ main(int argc, char **argv)
>  		switch (arg) {
>  		case 'd':
>  			xlog_config(D_ALL, 1);
> +			break;
>  		case 'f':
>  			xlog_syslog(0);
>  			xlog_stderr(1);

Acked-by: Jeff Layton <jlayton@redhat.com>
