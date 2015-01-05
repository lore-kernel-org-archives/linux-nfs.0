Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f178.google.com ([209.85.212.178]:59394 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754086AbbAES3g (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Jan 2015 13:29:36 -0500
Received: by mail-wi0-f178.google.com with SMTP id em10so3868780wid.11
        for <linux-nfs@vger.kernel.org>; Mon, 05 Jan 2015 10:29:35 -0800 (PST)
Date: Mon, 5 Jan 2015 19:23:22 +0100
From: "Yann E. MORIN" <yann.morin.1998@free.fr>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH nfs-utils] configure: use pkg-config to find libtirpc
Message-ID: <20150105182322.GB5077@free.fr>
References: <1416755357-12228-1-git-send-email-yann.morin.1998@free.fr>
 <54AA8E4A.6060705@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <54AA8E4A.6060705@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve, All,

On 2015-01-05 08:14 -0500, Steve Dickson spake thusly:
> On 11/23/2014 10:09 AM, Yann E. MORIN wrote:
> > Currently, we use a custom function to find libtirpc's headers and
> > libraries. This works fine for shared linking.
> > 
> > But for static linking, this forgets to link with -lpthread, which is
> > required by libtirpc.
> > 
> > A recent patch was sent to libtirpc to add that missing -lpthread in its
> > Libs.private section of its .pc file. Thus, pkg-config will soon be able
> > to return the appropriate libraries.
> > 
> > So, use pkg-config to find libtirpc.
> > 
> > And for older libtirpc versions, there is no change in behaviour: we're
> > still missing the -lpthread. But once libtirpc has been fixed, we'll
> > automatically get that missing library for free! :-)
> > 
> > Remove the --with-libirpc flag as it is no longer needed: pkg-config
> > will provide us with the -I and -L flags, now.
> It turns out that using pkg-config break builds on legacy OSs which
> is something I don't want to do. I think it's important to at least 
> try to maintain legacy builds so I'm looking to revert this patch. 

Sorry to read that it breaks on some systems... :-(

> So if I revert this patch, what will break in your world? 

What breaks is when libtirpc is available only as a static library.

libtirpc uses pthreads, but NFS-utils does not link to -lpthread, and so
there are undefined symbols at link time. Using pkg-config ensures that
we get the proper LDFLAGS for libtirpc.

What are those "legacy OSs"? Can I help in finding an adequate solution?
(note: any Linux distro I can install without problem, I could try to
give a spin to a *BSD one if really needed, but other "OSes" not so
much...)

If at all possible, I would like to keep pkg-config as the default, and
use the old (or another) method only as a fallback, because pkg-config
is so much nicer to deal with than trying to cope for all cases
ourselves. Would that be an acceptable solution for you?

Regards,
Yann E. MORIN.

PS. I'm only available in the evening UTC+1, so please bear with the
delay in my replies...
YEM.

-- 
.-----------------.--------------------.------------------.--------------------.
|  Yann E. MORIN  | Real-Time Embedded | /"\ ASCII RIBBON | Erics' conspiracy: |
| +33 662 376 056 | Software  Designer | \ / CAMPAIGN     |  ___               |
| +33 223 225 172 `------------.-------:  X  AGAINST      |  \e/  There is no  |
| http://ymorin.is-a-geek.org/ | _/*\_ | / \ HTML MAIL    |   v   conspiracy.  |
'------------------------------^-------^------------------^--------------------'
