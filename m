From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: slowness with nfs kernel 2.6.25 and Ontap 7.2.x
Date: Thu, 18 Sep 2008 07:45:40 -0700
Message-ID: <1221749140.7332.4.camel@localhost>
References: <3b6787960809171747y37d52114w31da245767c87fe2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Di Pe <dipeit@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:45085 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753990AbYIROpp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Sep 2008 10:45:45 -0400
In-Reply-To: <3b6787960809171747y37d52114w31da245767c87fe2-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-09-17 at 17:47 -0700, Di Pe wrote:
> Trond et al,
> 
> https://bugzilla.novell.com/show_bug.cgi?id=415607#c9
> 
> you know if there will there be an update to Kernel 2.6.25 or do we
> need to install OnTap 7.3 to fix or reduce this problem?
> 
> Thanks much
> dp

AFAICR Neil has sent me a patch for that BUG_ON, but due to vacation +
business travel, I haven't had time to review it yet. I'm planning on
prepping the NFS updates for the 2.6.28 merge window next week, so I'll
get back to it then.

Cheers
  Trond

