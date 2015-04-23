Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:32809 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030702AbbDWVvK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2015 17:51:10 -0400
Received: by layy10 with SMTP id y10so22511260lay.0
        for <linux-nfs@vger.kernel.org>; Thu, 23 Apr 2015 14:51:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5539240E.1060205@RedHat.com>
References: <1418718540-13667-1-git-send-email-ncopa@alpinelinux.org>
	<5539240E.1060205@RedHat.com>
Date: Thu, 23 Apr 2015 23:51:08 +0200
Message-ID: <CAC1BbcTb2jPuVDgAktkHeJDHVVSFaaZG=HrHeXP=m1iQ8Wm8FQ@mail.gmail.com>
Subject: Re: [Libtirpc-devel] [PATCH 0/9] Cleanups and fixes for musl libc
From: Bernhard Reutner-Fischer <rep.dot.nop@gmail.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Natanael Copa <ncopa@alpinelinux.org>,
        libtirpc-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 23 April 2015 at 18:55, Steve Dickson <SteveD@redhat.com> wrote:
>
>
> On 12/16/2014 03:28 AM, Natanael Copa wrote:
>> Various fixes for making libtirpc build and run with musl libc.
>>
>> I have also included some cleanups that I did while at it.
>>
>> Natanael Copa (9):
>>   Replace INSTALL symlink with a copy of the file
>>   Provide getrpcbynumber and getrpcbyname if those are missing
>>   Avoid use of internal glibc sys/cdefs.h header
>>   Add configure option to disable DES authentication
>>   Fix compile error: 'IPPORT_RESERVED' undeclared
>>   Define struct rpcent on non GNU libc
>>   Include string.h for memset
>>   Fix location of various standard header includes
>>   Add a HACKING file which tells where to send patches
> All 9 patches committed...

/HAVE_GETRPCBYNYMBER/s/BYNY/BYNU/

The hunk in tirpc/rpc/rpcent.h looks like it should have been guarded
by HAVE_GETRPCBYNUMBER and HAVE_GETRPCBYNAME and not by !GLIBC.
I'd have guarded the struct with !defined bynumber  || !defined byname
but i assume conflicting declarations are hopefully rare.
rpcent.c unconditionally compiles setrpcent(), endrpcent(),
getrpcent() so these should likely be omitted if available in libc,
too.

thanks,
