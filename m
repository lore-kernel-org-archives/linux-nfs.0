Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:37554 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758641Ab2C2CGw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Mar 2012 22:06:52 -0400
MIME-Version: 1.0
In-Reply-To: <1332986348.19172.43.camel@lade.trondhjem.org>
References: <1332986348.19172.43.camel@lade.trondhjem.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 28 Mar 2012 19:06:31 -0700
Message-ID: <CA+55aFwVzhgsw005P3+BkLw_=noJwkQB3G=Q4GqhfLL1WyPHfg@mail.gmail.com>
Subject: Re: [GIT PULL] Please pull NFS client bugfixes for Linux 3.4...
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 28, 2012 at 6:59 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
>
> Please pull from the signed tag "nfs-for-3.4-2" in the repository at
>
>   git pull git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tag nfs-for-3.4-2

Btw, please change your pull request to say "tag/nfs-for-3.4-2"
instead of "tag nfs-for-3.4-2".

Both work, but there's a subtle difference: the "pull tag xyz" is
basically asking me to not just pull, but also add the tag to my set
of tags, which I'm not interested in. In contrast "pull tag/xyz" asks
me to just pull the tag contents.

Anyway, pulled.

                    Linus
