Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43120 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818AbcAYGBv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Jan 2016 01:01:51 -0500
Date: Sun, 24 Jan 2016 22:01:47 -0800 (PST)
Message-Id: <20160124.220147.1840338377819463012.davem@davemloft.net>
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
Subject: Re: [PATCH 26/26] tcp: Use ahash
From: David Miller <davem@davemloft.net>
In-Reply-To: <E1aNKad-0008H5-Ax@gondolin.me.apana.org.au>
References: <20160124131021.GA31153@gondor.apana.org.au>
	<E1aNKad-0008H5-Ax@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 24 Jan 2016 21:20:23 +0800

> This patch replaces uses of the long obsolete hash interface with
> ahash.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: David S. Miller <davem@davemloft.net>
