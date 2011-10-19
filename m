Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:58631 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757185Ab1JSRkA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Oct 2011 13:40:00 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p9JHe0gw017350
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 19 Oct 2011 13:40:00 -0400
Date: Wed, 19 Oct 2011 13:40:20 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] mount.nfs: mtab corruption when RLIMIT_FSIZE causes
 a partial write
Message-ID: <20111019134020.52983723@corrin.poochiereds.net>
In-Reply-To: <4E9F0952.2040607@RedHat.com>
References: <1319038470-17750-1-git-send-email-steved@redhat.com>
	<20111019123626.7a80dfad@corrin.poochiereds.net>
	<4E9F047B.5000600@RedHat.com>
	<20111019132230.6cd85a0c@corrin.poochiereds.net>
	<4E9F0952.2040607@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 19 Oct 2011 13:30:58 -0400
Steve Dickson <SteveD@redhat.com> wrote:

> 
> 
> On 10/19/2011 01:22 PM, Jeff Layton wrote:
> > On Wed, 19 Oct 2011 13:10:19 -0400
> > Steve Dickson <SteveD@redhat.com> wrote:
> > 
> >>
> >>
> >> On 10/19/2011 12:36 PM, Jeff Layton wrote:
> >>> On Wed, 19 Oct 2011 11:34:30 -0400
> >>> Steve Dickson <steved@redhat.com> wrote:
> >>>
> >>>> This patch is a following on to commit 7a802337. Using the
> >>>> tool in https://bugzilla.redhat.com/show_bug.cgi?id=695916
> >>>> caused the fflush() and fclose() to fail in turn causing
> >>>> corruption in the mtab.
> >>>>
> >>>> The failures were in the internals of both calls. Switch those
> >>>> calls with the actual system calls eliminated the failures.
> >>>>
> >>>> Signed-off-by: Steve Dickson <steved@redhat.com>
> >>>> ---
> >>>>  support/nfs/nfs_mntent.c |    4 ++--
> >>>>  1 files changed, 2 insertions(+), 2 deletions(-)
> >>>>
> >>>> diff --git a/support/nfs/nfs_mntent.c b/support/nfs/nfs_mntent.c
> >>>> index a2118a2..b80f270 100644
> >>>> --- a/support/nfs/nfs_mntent.c
> >>>> +++ b/support/nfs/nfs_mntent.c
> >>>> @@ -117,7 +117,7 @@ void
> >>>>  nfs_endmntent (mntFILE *mfp) {
> >>>>  	if (mfp) {
> >>>>  		if (mfp->mntent_fp)
> >>>> -			fclose(mfp->mntent_fp);
> >>>> +			close(fileno(mfp->mntent_fp));
> >>>>  		if (mfp->mntent_file)
> >>>>  			free(mfp->mntent_file);
> >>>>  		free(mfp);
> >>>> @@ -147,7 +147,7 @@ nfs_addmntent (mntFILE *mfp, struct mntent *mnt) {
> >>>>  	free(m3);
> >>>>  	free(m4);
> >>>>  	if (res >= 0) {
> >>>> -		res = fflush(mfp->mntent_fp);
> >>>> +		res = fsync(fileno(mfp->mntent_fp));
> >>>
> >>> fsync doesn't imply an fflush. With this, I think you may end up
> >>> without everything being committed to disk if part or all of it is
> >>> still in the file stream buffer. You probably want to do an fflush()
> >>> and then an fsync here.
> >> The problem was with the fflush() call. The call was causing the
> >> mount to drop core in turn causing mtab corruption. Changing that
> >> call to a fsync() worked just fine... no corruption... every time! 
> >>
> > 
> > Ahh, then you have another problem here too then. Most likely it was
> > crashing because it caught a SIGXFSZ. Writing out the mtab should not
> > be affected by signals.
> So calling fflush() generates a SIGXFSZ and call fsync() does not... 
> I really don't see what the problem is is call simply calling fsync()
> which clearly works?
> 

Because they do different things. fflush() flushes out the (userspace)
stream buffer to the kernel's pagecache. fsync() forces the pagecache
to be written out and committed to disk.

If you call fsync() while the data is still in the userspace buffer
then it doesn't really do you any good. The data you wrote via fwrite()
won't be committed to disk.

-- 
Jeff Layton <jlayton@redhat.com>
