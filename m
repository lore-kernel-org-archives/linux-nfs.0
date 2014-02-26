Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:41134 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751017AbaBZOkw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Feb 2014 09:40:52 -0500
Subject: Re: What does rpc.mountd dlopen() libnfsjunct.so rather than
 libnfsjunct.so.0
From: Simo Sorce <simo@redhat.com>
To: NeilBrown <neilb@suse.de>
Cc: Chuck Lever <chuck.lever@oracle.com>, Steve Dickson <SteveD@redhat.com>,
        NFS <linux-nfs@vger.kernel.org>
In-Reply-To: <20140226180158.7f7d0e62@notabene.brown>
References: <20140226161646.1520358b@notabene.brown>
	 <728AA1BE-98D9-4E63-B415-8CB922AD121C@oracle.com>
	 <20140226180158.7f7d0e62@notabene.brown>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 26 Feb 2014 09:40:47 -0500
Message-ID: <1393425647.18299.158.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2014-02-26 at 18:01 +1100, NeilBrown wrote:
> On Tue, 25 Feb 2014 22:06:58 -0800 Chuck Lever <chuck.lever@oracle.com> wrote:
> 
> > 
> > 
> > > On Feb 25, 2014, at 9:16 PM, NeilBrown <neilb@suse.de> wrote:
> > > 
> > > 
> > > See $SUBJ
> > > 
> > > Shared libraries are usually versioned so you can release a new version with
> > > an incompatible API and gradually transition to it.
> > > 
> > > A rpc.mountd dlopens libnfsjunct.so with no version it is effectively
> > > prohibited from ever changing the API in an incompatible way.
> > 
> > There is an API version field that mountd can examine before using the plug-in.  .so symlinks to whichever library version is the blessed one.
> 
> What exactly does "blessed one" mean...
> 
> Maybe the question I want to ask is:
>  Is libnfsjunct.so something that only rpc.mountd would ever use and it could
>  not possibly make any sense for anything else to ever use it?
> 
> If so, then we probably don't want to install the .so.0 or .so.0.0.0 files
> and maybe should give libnfsjunct.so a different suffix because it is not
> "shared" in any sense (I wanted to suggest ".lo" for loadable object, but I
> think that is already used).
> 
> If not, then you could conceivably have two tool installed which use
> different version, so it doesn't make sense for either to be "blessed".
> The bare ".so" name would be "the version that should be used when building
> anything from source".
> 
> Does the question have a simple answer?

Shared objects are always called .so, however private modules SHOULD be
installed in a package private directory and no in /usr/lib[64]

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

