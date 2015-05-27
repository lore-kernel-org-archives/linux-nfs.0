Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:53019 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753137AbbE0PG4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 May 2015 11:06:56 -0400
Date: Wed, 27 May 2015 11:06:56 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andreas =?utf-8?Q?Gr=C3=BCnbacher?=
	<andreas.gruenbacher@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [RFC v3 19/45] richacl: Also recognize nontrivial
 mode-equivalent acls
Message-ID: <20150527150656.GB21309@fieldses.org>
References: <cover.1429868795.git.agruenba@redhat.com>
 <5e9ee3b123b3d648487cd18dc906b6a2cd23085b.1429868795.git.agruenba@redhat.com>
 <20150515205140.GD29627@fieldses.org>
 <CAHpGcMJAU+o_hyKLjBKGD7_akPxfMv0JeVCBcS1pKTwSRnCU-w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <CAHpGcMJAU+o_hyKLjBKGD7_akPxfMv0JeVCBcS1pKTwSRnCU-w@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 27, 2015 at 11:24:49AM +0200, Andreas Grünbacher wrote:
> Bruce,
> 
> 2015-05-15 22:51 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> > On Fri, Apr 24, 2015 at 01:04:16PM +0200, Andreas Gruenbacher wrote:
> > This comment is a little confusing:
> >
> >> + * This function does not consider the masks in @acl.
> >
> > Given that we do this later:
> >
> >> +     if (acl->a_flags & RICHACL_MASKED) {
> >> +             owner.allowed &= acl->a_owner_mask;
> >> +             group.allowed &= acl->a_group_mask;
> >> +             everyone.allowed &= acl->a_other_mask;
> >> +     }
> 
> Indeed, the comment seems to be a left-over from a previous version, sorry.
> 
> > I think the difference is that here you're checking that the end result
> > after applying masks is mode-equivalent, whereas in riachacl_equiv_mode
> > [...] you're also checking whether the masks themselves are
> > mode-equivalent?
> 
> Yes.
> 
> >Is that the right thing to do?
> 
> This patch and its consequences probably weren't thought through well enough
> initially. I meanwhile think that it doesn't matter if the masks themselves are
> mode-equivalent and that we can drop this check.

OK, thanks, that would simplify things.

--b.
