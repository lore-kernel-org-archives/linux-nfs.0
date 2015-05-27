Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:53016 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751340AbbE0PFZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 May 2015 11:05:25 -0400
Date: Wed, 27 May 2015 11:05:22 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andreas =?utf-8?Q?Gr=C3=BCnbacher?=
	<andreas.gruenbacher@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [RFC v3 14/45] richacl: Permission check algorithm
Message-ID: <20150527150522.GA21309@fieldses.org>
References: <cover.1429868795.git.agruenba@redhat.com>
 <380de2cdb4a129e4b5d7b586260b79d71c7d241d.1429868795.git.agruenba@redhat.com>
 <20150522210831.GA8689@fieldses.org>
 <CAHpGcMLbqOgHd=nbq6m_LinAk4S9zS80SfUUvU6Ah7d_p=OfFg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <CAHpGcMLbqOgHd=nbq6m_LinAk4S9zS80SfUUvU6Ah7d_p=OfFg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 27, 2015 at 01:25:18PM +0200, Andreas Grünbacher wrote:
> 2015-05-22 23:08 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> > On Fri, Apr 24, 2015 at 01:04:11PM +0200, Andreas Gruenbacher wrote:
> >> A richacl grants a requested access if the NFSv4 acl in the richacl
> >> grants the requested permissions (according to the NFSv4 permission
> >> check algorithm) and the file mask that applies to the process
> >> includes the requested permissions.
> >
> > Is that right?  Based on that I'd have thought that an acl like
> >
> >         owner  :r::mask
> >         group  :-::mask
> >         other  :-::mask
> >         bfields:r::allow
> >
> > would permit read to bfields in the case bfields is the file owner,
> > because both the mask entries and the NFSv4 ACL would permit access.
> >
> > But I think it doesn't (because the "bfields" entry is subject to the
> > group mask).
> 
> The problem at cause here that if we treat the acl and masks completely
> separately, we can end up with acl/mask combinations that don't have a
> representation as "normal" acls. For example, this:
> 
>    owner:r::mask
>    group:-::mask
>    other:-::mask
>   group@:r::allow
> 
> would grant the owner read access when in the owning group, but
> wouldn't grant the owning group access. This is handled by applying
> the group mask to all group-class entries; see this comment in the
> code:

OK, good, that makes sense, so I think all that's needed is some updates
to documentation; for example:

>                 /*
>                  * Apply the group file mask to entries other than OWNER@ and
>                  * EVERYONE@. This is not required for correct access checking

This is a strange way to put it; it makes it sound like the logic here
might not affect the access check result at all.

And this routine is basically the definition of the access check
algorithm, so the logic here is required.

>                  * but ensures that we grant the same permissions as the acl
>                  * computed by richacl_apply_masks() would grant.

I mean, I do understand what you're saying here, but it's a slightly
backwards way to put it....

>                  */
> 
> There is no necessity to also apply this rule to user entries matching the
> current owner though; we can change that here and in richacl_apply_masks().
> 
> > But if I'm right, I'm not sure how to describe the algorithm concisely.
> 
> Right, it's all a bit messy.

We need to put some thought into how this will be explained in man pages
and such, if you don't have that already.  It's inherently a complicated
ACL model, and hopefully this sort of corner case can be ignored most of
the time, but we need a good complete explanation somewhere that a
stressed sysadmin can follow if they need it....

I wish we could do something a little dumber and simpler, e.g., like

	http://docs.openafs.org/UserGuide/HDRWQ59.html

but maybe it's not practical.

--b.
