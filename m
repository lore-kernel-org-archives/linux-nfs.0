From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: Re: [PATCH] nfsd: Fix sort_pacl in fs/nfsd/nf4acl.c to
	actually	sort groups
Date: Tue, 27 Oct 2009 20:12:00 -0700
Message-ID: <1256699520.31791.25.camel@dyn9047022153>
References: <1256168703.31791.14.camel@dyn9047022153>
	 <20091027233244.GD14471@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NFS List <linux-nfs@vger.kernel.org>,
	NFS V4 Mailing List <nfsv4@linux-nfs.org>,
	Frank S Filz <ffilz@us.ibm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:44104 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932457AbZJ1DJf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Oct 2009 23:09:35 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e4.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n9S31kxU013431
	for <linux-nfs@vger.kernel.org>; Tue, 27 Oct 2009 23:01:46 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9S39dxC1134608
	for <linux-nfs@vger.kernel.org>; Tue, 27 Oct 2009 23:09:39 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n9S39dSm006392
	for <linux-nfs@vger.kernel.org>; Tue, 27 Oct 2009 23:09:39 -0400
In-Reply-To: <20091027233244.GD14471@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-10-27 at 19:32 -0400, J. Bruce Fields wrote:
> On Wed, Oct 21, 2009 at 04:45:02PM -0700, Frank Filz wrote:
> > We have been doing some extensive testing of Linux support for ACLs on
> > NFDS v4. We have noticed that the server rejects ACLs where the groups
> > are out of order, for example, the following ACL is rejected:
> > 
> > A::OWNER@:rwaxtTcCy
> > A::user101@domain:rwaxtcy
> > A::GROUP@:rwaxtcy
> > A:g:group102@domain:rwaxtcy
> > A:g:group101@domain:rwaxtcy
> > A::EVERYONE@:rwaxtcy
> > 
> > Examining the server code, I found that after converting an NFS v4 ACL
> > to POSIX, sort_pacl is called to sort the user ACEs and group ACEs.
> > Unfortunately, a minor bug causes the group sort to be skipped.
> 
> Good grief, I'm embarassed--OK, thanks for catching that!  Do you have
> any regression tests that'd be easy for someone else to run?

Using the above ACL (modified with appropriate groups and the
appropriate domain) with nfs4_setfacl will result in an EINVAL/Invalid
argument.

I'm working on a script to test ACL conversion, I will post it when it
is in a better state for public consumption. It does an exhaustive test
(which in full mode takes a day or two to complete), but I could add a
regression test that just hit various spot conditions (it will also have
to get smart about the ACL re-ordering in order to have an automated
regression test for this error).

We actually hit the bug by using nfs4_setfacl -a, discovering that the
command only succeeded if the index was specified to put the new group
ACE in the correct sorted position.

Thanks

Frank


