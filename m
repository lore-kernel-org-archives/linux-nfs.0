Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60922 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757619AbbIVBwN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Sep 2015 21:52:13 -0400
Date: Mon, 21 Sep 2015 21:52:13 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: linux-kernel@vger.kernel.org,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-security-module@vger.kernel.org,
        Andreas Gruenbacher <agruen@kernel.org>
Subject: Re: [RFC v7 21/41] richacl: Move everyone@ aces down the acl
Message-ID: <20150922015213.GB15960@fieldses.org>
References: <1441448856-13478-1-git-send-email-agruenba@redhat.com>
 <1441448856-13478-22-git-send-email-agruenba@redhat.com>
 <20150918193524.GA22671@fieldses.org>
 <CAHc6FU5m8KKSsEg18UhRSnVdsAzoFSD9pdLRv1DdDA==ZCQmdw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHc6FU5m8KKSsEg18UhRSnVdsAzoFSD9pdLRv1DdDA==ZCQmdw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 21, 2015 at 11:43:16PM +0200, Andreas Gruenbacher wrote:
> 2015-09-18 21:35 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> > On Sat, Sep 05, 2015 at 12:27:16PM +0200, Andreas Gruenbacher wrote:
> >> The POSIX standard puts processes which are not the owner or a member in
> >> the owning group or which match any ace other then everyone@ on the
> >> other file class.  We only know if a process is in the other class after
> >> processing the entire acl.
> >>
> >> Move all everyone@ aces in the acl down in the acl so that at most a
> >> single everyone@ allow ace remains at the end.  Permissions which are
> >> not explicitly allowed are implicitly denied, so an everyone@ deny ace
> >> is unneeded.
> >>
> >> The everyone@ aces can be moved down the acl without changing the
> >> permissions that the acl grants.  This transformation simplifies the
> >> following algorithms, and eventually allows us to turn the final
> >> everyone@ allow ace into an entry for the other class.
> >>
> >> Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
> >> ---
> >>  fs/richacl_compat.c | 65 +++++++++++++++++++++++++++++++++++++++++++++++++++++
> >>  1 file changed, 65 insertions(+)
> >>
> >> diff --git a/fs/richacl_compat.c b/fs/richacl_compat.c
> >> index 341e429..4f0acf5 100644
> >> --- a/fs/richacl_compat.c
> >> +++ b/fs/richacl_compat.c
> >> @@ -153,3 +153,68 @@ richace_change_mask(struct richacl_alloc *alloc, struct richace **ace,
> >>       }
> >>       return 0;
> >>  }
> >> +
> >> +/**
> >> + * richacl_move_everyone_aces_down  -  move everyone@ aces to the end of the acl
> >> + * @alloc:   acl and number of allocated entries
> >> + *
> >> + * Move all everyone aces to the end of the acl so that only a single everyone@
> >> + * allow ace remains at the end, and update the mask fields of all aces on the
> >> + * way.  The last ace of the resulting acl will be an everyone@ allow ace only
> >> + * if @acl grants any permissions to @everyone.  No @everyone deny aces will
> >> + * remain.
> >> + *
> >> + * This transformation does not alter the permissions that the acl grants.
> >> + * Having at most one everyone@ allow ace at the end of the acl helps us in the
> >> + * following algorithms.
> >> + */
> >> +static int
> >> +richacl_move_everyone_aces_down(struct richacl_alloc *alloc)
> >> +{
> >> +     struct richace *ace;
> >> +     unsigned int allowed = 0, denied = 0;
> >> +
> >> +     richacl_for_each_entry(ace, alloc->acl) {
> >> +             if (richace_is_inherit_only(ace))
> >> +                     continue;
> >> +             if (richace_is_everyone(ace)) {
> >> +                     if (richace_is_allow(ace))
> >> +                             allowed |= (ace->e_mask & ~denied);
> >> +                     else if (richace_is_deny(ace))
> >> +                             denied |= (ace->e_mask & ~allowed);
> >> +                     else
> >> +                             continue;
> >> +                     if (richace_change_mask(alloc, &ace, 0))
> >> +                             return -1;
> >> +             } else {
> >> +                     if (richace_is_allow(ace)) {
> >> +                             if (richace_change_mask(alloc, &ace, allowed |
> >> +                                             (ace->e_mask & ~denied)))
> >> +                                     return -1;
> >> +                     } else if (richace_is_deny(ace)) {
> >> +                             if (richace_change_mask(alloc, &ace, denied |
> >> +                                             (ace->e_mask & ~allowed)))
> >> +                                     return -1;
> >> +                     }
> >> +             }
> >> +     }
> >> +     if (allowed & ~RICHACE_POSIX_ALWAYS_ALLOWED) {
> >> +             struct richace *last_ace = ace - 1;
> >> +
> >> +             if (alloc->acl->a_entries &&
> >> +                 richace_is_everyone(last_ace) &&
> >> +                 richace_is_allow(last_ace) &&
> >> +                 richace_is_inherit_only(last_ace) &&
> >> +                 last_ace->e_mask == allowed)
> >> +                     last_ace->e_flags &= ~RICHACE_INHERIT_ONLY_ACE;
> >
> > That's a funny special case!  Is it even worth it, or could we just live
> > with an extra uninheritable EVERYONE ace in this case?
> 
> Inheritable everyone@ allow entries at the end of the ACL are not
> uncommon. This special case prevents the algorithm from splitting such
> entries into inherit-only and non-inheritable parts.

OK.--b.
