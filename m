From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 08/24] Removed warnings from mountd.c
Date: Wed, 21 Jul 2010 13:23:52 -0400
Message-ID: <4C472D28.6050608@oracle.com>
References: <1279669057-17509-1-git-send-email-steved@redhat.com> <1279669057-17509-9-git-send-email-steved@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:48843 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753305Ab0GURYk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Jul 2010 13:24:40 -0400
In-Reply-To: <1279669057-17509-9-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

On 07/20/10 07:37 PM, Steve Dickson wrote:
> mountd.c: In function 'mount_null_1_svc':
> mountd.c:195: warning: unused parameter 'rqstp'
> mountd.c:195: warning: unused parameter 'argp'
> mountd.c:195: warning: unused parameter 'resp'
> mountd.c: In function 'mount_dump_1_svc':
> mountd.c:213: warning: unused parameter 'argp'
> mountd.c: In function 'mount_umnt_1_svc':
> mountd.c:224: warning: unused parameter 'resp'
> mountd.c: In function 'mount_umntall_1_svc':
> mountd.c:248: warning: unused parameter 'argp'
> mountd.c:248: warning: unused parameter 'resp'
> mountd.c: In function 'mount_export_1_svc':
> mountd.c:258: warning: unused parameter 'argp'
> mountd.c: In function 'mount_exportall_1_svc':
> mountd.c:269: warning: unused parameter 'argp'
> mountd.c: In function 'mount_dump_1_svc':
> mountd.c:216: warning: unused parameter 'argp'
> mountd.c: In function 'mount_umnt_1_svc':
> mountd.c:227: warning: unused parameter 'resp'
> mountd.c: In function 'mount_umntall_1_svc':
> mountd.c:251: warning: unused parameter 'argp'
> mountd.c:251: warning: unused parameter 'resp'
> mountd.c: In function 'mount_export_1_svc':
> mountd.c:261: warning: unused parameter 'argp'
> mountd.c: In function 'mount_exportall_1_svc':
> mountd.c:272: warning: unused parameter 'argp'
>
> Signed-off-by: Steve Dickson<steved@redhat.com>
> ---
>   utils/mountd/mountd.c |   19 +++++++++++++++----
>   1 files changed, 15 insertions(+), 4 deletions(-)
>
> diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
> index 6571454..43aec11 100644
> --- a/utils/mountd/mountd.c
> +++ b/utils/mountd/mountd.c
> @@ -194,6 +194,9 @@ sig_hup (int sig)
>   bool_t
>   mount_null_1_svc(struct svc_req *rqstp, void *argp, void *resp)
>   {
> +	xlog(D_CALL, "MNT1(%s) null: rqstp %p argp %p resp %p",
> +		rqstp, argp, resp);
> +
>   	return 1;
>   }
>
> @@ -214,7 +217,8 @@ mount_dump_1_svc(struct svc_req *rqstp, void *argp, mountlist *res)
>   {
>   	struct sockaddr_in *addr = nfs_getrpccaller_in(rqstp->rq_xprt);
>
> -	xlog(D_CALL, "dump request from %s.", inet_ntoa(addr->sin_addr));
> +	xlog(D_CALL, "MNT1(%s) dump request: argp %p",
> +		inet_ntoa(addr->sin_addr), argp);
>   	*res = mountlist_list();
>
>   	return 1;
> @@ -235,6 +239,8 @@ mount_umnt_1_svc(struct svc_req *rqstp, dirpath *argp, void *resp)
>   		rpath[sizeof (rpath) - 1] = '\0';
>   		p = rpath;
>   	}
> +	xlog(D_CALL, "MNT1(%s) unmount: path %s resp %p",
> +		inet_ntoa(sin->sin_addr), p, resp);

I have to agree with Bruce: adding xlog() calls here is the wrong thing 
to do.  Instead, use

    __attribute__((unused))

for the unused parameters.

>   	if (!(exp = auth_authenticate("unmount", sin, p))) {
>   		return 1;
> @@ -247,10 +253,15 @@ mount_umnt_1_svc(struct svc_req *rqstp, dirpath *argp, void *resp)
>   bool_t
>   mount_umntall_1_svc(struct svc_req *rqstp, void *argp, void *resp)
>   {
> +	struct sockaddr_in *sin = nfs_getrpccaller_in(rqstp->rq_xprt);
> +
> +	xlog(D_CALL, "UMNT1(%s) unmountall: argp %s resp %p",
> +		inet_ntoa(sin->sin_addr), argp, resp);
> +
>   	/* Reload /etc/xtab if necessary */
>   	auth_reload();
>
> -	mountlist_del_all(nfs_getrpccaller_in(rqstp->rq_xprt));
> +	mountlist_del_all(sin);

You couldn't wait until the rest of my IPv6 mountd patches are 
integrated?  I address a lot of these problems in those patches, and now 
I'm going to have to rebase all of that work.  What's the rush?

>   	return 1;
>   }
>
> @@ -259,7 +270,7 @@ mount_export_1_svc(struct svc_req *rqstp, void *argp, exports *resp)
>   {
>   	struct sockaddr_in *addr = nfs_getrpccaller_in(rqstp->rq_xprt);
>
> -	xlog(D_CALL, "export request from %s.", inet_ntoa(addr->sin_addr));
> +	xlog(D_CALL, "EXPORT(%s) dump: argp %p", inet_ntoa(addr->sin_addr), argp);
>   	*resp = get_exportlist();
>   		
>   	return 1;
> @@ -270,7 +281,7 @@ mount_exportall_1_svc(struct svc_req *rqstp, void *argp, exports *resp)
>   {
>   	struct sockaddr_in *addr = nfs_getrpccaller_in(rqstp->rq_xprt);
>
> -	xlog(D_CALL, "exportall request from %s.", inet_ntoa(addr->sin_addr));
> +	xlog(D_CALL, "EXPORTALL(%s) dump: argp %p", inet_ntoa(addr->sin_addr), argp);
>   	*resp = get_exportlist();
>
>   	return 1;

