Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46838 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932684AbaKMUi1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Nov 2014 15:38:27 -0500
Date: Thu, 13 Nov 2014 15:38:24 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: mount default minor version behavior
Message-ID: <20141113203823.GB28845@fieldses.org>
References: <CAHQdGtTV_XW94GTeyFh+jMQ8EzkuTHv9dF+V0KMO+pqYMT3yrw@mail.gmail.com>
 <5463C066.8030205@Netapp.com>
 <5463C3F8.50004@RedHat.com>
 <CAHQdGtSnz84ymSC0n=vb5yMPj+ZfgJw=PMeDOhpvQHPwK+eq3A@mail.gmail.com>
 <5464F10D.3010402@RedHat.com>
 <CAHQdGtTqJDBTKZ3e9u3FgRjRbTFapEh+nYi0i+yy02Dar-ypPA@mail.gmail.com>
 <20141113190213.GA28516@fieldses.org>
 <CAHQdGtR-e2vqZKZa0yy8tcwShyqJ-m-pVNxSzej8WApbEfTtcg@mail.gmail.com>
 <20141113195516.GA28845@fieldses.org>
 <CAHQdGtSUU3WkQ__VnuFpTY=BwS2in6Nk_3f+ycnsZVtXq0TTrQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtSUU3WkQ__VnuFpTY=BwS2in6Nk_3f+ycnsZVtXq0TTrQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 13, 2014 at 03:22:20PM -0500, Trond Myklebust wrote:
> On Thu, Nov 13, 2014 at 2:55 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Thu, Nov 13, 2014 at 02:26:20PM -0500, Trond Myklebust wrote:
> >> Secondly, that's a layering violation. The main nfs module has no
> >> business knowing anything about the sub-modules other than how to load
> >> them when needed.  If I want to recompile my NFSv4 module to add
> >> NFSv4.2 support, then I shouldn't have to recompile the entire
> >> contents of my nfs directory.
> >
> > You don't have to, you just have to mount with -oversion=4.2  in that
> > case.
> >
> > The compile-time constant here is just a default starting point for
> > negotation.
> >
> > As long as there's no stable kernel API, and end users don't routinely
> > load modules from the future, the nfs module seems like a reasonable
> > enough place to store the default minorversion.
> >
> 
> It is reasonable if and only if your process can load modules and read
> procfs, neither of which are guaranteed in all situations where we may
> want to use mount.nfs.

Yeah, OK, so if we have to assume access to not much more than the mount
syscall then I give up.  (I guess the only way to let the nfs module
decide the default in that case would be to let the kernel do more of
the negotation?)

--b.
