Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43140 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751569AbcAYGC3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Jan 2016 01:02:29 -0500
Date: Sun, 24 Jan 2016 22:02:27 -0800 (PST)
Message-Id: <20160124.220227.1203168765001083726.davem@davemloft.net>
To: herbert@gondor.apana.org.au
Cc: linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, devel@driverdev.osuosl.org,
        dm-devel@redhat.com, linux-wireless@vger.kernel.org,
        linux-cifs@vger.kernel.org, ecryptfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        linux-nfs@vger.kernel.org, keyrings@vger.kernel.org,
        linux-bluetooth@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-wpan@vger.kernel.org, linux-afs@lists.infradead.org,
        drbd-dev@lists.linbit.com, open-iscsi@googlegroups.com
Subject: Re: [PATCH 19/26] ipsec: Use skcipher and ahash when probing
 algorithms
From: David Miller <davem@davemloft.net>
In-Reply-To: <E1aNKZT-0008Ew-7q@gondolin.me.apana.org.au>
References: <20160124131021.GA31153@gondor.apana.org.au>
	<E1aNKZT-0008Ew-7q@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 24 Jan 2016 21:19:11 +0800

> This patch removes the last reference to hash and ablkcipher from
> IPsec and replaces them with ahash and skcipher respectively.  For
> skcipher there is currently no difference at all, while for ahash
> the current code is actually buggy and would prevent asynchronous
> algorithms from being discovered.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: David S. Miller <davem@davemloft.net>
