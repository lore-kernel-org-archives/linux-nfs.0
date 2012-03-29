Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:60323 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750971Ab2C2EVO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Mar 2012 00:21:14 -0400
MIME-Version: 1.0
In-Reply-To: <1332994124.30608.5.camel@lade.trondhjem.org>
References: <1332986348.19172.43.camel@lade.trondhjem.org> <CA+55aFwVzhgsw005P3+BkLw_=noJwkQB3G=Q4GqhfLL1WyPHfg@mail.gmail.com>
 <1332986928.19172.45.camel@lade.trondhjem.org> <CA+55aFyQ0r5mN9=3DUVENCtdj8VMLRjiXTc5Xd4o+F=s9B8xMg@mail.gmail.com>
 <1332988097.19172.51.camel@lade.trondhjem.org> <4F73D44C.5090604@panasas.com>
 <CA+55aFyHmQBXw3ik3qv81_3Zp+4r-VUt_TNBs-M19b6Zt7PDeQ@mail.gmail.com> <1332994124.30608.5.camel@lade.trondhjem.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 28 Mar 2012 21:20:52 -0700
Message-ID: <CA+55aFwxkWpH1WyBnE1Lg9eRAfPsfcyoZev7-O9TGrPKTB1pOg@mail.gmail.com>
Subject: Re: [GIT PULL] Please pull NFS client bugfixes for Linux 3.4...
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Boaz Harrosh <bharrosh@panasas.com>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 28, 2012 at 9:08 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
>
> Maybe I'm running an older version of git (Fedora 16 latest update), but
> when I do

Yeah, you need git 1.7.9 to get the tag content support.

With older git versions, spell out "tags/xyz" instead of just "xyz",
and it will all work, but it still won't actually show the tag
content.

                        Linus
