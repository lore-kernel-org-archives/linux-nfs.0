Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:34951 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932793AbbIYSgm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Sep 2015 14:36:42 -0400
Date: Fri, 25 Sep 2015 14:36:40 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-security-module@vger.kernel.org
Subject: Re: [PATCH] richacl: Possible other write-through fix
Message-ID: <20150925183640.GC14850@fieldses.org>
References: <1441448856-13478-1-git-send-email-agruenba@redhat.com>
 <1441448856-13478-27-git-send-email-agruenba@redhat.com>
 <20150924183310.GE3823@fieldses.org>
 <1443199559-4870-1-git-send-email-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1443199559-4870-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 25, 2015 at 06:45:59PM +0200, Andreas Gruenbacher wrote:
> 2015-09-24 20:33 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> > On Sat, Sep 05, 2015 at 12:27:21PM +0200, Andreas Gruenbacher wrote:
> >> +int
> >> +richacl_apply_masks(struct richacl **acl, kuid_t owner)
> >> +{
> >> +     if ((*acl)->a_flags & RICHACL_MASKED) {
> >> +             struct richacl_alloc alloc = {
> >> +                     .acl = richacl_clone(*acl, GFP_KERNEL),
> >> +                     .count = (*acl)->a_count,
> >> +             };
> >> +             if (!alloc.acl)
> >> +                     return -ENOMEM;
> >> +
> >> +             if (richacl_move_everyone_aces_down(&alloc) ||
> >> +                 richacl_propagate_everyone(&alloc) ||
> >> +                 __richacl_apply_masks(&alloc, owner) ||
> >> +                 richacl_set_owner_permissions(&alloc) ||
> >> +                 richacl_set_other_permissions(&alloc) ||
> >
> > Hm, I'm a little unsure about this step: it seems like the one step that
> > can actually change the permissions (making them more permissive, in
> > this case), whereas the others are neutral.
> >
> > The following two steps should fix that, but I'm not sure they do.
> >
> > E.g. if I have an ACL like
> >
> >         mask 0777, WRITE_THROUGH
> >         GROUP@:r--::allow
> >
> > I think it should result in
> >
> >         OWNER@:   rwx::allow
> >         GROUP@:   -wx::deny
> >         GROUP@:   r--::allow
> >         EVERYONE@:rwx::allow
> >
> > But does the GROUP@ deny actually get in there?  It looks to me like the
> > denies inserted by richacl_isolate_group_class only take into account
> > the group mask, not the actual permissions granted to any group class
> > user.
> >
> > I may be mising something.
> 
> Thanks for the test case and analysis. The group@ deny ace that should be
> inserted here actually doesn't get inserted. I'm attaching a fix.

This looks correct with the fix, thanks!

One nit:

>  		if (richacl_move_everyone_aces_down(&alloc) ||
>  		    richacl_propagate_everyone(&alloc) ||
>  		    __richacl_apply_masks(&alloc, owner) ||
> +		    richacl_set_other_permissions(&alloc, &added) ||

It's still the case that this step lacks the property shared by the
other step, that it leaves permissions unchanged.  Instead it increases
permissions, then the following step fixes the problem.  That
complicates review slightly.

But I'm not sure that matters much.

Reviewed-by: J. Bruce Fields <bfields@redhat.com>

--b.

> +		    richacl_isolate_group_class(&alloc, added) ||
>  		    richacl_set_owner_permissions(&alloc) ||
> -		    richacl_set_other_permissions(&alloc) ||
> -		    richacl_isolate_owner_class(&alloc) ||
> -		    richacl_isolate_group_class(&alloc)) {
> +		    richacl_isolate_owner_class(&alloc)) {
>  			richacl_put(alloc.acl);
>  			return -ENOMEM;
>  		}
> -- 
> 2.4.3
