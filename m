Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:41897 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750979Ab1FIFSo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2011 01:18:44 -0400
Received: by vxi39 with SMTP id 39so919090vxi.19
        for <linux-nfs@vger.kernel.org>; Wed, 08 Jun 2011 22:18:43 -0700 (PDT)
In-Reply-To: <20110609013756.GA5304@master.debian.org>
References: <tsl1uz57fa1.fsf@mit.edu>
	<20110609013756.GA5304@master.debian.org>
Date: Thu, 9 Jun 2011 01:18:43 -0400
Message-ID: <BANLkTikKC5jdJG0KtrKxONmnSWSTm-9iyA@mail.gmail.com>
Subject: Re: libgssglue: incompatible with krb5 1.9
From: Kevin Coffman <kwc@citi.umich.edu>
To: Sam Hartman <hartmans@debian.org>, Kevin Coffman <kwc@citi.umich.edu>,
        Didier Raboud <odyx@debian.org>, linux-nfs@vger.kernel.org,
        629553@bugs.debian.org, 629692@bugs.debian.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

2011/6/8 Aníbal Monsalve Salazar <anibal@debian.org>:
> On Tue, Jun 07, 2011 at 12:55:02PM -0400, Sam Hartman wrote:
>>
>>package: libgssglue-dev
>>severity: serious
>>justification: package breaks nfs-utils build
>>version: 0.2-2
>>
>>Hi, Kevin and Debian maintainers:
>>
>>In an upcoming release, MIT has started adopting the new GSS-API type
>>names at the top of page 12 of RFC 5587.
>>
>>
>>For a variety of reasons, I pulled this change into Debian unstable.
>>Unfortunately, some applications such as nfs-utilsappear to pull in
>>gssapi.h from libgssglue, but pull in gssapi_ext.h from krb5.
>>
>>This does not work unless the gssapi.h from libgssglue includes the new
>>constant type names.
>>
>>--Sam
>
> Kevin,
>
> The original bug report #629553 is available at
> http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=629553
>
> and bug report #629692 (which has build logs) is available at
> http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=629692
>
> Sam,
>
> Could you please post the unified diff of gssapi.h from libgssglue that
> makes it work?
>
> Cheers,
>
> Aníbal

Sam's original message went to my spam folder.  I will attempt to look
at this in the next couple of days, but I can't make any promises.

K.C.
