Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57374 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751390Ab0HPSKk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Aug 2010 14:10:40 -0400
Date: Mon, 16 Aug 2010 14:08:29 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeremy Allison <jra@samba.org>
Cc: Jeff Layton <jlayton@redhat.com>, Neil Brown <neilb@suse.de>,
        utz lehmann <lkml123@s2y4n2c.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Volker.Lendecke@sernet.de, David Howells <dhowells@redhat.com>,
        Jan Engelhardt <jengelh@medozas.de>, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsde@jasper.es
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make
 extended  file stats available [ver #6]
Message-ID: <20100816180828.GB7764@fieldses.org>
References: <AANLkTimdFCGSKLn7aGMpBMIauHTsHY7hpAAmpo6uTcnD@mail.gmail.com>
 <1280524978.2452.9.camel@segv.aura.of.mankind>
 <20100801092529.5e6ba0e0@corrin.poochiereds.net>
 <20100805235218.GB31233@jeremy-laptop>
 <20100806133836.49757af9@notabene>
 <20100808121208.GA7329@jeremy-laptop>
 <20100808085301.24f53e5a@tlielax.poochiereds.net>
 <20100808130501.GA9851@jeremy-laptop>
 <20100813125432.GB8945@fieldses.org>
 <20100813175410.GA8202@samba1>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100813175410.GA8202@samba1>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 13, 2010 at 10:54:10AM -0700, Jeremy Allison wrote:
> On Fri, Aug 13, 2010 at 08:54:32AM -0400, J. Bruce Fields wrote:
> > On Sun, Aug 08, 2010 at 06:05:01AM -0700, Jeremy Allison wrote:
> > > We don't need to ape Windows in everything.
> > > The coming ACL disaster will show that (we will go from an ACL
> > > model that is slightly too complex to use, to one that is impossibly
> > > complex to use :-).
> > 
> > Care to elaborate?
> 
> POSIX ACLs -> RichACLs (NT-style). Not criticising Andreas here,
> people are asking for this. But Windows ACLs are a nightmare
> beyond human comprehension :-). In the "too complex to be
> usable" camp.
> 
> > And what would native ACL support mean for Samba?
> 
> RichACLs'll do it, but I feel sorry for the admins :-).

I was curious whether you can support that with any data (or even just
anecdotes) about real-world sysadmins.

The NT-style ACLs give me a headache, honestly.  But that may just be
because I've been involved with the implementation.  Admins may have the
luxury of using only the subset that they're comfortable with.

--b.
