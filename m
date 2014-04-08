Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:42966 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756894AbaDHSU5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Apr 2014 14:20:57 -0400
Date: Tue, 8 Apr 2014 13:59:59 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "Frank Filz" <ffilzlnx@mindspring.com>
Cc: "'Simo Sorce'" <simo@redhat.com>,
        "'Trond Myklebust'" <trond.myklebust@primarydata.com>,
        "'Dr Fields James Bruce'" <bfields@fieldses.org>,
        "'NFS'" <linux-nfs@vger.kernel.org>,
        "'Adamson William Andros'" <androsadamson@gmail.com>,
        "'Lever Charles Edward'" <chuck.lever@oracle.com>
Subject: Re: v4.0 CB_COMPOUND authentication failures
Message-ID: <20140408135959.04021312@tlielax.poochiereds.net>
In-Reply-To: <09b701cf5351$707b2a10$51717e30$@mindspring.com>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 8 Apr 2014 10:39:04 -0700
"Frank Filz" <ffilzlnx@mindspring.com> wrote:

> > > If you mount by IP do you really care about krb5 ? Probably not, maybe
> > > that's a clue we should not even try ...
> > >
> > 
> > It's certainly possible that someone passes in an IP address but then says
> "-o
> > sec=krb5". It has worked in the past, so it's hard to know whether and how
> > many people actually depend on it.
> 
> Mount by ip is sometimes used with clustered servers, especially when they
> have all their IP addresses in the DNS record. Even using a FQDN that just
> specifies that one IP address probably won't work then (since it probably is
> NOT the hostname used in the server credential).
> 
> Frank
> 

Well even if it works today, using IP addresses with krb5 requires a bit of
cognitive dissonance. krb5 is set up to use hostnames, so if you don't
provide them you end up using what DNS gives you. That effectively
leaves you only as secure as your DNS resolution is. Simo's blog post
outlines the potential danger of that approach.

-- 
Jeff Layton <jlayton@redhat.com>
