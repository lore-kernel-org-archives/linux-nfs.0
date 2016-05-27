Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from science.sciencehorizons.net ([71.41.210.147]:13714 "HELO
	ns.sciencehorizons.net" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with SMTP id S1755619AbcE0B4H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 May 2016 21:56:07 -0400
Date: 26 May 2016 21:56:05 -0400
Message-ID: <20160527015605.7083.qmail@ns.sciencehorizons.net>
From: "George Spelvin" <linux@sciencehorizons.net>
To: bfields@fieldses.org, linux@horizon.com
Subject: Re: [PATCH RESEND 03/10] <linux/sunrpc/svcauth.h>: Define hash_str() in terms of hash_string()
Cc: jlayton@poochiereds.net, linux-nfs@vger.kernel.org,
        linux@sciencehorizons.net
In-Reply-To: <20160527003254.GA25272@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> Hm.  Are there some missing includes, maybe?:
> 
> In file included from include/linux/hashtable.h:12:0,
>                  from fs/btrfs/props.c:19:
> include/linux/hash.h: In function `hash_64_genericâ':
>  include/linux/hash.h:76:3: error: implicit declaration of function `BUILD_BUG_ON' [-Werror=implicit-function-declaration]
>    BUILD_BUG_ON(bits > 32 || bits == 0);
>    ^

Ooh, excellent catch!  That's a paper-bag mistake.  Thank you for
saving me from Linus's wrath.

(My lame explanation: "make allyesconfig" is annoyingly slow, and that
error was an afterthought I added after the "real work" parts.  Do you
think that check should even be in there?)

#include <linux/bug.h> and try again, or re-pull...

Oh, bugger, that revealed something else that scrolled past
in previous builds.  I'll push when I've fixed this one, too..

drivers/base/power/trace.c defines its own static hash_string()
function *and* includes <limux/dcache.h>, leading to conflicting
declarations.  Which one to rename...?


Anyway, much obliged!
