Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:37037 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932640Ab2C2CUq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Mar 2012 22:20:46 -0400
MIME-Version: 1.0
In-Reply-To: <1332986928.19172.45.camel@lade.trondhjem.org>
References: <1332986348.19172.43.camel@lade.trondhjem.org> <CA+55aFwVzhgsw005P3+BkLw_=noJwkQB3G=Q4GqhfLL1WyPHfg@mail.gmail.com>
 <1332986928.19172.45.camel@lade.trondhjem.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 28 Mar 2012 19:20:24 -0700
Message-ID: <CA+55aFyQ0r5mN9=3DUVENCtdj8VMLRjiXTc5Xd4o+F=s9B8xMg@mail.gmail.com>
Subject: Re: [GIT PULL] Please pull NFS client bugfixes for Linux 3.4...
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 28, 2012 at 7:08 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
>
> Sure thing... I wasn't aware of that semantic difference, but I'm quite
> happy to add it to my script...

Thanks. And I noticed that it's supposed to be "tags/xyz" with a "s".

Of course, you might as well just say "xyz" without mentioning the
tag[s] part at all, unless you have a branch with the same name and
want to explicitly disambiguate.

                   Linus
