Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47235 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752342Ab2KNN7m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Nov 2012 08:59:42 -0500
Date: Wed, 14 Nov 2012 08:59:39 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: David Quigley <dpquigl@davequigley.com>
Cc: Steve Dickson <steved@redhat.com>,
        "David P. Quigley" <selinux@davequigley.com>,
        trond.myklebust@netapp.com, sds@tycho.nsa.gov,
        linux-nfs@vger.kernel.org, selinux@tycho.nsa.gov,
        linux-security-module@vger.kernel.org
Subject: Re: Labeled NFS [v5]
Message-ID: <20121114135939.GE23604@fieldses.org>
References: <1352700947-3915-1-git-send-email-dpquigl@davequigley.com>
 <20121112152335.GH30713@fieldses.org>
 <50A116F0.5050404@davequigley.com>
 <20121112160959.GK30713@fieldses.org>
 <50A16269.4060601@RedHat.com>
 <50A1A4EE.7030507@davequigley.com>
 <50A24345.8080309@RedHat.com>
 <50A31EF5.1050801@davequigley.com>
 <20121114134535.GD23604@fieldses.org>
 <624cc90c1bf726d8ff1a1ea0ace5f50f@countercultured.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <624cc90c1bf726d8ff1a1ea0ace5f50f@countercultured.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 14, 2012 at 08:50:17AM -0500, David Quigley wrote:
> On 11/14/2012 08:45, J. Bruce Fields wrote:
> >On Tue, Nov 13, 2012 at 11:32:53PM -0500, Dave Quigley wrote:
> >>Ok so if you go to http://www.selinuxproject.org/git you will see a
> >>repo for lnfs and lnfs-patchset. The instructions at
> >>http://www.selinuxproject.org/page/Labeled_NFS give you a better
> >>indication on how to pull the trees. I've attached a patch for NFS
> >>utils which gives support for security_label/nosecurity_label in
> >>your /etc/exports file.
> >
> >Do we need an export option?  Is there any reason not to make the
> >feature available whenever there's support available for it?
> 
> I guess we could build it in but I figured an export option allowed
> someone to turn off security labeling support if they didn't want it
> on that export. What happens to clients when the server returns a
> cap that they don't support? Do they mask the bits out?

Yeah, they should just ignore it.

While this is still experimental it's still nice to have a way to turn
this on and off at runtime so people can experiment without having to
have it on for everyone all the time.  But nfsd_supported_minorversion
should be sufficient for that.

(I don't think your patches actually dealt yet with the fact that this
is part of minor version 2?  Another for the todo list.)

--b.
