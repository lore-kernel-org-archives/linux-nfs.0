Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44476 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751469Ab1JSR25 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Oct 2011 13:28:57 -0400
Date: Wed, 19 Oct 2011 13:28:55 -0400
To: Steve Dickson <SteveD@redhat.com>
Cc: Jeff Layton <jlayton@poochiereds.net>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] mount.nfs: mtab corruption when RLIMIT_FSIZE
 causes a partial write
Message-ID: <20111019172855.GB32028@fieldses.org>
References: <1319038470-17750-1-git-send-email-steved@redhat.com>
 <20111019123626.7a80dfad@corrin.poochiereds.net>
 <4E9F047B.5000600@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E9F047B.5000600@RedHat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 19, 2011 at 01:10:19PM -0400, Steve Dickson wrote:
> 
> 
> On 10/19/2011 12:36 PM, Jeff Layton wrote:
> > On Wed, 19 Oct 2011 11:34:30 -0400
> > Steve Dickson <steved@redhat.com> wrote:
> > 
> >> This patch is a following on to commit 7a802337. Using the
> >> tool in https://bugzilla.redhat.com/show_bug.cgi?id=695916
> >> caused the fflush() and fclose() to fail in turn causing
> >> corruption in the mtab.
> >>
> >> The failures were in the internals of both calls. Switch those
> >> calls with the actual system calls eliminated the failures.
> >>
> >> Signed-off-by: Steve Dickson <steved@redhat.com>
> >> ---
> >>  support/nfs/nfs_mntent.c |    4 ++--
> >>  1 files changed, 2 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/support/nfs/nfs_mntent.c b/support/nfs/nfs_mntent.c
> >> index a2118a2..b80f270 100644
> >> --- a/support/nfs/nfs_mntent.c
> >> +++ b/support/nfs/nfs_mntent.c
> >> @@ -117,7 +117,7 @@ void
> >>  nfs_endmntent (mntFILE *mfp) {
> >>  	if (mfp) {
> >>  		if (mfp->mntent_fp)
> >> -			fclose(mfp->mntent_fp);
> >> +			close(fileno(mfp->mntent_fp));
> >>  		if (mfp->mntent_file)
> >>  			free(mfp->mntent_file);
> >>  		free(mfp);
> >> @@ -147,7 +147,7 @@ nfs_addmntent (mntFILE *mfp, struct mntent *mnt) {
> >>  	free(m3);
> >>  	free(m4);
> >>  	if (res >= 0) {
> >> -		res = fflush(mfp->mntent_fp);
> >> +		res = fsync(fileno(mfp->mntent_fp));
> > 
> > fsync doesn't imply an fflush. With this, I think you may end up
> > without everything being committed to disk if part or all of it is
> > still in the file stream buffer. You probably want to do an fflush()
> > and then an fsync here.
> The problem was with the fflush() call. The call was causing the
> mount to drop core in turn causing mtab corruption. Changing that
> call to a fsync() worked just fine... no corruption... every time! 

Looking at man setrlimit....  If you're worried about RLIMIT_FSIZE, then
I guess you need to handle SIGXFSZ and EFBIG returns from write().

It looks like lock_mtab() already sets SIGXFSZ to be ignored.  Is a libc
bug crashing fflush on EFBIG?  Or maybe the ftruncate is a problem?
Maybe you just want to do away with stream IO completely?

--b.

> 
> steved.
> 
> > 
> >>  		if (res < 0)
> >>  			/* Avoid leaving a corrupt mtab file */
> >>  			ftruncate(fileno(mfp->mntent_fp), length);
> > 
> > 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
