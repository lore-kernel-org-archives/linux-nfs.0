Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33728 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751480AbcE0MQf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 May 2016 08:16:35 -0400
Date: Fri, 27 May 2016 08:16:32 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: George Spelvin <linux@sciencehorizons.net>
Cc: linux@horizon.com, jlayton@poochiereds.net, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RESEND 03/10] <linux/sunrpc/svcauth.h>: Define hash_str()
 in terms of hash_string()
Message-ID: <20160527121632.GC25272@fieldses.org>
References: <20160527015605.7083.qmail@ns.sciencehorizons.net>
 <20160527032946.12751.qmail@ns.sciencehorizons.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160527032946.12751.qmail@ns.sciencehorizons.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 26, 2016 at 11:29:46PM -0400, George Spelvin wrote:
> Okay, it's now okay to re-pull.  I renamed mine to hashlen_string(),
> since that's what it returns (the hash and the length), which both
> solves the problem,and is frankly a better name.
> 
> Thank you for prodding me to wade through the GCC 6 warning
> spam.  Thre were some problems hiding there.
> 
> I discovered that adding #include <linux/bug.h> breaks the tools.perf
> build.  It makes local copies of some kernel headers under control of
> a MANIFEST file, and I can't be arsed to figure it out.
> 
> So I deleted the BUILD_BUG_ON entirely, and it's now (finally!) finished
> an allyesconfig build without any warnings that look new.

I also needed the following.

That still gets me some compiler warnings in gfs2, but looks like code
your patches don't touch, so that's probably a preexisting gfs2 problem.

But... the resulting kernel isn't booting succesfully for me.  Not sure
what's up there, I'll investigate some more.

--b.

commit 5168cb717b37ef0b183dee9b411a85831b558b9b
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Fri May 27 07:10:21 2016 -0400

    XXX

diff --git a/include/linux/hash.h b/include/linux/hash.h
index 1afde47..21b8ebc 100644
--- a/include/linux/hash.h
+++ b/include/linux/hash.h
@@ -15,6 +15,7 @@
  */
 
 #include <asm/types.h>
+#include <linux/bug.h>
 #include <linux/compiler.h>
 
 /* 2^31 + 2^29 - 2^25 + 2^22 - 2^19 - 2^16 + 1 */
