Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:42156 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751296AbdBXUce (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 24 Feb 2017 15:32:34 -0500
Date: Fri, 24 Feb 2017 15:32:32 -0500
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: Trond Myklebust <trondmy@primarydata.com>,
        "steved@redhat.com" <steved@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] nfsd: Change the default to enable all minor
 versions unless told otherwise
Message-ID: <20170224203232.GC26378@fieldses.org>
References: <20170224003344.113724-1-trond.myklebust@primarydata.com>
 <20170224003344.113724-2-trond.myklebust@primarydata.com>
 <20170224003344.113724-3-trond.myklebust@primarydata.com>
 <87ino0qtf4.fsf@notabene.neil.brown.name>
 <1487900531.114433.1.camel@primarydata.com>
 <87fuj4qq4y.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <87fuj4qq4y.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 24, 2017 at 01:27:57PM +1100, NeilBrown wrote:
> On Fri, Feb 24 2017, Trond Myklebust wrote:
> 
> > Hi Neil,
> >
> > On Fri, 2017-02-24 at 12:17 +1100, NeilBrown wrote:
> >> On Thu, Feb 23 2017, Trond Myklebust wrote:
> >> 
> >> > Instead of letting the kernel decide, default to enabling all
> >> > versions,
> >> > and let the user be more specifc in /etc/nfs.conf or on the command
> >> > line.
> >> 
> >> What is your rationale for this?
> >> I think there is value in allowing the kernel to support a version
> >> while
> >> disabling it by default.  This allows it to be used for
> >> experimentation,
> >> without much risk of it being used in production until it is deemed
> >> to
> >> be really ready.
> >
> > I think we can still do that by having the kernel simply not report
> > that version. You'll note that -V4.x and -N4.x are allowed whether or
> > not the kernel is reporting a version 'x' in /proc/fs/nfsd/versions.
> >
> > IOW: if you want to make the version not appear by default because it
> > is unstable, then you probably don't want it to appear when the user
> > does '+V4' either so you might as well hide it in
> > /proc/fs/nfsd/versions too.
> 
> That seems reasonable - possibly even better than the current approach,
> though it is hard to be sure without actually trying it out for a while.
> I haven't poured over the patches enough for a reviewed-by, but
>   Acked-by: NeilBrown <neilb@suse.com>

It's too late to tell old kernels to hide experimental versions, though.
And it's 4.1's experimental stage that's most likely to be a
problem--though maybe that's getting long enough go that not too many
people are bisecting back to that era of kernel.

I dunno, I'm inclined to drop as long as this part isn't necessary to
solve Trond's immediate problem.

--b.
