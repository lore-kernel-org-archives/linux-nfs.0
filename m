Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:3614 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761896Ab3DBQ3M (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Apr 2013 12:29:12 -0400
Subject: Re: [PATCH] Avoid PTR lookups when possible
From: Simo Sorce <simo@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs <linux-nfs@vger.kernel.org>,
        Jeffrey Layton <jlayton@redhat.com>
In-Reply-To: <D550C8E7-AF28-42DC-9777-9999064C9ECF@oracle.com>
References: <1364910351.2660.1243.camel@willson.li.ssimo.org>
	 <515AF6DB.4000708@RedHat.com>
	 <D550C8E7-AF28-42DC-9777-9999064C9ECF@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 02 Apr 2013 12:29:09 -0400
Message-ID: <1364920149.2660.1258.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-04-02 at 08:51 -0700, Chuck Lever wrote:
> > Is this "reinventing the wheel"? ;-) Don't we already have a why of
> determining a FQDN? 
> > Maybe not...
> 
> Yes, we do.  Have a look in support/export/hostname.c for tools and
> helpers for dealing with IP addresses properly.
> 
The only function I see that may fit the bill is host_addrinfo() which
calls getaddrinfo() which I avoided because gssapi will alraedy do that.

Maybe it is ok to only check by negatives ?
IE check if the string is an ipv4 or an ipv6 address and if not just
pass the string in as is ?

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

