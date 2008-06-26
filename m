From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] NFS performance debugging
Date: Thu, 26 Jun 2008 13:03:42 -0400
Message-ID: <20080626170342.GB6961@fieldses.org>
References: <200806231659.58158@fortytwo.ch> <200806250902.42880@fortytwo.ch>
	<20080625165658.GA12629@fieldses.org>
	<200806260819.35108@fortytwo.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Adrian von Bidder <avbidder-xzBkAS4TQxQfv37vnLkPlQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:33139 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752001AbYFZRlr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Jun 2008 13:41:47 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1KBusz-0001T1-GR
	for linux-nfs@vger.kernel.org; Fri, 27 Jun 2008 03:03:53 +1000
In-Reply-To: <200806260819.35108-xzBkAS4TQxQfv37vnLkPlQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 26, 2008 at 08:19:29AM +0200, Adrian von Bidder wrote:
> On Wednesday 25 June 2008 18.56:58 J. Bruce Fields wrote:
> > On Wed, Jun 25, 2008 at 09:02:42AM +0200, Adrian von Bidder wrote:
> > > First tries showed
> > >  * There are no acl on my files now
> >
> > NFSv4 uses an entirely different type of ACL, for which you need
> > different client-side tools; see
> 
> I'm absolutely confused on the state of nfs4 acls.  There are so many old 
> mailing list posts around that it's difficult to see what information 
> applies to the currentimplementation.  So: are POSIX acls in the server 
> filesystem somehow mapped to nfsv4 acls on the client side?  I understand 
> there understands an RFC proposal on how to do this, and 
> http://wiki.linux-nfs.org/wiki/index.php/ACLs is very interesting but 
> doesn't really cover the current state of the implementation.

I've attempted to update that wiki page to fix that problem; could you
take a look and tell me whether the changes help?

> > 	http://www.citi.umich.edu/projects/nfsv4/linux/nfs4-acl-tools/
> 
> Hmm.  Not packaged in Debian yet?????? ;-)  So work to do for me if I end up 
> using nfs4

Yes.  Volunteers to package those things welcomed....

(Or maybe we should get them into nfs-utils at some point.  I don't
know.)

--b.

> > >  * user id mapping seems funny: some users map to nobody, others map
> > > correctly.  Huh?
> >
> > And whereas v2/v3 require only uid's and gid's to agree, v4 (if you're
> > using auth_sys) requires uid's, gid's, *and* user and group names to
> > agree.
> 
> I got that fixed.  "localdomain" in idmapd.conf...
> 
> cheers
> -- vbi
> 
> 
> -- 
> > Maybe that question would be a good starting point: What's the use for
> > a gender field there?
> Stalking.
>         -- Miriam Ruiz, Marco d'Itri (im that order)



-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

