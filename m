Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33812 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755697AbbIWVFd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Sep 2015 17:05:33 -0400
Date: Wed, 23 Sep 2015 17:05:31 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-security-module@vger.kernel.org,
        Andreas Gruenbacher <agruen@kernel.org>
Subject: Re: [RFC v7 26/41] richacl: Apply the file masks to a richacl
Message-ID: <20150923210531.GC29349@fieldses.org>
References: <1441448856-13478-1-git-send-email-agruenba@redhat.com>
 <1441448856-13478-27-git-send-email-agruenba@redhat.com>
 <20150922191108.GC19127@fieldses.org>
 <20150923191832.GA29577@fieldses.org>
 <CAHc6FU4YkLJUAQEfH7CG8sAzXYbGzg_ibyT7m26Fc1p26v1=VQ@mail.gmail.com>
 <20150923203357.GC30521@fieldses.org>
 <CAHc6FU4Jh=-K5=DBERP3-vv8Sak4XGjVJgJ85mTeyPiApUhz+g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHc6FU4Jh=-K5=DBERP3-vv8Sak4XGjVJgJ85mTeyPiApUhz+g@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 23, 2015 at 10:40:18PM +0200, Andreas Gruenbacher wrote:
> 2015-09-23 22:33 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> > The same could be said if there's a group-i-belong-to:rwx::allow entry,
> > do we make that exception too?
> 
> We cannot because that would be incorrect for all other group members.

OK.  So people have to learn how the group mask works anyway, and now
they have to learn a special exception to that rule.

I don't like having this exception.  Or making the richacl->v4acl
translation dependent on the owner.

But I admit it's surprising to that an 0700 mask with
"bfields:rwx::allow" ACL denies access to a bfields-owned file.

--b.
