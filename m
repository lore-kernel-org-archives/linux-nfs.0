From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 08/24] Removed warnings from mountd.c
Date: Wed, 21 Jul 2010 13:12:51 -0400
Message-ID: <20100721171251.GB26418@fieldses.org>
References: <1279669057-17509-1-git-send-email-steved@redhat.com>
 <1279669057-17509-9-git-send-email-steved@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:40290 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752053Ab0GURNe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Jul 2010 13:13:34 -0400
In-Reply-To: <1279669057-17509-9-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 20, 2010 at 07:37:21PM -0400, Steve Dickson wrote:
> mountd.c: In function 'mount_null_1_svc':
> mountd.c:195: warning: unused parameter 'rqstp'
> mountd.c:195: warning: unused parameter 'argp'
> mountd.c:195: warning: unused parameter 'resp'
> mountd.c: In function 'mount_dump_1_svc':
> mountd.c:213: warning: unused parameter 'argp'
...
> @@ -214,7 +217,8 @@ mount_dump_1_svc(struct svc_req *rqstp, void *argp, mountlist *res)
>  {
>  	struct sockaddr_in *addr = nfs_getrpccaller_in(rqstp->rq_xprt);
>  
> -	xlog(D_CALL, "dump request from %s.", inet_ntoa(addr->sin_addr));
> +	xlog(D_CALL, "MNT1(%s) dump request: argp %p", 
> +		inet_ntoa(addr->sin_addr), argp);

Since those are unused, adding them to the debugging log doesn't add any
useful information.

The extra warnings is maybe a useful exercise to do every now and then
to check if it turns up bugs, but I'm not sure forcing all the code to
pass those tests is worthwhile.

--b.
