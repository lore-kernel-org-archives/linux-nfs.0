From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] [PATCH] nfs4, special files, and set/listxattr asymmetry
Date: Tue, 8 Jan 2008 17:25:22 -0500
Message-ID: <20080108222522.GT22155@fieldses.org>
References: <20080108182038.GJ22155@fieldses.org>
	<200801082147.m08LlF3D023364@agora.fsl.cs.sunysb.edu>
	<20080108215736.GP22155@fieldses.org>
	<1199829935.8434.75.camel@moss-terrapins.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: Dave Quigley <dpquigl@tycho.nsa.gov>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:49309 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755982AbYAHWZj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jan 2008 17:25:39 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JCMt6-0000Ev-Lj
	for linux-nfs@vger.kernel.org; Wed, 09 Jan 2008 09:25:36 +1100
In-Reply-To: <1199829935.8434.75.camel-88+Bj4OksMGWPftkNcioYDMZycKHmlmlfvIqQ387n9k@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 08, 2008 at 05:05:35PM -0500, Dave Quigley wrote:
> xattrs are only the local Linux representation of a MAC attribute. For
> the purpose of interoperability we can't assume xattrs considering NFSv4
> doesn't contain them in the specification. We considered the named
> attributes but they fall short concerning file labeling. Instead we are
> working on adding another recommended attribute to the NFSv4
> specification to handle an opaque security label. For your purposes you
> can continue to think of them as extended attributes since that is the
> interface that Linux has chosen for security attributes. However, I
> don't see this functionality making its way into Linux any time soon
> since it will require a change to the NFSv4 standard and they are
> wrapping up the NFSv4.1 specification. I can't say how long it will be
> before NFSv4.2 starts up. Maybe future events will cause that to happen
> sooner than later.

I would hope that the existance of a good, well-documented
implementation is the important thing, and would make things go more
quickly.

--b.

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

