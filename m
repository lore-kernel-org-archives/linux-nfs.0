Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:48164 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755742Ab3LENXv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Dec 2013 08:23:51 -0500
Date: Thu, 5 Dec 2013 05:23:41 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Trond Myklebust <trondmy@gmail.com>, Christoph Hellwig <hch@infradead.org>,
        Jim Rees <rees@umich.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        An?bal Monsalve Salazar <anibal@debian.org>,
        "Steinar H. Gunderson" <sesse@debian.org>
Subject: Re: librpcsecgss: FTBFS on GNU/kFreeBSD
Message-ID: <20131205132341.GA3381@infradead.org>
References: <20090703133142.14887.33854.reportbug@localhost.localdomain>
 <20131124051904.GA16651@master.debian.org>
 <20131124090924.GA29659@infradead.org>
 <20131124130753.GA15178@umich.edu>
 <20131204131317.GA7776@infradead.org>
 <108D7BCB-5869-45BB-A287-C6593257F193@oracle.com>
 <1021B36D-17B9-477F-A8AE-86D6A7750B80@gmail.com>
 <09856BCA-A255-4975-8144-D38775DC44A8@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <09856BCA-A255-4975-8144-D38775DC44A8@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[adding back Anibal, and adding Steinar as tirpc maintainer for Debian]

On Wed, Dec 04, 2013 at 01:14:47PM -0500, Chuck Lever wrote:
> But I'm looking at tirpc/rpc/auth_gss.h.  Both libraries provide roughly
> the same API.  And I'm able to build a working GSS-enabled version of
> rpc.fedfsd and clients.  "git log" tells me src/auth_gss.c and
> tirpc/rpc/auth_gss.h have been in libtirpc since at least 0.1.7.
>
> libtirpc applications currently have to link explicitly with
> libgssapi_krb5 (provided by MIT Kerberos), AFAICT, to get GSS support.


> MIT Kerberos provides libgssapi_krb5.
> 
> libtirpc provides the RPCSEC APIs based on the Kerberos v5 mechanism provided in libgssapi_krb5.
> 
> librpcsecgss provides RPCSEC APIs based on the GSSAPI Kerberos v5 mechanism provided in libgssglue, which is deprecated.

So what's actually still using librpcsecgss and libgssglue?

There is no rdepends for librpcsecgss on my Debian -stable system,
and I couldn't find any obvious user for unstable either.  For
libgssglue1 -stable has a few consumers:

 nfs-common
 libtirpc1
 librpcsecgss3
 libgssglue-dev
 libgssapi-krb5-2

libgssapi-krb5-2 seems to have dropped the libgssglue dependency in
unstable, but the others still seem to be be around.

How does the situation look for Fedora and SuSE?
