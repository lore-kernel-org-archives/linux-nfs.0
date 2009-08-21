From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: mount.nfs: access denied by server
Date: Fri, 21 Aug 2009 16:59:21 -0400
Message-ID: <20090821205921.GC23529@fieldses.org>
References: <1250822171.6514.29.camel@heimdal.trondhjem.org> <BAE89B4F-CA8C-46B2-82EA-9BAA438C1DF7@oracle.com> <20090821182418.GE21043@fieldses.org> <31F3372A-891E-44EF-8DD2-78D5A3AD5CF1@oracle.com> <20090821200403.GA23529@fieldses.org> <4A8F0118.60705@sun.com> <4A8F0619.60305@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Haynes <Thomas.Haynes-UdXhSnd/wVw@public.gmane.org>,
	Chuck Lever <Chuck.Lever@oracle.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39946 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932675AbZHUU72 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Aug 2009 16:59:28 -0400
In-Reply-To: <4A8F0619.60305@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 21, 2009 at 04:39:53PM -0400, Peter Staubach wrote:
> Tom Haynes wrote:
> > J. Bruce Fields wrote:
> >>
> >>> Right now, we use AUTH_SYS if the mount command didn't specify a
> >>> flavor, but the flavor we're going to use is always checked against
> >>> the server's returned list.  You seem to be suggesting we should
> >>> ignore the server's list entirely if sec= was specified...?
> >>>     
> >>
> >> Yes.  I can't see what practical problems that would cause.
> >>
> 
> Here, I am going to disagree.  The client should compare the
> flavor specified with the list of authentication flavors
> returned by the server and if the specific flavor isn't on
> the list, then the mount attempt should be failed.

Why?  What can go wrong if you just try the flavor?

Ugh: to answer my own question: ok, if the server allows auth_sys for
the NFS operations required on mount (as suggested by the security
considerations rfc), then that would mean mount would always succeed,
and nobody would see the error until the first operation on the
filesystem.  It would be better to return the error on mount.

So, I think I have to give in and agree with you.  People will just have
to upgrade their mountd's....

--b.
