Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:44666 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751746Ab3DJKnI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Apr 2013 06:43:08 -0400
Date: Wed, 10 Apr 2013 06:43:04 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Steve Dickson <SteveD@redhat.com>, Simo Sorce <simo@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] Avoid reverse resolution for server name
Message-ID: <20130410064304.0e2e3bfd@corrin.poochiereds.net>
In-Reply-To: <20130409192259.GD3800@fieldses.org>
References: <515B2F8D.3030302@RedHat.com>
	<1364931149-18484-2-git-send-email-simo@redhat.com>
	<5162C8A5.4030307@RedHat.com>
	<1365430116.20560.6.camel@willson.li.ssimo.org>
	<51644CC5.3070609@RedHat.com>
	<1365528308.20560.42.camel@willson.li.ssimo.org>
	<5164514A.7020606@RedHat.com>
	<20130409185445.GA3800@fieldses.org>
	<51646838.3050209@RedHat.com>
	<20130409192259.GD3800@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 9 Apr 2013 15:22:59 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Apr 09, 2013 at 03:12:56PM -0400, Steve Dickson wrote:
> > 
> > 
> > On 09/04/13 14:54, J. Bruce Fields wrote:
> > > Argh, no, one away or another the default needs to be to not do the PTR
> > > lookup.
> > Fine... 
> >  
> > > 
> > > The transition Simo's using was Jeff's suggestion.  Let's just stick to
> > > that if we don't have a good reason.
> > Yeah... I would like to avoid adding to flags... I don't think both are 
> > needed.
> 
> So, no flags.
> 
> > > (But I don't have strong opinions about how to do it either.  I'd
> > > actually be OK with being harsh and just switching to the new behavior
> > > without any option.)
> > My crutch is I'm not a big DNS guy so I'm not sure how much breakage 
> > would occur... So I would rather be on the safe side and give people
> > a way to go back... 
> 
> So, yes to flags.  I'm confused!
> 
> I guess we can be moderately harsh: switch to the new default and
> provide only a flag to restore the old default for whoever wants it, but
> not a flag to specify the new default.  Is that what you mean?
> 

I think the above is the best course of action at this point. My
original thinking was "let's transition to the new behavior gracefully"
-- start with the default as-is, and then after suitably warning
everyone switch the default to the new behavior.

Now there's a CVE in play though, so I think our hands are tied here.
We have to change the default to the new behavior now without any sort
of graceful transition. That's likely to break in some environments at
least, so I think we need some mechanism to allow people to switch gssd
to the old behavior.

Note too that the problems are not likely to be "lack of a PTR record",
but rather that they have multiple A records pointing at the server. In
that situation, the ai_canonname field in the addrinfo struct may not
match what the PTR record points to, depending on which server name you
use.
-- 
Jeff Layton <jlayton@redhat.com>
