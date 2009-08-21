From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: mount.nfs: access denied by server
Date: Fri, 21 Aug 2009 17:08:12 -0400
Message-ID: <1250888892.5700.7.camel@heimdal.trondhjem.org>
References: <1250822171.6514.29.camel@heimdal.trondhjem.org>
	 <BAE89B4F-CA8C-46B2-82EA-9BAA438C1DF7@oracle.com>
	 <20090821182418.GE21043@fieldses.org>
	 <31F3372A-891E-44EF-8DD2-78D5A3AD5CF1@oracle.com>
	 <20090821200403.GA23529@fieldses.org> <4A8F0118.60705@sun.com>
	 <4A8F0619.60305@redhat.com>  <20090821205921.GC23529@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Staubach <staubach@redhat.com>,
	Tom Haynes <Thomas.Haynes-UdXhSnd/wVw@public.gmane.org>,
	Chuck Lever <Chuck.Lever@oracle.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:15524 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932683AbZHUVIm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Aug 2009 17:08:42 -0400
In-Reply-To: <20090821205921.GC23529@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-08-21 at 16:59 -0400, J. Bruce Fields wrote:
> On Fri, Aug 21, 2009 at 04:39:53PM -0400, Peter Staubach wrote:
> > Tom Haynes wrote:
> > > J. Bruce Fields wrote:
> > >>
> > >>> Right now, we use AUTH_SYS if the mount command didn't specify a
> > >>> flavor, but the flavor we're going to use is always checked against
> > >>> the server's returned list.  You seem to be suggesting we should
> > >>> ignore the server's list entirely if sec= was specified...?
> > >>>     
> > >>
> > >> Yes.  I can't see what practical problems that would cause.
> > >>
> > 
> > Here, I am going to disagree.  The client should compare the
> > flavor specified with the list of authentication flavors
> > returned by the server and if the specific flavor isn't on
> > the list, then the mount attempt should be failed.
> 
> Why?  What can go wrong if you just try the flavor?
> 
> Ugh: to answer my own question: ok, if the server allows auth_sys for
> the NFS operations required on mount (as suggested by the security
> considerations rfc), then that would mean mount would always succeed,
> and nobody would see the error until the first operation on the
> filesystem.  It would be better to return the error on mount.
> 
> So, I think I have to give in and agree with you.  People will just have
> to upgrade their mountd's....

People have lived with the current situation for years without any
trouble. It was only the addition of the security negotiation that
exposed the mountd bug.

My position is that if mountd returns a clearly invalid (i.e. empty)
list, then that's not a reason to interrupt the mount. We should just
fall back to what we did prior to including security negotiation.

The alternative is simply not to merge security negotiation until people
have had ample time to upgrade mountd (i.e. 2-3 years from now).

Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
