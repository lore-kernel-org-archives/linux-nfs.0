Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51427 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753810Ab0H0OQI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Aug 2010 10:16:08 -0400
Received: by wwb28 with SMTP id 28so3447009wwb.1
        for <linux-nfs@vger.kernel.org>; Fri, 27 Aug 2010 07:16:07 -0700 (PDT)
In-Reply-To: <AANLkTikWR_YSnx=4=KAodATpX+xO9+hj-cf7_e158f4d@mail.gmail.com>
References: <AANLkTikWR_YSnx=4=KAodATpX+xO9+hj-cf7_e158f4d@mail.gmail.com>
Date: Fri, 27 Aug 2010 09:16:06 -0500
Message-ID: <AANLkTi=gj901aF_84+40j9MhvAwNJSNB8qRnpY8o0gBZ@mail.gmail.com>
Subject: Re: fsync/wb deadlocks in 2.6.32
From: davidr@ressman.org
To: linux-nfs@vger.kernel.org
Cc: cl@linux-foundation.com
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi all,

I'm guessing this is uncommon and nobody here has seen it. One of my
friends looked through the list archives and discovered commit
0702099bd86c33c2dcdbd3963433a61f3f503901, which looked relevant. I
backported it to 2.6.32.18 (if you can call anything involving a one
line patch "backporting" :) ), and the problem has not yet returned.

That said, I'm not sure if this actually corrects the problem or
pushes it deeper into a place where it's not going to hang the host,
but is still unsafe because the original commit was to 2.6.35+. Any
comments?

Thanks!

David



--- linux-2.6.32.18.orig/fs/nfs/file.c  2010-08-10 12:45:57.000000000 -0500
+++ linux-2.6.32.18/fs/nfs/file.c       2010-08-20 10:15:37.608665292 -0500
@@ -220,7 +220,7 @@ static int nfs_do_fsync(struct nfs_open_
       have_error |= test_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
       if (have_error)
               ret = xchg(&ctx->error, 0);
-       if (!ret)
+       if (!ret && status < 0)
               ret = status;
       return ret;
 }
