Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33801 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753939AbbIWUd6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Sep 2015 16:33:58 -0400
Date: Wed, 23 Sep 2015 16:33:57 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-security-module@vger.kernel.org,
        Andreas Gruenbacher <agruen@kernel.org>
Subject: Re: [RFC v7 26/41] richacl: Apply the file masks to a richacl
Message-ID: <20150923203357.GC30521@fieldses.org>
References: <1441448856-13478-1-git-send-email-agruenba@redhat.com>
 <1441448856-13478-27-git-send-email-agruenba@redhat.com>
 <20150922191108.GC19127@fieldses.org>
 <20150923191832.GA29577@fieldses.org>
 <CAHc6FU4YkLJUAQEfH7CG8sAzXYbGzg_ibyT7m26Fc1p26v1=VQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHc6FU4YkLJUAQEfH7CG8sAzXYbGzg_ibyT7m26Fc1p26v1=VQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 23, 2015 at 10:29:40PM +0200, Andreas Gruenbacher wrote:
> 2015-09-23 21:18 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> > On Tue, Sep 22, 2015 at 03:11:08PM -0400, bfields wrote:
> >> user aces like owner aces what you intended to do,
> >> and if so, why?
> >
> > That does look wrong to me; in an example like:
> >
> >         file owner bfields
> >         mask 0700, not WRITE_THROUGH
> >         bfields:rwx::allow
> >
> > The permission algorithm grants nothing to anyone, but it looks to me
> > like richacl_apply_masks just leaves this as
> >
> >         bfields:rwx::allow
> >
> > but it would give the right result (an empty/deny-all ACL) if it weren't
> > for this odd case here.
> 
> In POSIX ACLs, only the entry that best matches the process determines
> the access permissions. For the file owner, this would always be the
> "user::" entry, and such an entry always exists.
> 
> In richacls, permissions from multiple entries do accumulate; the
> permission check algorithm does not pick a "best match". When bfields
> owns a file and a "bfields:rwx::allow" entry exists, denying rwx
> access to bfields would be very surprising.

The same could be said if there's a group-i-belong-to:rwx::allow entry,
do we make that exception too?

--b.

> It makes more sense to put
> user entries that match the current owner into the owner class, and
> apply the owner mask instead of the group mask. This was working in an
> earlier version but apparently broke at some point.
> 
> So the result that richacl_apply_masks computes here is correct, and
> the permission check algorithm needs a little fix.
> 
> Thanks,
> Andreas
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
