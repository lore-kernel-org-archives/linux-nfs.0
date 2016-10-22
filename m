Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45948 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754877AbcJVUug (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 22 Oct 2016 16:50:36 -0400
Date: Sat, 22 Oct 2016 16:50:28 -0400 (EDT)
Message-Id: <20161022.165028.1826469214601163183.davem@davemloft.net>
To: pabeni@redhat.com
Cc: netdev@vger.kernel.org, jmorris@namei.org,
        trond.myklebust@primarydata.com, aduyck@mirantis.com,
        daniel@iogearbox.net, edumazet@google.com, tom@herbertland.com,
        hannes@stressinduktion.org, ecree@solarflare.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH net-next v6 0/3] udp: refactor memory accounting
From: David Miller <davem@davemloft.net>
In-Reply-To: <cover.1477043395.git.pabeni@redhat.com>
References: <cover.1477043395.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Fri, 21 Oct 2016 13:55:44 +0200

> This patch series refactor the udp memory accounting, replacing the
> generic implementation with a custom one, in order to remove the needs for
> locking the socket on the enqueue and dequeue operations. The socket backlog
> usage is dropped, as well.
 ...

Series applied, thank you.
