Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:35795 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760686Ab3DBUdh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Apr 2013 16:33:37 -0400
Subject: Re: [PATCH] Avoid PTR lookups when possible
From: Simo Sorce <simo@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs <linux-nfs@vger.kernel.org>,
        Jeffrey Layton <jlayton@redhat.com>
In-Reply-To: <4C53BFA2-E684-4638-A7B9-E439EB3CB7E6@oracle.com>
References: <1364910351.2660.1243.camel@willson.li.ssimo.org>
	 <515AF6DB.4000708@RedHat.com>
	 <D550C8E7-AF28-42DC-9777-9999064C9ECF@oracle.com>
	 <1364920149.2660.1258.camel@willson.li.ssimo.org>
	 <4C53BFA2-E684-4638-A7B9-E439EB3CB7E6@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 02 Apr 2013 16:33:34 -0400
Message-ID: <1364934814.2660.1286.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-04-02 at 13:21 -0700, Chuck Lever wrote:
> On Apr 2, 2013, at 9:29 AM, Simo Sorce <simo@redhat.com> wrote:
> 
> > On Tue, 2013-04-02 at 08:51 -0700, Chuck Lever wrote:
> >>> Is this "reinventing the wheel"? ;-) Don't we already have a why of
> >> determining a FQDN? 
> >>> Maybe not...
> >> 
> >> Yes, we do.  Have a look in support/export/hostname.c for tools and
> >> helpers for dealing with IP addresses properly.
> >> 
> > The only function I see that may fit the bill is host_addrinfo() which
> > calls getaddrinfo() which I avoided because gssapi will alraedy do that.
> 
> That looks like the right way to do it.  It may be reasonable to assume our resolver caches results, so a second call may not be much of a latency hit.
> 
> But AI_CANONNAME may rely on the target host having a PTR record.

No, I already filed bugs against glibc in the past where it happened by
mistake that a PTR request was done with some flag combinations.
Some distributions have patches to fix that as getaddrinfo should
exclusively deal with CNAME -> A name "canonicalization" and nothing
else. Using a PTR request is a bug. 

However I already addressed the fact I cannot use any function in that
file from gssd_proc.c so I simply used inet_pton directly, works fine
and according to comments in host_pton it is also required even if
getaddrinfo was used, and sufficient for my purposes.

> > Maybe it is ok to only check by negatives ?
> > IE check if the string is an ipv4 or an ipv6 address and if not just
> > pass the string in as is ?
> 
> IIRC, the pton() function fails if your string does not contain a presentation address.

This is fine.

>   But that allows unqualified domain labels, doesn't it?

GSSAPI will call getaddrinfo() anyway so if a shortname is used it will
be canonicalized as long as the local resolver can resolve it into a
fqdn.

If it can't though luck, either use a fqdn on the mount command or do
not enable this feature (which is why it is off by default and
selectable in the last patchset).

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

