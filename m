Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:39224 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751821AbdLDPrP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 4 Dec 2017 10:47:15 -0500
Date: Mon, 4 Dec 2017 10:47:15 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Thiago Rafael Becker <thiago.becker@gmail.com>
Cc: NeilBrown <neilb@suse.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/3, V2] kernel: Move groups_sort to the caller of
 set_groups.
Message-ID: <20171204154715.GB4405@fieldses.org>
References: <20171130130457.11429-1-thiago.becker@gmail.com>
 <20171130130457.11429-3-thiago.becker@gmail.com>
 <87mv2ztgix.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1712041049280.1738@tbecker-rhat>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <alpine.LFD.2.21.1712041049280.1738@tbecker-rhat>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 04, 2017 at 01:39:37PM -0200, Thiago Rafael Becker wrote:
> 
> 
> On Mon, 4 Dec 2017, NeilBrown wrote:
> 
> >I think you need to add groups_sort() in a few more places.
> >Almost anywhere that calls groups_alloc() should be considered.
> >net/sunrpc/svcauth_unix.c, net/sunrpc/auth_gss/svcauth_gss.c,
> >fs/nfsd/auth.c definitely need it.
> 
> So are any other functions that modify group_info. OK, I think I'll
> implement the type detection below as it helps detecting where these
> situations are located.
> 
> This may take some time to make sane. I wonder if we shouldn't
> accept the first change suggested to fix the corruption detected in
> auth.unix.gid while I work on a new set of patches. Also, that patch
> doesn't change behavior of set_groups, and is easier to backport if
> distros relying on older kernels need to do so and change behavior.
> The first suggestion is undergoing tests, and so far we didn't
> detect any new corruptions on auth.unix.gid.

I'm a little confused--we can remedy the oversight Neil points out just
by adding a few more group_sort()s, and that shouldn't be hard, right?

I'd be OK with doing that first and then adding a code to enforce the
sorting second.

--b.

> 
> >Maybe it could be done with types.
> 
> I changed the interfaces on groups_{alloc,sort} to check. There are
> some extra changes needed in groups_from_user and others to make
> this viable, but I like it and I'll try to make it happen.
> 
> >Thanks,
> >NeilBrown
> >
> 
> Thanks,
> trbecker
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
