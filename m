From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 0/4][RFC] NFSv3: implement extended attribute (XATTR)
 protocol
Date: Sun, 20 Sep 2009 15:13:28 +1000 (EST)
Message-ID: <alpine.LRH.2.00.0909201503390.926@tundra.namei.org>
References: <alpine.LRH.2.00.0909200020360.31818@tundra.namei.org> <4AB51538.7060201@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from tundra.namei.org ([65.99.196.166]:56838 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751264AbZITFN6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 20 Sep 2009 01:13:58 -0400
In-Reply-To: <4AB51538.7060201@schaufler-ca.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 19 Sep 2009, Casey Schaufler wrote:

> > Currently, the code is implemented only to support Linux namespace.name 
> > xattrs in the "user" namespace.
> 
> Why the limitation? It's been a while since I looked at that code,
> but it seems that it would require extra effort to impose that
> restriction. It has also proven that while Irix xattrs (which are
> the basis for Linux xattrs) were intended for end user purposes
> initially, they were only ever actually used for system attributes,
> and almost exclusively security attributes at that.

As a first step, it keeps the semantics simple, and provides a direct 
mapping between the userland API and the NFS protocol.  System level 
xattrs may have semantics which extend beyond the simple NFS xattr 
protocol (e.g. full security labeling as we've previously discussed & 
documented needs to convey more than just object labels).

Some xattr uses are internal local interfaces, such as with Linux ACLs, 
where xattrs are used internally for storing the ACL data, but the exposed 
API is quite different (as is the NFS protocol).

We can go beyond user.*, but I think each system-level xattr exposed via 
NFS will need to be considered on a case-by-case basis.

> > It could be extended to support other 
> > similar name/value pair xattr implementations (and not far from IRIX wire 
> > compat), although that's not an aim of this version.  There may also be 
> > some scope for limited support of system xattrs (e.g. 'dumb' security 
> > label transport), although I've not looked beyond user.* so far.
> >   
> 
> I suggest that support for "dumb" security attributes will dramatically
> increase the value and frequency of use of this facility.

Indeed, there is significant demand for this.  e.g. NFS root, remote 
access 
to VM images.  It's not a complete solution, of course.


- James
-- 
James Morris
<jmorris@namei.org>
