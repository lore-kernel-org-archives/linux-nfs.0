Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:51189 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751393Ab0HMUx7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Aug 2010 16:53:59 -0400
In-Reply-To: <1281726579.2810.10.camel@localhost.localdomain>
References: <AANLkTimnyXKahtjaFeSsgcq=xMy-pP3na1jidQhZ-dt2@mail.gmail.com>
	<AANLkTin2P5kcrC1SU-ANffSHyW8Ar4x4+qFuqVMFhYJE@mail.gmail.com>
	<AANLkTin-dksybH0ANypheovXXubwd+SRCpurdVRU7-Z=@mail.gmail.com>
	<1281726579.2810.10.camel@localhost.localdomain>
Date: Fri, 13 Aug 2010 13:53:57 -0700
Message-ID: <AANLkTinJ04d2Bjuv2E4OOG=35TSHArEP6cHqGUQVUoy2@mail.gmail.com>
Subject: Re: Proposal: Use hi-res clock for file timestamps
From: "Patrick J. LoPresti" <lopresti@gmail.com>
To: john stultz <johnstul@us.ibm.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 13, 2010 at 12:09 PM, john stultz <johnstul@us.ibm.com> wrote:
>
> So other then "show some numbers", my only thought that might make the
> patch more attractive is that rather than a global change, or a static
> CONFIG_ option, would it maybe make more sense as a mount option?

I really like this idea.

Consider the following "revision 2" of my proposal:

1) Add a function pointer "current_fs_time" to struct super_block.

2) Replace all calls of the form:

    current_fs_time(sb);

with

  sb->current_fs_time(sb);

 3) Arrange for the default value to point to the current implementation.

These first three could be one patch.  They change no functionality;
they just enable the next step.

Finally:

  4) Add a mount option to cause sb->current_fs_time(sb) to use the
hi-res implementation.

Comments?

 - Pat
