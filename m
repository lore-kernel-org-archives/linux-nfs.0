Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38120 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753316AbaIWPUD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Sep 2014 11:20:03 -0400
Date: Tue, 23 Sep 2014 11:20:00 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Simo Sorce <simo@redhat.com>
Cc: NeilBrown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] nfs-service: Added the starting of gssproxy
Message-ID: <20140923152000.GC29932@fieldses.org>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140923084854.6c67d401@willson.usersys.redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 23, 2014 at 08:48:54AM -0400, Simo Sorce wrote:
> On Tue, 23 Sep 2014 12:08:04 +1000
> NeilBrown <neilb@suse.de> wrote:
> > I don't think you want an install section.  That means the service
> > has to be explicitly enabled, which is a pain.
> > I think nfs-server.service should Want= this.
> > I also think 
> > 
> >   ConditionPathExists=/etc/krb5.keytab
> > 
> > would be appropriate.
> 
> If GSS-Proxy is in use the administrator may choose to use a keytab in
> a different location, so I am not entirely sure we should depend
> on /etc/krb5.keytab, however it is also ok to decide that if the admin
> wants to use a different place that they create a custom unit file.
> Up to you.

Note we're already using the same line in rpc-gssd.service and
rpc-svcgssd.service.

Can you suggest a better "does this host have krb5 configured?" test?

I think false positives are OK, but not false negatives.

(So, if we run those daemons unnecessarily it may annoy some people, but
if we fail to run them when they're needed then things really don't
work.)

--b.
