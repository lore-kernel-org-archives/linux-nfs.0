From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Help please
Date: Tue, 15 Jun 2010 09:15:40 -0400
Message-ID: <1276607740.4922.2.camel@heimdal.trondhjem.org>
References: <AANLkTinQkRf_ZkN5qw1rsK5MY7pB1NjFd5CiLaPa-ZOU@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: Alexander Samad <alex-SGFoFqf0RKf0CCvOHzKKcA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:36062 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752525Ab0FONPp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jun 2010 09:15:45 -0400
In-Reply-To: <AANLkTinQkRf_ZkN5qw1rsK5MY7pB1NjFd5CiLaPa-ZOU-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2010-06-15 at 12:01 +1000, Alexander Samad wrote:
> Hi
> 
> sorry if this is a duplicate, I have been having some problem
> subscribing to the ml.
> 
> 
> 
> I am having some problem with nfs-kernel on a debian amd64 (sid)  i am
> using version (1:1.2.2-1).
> 
> when I do a tcpdump on my nfs machine and do a mount -o vers=4,udp
> nfs:/exports/video /exports/video/ it fails

UDP transport is not supported by the NFSv4 protocol. Some servers may
allow it, but most will not.

Cheers
  Trond

