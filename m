From: "Adam Olsen" <arolsen@gmail.com>
Subject: Re: NFS+GD issues on kernel 2.6.24, but not 2.6.22
Date: Thu, 15 May 2008 10:20:23 -0600
Message-ID: <2473b43f0805150920p6d12000cq8366fa3f3fe77c7f@mail.gmail.com>
References: <2473b43f0805150706g5be9918cu3c77d9135cded912@mail.gmail.com>
	 <20080515084610.4e5161bc@tupile.poochiereds.net>
	 <2473b43f0805150855o59a14e34h82b20f847c53f392@mail.gmail.com>
	 <482C600F.3040909@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "James Pearson" <james-p-5Ol4pYTxKWu0ML75eksnrtBPR1lH4CV8@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.176]:9394 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756608AbYEOQU1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 May 2008 12:20:27 -0400
Received: by el-out-1112.google.com with SMTP id s27so146704ele.1
        for <linux-nfs@vger.kernel.org>; Thu, 15 May 2008 09:20:23 -0700 (PDT)
In-Reply-To: <482C600F.3040909-5Ol4pYTxKWu0ML75eksnrtBPR1lH4CV8@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 15, 2008 at 10:08 AM, James Pearson
<james-p-5Ol4pYTxKWu0ML75eksnrtBPR1lH4CV8@public.gmane.org> wrote:
>  Is this a 32 bit app running on a 64 OS by any chance?

Nope, here is `uname -a` on the failing system:

Linux slavedb 2.6.24-16-server #1 SMP Thu Apr 10 13:58:00 UTC 2008
i686 GNU/Linux

-- 
Adam Olsen
SendOutCards.com
http://www.vimtips.org
http://last.fm/user/synic
