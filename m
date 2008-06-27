From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] NFS performance debugging
Date: Fri, 27 Jun 2008 13:47:53 -0400
Message-ID: <20080627174753.GE18933@fieldses.org>
References: <200806231659.58158@fortytwo.ch> <200806260819.35108@fortytwo.ch>
	<20080626170342.GB6961@fieldses.org>
	<200806270824.54066@fortytwo.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Adrian von Bidder <avbidder-xzBkAS4TQxQfv37vnLkPlQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:57106 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752434AbYF0RsM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Jun 2008 13:48:12 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1KCI3N-00039o-Pp
	for linux-nfs@vger.kernel.org; Sat, 28 Jun 2008 03:48:09 +1000
In-Reply-To: <200806270824.54066-xzBkAS4TQxQfv37vnLkPlQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 27, 2008 at 08:24:49AM +0200, Adrian von Bidder wrote:
> On Thursday 26 June 2008 19.03:42 you wrote:
> > On Thu, Jun 26, 2008 at 08:19:29AM +0200, Adrian von Bidder wrote:
> > > On Wednesday 25 June 2008 18.56:58 J. Bruce Fields wrote:
> > > > On Wed, Jun 25, 2008 at 09:02:42AM +0200, Adrian von Bidder wrote:
> > > > > First tries showed
> > > > >  * There are no acl on my files now
> > > >
> > > > NFSv4 uses an entirely different type of ACL, for which you need
> > > > different client-side tools; see
> > >
> > > I'm absolutely confused on the state of nfs4 acls.  There are so many
> > > old mailing list posts around that it's difficult to see what
> > > information applies to the currentimplementation.  So: are POSIX acls
> > > in the server filesystem somehow mapped to nfsv4 acls on the client
> > > side?  I understand there understands an RFC proposal on how to do
> > > this, and
> > > http://wiki.linux-nfs.org/wiki/index.php/ACLs is very interesting but
> > > doesn't really cover the current state of the implementation.
> >
> > I've attempted to update that wiki page to fix that problem; could you
> > take a look and tell me whether the changes help?
> 
> The summary is: "POSIX ACLs on the server side turn (more or less) into 
> NFSv4 ACL on the client.", correct?

Yes (but note that that translation happens on the server).

> So our current ACL based system of 
> permissions should work except that we can't modify permissions on the 
> client side until I've deployed nfs4 acl tools ...

ACL's will definitely still be enforced correctly, yes--enforcement of
permissions is entirely left up to the exported filesystem.

> > > > 	http://www.citi.umich.edu/projects/nfsv4/linux/nfs4-acl-tools/
> > >
> > > Hmm.  Not packaged in Debian yet?????? ;-)  So work to do for me if I
> > > end up using nfs4
> >
> > Yes.  Volunteers to package those things welcomed....
> 
> ... which means you've possibly got your Debian packager, and I might even 
> be able to do that on company time.

If you get a chance to work on that, that would be great.

> Ok, I guess I know in which direction to put my work now, thanks a lot.  
> (nfs-iostat will be the first thing I'll try, though, to get some more 
> data.)

Yes, that's probably best.  (NFSv4 will be somewhat of a long shot, and
in any case it'll help to first understand better where the time's
going.)

--b.

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

