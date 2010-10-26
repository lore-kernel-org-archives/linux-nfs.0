Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33490 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753080Ab0JZVCz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Oct 2010 17:02:55 -0400
In-Reply-To: <201010262255.40481.arnd@arndb.de>
References: <20101026164549.GD19445@fieldses.org> <201010262218.36940.arnd@arndb.de>
 <4CC73BA6.1090407@netapp.com> <201010262255.40481.arnd@arndb.de>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 26 Oct 2010 14:02:05 -0700
Message-ID: <AANLkTimPBqafDPxYpZjuym8+-yk4vKYTU15Js-Ux_e6Z@mail.gmail.com>
Subject: Re: nfsd changes for 2.6.37
To: Arnd Bergmann <arnd@arndb.de>
Cc: Bryan Schumaker <bjschuma@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Oct 26, 2010 at 1:55 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>
> Finally, we can build fs/locks.c, nfs and nfsd with CONFIG_BKL
> disabled.
>
> *not tested*

Ok, please make this so, so that we finally can effectively get rid of
the BKL in this release (I don't really care about the random old
drivers that may be "depends on BKL").

But that obviously requires at least some minimal testing by somebody
who is using NFS heavily, including locking. I assume that the
connectathon tests include file locking? And I presume that the nfs
developers run those at least semi-regularly and could do at least
that kind of minimal testing?

                        Linus
