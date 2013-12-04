Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:33199 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755889Ab3LDRx2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Dec 2013 12:53:28 -0500
Received: by mail-ie0-f177.google.com with SMTP id tp5so27163512ieb.36
        for <linux-nfs@vger.kernel.org>; Wed, 04 Dec 2013 09:53:27 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.0 \(1812\))
Subject: Re: librpcsecgss: FTBFS on GNU/kFreeBSD
From: Trond Myklebust <trondmy@gmail.com>
In-Reply-To: <108D7BCB-5869-45BB-A287-C6593257F193@oracle.com>
Date: Wed, 4 Dec 2013 12:53:23 -0500
Cc: Christoph Hellwig <hch@infradead.org>, Jim Rees <rees@umich.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <1021B36D-17B9-477F-A8AE-86D6A7750B80@gmail.com>
References: <20090703133142.14887.33854.reportbug@localhost.localdomain> <20131124051904.GA16651@master.debian.org> <20131124090924.GA29659@infradead.org> <20131124130753.GA15178@umich.edu> <20131204131317.GA7776@infradead.org> <108D7BCB-5869-45BB-A287-C6593257F193@oracle.com>
To: Lever Charles Edward <chuck.lever@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 4, 2013, at 12:14, Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Dec 4, 2013, at 8:13 AM, Christoph Hellwig <hch@infradead.org> wrote:
> 
>> Btw, looks like librpcsecgss is indeed pretty much unmaintained.  The
>> last upstream release is a tarball drop from CITI in 2009 and there
>> doesn't appear to be a source repository of any kind.
>> 
>> I think the best idea would be to merge it into the libtirpc repo,
>> as both the heritage and usage of the codebases is the same.
> 
> Comparing what's packaged in nfs-utils-lib and what's in libtirpc: it appears libtirpc already has librpcsecgss.

It does? AFAICS a freshly cloned copy of libtirpc only contains the prehistoric krb4/DES implementation. I see no GSS library.

I thought the reason why we deprecated librpcsecgss was that the MIT Kerberos libraries now have the equivalent hooks.

Cheers
  Trond