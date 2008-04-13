From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: nfs: infinite loop in fcntl(F_SETLKW)
Date: Sun, 13 Apr 2008 10:28:08 +0200
Message-ID: <E1JkxZI-0003Bc-9C@pomaz-ex.szeredi.hu>
References: <E1JjcgO-0004q2-VJ@pomaz-ex.szeredi.hu> <E1Jk2oI-0007UX-MS@pomaz-ex.szeredi.hu> <1207861339.8180.14.camel@heimdal.trondhjem.org> <1207861661.8180.18.camel@heimdal.trondhjem.org> <1207862436.8180.30.camel@heimdal.trondhjem.org> <20080410215410.GF22324@fieldses.org>
Cc: trond.myklebust@fys.uio.no, miklos@szeredi.hu,
	eshel@almaden.ibm.com, neilb@suse.de, akpm@linux-foundation.org,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fxip-0047f.externet.hu ([88.209.222.127]:41429 "EHLO
	pomaz-ex.szeredi.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756612AbYDMI22 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Apr 2008 04:28:28 -0400
In-reply-to: <20080410215410.GF22324@fieldses.org> (bfields@fieldses.org)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Apologies, that was indeed a behavioral change introduced in a commit
> that claimed just to be shuffling code around.

Another complaint about this series: using EINPROGRESS to signal
asynchronous locking looks really fishy.  How does the filesystem
know, that the caller wants to do async locking?  How do we make sure,
that the filesystem (like fuse or 9p, which "blindly" return the error
from the server) doesn't return EINPROGRESS even when it's _not_ doing
an asynchronous lock?

I think it would have been much cleaner to have a completely separate
interface for async locking, instead of trying to cram that into
f_op->lock().

Would that be possible to fix now?  Or at least make EINPROGRESS a
kernel-internal error value (>512), to make it that it has a special
meaning for the _kernel only_?

Thanks,
Miklos
