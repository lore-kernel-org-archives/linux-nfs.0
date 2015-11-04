Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54576 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965410AbbKDVt3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Nov 2015 16:49:29 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (Postfix) with ESMTPS id 59F50744
	for <linux-nfs@vger.kernel.org>; Wed,  4 Nov 2015 21:49:29 +0000 (UTC)
Subject: Re: [nfs-utils PATCH] close the syslog fd in daemon_init()
To: Scott Mayhew <smayhew@redhat.com>
References: <1443540985-27992-1-git-send-email-smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <563A7D68.3080707@RedHat.com>
Date: Wed, 4 Nov 2015 16:49:28 -0500
MIME-Version: 1.0
In-Reply-To: <1443540985-27992-1-git-send-email-smayhew@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/29/2015 11:36 AM, Scott Mayhew wrote:
> Commit 7addf9d (cleanup daemonization code) added the following line to
> mydaemon_init():
> 
>         dup2(pipefds[1], 3);
> 
> If we've already called vsyslog() before the fork(), then chances are fd
> 3 was being used for the syslog socket.  In that case the next vsyslog()
> call will cause the data to appear on the read end of the pipe, causing
> the parent to exit with a nonzero status.  If systemd is running, it
> will see the parent's nonzero exit status and will terminate the child
> as well.
> 
> So just call closelog() to close the fd.  The next call to vsyslog()
> will open a new one if need be.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
Committed... Actual this is the one I fixed the warning on... 

steved.

> ---
>  support/nfs/mydaemon.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/support/nfs/mydaemon.c b/support/nfs/mydaemon.c
> index 3391eff..701cfd9 100644
> --- a/support/nfs/mydaemon.c
> +++ b/support/nfs/mydaemon.c
> @@ -122,6 +122,7 @@ daemon_init(bool fg)
>  	dup2(tempfd, 0);
>  	dup2(tempfd, 1);
>  	dup2(tempfd, 2);
> +	closelog();
>  	dup2(pipefds[1], 3);
>  	pipefds[1] = 3;
>  	closeall(4);
> 
