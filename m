Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:32274 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932311Ab3LDSPR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Dec 2013 13:15:17 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: librpcsecgss: FTBFS on GNU/kFreeBSD
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1021B36D-17B9-477F-A8AE-86D6A7750B80@gmail.com>
Date: Wed, 4 Dec 2013 13:14:47 -0500
Cc: Christoph Hellwig <hch@infradead.org>, Jim Rees <rees@umich.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <09856BCA-A255-4975-8144-D38775DC44A8@oracle.com>
References: <20090703133142.14887.33854.reportbug@localhost.localdomain> <20131124051904.GA16651@master.debian.org> <20131124090924.GA29659@infradead.org> <20131124130753.GA15178@umich.edu> <20131204131317.GA7776@infradead.org> <108D7BCB-5869-45BB-A287-C6593257F193@oracle.com> <1021B36D-17B9-477F-A8AE-86D6A7750B80@gmail.com>
To: Trond Myklebust <trondmy@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 4, 2013, at 12:53 PM, Trond Myklebust <trondmy@gmail.com> wrote:

> 
> On Dec 4, 2013, at 12:14, Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> 
>> On Dec 4, 2013, at 8:13 AM, Christoph Hellwig <hch@infradead.org> wrote:
>> 
>>> Btw, looks like librpcsecgss is indeed pretty much unmaintained.  The
>>> last upstream release is a tarball drop from CITI in 2009 and there
>>> doesn't appear to be a source repository of any kind.
>>> 
>>> I think the best idea would be to merge it into the libtirpc repo,
>>> as both the heritage and usage of the codebases is the same.
>> 
>> Comparing what's packaged in nfs-utils-lib and what's in libtirpc: it appears libtirpc already has librpcsecgss.
> 
> It does? AFAICS a freshly cloned copy of libtirpc only contains the prehistoric krb4/DES implementation. I see no GSS library.

I pulled from:

  git://git.infradead.org/~steved/libtirpc.git

Yes, there's AUTH_DES support in libtirpc, and who knows if our implementation works.

But I'm looking at tirpc/rpc/auth_gss.h.  Both libraries provide roughly the same API.  And I'm able to build a working GSS-enabled version of rpc.fedfsd and clients.  "git log" tells me src/auth_gss.c and tirpc/rpc/auth_gss.h have been in libtirpc since at least 0.1.7.

libtirpc applications currently have to link explicitly with libgssapi_krb5 (provided by MIT Kerberos), AFAICT, to get GSS support.

I'd like to add support in libtirpc for dynamically loading libgssapi_krb5 when it is needed.  Then applications would need only invoke rpc_gss_*() (or the legacy authgss_*() equivalent) to get RPCSECGSS, if libgssapi_krb5 is already installed on their system.

> I thought the reason why we deprecated librpcsecgss was that the MIT Kerberos libraries now have the equivalent hooks.

My understanding:

MIT Kerberos provides libgssapi_krb5.

libtirpc provides the RPCSEC APIs based on the Kerberos v5 mechanism provided in libgssapi_krb5.

librpcsecgss provides RPCSEC APIs based on the GSSAPI Kerberos v5 mechanism provided in libgssglue, which is deprecated.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



