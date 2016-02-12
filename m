Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:37369 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750771AbcBLPkg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Feb 2016 10:40:36 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.2 \(3112\))
Subject: Re: [PATCH nfs-utils] statd: Don't unregister statd service on failing to execute callout
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1455259282-7237-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Date: Fri, 12 Feb 2016 10:40:01 -0500
Cc: Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <989760D9-029D-43E2-ABA3-8DC9F579BE68@oracle.com>
References: <1455259282-7237-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-


> On Feb 12, 2016, at 1:41 AM, Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp> wrote:
> 
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
> Although this may not be an expected way of using -H option, it would be
> better if statd could continue to work even in that situation. Also,
> execl() could fail for other reasons like ENFILE and EIO, where statd
> service should not be unregistered as well.
> Call _exit(), which does not call any exit-handlers, instead of exit() to
> take care of those situations and make statd more reliable.

OK, but I think the explanation could be simpler? It doesn't
seem like a matter of "it would be better if" but more like
"a forked child must not unregister the statd RPC server."
In other words, this seems like a real bug to me, not an
enhancement.

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>


> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> ---
> support/include/ha-callout.h |    2 +-
> 1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/support/include/ha-callout.h b/support/include/ha-callout.h
> index 1164336..a454bdb 100644
> --- a/support/include/ha-callout.h
> +++ b/support/include/ha-callout.h
> @@ -47,7 +47,7 @@ ha_callout(char *event, char *arg1, char *arg2, int arg3)
> 			      arg3 < 0 ? NULL : buf,
> 			      NULL);
> 			perror("execl");
> -			exit(2);
> +			_exit(2);
> 		case -1: perror("fork");
> 			break;
> 		default: pid = waitpid(pid, &ret, 0);
> -- 
> 1.7.1
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever




