Return-Path: linux-nfs-owner@vger.kernel.org
Received: from shards.monkeyblade.net ([149.20.54.216]:45382 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027AbaGOXF4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2014 19:05:56 -0400
Date: Tue, 15 Jul 2014 16:05:55 -0700 (PDT)
Message-Id: <20140715.160555.407533257702039786.davem@davemloft.net>
To: jlayton@primarydata.com
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] net: clean up some sparse endianness warnings in ipv6.h
From: David Miller <davem@davemloft.net>
In-Reply-To: <1405340746-10678-1-git-send-email-jlayton@primarydata.com>
References: <1405340746-10678-1-git-send-email-jlayton@primarydata.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@primarydata.com>
Date: Mon, 14 Jul 2014 08:25:46 -0400

>  #endif
> -		(a->s6_addr32[2] ^ htonl(0x0000ffff))) == 0UL;
> +		((a->s6_addr32[2] ^ htonl(0x0000ffff)) == cpu_to_be32(0)));

While you are spinning a new version, change this htonl() to be
cpu_to_be32().  All the rest of this entire expression uses the
cpu_to_*() interfaces, so for consistency this should too.

Thanks.
