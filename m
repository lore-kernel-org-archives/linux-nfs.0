Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.24]:53677 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754575AbbEMTAE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 May 2015 15:00:04 -0400
From: Arnd Bergmann <arnd@arndb.de>
To: linux-arm-kernel@lists.infradead.org
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: work around a gcc-5.1 warning
Date: Wed, 13 May 2015 20:59:36 +0200
Message-ID: <9574260.omRer6Oeha@wuerfel>
In-Reply-To: <20150513181143.GD2827@fieldses.org>
References: <2121336.tAfQfAWQ2u@wuerfel> <20150513181143.GD2827@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wednesday 13 May 2015 14:11:43 J. Bruce Fields wrote:
> 
> OK, I guess.  How about simplifying slightly and doing it this way?--b
> 
> commit 3ae81ac291ec
> Author: Arnd Bergmann <arnd@arndb.de>
> Date:   Tue May 12 23:31:29 2015 +0200
> 
>     nfsd: work around a gcc-5.1 warning
>     
>     gcc-5.0 warns about a potential uninitialized variable use in nfsd:
>     
>     fs/nfsd/nfs4state.c: In function 'nfsd4_process_open2':
>     fs/nfsd/nfs4state.c:3781:3: warning: 'old_deny_bmap' may be used uninitialized in this function [-Wmaybe-uninitialized]
>        reset_union_bmap_deny(old_deny_bmap, stp);
>        ^
>     fs/nfsd/nfs4state.c:3760:16: note: 'old_deny_bmap' was declared here
>       unsigned char old_deny_bmap;
>                     ^
>     
>     This is a false positive, the code path that is warned about cannot
>     actually be reached.
>     
>     This adds an initialization for the variable to make the warning go
>     away.
>     
>     Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> 

Works for me, thanks!

	Arnd
