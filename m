Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:22693 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751370Ab2CHUzq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Mar 2012 15:55:46 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q28Kti9F000627
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 8 Mar 2012 15:55:46 -0500
Message-ID: <4F591CD5.7070102@RedHat.com>
Date: Thu, 08 Mar 2012 15:55:49 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] rpcbind: drop supplemental groups
References: <1331217450-20798-1-git-send-email-steved@redhat.com>
In-Reply-To: <1331217450-20798-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/08/2012 09:37 AM, Steve Dickson wrote:
> Drop out of the 'root' group to ensure the process does
> not have any access to writable or readable files
> to that group.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed....

steved.
> ---
>  src/rpcbind.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/src/rpcbind.c b/src/rpcbind.c
> index 24e069b..9a0504d 100644
> --- a/src/rpcbind.c
> +++ b/src/rpcbind.c
> @@ -236,6 +236,10 @@ main(int argc, char *argv[])
>                          syslog(LOG_ERR, "setgid to '%s' (%d) failed: %m", id, p->pw_gid);
>                          exit(1);
>                  }
> +		if (setgroups(0, NULL) == -1) {
> +			syslog(LOG_ERR, "dropping supplemental groups failed: %m");
> +			exit(1);
> +		}
>  		if (setuid(p->pw_uid) == -1) {
>  			syslog(LOG_ERR, "setuid to '%s' (%d) failed: %m", id, p->pw_uid);
>  			exit(1);
