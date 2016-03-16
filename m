Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52469 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934845AbcCPSVA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Mar 2016 14:21:00 -0400
Subject: Re: [PATCH nfs-utils v2] statd: Don't unregister statd service on
 failing to execute callout
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
References: <1455582968-4474-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <56E9A40A.5040405@RedHat.com>
Date: Wed, 16 Mar 2016 14:20:58 -0400
MIME-Version: 1.0
In-Reply-To: <1455582968-4474-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/15/2016 07:36 PM, Toshiaki Makita wrote:
> statd calls atexit(statd_unregister) to unregister statd service on exit,
> which actually has a side-effect that ha_callout() unregisters statd
> service even when the child callout process exits on execl() failure.
> 
> Certain clustering software's deployment script adds -H option with its
> specified file non-existent, when it is configured not to use callout.
> In other words, -H seems to be used no matter if callout is needed or not,
> but when callout is unnecessary, the specified callout program is not
> deployed.
> This causes statd not to work once a lock is requested by its NFS client,
> as execl() in ha_callout() results in ENOENT and exit() of the child
> process calls exit-handler statd_unregister(). Eventually, the NFS client
> gets stuck with messages "lockd: cannot monitor xxx" on the NFS server.
> 
> Also, execl() could fail for other reasons like ENFILE or EIO as well.
> 
> A forked child must not unregister the statd RPC server, so use
> _exit(), which does not call any exit-handlers, instead of exit().
> 
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
Committed.... 

steved.
> ---
> v2:
> - Simplified changelog.
> 
>  support/include/ha-callout.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/support/include/ha-callout.h b/support/include/ha-callout.h
> index 1164336..a454bdb 100644
> --- a/support/include/ha-callout.h
> +++ b/support/include/ha-callout.h
> @@ -47,7 +47,7 @@ ha_callout(char *event, char *arg1, char *arg2, int arg3)
>  			      arg3 < 0 ? NULL : buf,
>  			      NULL);
>  			perror("execl");
> -			exit(2);
> +			_exit(2);
>  		case -1: perror("fork");
>  			break;
>  		default: pid = waitpid(pid, &ret, 0);
> 
