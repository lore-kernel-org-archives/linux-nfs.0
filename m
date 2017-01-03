Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39154 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752816AbdACQEX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Jan 2017 11:04:23 -0500
Date: Tue, 03 Jan 2017 10:56:42 -0500 (EST)
Message-Id: <20170103.105642.1067305724615533420.davem@davemloft.net>
To: nicolas.dichtel@6wind.com
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org,
        dri-devel@lists.freedesktop.org, netdev@vger.kernel.org,
        linux-media@vger.kernel.org, linux-mmc@vger.kernel.org,
        netfilter-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-raid@vger.kernel.org, linux-spi@vger.kernel.org,
        linux-mtd@lists.infradead.org, linux-rdma@vger.kernel.org,
        fcoe-devel@open-fcoe.org, alsa-devel@alsa-project.org,
        linux-fbdev@vger.kernel.org, xen-devel@lists.xenproject.org,
        arnd@arndb.de, airlied@linux.ie
Subject: Re: [PATCH] uapi: use wildcards to list files
From: David Miller <davem@davemloft.net>
In-Reply-To: <1483454144-10519-1-git-send-email-nicolas.dichtel@6wind.com>
References: <20161203.192346.1198940437155108508.davem@davemloft.net>
        <1483454144-10519-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue,  3 Jan 2017 15:35:44 +0100

> Regularly, when a new header is created in include/uapi/, the developer
> forgets to add it in the corresponding Kbuild file. This error is usually
> detected after the release is out.
> 
> In fact, all headers under include/uapi/ should be exported, so let's
> use wildcards.
> 
> After this patch, the following files, which were not exported, are now
> exported:
 ...
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Acked-by: David S. Miller <davem@davemloft.net>
