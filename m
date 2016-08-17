Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34293 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751495AbcHQOcj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Aug 2016 10:32:39 -0400
Received: by mail-wm0-f65.google.com with SMTP id q128so24751155wma.1
        for <linux-nfs@vger.kernel.org>; Wed, 17 Aug 2016 07:32:04 -0700 (PDT)
Date: Wed, 17 Aug 2016 16:32:00 +0200
From: "Yann E. MORIN" <yann.morin.1998@free.fr>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>,
        libtirpc-devel@lists.sourceforge.net
Subject: Re: [Libtirpc-devel] [PATCHv2] src: remove use of the __P() macro
Message-ID: <20160817143200.GD5778@free.fr>
References: <1471294191-17800-1-git-send-email-yann.morin.1998@free.fr>
 <4b788aa2-d8c5-b47c-e7ed-48a1e5824491@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <4b788aa2-d8c5-b47c-e7ed-48a1e5824491@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve, Chuck, Mike, All,

On 2016-08-17 10:26 -0400, Steve Dickson spake thusly:
> On 08/15/2016 04:49 PM, Yann E. MORIN wrote:
> > The __P() macro is a legacy compatibility macro aimed making pre-ANSI
> > (i.e. K&R) compilers that do not support function prototypes happy,
> > while still allowing such prototypes for ANSI-compliant compilers.
> > 
> > Since virtually all compilers have been ANSI-compliant for a few decades
> > now, use of __P() is totally useless.
> > 
> > Furthermore, __P() is defined in the non-standard sys/cdefs.h header.
> > This header is present in glibc and uClibc, and both have it included
> > from many of their headers. So, sys/cdefs.h is automagically included in
> > most cases and its macros are available.
> > 
> > However, the musl C library does not provide this sys/cdefs.h header.
> > Thus, the build breaks on musl.
> > 
> > For all the above reasons, get rid of __P() wherever it is used; just
> > always declare real function prototypes.
> > 
> > Signed-off-by: "Yann E. MORIN" <yann.morin.1998@free.fr>
> > Cc: Chuck Lever <chuck.lever@oracle.com>
> > Cc: Steve Dickson <SteveD@redhat.com>
> > Cc: Mike Frysinger <vapier@gentoo.org>
> Committed... 

Thanks all for your reviews and suggestions! :-)

Regards,
Yann E. MORIN.

-- 
.-----------------.--------------------.------------------.--------------------.
|  Yann E. MORIN  | Real-Time Embedded | /"\ ASCII RIBBON | Erics' conspiracy: |
| +33 662 376 056 | Software  Designer | \ / CAMPAIGN     |  ___               |
| +33 223 225 172 `------------.-------:  X  AGAINST      |  \e/  There is no  |
| http://ymorin.is-a-geek.org/ | _/*\_ | / \ HTML MAIL    |   v   conspiracy.  |
'------------------------------^-------^------------------^--------------------'
