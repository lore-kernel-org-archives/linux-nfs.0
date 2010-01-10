From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [2.6.33-rc3] NFS4 and dentry issues...
Date: Sun, 10 Jan 2010 15:08:13 -0500
Message-ID: <1263154093.2987.34.camel@localhost>
References: <6278d2221001090632m7fdd77qc73c203840a2a78e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: Daniel J Blueman <daniel.blueman@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:55178 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751580Ab0AJUIS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 10 Jan 2010 15:08:18 -0500
In-Reply-To: <6278d2221001090632m7fdd77qc73c203840a2a78e-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2010-01-09 at 14:32 +0000, Daniel J Blueman wrote: 
> When synchronising files (unison, like a two way rsync) over an NFS4
> mount (server with 2.6.32.2) on a client running 2.6.33-rc3 (also
> -rc2), I ran into dcache issues [1].
> 
> I've been unable to consistently reproduce this for bisecting, and
> filesystem benchmarks via NFS on tmpfs over localhost fails to
> reproduce it either.
> 
> What additional information may be useful?

There is a known issue in 2.6.33-rc3 with rename causing corruption of
the dentry lookup hash lists.

A fix for that problem has already been merged into mainline as
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git&a=commitdiff&h=56335936de1a41c8978fde62b2158af77ddc7258

Could you see if you can reproduce your problem with that fix applied?

Cheers
  Trond

