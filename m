Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:19313 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751667Ab1JSRWK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Oct 2011 13:22:10 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p9JHM9FW024960
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 19 Oct 2011 13:22:10 -0400
Date: Wed, 19 Oct 2011 13:22:30 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] mount.nfs: mtab corruption when RLIMIT_FSIZE causes
 a partial write
Message-ID: <20111019132230.6cd85a0c@corrin.poochiereds.net>
In-Reply-To: <4E9F047B.5000600@RedHat.com>
References: <1319038470-17750-1-git-send-email-steved@redhat.com>
	<20111019123626.7a80dfad@corrin.poochiereds.net>
	<4E9F047B.5000600@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 19 Oct 2011 13:10:19 -0400
Steve Dickson <SteveD@redhat.com> wrote:

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
> 

Ahh, then you have another problem here too then. Most likely it was
crashing because it caught a SIGXFSZ. Writing out the mtab should not
be affected by signals.

In the mount.cifs helper, I have it do the following before altering
the mtab (with appropriate error handling):

        rc = setreuid(geteuid(), -1);
        rc = sigfillset(&mask);
        rc = sigprocmask(SIG_SETMASK, &mask, &oldmask);


IOW, set the real uid to the effective UID to ensure that an
unprivileged user can't signal the process if it was run as a setuid
root program and the real UID isn't root. It then masks off all
signals. That leaves SIGKILL by root as a way to interrupt it but
there's really nothing you can do about that.

> 
> > 
> >>  		if (res < 0)
> >>  			/* Avoid leaving a corrupt mtab file */
> >>  			ftruncate(fileno(mfp->mntent_fp), length);
> > 
> > 


-- 
Jeff Layton <jlayton@redhat.com>
