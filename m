Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:14330 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754253Ab3KARTB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Nov 2013 13:19:01 -0400
Date: Fri, 1 Nov 2013 13:18:55 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "cye@redhat.com" <cye@redhat.com>,
        "dpquigl@davequigley.com" <dpquigl@davequigley.com>,
        "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: fix oops when trying to set SELinux label
Message-ID: <20131101131855.224ddb4b@tlielax.poochiereds.net>
In-Reply-To: <A1A30425-FA21-4D8B-ABB4-F7E02C2D5DEA@netapp.com>
References: <1383317372-3373-1-git-send-email-jlayton@redhat.com>
	<20131101120211.586aef7a@corrin.poochiereds.net>
	<1383324599.2911.2.camel@leira.trondhjem.org>
	<20131101125719.38843cfb@tlielax.poochiereds.net>
	<A1A30425-FA21-4D8B-ABB4-F7E02C2D5DEA@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=Windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 1 Nov 2013 17:05:08 +0000
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> 
> On Nov 1, 2013, at 12:57, Jeff Layton <jlayton@redhat.com> wrote:
> 
> > On Fri, 1 Nov 2013 16:50:00 +0000
> > "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> > 
> >> On Fri, 2013-11-01 at 12:02 -0400, Jeff Layton wrote:
> >>> It looks like _nfs4_get_security_label() has the same problem, but I've
> >>> so far been unable to get it to be called, so I didn't patch it. It
> >>> seems like getxattr does some special stuff for SELinux labels that
> >>> cause them only to ever be fetched once.
> >>> 
> >>> Is there some trick to it?
> >>> 
> >> 
> >> Doesn't 'ls -Z' cause them to security label to be read again?
> >> 
> > 
> > As best I can tell, security labels are set on the inode when the inode
> > is instantiated, and then are reset on changes (i.e. setxattr). If
> 
> …and on getxattr, afaics.
> 

I don't see that. The call chain is something like this:

vfs_getxattr
  xattr_getsecurity
    security_inode_getsecurity
       selinux_inode_getsecurity

...and that function looks like it just converts the current security
context on the inode to text and plops that into the buffer.

> > another client changes the label though, it's not clear to me how your
> > client would ever notice it until the inode is dropped from the cache.
> > 
> > ISTR Eric Paris explaining to me that they do that for performance
> > reasons but it seems like something that needs to be reconsidered in
> > light of labeled NFS. Not picking up a security label change seems like
> > a bug, IMO...
> 
> To be effective, the security label should normally be set at file creation time. It should rarely, if ever, change. Why would you need to change it from a different client?
> 

At least in Fedora, there are SELinux policy changes all the time.
Sometimes that involves changing how files are labeled. I don't think
it's reasonable to assume that they only get set at creation time.

-- 
Jeff Layton <jlayton@redhat.com>
