Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.linuxfoundation.org ([140.211.169.12]:53085 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752074Ab3LXRer (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Dec 2013 12:34:47 -0500
Date: Tue, 24 Dec 2013 09:35:09 -0800
From: Greg KH <gregkh@linuxfoundation.org>
To: Alexander Aring <alex.aring@gmail.com>
Cc: hannes@stressinduktion.org, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, stable@vger.kernel.org, werner@almesberger.net
Subject: Re: [PATCH v2] nfs: fix dead code of ipv6_addr_scope
Message-ID: <20131224173509.GA24392@kroah.com>
References: <1387753276-27009-1-git-send-email-alex.aring@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
> ---
> - change check on linklocal address from
>   (ipv6_addr_src_scope(&a6->sin6_addr) == IPV6_ADDR_SCOPE_LINKLOCAL) to
>   (ipv6_addr_scope(&a6->sin6_addr) & IPV6_ADDR_LINKLOCAL) which is a
>   little bit faster.
> - change commit msg.

<formletter>

This is not the correct way to submit patches for inclusion in the
stable kernel tree.  Please read Documentation/stable_kernel_rules.txt
for how to do this properly.

</formletter>
