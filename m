Return-Path: linux-nfs-owner@vger.kernel.org
Received: from p02c11o145.mxlogic.net ([208.65.144.78]:51304 "EHLO
	p02c11o145.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754050Ab2COSay convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Mar 2012 14:30:54 -0400
From: Peter Staubach <pstaubach@exagrid.com>
To: Steve Dickson <SteveD@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Date: Thu, 15 Mar 2012 14:29:07 -0400
Subject: RE: [PATCH 1/1] nfsd: Warn when no servers are specified on the
 command line
Message-ID: <FA8A9A935BFD3A4D8F0CDA1C4F611BCC062D5C8012@IT-1874.Isys.com>
References: <1331832223-20737-1-git-send-email-steved@redhat.com>
 <FA8A9A935BFD3A4D8F0CDA1C4F611BCC062D5C800D@IT-1874.Isys.com>
 <4F6232CF.7010509@RedHat.com>
In-Reply-To: <4F6232CF.7010509@RedHat.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I suspect that no arguments are being specified by nfsd, then they didn't do much configuration.  :-)

Hmmm, I guess, without having checked, I had assumed that the default was 8.  1 seems like a pretty questionable default.

	Thanx...

		ps


-----Original Message-----
From: Steve Dickson [mailto:SteveD@redhat.com] 
Sent: Thursday, March 15, 2012 2:20 PM
To: Peter Staubach
Cc: Linux NFS Mailing list
Subject: Re: [PATCH 1/1] nfsd: Warn when no servers are specified on the command line



On 03/15/2012 02:01 PM, Peter Staubach wrote:
> I am curious why such a message is required?  
To let people know their NFS server may not be configured as expected.

> Isn't the reason for having a default is so that the option does not need to specified?
I guess... but starting one nfsd is probably not what people want to do... Maybe bumping the default up to a more reasonable number could work... 

steved.

> 
> 	Thanx...
> 
> 		ps
> 
> 
> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org 
> [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Steve Dickson
> Sent: Thursday, March 15, 2012 1:24 PM
> To: Linux NFS Mailing list
> Subject: [PATCH 1/1] nfsd: Warn when no servers are specified on the 
> command line
> 
> When the number of servers are not specified on the command, log a 
> warning message that the default number of services will be started
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  utils/nfsd/nfsd.c |    7 +++++--
>  1 files changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c index 
> 8bc5d3a..c744ee1 100644
> --- a/utils/nfsd/nfsd.c
> +++ b/utils/nfsd/nfsd.c
> @@ -188,6 +188,8 @@ main(int argc, char **argv)
>  		}
>  	}
>  
> +	xlog_open(progname);
> +
>  	if (optind < argc) {
>  		if ((count = atoi(argv[optind])) < 0) {
>  			/* insane # of servers */
> @@ -203,10 +205,11 @@ main(int argc, char **argv)
>  			socket_up = 1;
>  			goto set_threads;
>  		}
> +	} else {
> +		xlog(L_WARNING, "No server number specified. '%d' nfsd will be started",
> +			count);
>  	}
>  
> -	xlog_open(progname);
> -
>  	nfsd_enable_protos(&proto4, &proto6);
>  
>  	if (!NFSCTL_TCPISSET(protobits)) {
> --
> 1.7.7.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" 
> in the body of a message to majordomo@vger.kernel.org More majordomo 
> info at  http://vger.kernel.org/majordomo-info.html
