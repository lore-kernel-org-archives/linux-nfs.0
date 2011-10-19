Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:46350 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753095Ab1JSTo3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Oct 2011 15:44:29 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p9JJiSr3002753
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 19 Oct 2011 15:44:29 -0400
Message-ID: <4E9F289C.2070003@RedHat.com>
Date: Wed, 19 Oct 2011 15:44:28 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] mount.nfs: mtab corruption when RLIMIT_FSIZE causes
 a partial write
References: <1319038470-17750-1-git-send-email-steved@redhat.com>
In-Reply-To: <1319038470-17750-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It turns out this is only a RHEL6 bug. I (stupidly) made the assumption that
since the RHEL6 patch cleanly applied to upstream, both streams worked
in the same way... which is not the case. 

With upstream, this mtab code is not even compiled when the libmount 
code is enabled. Secondly, with later systems /etc/mtab is symbolically
linked to /proc/mounts, making the file read-only. Finally when
/etc/mtabs is a regular file and is writeable, the  SIGXFSZ
signal is handled properly in lock_mtab() so there is no corruption.

Sorry for the noise.

steved.

On 10/19/2011 11:34 AM, Steve Dickson wrote:
> This patch is a following on to commit 7a802337. Using the
> tool in https://bugzilla.redhat.com/show_bug.cgi?id=695916
> caused the fflush() and fclose() to fail in turn causing
> corruption in the mtab.
> 
> The failures were in the internals of both calls. Switch those
> calls with the actual system calls eliminated the failures.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  support/nfs/nfs_mntent.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/support/nfs/nfs_mntent.c b/support/nfs/nfs_mntent.c
> index a2118a2..b80f270 100644
> --- a/support/nfs/nfs_mntent.c
> +++ b/support/nfs/nfs_mntent.c
> @@ -117,7 +117,7 @@ void
>  nfs_endmntent (mntFILE *mfp) {
>  	if (mfp) {
>  		if (mfp->mntent_fp)
> -			fclose(mfp->mntent_fp);
> +			close(fileno(mfp->mntent_fp));
>  		if (mfp->mntent_file)
>  			free(mfp->mntent_file);
>  		free(mfp);
> @@ -147,7 +147,7 @@ nfs_addmntent (mntFILE *mfp, struct mntent *mnt) {
>  	free(m3);
>  	free(m4);
>  	if (res >= 0) {
> -		res = fflush(mfp->mntent_fp);
> +		res = fsync(fileno(mfp->mntent_fp));
>  		if (res < 0)
>  			/* Avoid leaving a corrupt mtab file */
>  			ftruncate(fileno(mfp->mntent_fp), length);
