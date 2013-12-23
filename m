Return-Path: linux-nfs-owner@vger.kernel.org
Received: from order.stressinduktion.org ([87.106.68.36]:46795 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756682Ab3LWDSr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Dec 2013 22:18:47 -0500
Date: Mon, 23 Dec 2013 04:18:45 +0100
From: Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Alexander Aring <alex.aring@gmail.com>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org, stable@vger.kernel.org,
        werner@almesberger.net
Subject: Re: [PATCH v2] nfs: fix dead code of ipv6_addr_scope
Message-ID: <20131223031845.GM14073@order.stressinduktion.org>
References: <1387753276-27009-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1387753276-27009-1-git-send-email-alex.aring@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 23, 2013 at 12:01:16AM +0100, Alexander Aring wrote:
> This patch corrects the check on a linklocal address.
> 
> Currently this can't be work, because ipv6_addr_scope returns a int with
> a mask of IPV6_ADDR_SCOPE_MASK (0x00f0U) and IPV6_ADDR_SCOPE_LINKLOCAL
> is 0x02. So the condition is always false.
> 
> Signed-off-by: Alexander Aring <alex.aring@gmail.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

