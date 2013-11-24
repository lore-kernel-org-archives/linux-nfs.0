Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:61591 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752150Ab3KXNIg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 24 Nov 2013 08:08:36 -0500
Date: Sun, 24 Nov 2013 08:07:53 -0500
From: Jim Rees <rees@umich.edu>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: librpcsecgss: FTBFS on GNU/kFreeBSD
Message-ID: <20131124130753.GA15178@umich.edu>
References: <20090703133142.14887.33854.reportbug@localhost.localdomain>
 <20131124051904.GA16651@master.debian.org>
 <20131124090924.GA29659@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131124090924.GA29659@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Christoph Hellwig wrote:

  On Sun, Nov 24, 2013 at 04:19:04PM +1100, An?bal Monsalve Salazar wrote:
  >  	(void)gettimeofday(&now, (struct timezone *)0);
  > -#ifdef __linux__
  > +#if defined (__linux__) || defined(__GLIBC__)
  >  	call_msg.rm_xid = getpid() ^ now.tv_sec ^ now.tv_usec;
  >  #else
  >  	call_msg.rm_xid = arc4random();
  
  Using getpid() instead of a random generator seems fairly dangerous.
  Why don't we use a real RNG/PRNG here?

Maybe we're just trying to avoid collisions, and don't care if someone can
guess xids? But either way, agreed. Also, shouldn't the existence of
arc4random() be determined by configure? Isn't that why we use configure, so
we don't need fragile ifdefs in the code?

Is anyone maintaining this library?
