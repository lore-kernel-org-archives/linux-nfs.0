Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f180.google.com ([209.85.223.180]:64518 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755742Ab3LENpV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Dec 2013 08:45:21 -0500
Received: by mail-ie0-f180.google.com with SMTP id tp5so28813825ieb.39
        for <linux-nfs@vger.kernel.org>; Thu, 05 Dec 2013 05:45:21 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.0 \(1812\))
Subject: Re: librpcsecgss: FTBFS on GNU/kFreeBSD
From: Trond Myklebust <trondmy@gmail.com>
In-Reply-To: <20131205134325.GA25933@infradead.org>
Date: Thu, 5 Dec 2013 08:45:19 -0500
Cc: Lever Charles Edward <chuck.lever@oracle.com>, Jim Rees <rees@umich.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        An?bal Monsalve Salazar <anibal@debian.org>,
        "Steinar H. Gunderson" <sesse@debian.org>
Message-Id: <7AB02817-E6DE-486A-A4CB-8A67AF44972A@gmail.com>
References: <20090703133142.14887.33854.reportbug@localhost.localdomain> <20131124051904.GA16651@master.debian.org> <20131124090924.GA29659@infradead.org> <20131124130753.GA15178@umich.edu> <20131204131317.GA7776@infradead.org> <108D7BCB-5869-45BB-A287-C6593257F193@oracle.com> <1021B36D-17B9-477F-A8AE-86D6A7750B80@gmail.com> <09856BCA-A255-4975-8144-D38775DC44A8@oracle.com> <20131205132341.GA3381@infradead.org> <274DEB30-A80C-49C2-9487-BAD980C86F63@gmail.com> <20131205134325.GA25933@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 5, 2013, at 8:43, Christoph Hellwig <hch@infradead.org> wrote:

> On Thu, Dec 05, 2013 at 08:41:27AM -0500, Trond Myklebust wrote:
>>> libgssapi-krb5-2 seems to have dropped the libgssglue dependency in
>>> unstable, but the others still seem to be be around.
>> 
>> I thought that Debian installs the Heimdal kerberos libraries by default. Does it have the gssapi hooks?
> 
> libgssapi-krb5-2 is described as "MIT Kerberos runtime libraries - krb5
> GSS-API Mechanism" and depends on libkrb5-3 which is "MIT Kerberos
> runtime libraries".  Nothing Heimdal related in this dependency chain.

Then it should be able to drop the CITI librpcsecgss and libgssglue.

Cheers
  Trond