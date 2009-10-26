From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: regression, bisected: getcwd() ENOENT on NFS4...
Date: Mon, 26 Oct 2009 09:19:50 -0400
Message-ID: <1256563190.3742.4.camel@heimdal.trondhjem.org>
References: <6278d2220910251631j40caec00lf2dee6159947d983@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: Daniel J Blueman <daniel.blueman@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34529 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754577AbZJZNUB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Oct 2009 09:20:01 -0400
In-Reply-To: <6278d2220910251631j40caec00lf2dee6159947d983-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2009-10-25 at 23:31 +0000, Daniel J Blueman wrote:
> Since 2.6.30-rc, I've been experiencing various issues relating to
> getcwd() returning ENOENT on NFS4 clients. I used an over-complicated
> but reliable reproducer [1] (on Karmic RC against a 2.6.32-rc5 NFS4
> server) to bisect [2].
> 
> The impact of this regression is moderate (side-effects range from
> benign to failure), so we should get a fix into 2.6.32 if at all
> possible and strongly consider a 2.6.31 stable update.
> 
> Thanks,
>   Daniel
> 
> --- [1]
> 
> $ apt-get source apt
> $ cd apt-*
> $ ./configure && make
> [snip]
> sh: getcwd() failed: No such file or directory
> 
> --- [2]
> 
> a65318bf3afc93ce49227e849d213799b072c5fd is first bad commit
> commit a65318bf3afc93ce49227e849d213799b072c5fd
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Wed Mar 11 14:10:28 2009 -0400
> 
>     NFSv4: Simplify some cache consistency post-op GETATTRs

I'm having a lot of trouble seeing how this patch could result in
ENOENT. All it should be doing is reducing the frequency with which we
update some of the inode metadata.

Have you ever been able to capture one of these errors using strace?

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
