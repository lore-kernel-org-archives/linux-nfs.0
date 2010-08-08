Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fn.samba.org ([216.83.154.106]:59077 "EHLO lists.samba.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753936Ab0HHNFF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 8 Aug 2010 09:05:05 -0400
Date: Sun, 8 Aug 2010 06:05:01 -0700
From: Jeremy Allison <jra@samba.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Jeremy Allison <jra@samba.org>, Neil Brown <neilb@suse.de>,
        utz lehmann <lkml123@s2y4n2c.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Volker.Lendecke@sernet.de, David Howells <dhowells@redhat.com>,
        Jan Engelhardt <jengelh@medozas.de>, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsde@jasper.es
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make
 extended  file stats available [ver #6]
Message-ID: <20100808130501.GA9851@jeremy-laptop>
Reply-To: Jeremy Allison <jra@samba.org>
References: <20100715021712.5544.44845.stgit@warthog.procyon.org.uk>
 <30448.1279800887@redhat.com>
 <E1Obuiy-00C9jr-Al@intern.SerNet.DE>
 <AANLkTimdFCGSKLn7aGMpBMIauHTsHY7hpAAmpo6uTcnD@mail.gmail.com>
 <1280524978.2452.9.camel@segv.aura.of.mankind>
 <20100801092529.5e6ba0e0@corrin.poochiereds.net>
 <20100805235218.GB31233@jeremy-laptop>
 <20100806133836.49757af9@notabene>
 <20100808121208.GA7329@jeremy-laptop>
 <20100808085301.24f53e5a@tlielax.poochiereds.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100808085301.24f53e5a@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, Aug 08, 2010 at 08:53:01AM -0400, Jeff Layton wrote:
> 
> It would be more convenient if this were part of stat() but adding a
> new stat call is non-trivial. Even if we did that, it still doesn't
> solve the problem of being able to set the create time. The fact that
> that's rarely done doesn't really matter much -- we ought to shoot for
> the semantics that are needed to handle this properly.

*BSD didn't. They just added something that was useful to UNIX.
I'd be happy with that. We don't need to ape Windows in everything.
The coming ACL disaster will show that (we will go from an ACL
model that is slightly too complex to use, to one that is impossibly
complex to use :-).

> If that's the case, don't you have to query for this EA every time you
> need to return the create time anyway? If so, then doing this really
> isn't any more costly -- you'd just be querying a different EA, right?

No, we'd be querying an additional EA. The EA we query contains
the DOS attribues as well as the create time.

Jeremy.
