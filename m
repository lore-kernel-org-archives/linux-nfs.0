Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:60165 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755589Ab3KXJJY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Nov 2013 04:09:24 -0500
Received: from hch by bombadil.infradead.org with local (Exim 4.80.1 #2 (Red Hat Linux))
	id 1VkVgy-0007ja-4y
	for linux-nfs@vger.kernel.org; Sun, 24 Nov 2013 09:09:24 +0000
Date: Sun, 24 Nov 2013 01:09:24 -0800
From: Christoph Hellwig <hch@infradead.org>
To: linux-nfs@vger.kernel.org
Subject: Re: librpcsecgss: FTBFS on GNU/kFreeBSD
Message-ID: <20131124090924.GA29659@infradead.org>
References: <20090703133142.14887.33854.reportbug@localhost.localdomain>
 <20131124051904.GA16651@master.debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131124051904.GA16651@master.debian.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Nov 24, 2013 at 04:19:04PM +1100, An?bal Monsalve Salazar wrote:
>  	(void)gettimeofday(&now, (struct timezone *)0);
> -#ifdef __linux__
> +#if defined (__linux__) || defined(__GLIBC__)
>  	call_msg.rm_xid = getpid() ^ now.tv_sec ^ now.tv_usec;
>  #else
>  	call_msg.rm_xid = arc4random();

Using getpid() instead of a random generator seems fairly dangerous.
Why don't we use a real RNG/PRNG here?

