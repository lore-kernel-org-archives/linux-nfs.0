Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vw0-f46.google.com ([209.85.212.46]:38185 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755042Ab1JSQgI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Oct 2011 12:36:08 -0400
Received: by vws1 with SMTP id 1so1397031vws.19
        for <linux-nfs@vger.kernel.org>; Wed, 19 Oct 2011 09:36:08 -0700 (PDT)
Date: Wed, 19 Oct 2011 12:36:26 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] mount.nfs: mtab corruption when RLIMIT_FSIZE causes
 a partial write
Message-ID: <20111019123626.7a80dfad@corrin.poochiereds.net>
In-Reply-To: <1319038470-17750-1-git-send-email-steved@redhat.com>
References: <1319038470-17750-1-git-send-email-steved@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 19 Oct 2011 11:34:30 -0400
Steve Dickson <steved@redhat.com> wrote:

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

fsync doesn't imply an fflush. With this, I think you may end up
without everything being committed to disk if part or all of it is
still in the file stream buffer. You probably want to do an fflush()
and then an fsync here.

>  		if (res < 0)
>  			/* Avoid leaving a corrupt mtab file */
>  			ftruncate(fileno(mfp->mntent_fp), length);


-- 
Jeff Layton <jlayton@poochiereds.net>
