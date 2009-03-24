From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: NFS4 ACL <-> Posix ACL
Date: Tue, 24 Mar 2009 18:22:47 -0400
Message-ID: <1237933367.7516.27.camel@heimdal.trondhjem.org>
References: <7f62dcb30903181042n42bae0bbk99f5c91fce6e9e82@mail.gmail.com>
	 <20090319193514.GE3072@fieldses.org>
	 <7f62dcb30903230646u183c79e0i4366edebe32654d5@mail.gmail.com>
	 <20090323213304.GG1067@fieldses.org>
	 <7f62dcb30903231856h7a17cea5ud7a22796ddfb6383@mail.gmail.com>
	 <20090324201002.GF19389@fieldses.org>
	 <1237931047.7516.15.camel@heimdal.trondhjem.org>
	 <20090324221537.GO19389@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alex Bremer <albremer@googlemail.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:31632 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750771AbZCXWWz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Mar 2009 18:22:55 -0400
In-Reply-To: <20090324221537.GO19389@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-03-24 at 18:15 -0400, J. Bruce Fields wrote:
> On Tue, Mar 24, 2009 at 05:44:07PM -0400, Trond Myklebust wrote:
> > On Tue, 2009-03-24 at 16:10 -0400, J. Bruce Fields wrote:
> > > On Tue, Mar 24, 2009 at 02:56:25AM +0100, Alex Bremer wrote:
> > > > >> How do other people share public files with NFS4? If there is no other
> > > > >> way than setting the users's umask to 002, this would practically
> > > > >> limit the use of NFS4 to private shares like home directories.
> > > > >
> > > > > I don't understand why--can't you use the user-private-group trick?:
> ...
> > > > - we actually have directories where files should only be group readable.
> > > 
> > > I don't get it--why not set an inheritable acl on those directories that
> > > permits only read to the group?
> > 
> > That only works if the client actually respects the acl...
> 
> I don't understand.  ACL enforcement and inheritance are both done on
> the server side.
> 
> The problem is just that the umask is applied on the client side.  But
> if the umask is 002, and an inheritable ACL permits only read, then the
> result of inheritance and umask-application will be an ACL that permits
> reads (and only reads) to the group owner (and to any named users and
> groups).

The client currently always sends a mode. My interpretation of RFC3530
is that this will always override the inherited ACL (see the discussion
in OP_OPEN and OP_CREATE w.r.t. the createattrs field).

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
