Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:35069 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762224Ab3DBUVi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Apr 2013 16:21:38 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.3 \(1503\))
Subject: Re: [PATCH] Avoid PTR lookups when possible
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1364920149.2660.1258.camel@willson.li.ssimo.org>
Date: Tue, 2 Apr 2013 13:21:36 -0700
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs <linux-nfs@vger.kernel.org>,
        Jeffrey Layton <jlayton@redhat.com>
Message-Id: <4C53BFA2-E684-4638-A7B9-E439EB3CB7E6@oracle.com>
References: <1364910351.2660.1243.camel@willson.li.ssimo.org> <515AF6DB.4000708@RedHat.com> <D550C8E7-AF28-42DC-9777-9999064C9ECF@oracle.com> <1364920149.2660.1258.camel@willson.li.ssimo.org>
To: Simo Sorce <simo@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 2, 2013, at 9:29 AM, Simo Sorce <simo@redhat.com> wrote:

> On Tue, 2013-04-02 at 08:51 -0700, Chuck Lever wrote:
>>> Is this "reinventing the wheel"? ;-) Don't we already have a why of
>> determining a FQDN? 
>>> Maybe not...
>> 
>> Yes, we do.  Have a look in support/export/hostname.c for tools and
>> helpers for dealing with IP addresses properly.
>> 
> The only function I see that may fit the bill is host_addrinfo() which
> calls getaddrinfo() which I avoided because gssapi will alraedy do that.

That looks like the right way to do it.  It may be reasonable to assume our resolver caches results, so a second call may not be much of a latency hit.

But AI_CANONNAME may rely on the target host having a PTR record.

> Maybe it is ok to only check by negatives ?
> IE check if the string is an ipv4 or an ipv6 address and if not just
> pass the string in as is ?

IIRC, the pton() function fails if your string does not contain a presentation address.  But that allows unqualified domain labels, doesn't it?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



