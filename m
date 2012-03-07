Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:49140 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757048Ab2CGUH0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Mar 2012 15:07:26 -0500
Subject: Re: [PATCH 1/1] exportfs: Stop racing exportfs on clusters
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1331150190-18401-1-git-send-email-steved@redhat.com>
Date: Wed, 7 Mar 2012 15:07:22 -0500
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-Id: <8161FED5-1305-445B-AEFE-C182AA00A9DD@oracle.com>
References: <1331150190-18401-1-git-send-email-steved@redhat.com>
To: Steve Dickson <steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 7, 2012, at 2:56 PM, Steve Dickson wrote:

> This problem can occur when multiple cluster services fail over
> at the same time, causing missing high-available exports.
> Having a lot of nfs-exports will trigger this issue easier.

Does this address https://bugzilla.linux-nfs.org/show_bug.cgi?id=224 ?

> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
> support/include/exportfs.h |    4 ++++
> utils/exportfs/exportfs.c  |   24 ++++++++++++++++++++++++
> 2 files changed, 28 insertions(+), 0 deletions(-)
> 
> diff --git a/support/include/exportfs.h b/support/include/exportfs.h
> index 01e87dd..99916e5 100644
> --- a/support/include/exportfs.h
> +++ b/support/include/exportfs.h
> @@ -32,6 +32,10 @@ enum {
> 	FSLOC_STUB
> };
> 
> +#ifndef EXP_LOCKFILE
> +#define EXP_LOCKFILE "/var/lib/nfs/export-lock"
> +#endif
> +
> typedef struct mclient {
> 	struct mclient *	m_next;
> 	char *			m_hostname;
> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> index 7432a65..769d438 100644
> --- a/utils/exportfs/exportfs.c
> +++ b/utils/exportfs/exportfs.c
> @@ -16,6 +16,7 @@
> #include <sys/stat.h>
> #include <sys/vfs.h>
> #include <sys/stat.h>
> +#include <sys/file.h>
> #include <unistd.h>
> #include <stdbool.h>
> #include <stdlib.h>
> @@ -44,6 +45,23 @@ static void	validate_export(nfs_export *exp);
> static int	matchhostname(const char *hostname1, const char *hostname2);
> static void	export_d_read(const char *dname);
> 
> +static const char *lockfile = EXP_LOCKFILE;
> +static int _lockfd = -1;
> +
> +void 
> +grab_lockfile()
> +{
> +	_lockfd = open(lockfile, O_CREAT|O_RDWR, 0666);
> +	if (_lockfd != -1) 
> +		lockf(_lockfd, F_LOCK, 0);
> +}
> +void 
> +release_lockfile()
> +{
> +	if (_lockfd != -1)
> +		lockf(_lockfd, F_ULOCK, 0);
> +}
> +
> int
> main(int argc, char **argv)
> {
> @@ -129,6 +147,12 @@ main(int argc, char **argv)
> 			return 0;
> 		}
> 	}
> +	/*
> +	 * Serialize things as best we can
> +	 */
> +	grab_lockfile();
> +	atexit(release_lockfile);
> +
> 	if (f_export && ! f_ignore) {
> 		export_read(_PATH_EXPORTS);
> 		export_d_read(_PATH_EXPORTS_D);
> -- 
> 1.7.7.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




