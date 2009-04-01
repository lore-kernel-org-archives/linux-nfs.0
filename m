Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:49068 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764302AbZDAQG1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Apr 2009 12:06:27 -0400
Date: Wed, 1 Apr 2009 12:06:23 -0400
To: spencer shepler <spencer.shepler@gmail.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: Making crossmnt a default export option
Message-ID: <20090401160623.GD5018@fieldses.org>
References: <49CA7D93.9050608@RedHat.com> <b314b0e60903251736i42b1113cj6aafc058d775b2c2@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <b314b0e60903251736i42b1113cj6aafc058d775b2c2@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Mar 25, 2009 at 07:36:45PM -0500, spencer shepler wrote:
> On Wed, Mar 25, 2009 at 1:53 PM, Steve Dickson <SteveD@redhat.com> wrote:
> > Hello,
> >
> > What would be the ramifications of turning on the crossmnt
> > option on by default? Currently the the default is nocrossmnt.
> >
> > In my recent work with pseudo exports, it has become very apparent
> > that having the crossmnt always set, especially with multi file
> > system exports, allows mount to "just work"!
> >
> > So historically what is the reason for not allowing the clients
> > to always cross file systems? Is it a security issue?
> > And again, what would be the ramifications always allowing, by
> > default, clients to cross file systems?
> 
> As Trond mentioned, the OpenSolaris client doesn't automatically
> create mount points when crossing the server's filesystem boundaries
> (for NFSv3).
> NFSv4 support for that behavior is now present for OpenSolaris.
> 
> So the risk is running into clients that don't behave like the Linux
> client and then "mv" will not be able to determine the appropriate
> behavior when mv'ing files between those filesystems.

And some applications may be confused when they see different files that
appear to be on the same filesystem but that have different inodes.
Etc.

And this requires people to change their exports.  We've done this
before (with sync and subtree_check), but it's something to avoid if at
all possible.

So preserving the current behavior for v2/v3 is important.

--b.
