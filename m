Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:12157 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756739AbaDHW5v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Apr 2014 18:57:51 -0400
Subject: RE: v4.0 CB_COMPOUND authentication failures
From: Simo Sorce <simo@redhat.com>
To: Frank Filz <ffilzlnx@mindspring.com>
Cc: "'Jeff Layton'" <jlayton@redhat.com>,
        "'Trond Myklebust'" <trond.myklebust@primarydata.com>,
        "'Dr Fields James Bruce'" <bfields@fieldses.org>,
        "'NFS'" <linux-nfs@vger.kernel.org>,
        "'Adamson William Andros'" <androsadamson@gmail.com>,
        "'Lever Charles Edward'" <chuck.lever@oracle.com>
In-Reply-To: <09e001cf537c$29ed9580$7dc8c080$@mindspring.com>
References: <20140408082140.340c1328@tlielax.poochiereds.net>
	 <20140408123501.GA3532@fieldses.org>
	 <20140408094903.33e42de2@tlielax.poochiereds.net>
	 <20140408140333.GD3882@fieldses.org>
	 <6CC79B2A-8AE2-4A36-BB57-380C2F9813C0@primarydata.com>
	 <20140408144652.GE3882@fieldses.org>
	 <ECD8245B-CDEE-442E-A41A-BECE08BEEDA1@primarydata.com>
	 <20140408124428.5152ae8b@tlielax.poochiereds.net>
	 <1396978021.14203.163.camel@willson.li.ssimo.org>
	 <20140408133040.3c149238@tlielax.poochiereds.net>
	 <09b701cf5351$707b2a10$51717e30$@mindspring.com>
	 <1396980375.14203.167.camel@willson.li.ssimo.org>
	 <09e001cf537c$29ed9580$7dc8c080$@mindspring.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 08 Apr 2014 18:52:38 -0400
Message-ID: <1396997558.19767.22.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2014-04-08 at 15:44 -0700, Frank Filz wrote:
> > On Tue, 2014-04-08 at 10:39 -0700, Frank Filz wrote:
> > > > > If you mount by IP do you really care about krb5 ? Probably not,
> > > > > maybe that's a clue we should not even try ...
> > > > >
> > > >
> > > > It's certainly possible that someone passes in an IP address but
> > > > then says
> > > "-o
> > > > sec=krb5". It has worked in the past, so it's hard to know whether
> > > > and how many people actually depend on it.
> > >
> > > Mount by ip is sometimes used with clustered servers, especially when
> > > they have all their IP addresses in the DNS record. Even using a FQDN
> > > that just specifies that one IP address probably won't work then
> > > (since it probably is NOT the hostname used in the server credential).
> > 
> > I do not understand this, using an IP address or a name that resolve to said IP
> > address is the same.
> 
> But a name can resolve to a set of IP addresses, often in round-robin
> fashion. It would cause havoc with NFS server on a cluster if a v3
> client had locks on 192.168.0.10 (resolved from server.mycompany.com),
> and then rebooted, and resolved to 192.168.0.9 and sent SM_NOTIFY
> there). At least that isn't an issue with v4...

Sound you configured your DNS wrong, DNS round robin is not the right
way to do load balancing for NFSv3.

Also if you are specifying an IP address you can as well specify an
explicit name instead, you can achieve that by using a RR CNAME and then
make sure the client sticks to the resolved A name for the life of the
locks.

For a reboot situation you are screwed anyway unless you configure an
explicit address, in which case you do not have redundancy anyway.
You just use a DNS name that is resolved into a unique IP address.

> Or worse, tcp connection is dropped due to inactivity, and new
> connection is made to a different server node. But this could still be
> an issue with v4...

Same as above.

> The workaround has been to specify specific IP address.

The workaround to what ? Why are you using RR names if client are going
to stick to a specific server anyway ? You are working around a problem
you are created yourself, fix the problem! (You can fix it also by
setting an entry in /etc/hosts, it is semantically identical to
specifying an IP address on the mount anyway).

> Now I haven't done enough with krb5 recently to know how well that
> works...

> I guess I'm just offering one reason IP addresses might have been
> specified on mount...

A bogus reason :-)

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

