From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: NFS4 ACL <-> Posix ACL
Date: Tue, 24 Mar 2009 19:20:52 -0400
Message-ID: <1237936852.7516.50.camel@heimdal.trondhjem.org>
References: <20090319193514.GE3072@fieldses.org>
	 <7f62dcb30903230646u183c79e0i4366edebe32654d5@mail.gmail.com>
	 <20090323213304.GG1067@fieldses.org>
	 <7f62dcb30903231856h7a17cea5ud7a22796ddfb6383@mail.gmail.com>
	 <20090324201002.GF19389@fieldses.org>
	 <1237931047.7516.15.camel@heimdal.trondhjem.org>
	 <20090324221537.GO19389@fieldses.org>
	 <1237933367.7516.27.camel@heimdal.trondhjem.org>
	 <20090324223443.GQ19389@fieldses.org>
	 <1237935281.7516.40.camel@heimdal.trondhjem.org>
	 <20090324230209.GX19389@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alex Bremer <albremer@googlemail.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58159 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753237AbZCXXV1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Mar 2009 19:21:27 -0400
In-Reply-To: <20090324230209.GX19389@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-03-24 at 19:02 -0400, J. Bruce Fields wrote:
> On Tue, Mar 24, 2009 at 06:54:41PM -0400, Trond Myklebust wrote:
> > On Tue, 2009-03-24 at 18:34 -0400, J. Bruce Fields wrote:
> > > On Tue, Mar 24, 2009 at 06:22:47PM -0400, Trond Myklebust wrote:
> > > > On Tue, 2009-03-24 at 18:15 -0400, J. Bruce Fields wrote:
> > > > > On Tue, Mar 24, 2009 at 05:44:07PM -0400, Trond Myklebust wrote:
> > > > > > On Tue, 2009-03-24 at 16:10 -0400, J. Bruce Fields wrote:
> > > > > > > On Tue, Mar 24, 2009 at 02:56:25AM +0100, Alex Bremer wrote:
> > > > > > > > >> How do other people share public files with NFS4? If there is no other
> > > > > > > > >> way than setting the users's umask to 002, this would practically
> > > > > > > > >> limit the use of NFS4 to private shares like home directories.
> > > > > > > > >
> > > > > > > > > I don't understand why--can't you use the user-private-group trick?:
> > > > > ...
> > > > > > > > - we actually have directories where files should only be group readable.
> > > > > > > 
> > > > > > > I don't get it--why not set an inheritable acl on those directories that
> > > > > > > permits only read to the group?
> > > > > > 
> > > > > > That only works if the client actually respects the acl...
> > > > > 
> > > > > I don't understand.  ACL enforcement and inheritance are both done on
> > > > > the server side.
> > > > > 
> > > > > The problem is just that the umask is applied on the client side.  But
> > > > > if the umask is 002, and an inheritable ACL permits only read, then the
> > > > > result of inheritance and umask-application will be an ACL that permits
> > > > > reads (and only reads) to the group owner (and to any named users and
> > > > > groups).
> > > > 
> > > > The client currently always sends a mode. My interpretation of RFC3530
> > > > is that this will always override the inherited ACL (see the discussion
> > > > in OP_OPEN and OP_CREATE w.r.t. the createattrs field).
> > > 
> > > Depends on what you mean by "override".  It shouldn't be replacing the
> > > inherited ACL wholesale; see 6.4.3.
> > 
> > That is the v4.1 draft, which is hardly normative for NFSv4.0 servers.
> > Note, however, that in the v4.1 case too, the server is required to
> > replace the OWNER@, GROUP@ and EVERYONE@ fields when the client sends a
> > mode attribute (afaics from 6.4.1.1).
> 
> Sure, but there's no need to blow away ACEs for named users and
> groups--anyone that cares about posix should be restricting them to
> grant no more than the mode group bits, but that's all.

The client still needs to know whether or not it should apply the umask.
I therefore don't see how changing server behaviour to the above can
solve the problem in practice.

Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
