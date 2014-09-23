Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:6646 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755873AbaIWQBB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Sep 2014 12:01:01 -0400
Date: Tue, 23 Sep 2014 12:00:54 -0400
From: Simo Sorce <simo@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: NeilBrown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] nfs-service: Added the starting of gssproxy
Message-ID: <20140923120054.7dc8764a@willson.usersys.redhat.com>
In-Reply-To: <20140923152000.GC29932@fieldses.org>
References: <20140922152603.75005941@willson.usersys.redhat.com>
	<54207BCD.70101@RedHat.com>
	<20140922204401.GI26763@fieldses.org>
	<5420911D.6080506@RedHat.com>
	<20140922223423.GA29932@fieldses.org>
	<5420B78D.6040704@RedHat.com>
	<20140922202655.5e308e58@willson.usersys.redhat.com>
	<20140923015549.GB32712@fieldses.org>
	<20140923120804.51dbcc2e@notabene.brown>
	<20140923084854.6c67d401@willson.usersys.redhat.com>
	<20140923152000.GC29932@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 23 Sep 2014 11:20:00 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Sep 23, 2014 at 08:48:54AM -0400, Simo Sorce wrote:
> > On Tue, 23 Sep 2014 12:08:04 +1000
> > NeilBrown <neilb@suse.de> wrote:
> > > I don't think you want an install section.  That means the service
> > > has to be explicitly enabled, which is a pain.
> > > I think nfs-server.service should Want= this.
> > > I also think 
> > > 
> > >   ConditionPathExists=/etc/krb5.keytab
> > > 
> > > would be appropriate.
> > 
> > If GSS-Proxy is in use the administrator may choose to use a keytab
> > in a different location, so I am not entirely sure we should depend
> > on /etc/krb5.keytab, however it is also ok to decide that if the
> > admin wants to use a different place that they create a custom unit
> > file. Up to you.
> 
> Note we're already using the same line in rpc-gssd.service and
> rpc-svcgssd.service.
> 
> Can you suggest a better "does this host have krb5 configured?" test?
> 
> I think false positives are OK, but not false negatives.
> 
> (So, if we run those daemons unnecessarily it may annoy some people,
> but if we fail to run them when they're needed then things really
> don't work.)

I would simply not test for presence of a keytab if it were my call.

If the admin decided to start nfs-secure I assume he already got the
proper key material, ie I am not so sure that double-checking the admin
in the unit files is right for gssproxy, because gssproxy has
directives that allow the admin to put the keytab elsewhere.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York
