Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58221 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751060AbcDFP64 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Apr 2016 11:58:56 -0400
Date: Wed, 6 Apr 2016 11:58:52 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
cc: Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [RFC PATCH] mount.nfs: skip option validation on remount
In-Reply-To: <5C9855F4-AF15-479B-989E-B0B056A8604E@oracle.com>
Message-ID: <alpine.OSX.2.19.9992.1604061152040.18253@planck>
References: <712798c489f69e39f235077f6ca85a7c133eeb58.1459949813.git.bcodding@redhat.com> <541141C7-9928-43FE-8C45-82A914038EC1@oracle.com> <alpine.OSX.2.19.9992.1604061124080.18253@planck> <5C9855F4-AF15-479B-989E-B0B056A8604E@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 6 Apr 2016, Chuck Lever wrote:

>
> > On Apr 6, 2016, at 8:24 AM, Benjamin Coddington <bcodding@redhat.com> wrote:
> >
> > On Wed, 6 Apr 2016, Chuck Lever wrote:
> >>
> >>> On Apr 6, 2016, at 6:41 AM, Benjamin Coddington <bcodding@redhat.com> wrote:
> >>>
> >>> I'm not exactly sure this is the safest thing to do since you can pass
> >>> -oremount on the first mount and skip option validation.  Maybe someone with
> >>> better insight into the mount paths could comment.  Does mount need some
> >>> refactoring?  Its logic seems arcane.. and I think there is a lot of dead
> >>> code.
> >>
> >> It's arcane because NFS mounting has a lot of corner cases
> >> that have evolved over the years. If you have an example of
> >> dead code, can you post it?
> >
> > Absolutely.  I don't have it ready right now, but I do remember coming across
> > some sections several times and wondering how they could be used.
> >
> > I need to do a better job of posting when I find things instead of putting
> > them off and forgetting about them.
> >
> >>> This is very quick attempt to fix
> >>> https://bugzilla.redhat.com/show_bug.cgi?id=1313550
> >>
> >> "You are not authorized to access bug #1313550."
> >
> > Sorry.  I've just tried to fix that and I cannot.  The basic info there is
> > that kdump always tries to remount,rw a target.. and that is breaking on
> > NFS.
>
> Always breaking? Or just in the case where the server has
> multiple homes?

In the case of multiple records.

> > The bug doesn't really provide anything more useful to the discussion
> > other than maybe help Steved find the original problem.
> >
> >> I'm guessing you want to use the existing addr= option on a
> >> remount in case the DNS resolution returns a different address.
> >
> > Right.
> >
> >> I'm uncertain why a remount should succeed in this case: if
> >> the server has a different IP address, how was the mount working
> >> at all?
> >
> > If the server has multiple A or AAAA records, and the the results are
> > returned round-robin style, we can end up with a different address for
> > the server.
>
> I agree that a second DNS resolution here is probably not
> helpful or needed. Still, multi-home NFS seems like a crap
> shoot to begin with. Maybe I'm just not awake yet.

It is a crap-shoot.  But I think I should try to give a multi-homed server a
shot at serving NFS..  In this case, the server may not actually even
respond on the additional addresses - they just resolve.

> But I think you do need to validate mount options on a
> remount: otherwise you can pass "-o remount,garbage". Or
> did I misunderstand?

No, I don't think you did.. and that's the second opinion I'd sorta
expected.  So thanks for looking at this, and I'll re-spin it to do it the
non-lazy way.

Ben

> >
> >>> 8<-------------------------------------------------------------------------
> >>>
> >>> A remount might fail if name resolution returns a different server address
> >>> for the mount.  Since we've already validated the options the first time,
> >>> skip validation if remounting.
> >>>
> >>> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> >>> ---
> >>> utils/mount/stropts.c |    6 +++---
> >>> 1 files changed, 3 insertions(+), 3 deletions(-)
> >>>
> >>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> >>> index 86829a9..9383bb4 100644
> >>> --- a/utils/mount/stropts.c
> >>> +++ b/utils/mount/stropts.c
> >>> @@ -1090,15 +1090,15 @@ static const char *nfs_background_opttbl[] = {
> >>>
> >>> static int nfsmount_start(struct nfsmount_info *mi)
> >>> {
> >>> -	if (!nfs_validate_options(mi))
> >>> -		return EX_FAIL;
> >>> -
> >>> 	/*
> >>> 	 * Avoid retry and negotiation logic when remounting
> >>> 	 */
> >>> 	if (mi->flags & MS_REMOUNT)
> >>> 		return nfs_remount(mi);
> >>>
> >>> +	if (!nfs_validate_options(mi))
> >>> +		return EX_FAIL;
> >>> +
> >>> 	if (po_rightmost(mi->options, nfs_background_opttbl) == 0)
> >>> 		return nfsmount_bg(mi);
> >>> 	else
> >>> --
> >>> 1.7.1
> >>>
> >>> --
> >>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >>> the body of a message to majordomo@vger.kernel.org
> >>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>
> >> --
> >> Chuck Lever
>
> --
> Chuck Lever
>
>
>
>
