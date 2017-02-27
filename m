Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44788 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751510AbdB1A5n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 27 Feb 2017 19:57:43 -0500
Date: Mon, 27 Feb 2017 18:03:57 -0500
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "neilb@suse.com" <neilb@suse.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 0/2] Fix up nfsd to enable NFSv4.x without NFSv4.0
Message-ID: <20170227230357.GA11912@fieldses.org>
References: <20170222233533.23845-1-trond.myklebust@primarydata.com>
 <87y3wxrcha.fsf@notabene.neil.brown.name>
 <1487811610.4863.10.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1487811610.4863.10.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 23, 2017 at 01:00:12AM +0000, Trond Myklebust wrote:
> On Thu, 2017-02-23 at 11:13 +1100, NeilBrown wrote:
> > On Wed, Feb 22 2017, Trond Myklebust wrote:
> > 
> > > This patch series was intended as a standalone series. However it
> > > now
> > > aims to fix up a few issues with Neil's initial patch:
> > > 
> > > 1) When the user turns off all minor versions of NFSv4, then that
> > > should
> > >    be equivalent to turning off NFSv4 support, and so when someone
> > > tries
> > >    to mount, we should return RPC_PROG_MISMATCH.
> > > 2) Allow the user to use either '4.0' or '4' in order to enable or
> > > disable
> > >    minor version 0. Other minor versions remain enabled/disabled
> > > using the
> > >    '4.x' format.
> > 
> > If I understand you and the code correctly, then this change means
> > that
> > if I run
> > 
> >    rpc.nfsd -N 4
> > 
> > the nfs server will continue to server v4.1 and v4.2 requests, only
> > v4.0
> > will be disabled (Assuming a kernel which defaults to serving v4.0,
> > v4.1
> > and v4.0).
> 
> Unfortunately not... The problem is that rpc.nfsd has a borken parser
> that refuses the '-N4 -V4.2' syntax, and that throws hissy fit if you
> try to feed it '-N4.0' or '-V4.0'.
> 
> The kernel change needs to be accompanied by a fix to nfs-utils.
> 
> > Is that really what we want?
> > 
> > The text in the man page for rpc.nfsd could be read as allowing this
> > interpretation, though it isn't explicit.
> > I've always used "NFSv4" to mean any or all for 4.0, 4.1, 4.2, ...
> 
> We _could_ do that. As I said, that's a question of fixing rpc.nfsd.
> 
> The question here, though, is what should the kernel do when you start
> poking into /proc/fs/nfsd/versions. I think adding a new field between
> '4' and '4.0' might be more disruptive than changing the meaning of '4'
> to mean '4.0' as there might be other parsers of that pseudofile out
> there today.

I'm OK with that, unless Neil sees a problem.

The changelog on the first patch doesn't seem to describe the v2 version
very well; using the below cribbed from your cover letter instead.

    nfsd: fix configuration of supported minor versions
    
    When the user turns off all minor versions of NFSv4, that should be
    equivalent to turning off NFSv4 support, so a mount attempt using NFSv4
    should get RPC_PROG_MISMATCH, not NFSERR_MINOR_VERS_MISMATCH.
    
    Allow the user to use either '4.0' or '4' to enable or disable minor
    version 0.  Other minor versions are still enabled or disabled using the
    '4.x' format.

--b.
