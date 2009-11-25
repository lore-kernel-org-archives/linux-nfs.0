From: "Stephen R. van den Berg" <srb-PCMv+cxZuL0@public.gmane.org>
Subject: Re: Fw: Deadlock regression in v2.6.31.6
Date: Wed, 25 Nov 2009 10:00:23 +0100
Message-ID: <64b4daae0911250100x1a1c9515gd407061fb23c1a88@mail.gmail.com>
References: <20091124233555.da6439c4.akpm@linux-foundation.org>
	 <64b4daae0911250056g3364d24l98850a272dcfe483@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f213.google.com ([209.85.220.213]:53099 "EHLO
	mail-fx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752398AbZKYJAS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Nov 2009 04:00:18 -0500
Received: by fxm5 with SMTP id 5so6708032fxm.28
        for <linux-nfs@vger.kernel.org>; Wed, 25 Nov 2009 01:00:24 -0800 (PST)
In-Reply-To: <64b4daae0911250056g3364d24l98850a272dcfe483-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 25, 2009 at 09:56, Stephen R. van den Berg <srb-PCMv+cxZuL0@public.gmane.org> wrote:
> (it happens everytime, so it is very reproducible):

If anyone wants more debugging info or wants me to try a fix, just let
me know, the problem can be reproduced at will and I have the kernel
source ready for modifications.  The last trace was relative to
2.6.31.6.  It did not trigger any DO_BUG() checks (I enabled
RPC_DEBUG).
-- 
Sincerely,
                Stephen R. van den Berg.
