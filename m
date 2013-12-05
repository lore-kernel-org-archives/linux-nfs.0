Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:55253 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756705Ab3LENlb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Dec 2013 08:41:31 -0500
Received: by mail-ie0-f177.google.com with SMTP id tp5so28806545ieb.22
        for <linux-nfs@vger.kernel.org>; Thu, 05 Dec 2013 05:41:31 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.0 \(1812\))
Subject: Re: librpcsecgss: FTBFS on GNU/kFreeBSD
From: Trond Myklebust <trondmy@gmail.com>
In-Reply-To: <20131205132341.GA3381@infradead.org>
Date: Thu, 5 Dec 2013 08:41:27 -0500
Cc: Lever Charles Edward <chuck.lever@oracle.com>, Jim Rees <rees@umich.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        An?bal Monsalve Salazar <anibal@debian.org>,
        "Steinar H. Gunderson" <sesse@debian.org>
Message-Id: <274DEB30-A80C-49C2-9487-BAD980C86F63@gmail.com>
References: <20090703133142.14887.33854.reportbug@localhost.localdomain> <20131124051904.GA16651@master.debian.org> <20131124090924.GA29659@infradead.org> <20131124130753.GA15178@umich.edu> <20131204131317.GA7776@infradead.org> <108D7BCB-5869-45BB-A287-C6593257F193@oracle.com> <1021B36D-17B9-477F-A8AE-86D6A7750B80@gmail.com> <09856BCA-A255-4975-8144-D38775DC44A8@oracle.com> <20131205132341.GA3381@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 5, 2013, at 8:23, Christoph Hellwig <hch@infradead.org> wrote:

> [adding back Anibal, and adding Steinar as tirpc maintainer for Debian]
> 
> On Wed, Dec 04, 2013 at 01:14:47PM -0500, Chuck Lever wrote:
>> But I'm looking at tirpc/rpc/auth_gss.h.  Both libraries provide roughly
>> the same API.  And I'm able to build a working GSS-enabled version of
>> rpc.fedfsd and clients.  "git log" tells me src/auth_gss.c and
>> tirpc/rpc/auth_gss.h have been in libtirpc since at least 0.1.7.
>> 
>> libtirpc applications currently have to link explicitly with
>> libgssapi_krb5 (provided by MIT Kerberos), AFAICT, to get GSS support.
> 
> 
>> MIT Kerberos provides libgssapi_krb5.
>> 
>> libtirpc provides the RPCSEC APIs based on the Kerberos v5 mechanism provided in libgssapi_krb5.
>> 
>> librpcsecgss provides RPCSEC APIs based on the GSSAPI Kerberos v5 mechanism provided in libgssglue, which is deprecated.
> 
> So what's actually still using librpcsecgss and libgssglue?
> 
> There is no rdepends for librpcsecgss on my Debian -stable system,
> and I couldn't find any obvious user for unstable either.  For
> libgssglue1 -stable has a few consumers:
> 
> nfs-common
> libtirpc1
> librpcsecgss3
> libgssglue-dev
> libgssapi-krb5-2
> 
> libgssapi-krb5-2 seems to have dropped the libgssglue dependency in
> unstable, but the others still seem to be be around.

I thought that Debian installs the Heimdal kerberos libraries by default. Does it have the gssapi hooks?

> How does the situation look for Fedora and SuSE?

Fedora’s nfs-utils RPM lists a dependency on ‘libgssapi_krb5.so.2()(64bit)' and 'libgssapi_krb5.so.2(gssapi_krb5_2_MIT)(64bit)', so it uses the gssapi from the MIT kerberos libraries.

Not sure about SuSE, but I believe they use MIT kerberos too. Neil Brown would know.

Cheers
  Trond