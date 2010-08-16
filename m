Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57364 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750845Ab0HPSHH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Aug 2010 14:07:07 -0400
Date: Mon, 16 Aug 2010 14:04:50 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeremy Allison <jra@samba.org>
Cc: Jan Engelhardt <jengelh@medozas.de>, Jeff Layton <jlayton@redhat.com>,
        Neil Brown <neilb@suse.de>, utz lehmann <lkml123@s2y4n2c.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Volker.Lendecke@sernet.de, David Howells <dhowells@redhat.com>,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        viro@zeniv.linux.org.uk, linux-fsde@jasper.es
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make
 extended file stats available [ver #6]
Message-ID: <20100816180450.GA7764@fieldses.org>
References: <20100801092529.5e6ba0e0@corrin.poochiereds.net>
 <20100805235218.GB31233@jeremy-laptop>
 <20100806133836.49757af9@notabene>
 <20100808121208.GA7329@jeremy-laptop>
 <20100808085301.24f53e5a@tlielax.poochiereds.net>
 <20100808130501.GA9851@jeremy-laptop>
 <20100813125432.GB8945@fieldses.org>
 <20100813175410.GA8202@samba1>
 <alpine.LSU.2.01.1008132104290.12206@obet.zrqbmnf.qr>
 <20100813191900.GB8202@samba1>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100813191900.GB8202@samba1>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 13, 2010 at 12:19:00PM -0700, Jeremy Allison wrote:
> On Fri, Aug 13, 2010 at 09:06:28PM +0200, Jan Engelhardt wrote:
> > 
> > On Friday 2010-08-13 19:54, Jeremy Allison wrote:
> > >On Fri, Aug 13, 2010 at 08:54:32AM -0400, J. Bruce Fields wrote:
> > >> On Sun, Aug 08, 2010 at 06:05:01AM -0700, Jeremy Allison wrote:
> > >> > We don't need to ape Windows in everything.
> > >> > The coming ACL disaster will show that (we will go from an ACL
> > >> > model that is slightly too complex to use, to one that is impossibly
> > >> > complex to use :-).
> > >> 
> > >> Care to elaborate?
> > >
> > >POSIX ACLs -> RichACLs (NT-style). Not criticising Andreas here,
> > >people are asking for this. But Windows ACLs are a nightmare
> > >beyond human comprehension :-). In the "too complex to be
> > >usable" camp.
> > 
> > Well, for one, ACLs in NT can be recursive IIRC. You can't say that of Linux
> > ACLs - instead you have to setfacl -R and setfacl -Rd to give one user access
> > to a directory and all its subdirs including future new inodes.
> 
> You do realize that Windows does exactly the same thing under
> the covers, right ? Watch SMB or SMB2 traffic between a client
> and Windows server when someone changes an ACL sometime :-).

Yeah.  There's some explanation here:

	http://tools.ietf.org/search/rfc5661#section-6.4.3.2

What NT-style ACLs provide is a few bits that help a setfacl-like
application decide how to propagate the change.  But it's still up to
the application to do the recursive traversal.

--b.
