Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58544 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751984AbbIQRaw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Sep 2015 13:30:52 -0400
Date: Thu, 17 Sep 2015 13:30:51 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andreas =?utf-8?Q?Gr=C3=BCnbacher?=
	<andreas.gruenbacher@gmail.com>
Cc: Andreas Gruenbacher <agruenba@redhat.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux API Mailing List <linux-api@vger.kernel.org>,
        linux-cifs@vger.kernel.org,
        LSM List <linux-security-module@vger.kernel.org>
Subject: Re: [RFC v7 10/41] richacl: Permission check algorithm
Message-ID: <20150917173051.GC13048@fieldses.org>
References: <1441448856-13478-1-git-send-email-agruenba@redhat.com>
 <1441448856-13478-11-git-send-email-agruenba@redhat.com>
 <20150911211617.GF11677@fieldses.org>
 <CAHpGcMJofUKKumcUe=6LOFZrVcJRM5APchbCQpfQzbMK7N1FYg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <CAHpGcMJofUKKumcUe=6LOFZrVcJRM5APchbCQpfQzbMK7N1FYg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Sep 12, 2015 at 12:12:16AM +0200, Andreas Grünbacher wrote:
> 2015-09-11 23:16 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> > On Sat, Sep 05, 2015 at 12:27:05PM +0200, Andreas Gruenbacher wrote:
> >> +             /*
> >> +              * Apply the group file mask to entries other than owner@ and
> >> +              * everyone@ or user entries matching the owner.  This ensures
> >> +              * that we grant the same permissions as the acl computed by
> >> +              * richacl_apply_masks().
> >> +              *
> >> +              * Without this restriction, the following richacl would grant
> >> +              * rw access to processes which are both the owner and in the
> >> +              * owning group, but not to other users in the owning group,
> >> +              * which could not be represented without masks:
> >> +              *
> >> +              *  owner:rw::mask
> >> +              *  group@:rw::allow
> >> +              */
> >> +             if ((acl->a_flags & RICHACL_MASKED) && richace_is_allow(ace))
> >> +                     ace_mask &= acl->a_group_mask;
> >
> > I'm having trouble understanding this.  I think the problem is that I
> > don't really understand the notation in your example.  Is a_group_mask
> > zero in that example?  I think it must be, in which case, OK I think I
> > get it.
> 
> Yes. I'm not sure if the example becomes easier to understand when the
> empty group mask and perhaps also the other mask is included.

I think it would have been for me.

In general I find it confusing to present the mask bits as additional
ACEs--they're really pretty different.

> > (Though I still have to think about it a little more to convince myself
> > that richacl_apply_masks() always gets the same result.)
> 
> I have tried to break the algorithm into digestible pieces. Do you see
> another way to make things easier to understand?

I just haven't reread those carefully enough yet, working on it....

--b.
