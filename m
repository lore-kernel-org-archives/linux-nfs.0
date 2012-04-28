Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37752 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750945Ab2D1P7T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 28 Apr 2012 11:59:19 -0400
Date: Sat, 28 Apr 2012 11:59:17 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 0/3] Fix use_ipaddr race
Message-ID: <20120428155917.GA23348@fieldses.org>
References: <1334961978-2843-1-git-send-email-bfields@redhat.com>
 <20120423110419.1311c364@notabene.brown>
 <20120428112639.GA22396@fieldses.org>
 <20120428214726.1742c905@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120428214726.1742c905@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Apr 28, 2012 at 09:47:26PM +1000, NeilBrown wrote:
> On Sat, 28 Apr 2012 07:26:39 -0400 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
> 
> > On Mon, Apr 23, 2012 at 11:04:19AM +1000, NeilBrown wrote:
> > > On Fri, 20 Apr 2012 18:46:15 -0400 "J. Bruce Fields" <bfields@redhat.com>
> > > wrote:
> > > 
> > > >   mountd: unconditionally resolve ip address
> > > 
> > > Not a good idea.  If /etc/exports only contains IP address and subnets, then
> > > we don't ever want to do any address resolution.  The "resolve ip address"
> > > must at least be conditional on "are there any domain-name, wild-cards,
> > > netgroups in /etc/exports".
> > 
> > The bug is my changelog.  All we're really doing there is parsing the ip
> > address, not resolving anything.
> 
> Ahhh. I see that now.  Thanks.
> 
> > 
> > ...
> > > >   mountd: ignore use_ipaddr and just try both client types
> > > 
> > > Maybe ... though if we could syntactically distinguish "use_ipaddr" domains
> > > from "!use_ipaddr" domain and still just choose one test to perform, I think
> > > I'd prefer that.
> > 
> > Hm, OK.  Something like the following?  (Totally untested.)
> 
> Yes, that looks good.
> 
> I could probably bike-shed for a while about the leading '?', and wonder if
> '!' or '$' might be better choices, or if leading '[' and trailing ']' is
> best but I won't.  He who writes the code makes the choice.

Hah.  I think I had some vague idea like "the ? reminds us there's still
some question to be answered about this".  Anyway, my one worry is that
I'm not sure what the syntax of the existing client types.

Hm, the documentation says "?" and "[character set]" can be used in
wildcard domains, so maybe we do want '!' or '$'.

--b.
