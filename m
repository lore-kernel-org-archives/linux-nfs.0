Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from minas.ics.muni.cz ([147.251.4.40]:57265 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758516Ab0EYWna (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 May 2010 18:43:30 -0400
Date: Wed, 26 May 2010 00:43:20 +0200
From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
To: Leszek Urbanski <tgr.kb@moo.pl>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Deadlock/crash in 2.6.32.12 when copying large files
Message-ID: <20100525224320.GR9731@ics.muni.cz>
References: <20100525222657.GA14891@moo.pl>
Content-Type: text/plain; charset=iso-8859-2
In-Reply-To: <20100525222657.GA14891@moo.pl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

On Wed, May 26, 2010 at 12:26:57AM +0200, Leszek Urbanski wrote:
> I've hit https://bugzilla.kernel.org/show_bug.cgi?id=15578 again with
> 2.6.32.12 on amd64.
> 
> I can reproduce it every time when copying large (>2G) files over NFS.
> The call trace is at https://bugzilla.kernel.org/attachment.cgi?id=26519
> 
> Needless to say it results in a system crash (kswapd deadlock, network stack
> failure because of memory allocation failure for SKBs, etc.).
> 
> Trond Myklebust closed this bug a while ago, but apparently it's not completely
> fixed and needs to be re-opened.

You could try this workaround, it works for me. Cherry picked from 2.6.34
vanila.

commit 3d7b08945e54a3a5358d5890240619a013cb7388
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Apr 22 15:35:55 2010 -0400

    SUNRPC: Fix a bug in rpcauth_prune_expired

    Don't want to evict a credential if cred->cr_expire == jiffies, since that
    means that it was just placed on the cred_unused list. We therefore need to
    use time_in_range() rather than time_in_range_open().

    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index f394fc1..95afe79 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -237,7 +237,7 @@ rpcauth_prune_expired(struct list_head *free, int
nr_to_scan)
        list_for_each_entry_safe(cred, next, &cred_unused, cr_lru) {

                /* Enforce a 60 second garbage collection moratorium */
-               if (time_in_range_open(cred->cr_expire, expired, jiffies) &&
+               if (time_in_range(cred->cr_expire, expired, jiffies) &&
                    test_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags) != 0)
                        continue;


-- 
Luká¹ Hejtmánek
