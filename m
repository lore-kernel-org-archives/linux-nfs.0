Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f178.google.com ([209.85.212.178]:53286 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159AbbAFTFc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2015 14:05:32 -0500
Received: by mail-wi0-f178.google.com with SMTP id em10so109979wid.5
        for <linux-nfs@vger.kernel.org>; Tue, 06 Jan 2015 11:05:30 -0800 (PST)
Date: Tue, 6 Jan 2015 20:05:26 +0100
From: "Yann E. MORIN" <yann.morin.1998@free.fr>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH nfs-utils] configure: use pkg-config to find libtirpc
Message-ID: <20150106190526.GA17878@free.fr>
References: <1416755357-12228-1-git-send-email-yann.morin.1998@free.fr>
 <54AA8E4A.6060705@RedHat.com>
 <20150105182322.GB5077@free.fr>
 <54AC2D52.8030203@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <54AC2D52.8030203@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve, All,

On 2015-01-06 13:45 -0500, Steve Dickson spake thusly:
> On 01/05/2015 01:23 PM, Yann E. MORIN wrote:
> > 
> > What are those "legacy OSs"? Can I help in finding an adequate solution?
> > (note: any Linux distro I can install without problem, I could try to
> > give a spin to a *BSD one if really needed, but other "OSes" not so
> > much...)
> The problem is here... 
>     http://www.spinics.net/lists/linux-nfs/msg48570.html

Ah, OK! That's because the check I implemented requires libtirpc 0.2.4.
I choose to require that version because it was the one I tested
against.

But if older versions are allowed, or even any other, it is simple to
change the required version string:

    -PKG_CHECK_MODULES([TIRPC], [libtirpc >= 0.2.4],
    +PKG_CHECK_MODULES([TIRPC], [libtirpc >= 0.2.1],

Or for accepting any version:

    -PKG_CHECK_MODULES([TIRPC], [libtirpc >= 0.2.4],
    +PKG_CHECK_MODULES([TIRPC], [libtirpc],

> > If at all possible, I would like to keep pkg-config as the default, and
> > use the old (or another) method only as a fallback, because pkg-config
> > is so much nicer to deal with than trying to cope for all cases
> > ourselves. Would that be an acceptable solution for you?
> Yes.. I would be more than willing to work out something that works in
> both cases.... 

Yes, I checked the old code, and it does not require any version for
libtirpc, just that it exists.

The old code also checks for authgss_free_private_data, that was
introduced in libtirpc between 0.2.2 and 0.2.3, and the change I
proposed did not handle that. It completely slipped by.

So, to propose a fix, I need to know what the oldest libtirpc version
should be supported. From the mesage pointed to above, it seems we
should support at least back to libtirpc 0.2.1. Do we have to support
yet older versions, or even any version?

Second, I'll also work on providing a way to restore detection and use
of authgss_free_private_data.

Note: I'll hopefuly have time to work on this tonight, and send a fix
before midnight UTC.

Sorry for the mishap... :-(

Regards,
Yann E. MORIN.

-- 
.-----------------.--------------------.------------------.--------------------.
|  Yann E. MORIN  | Real-Time Embedded | /"\ ASCII RIBBON | Erics' conspiracy: |
| +33 662 376 056 | Software  Designer | \ / CAMPAIGN     |  ___               |
| +33 223 225 172 `------------.-------:  X  AGAINST      |  \e/  There is no  |
| http://ymorin.is-a-geek.org/ | _/*\_ | / \ HTML MAIL    |   v   conspiracy.  |
'------------------------------^-------^------------------^--------------------'
