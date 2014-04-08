Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:55849 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757822AbaDHSGZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Apr 2014 14:06:25 -0400
Subject: RE: v4.0 CB_COMPOUND authentication failures
From: Simo Sorce <simo@redhat.com>
To: Frank Filz <ffilzlnx@mindspring.com>
Cc: "'Jeff Layton'" <jlayton@redhat.com>,
        "'Trond Myklebust'" <trond.myklebust@primarydata.com>,
        "'Dr Fields James Bruce'" <bfields@fieldses.org>,
        "'NFS'" <linux-nfs@vger.kernel.org>,
        "'Adamson William Andros'" <androsadamson@gmail.com>,
        "'Lever Charles Edward'" <chuck.lever@oracle.com>
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
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 08 Apr 2014 14:06:15 -0400
Message-ID: <1396980375.14203.167.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2014-04-08 at 10:39 -0700, Frank Filz wrote:
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

I do not understand this, using an IP address or a name that resolve to
said IP address is the same.

As long as the server has a keytab with a key in that name it should
just work fine, even if the hostname on the actual machine is different.

If this does not work it is a bug in rpc.svcgssd/gss-proxy, and should
be fixed, not something to try to work around using IP addresses.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

