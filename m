Return-Path: <SRS0=L7au=UT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AEE3AC43613
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Jun 2019 15:35:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7037F2070B
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Jun 2019 15:35:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="xVzh8kdW"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726760AbfFTPfT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 20 Jun 2019 11:35:19 -0400
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:60105 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1726654AbfFTPfS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Jun 2019 11:35:18 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
        by mailout.nyi.internal (Postfix) with ESMTP id 007E922359;
        Thu, 20 Jun 2019 11:35:18 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Thu, 20 Jun 2019 11:35:18 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
        messagingengine.com; h=cc:content-type:date:from:in-reply-to
        :message-id:mime-version:references:subject:to:x-me-proxy
        :x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; bh=SFSTH3
        yRd/RrcGfRQj2v2FL3rPg816B7mDskq6jxmr4=; b=xVzh8kdW/jtXTkoNFhddC6
        jt9y5Pa/PvqwkiDP29x8jBa4mMIYrLvIHlaC5Ys+VXnwdrI9PfXuMRUO2ZUWV518
        sj3E79ZhfP2EBCaScJAAwr+CGy5yoIISHaN6di7wzlPQRbzoiblzotmPjJ0c8Iw9
        lk9j9ZcUc1d3xB69h34NB7+ST6SXItggC+5FDNf/Z3YcBtOPhPeYXvw0yCVbBLkh
        kUL5SpjJo27YG1gmwbIiOwBdMmcbLbIsW/iqFE9wXiC75WK0YxlUkj3c1OoC6gt1
        BRN13K7g1XnZZeOcVDAH3Crb87wp7SV9IA7x5eVfCARh/69cxokbyXk3/nWm+1NA
        ==
X-ME-Sender: <xms:tacLXTzn4N4mkEegamzxw8vvJUNo3tzYVC_T_nuKQvHNbS0zHyt21Q>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduvddrtdeggdelfecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpeffhffvuffkfhggtggujggfsehttdertddtredvnecuhfhrohhmpefkughoucfu
    tghhihhmmhgvlhcuoehiughoshgthhesihguohhstghhrdhorhhgqeenucfkphepudelfe
    drgeejrdduieehrddvhedunecurfgrrhgrmhepmhgrihhlfhhrohhmpehiughoshgthhes
    ihguohhstghhrdhorhhgnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:tacLXUD4-sW6hdkfCf9FYWRX28Gi8zGWyfd2FEUO6SJLfaf6gXs3AA>
    <xmx:tacLXcBShGwstviBDEqjJlUA1SlXLXW0iiRoNgNsSyilP1qSJTBzNQ>
    <xmx:tacLXf5SykGl47c_aq8JgzIA8r-yOu-W1UqvX9DEpvpfl4WvU1dztg>
    <xmx:tacLXXOhDjgaDtDuyJIGuNJ-a0LOe9a0vMg0y1Lj9kQwbpW01Fe5nQ>
Received: from localhost (unknown [193.47.165.251])
        by mail.messagingengine.com (Postfix) with ESMTPA id E46BD80061;
        Thu, 20 Jun 2019 11:35:16 -0400 (EDT)
Date:   Thu, 20 Jun 2019 18:35:14 +0300
From:   Ido Schimmel <idosch@idosch.org>
To:     Trond Myklebust <trondmy@gmail.com>
Cc:     Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: Fix a credential refcount leak
Message-ID: <20190620153514.GA30458@splinter>
References: <20190620144740.4169-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190620144740.4169-1-trond.myklebust@hammerspace.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Jun 20, 2019 at 10:47:40AM -0400, Trond Myklebust wrote:
> All callers of __rpc_clone_client() pass in a value for args->cred,
> meaning that the credential gets assigned and referenced in
> the call to rpc_new_client().
> 
> Reported-by: Ido Schimmel <idosch@idosch.org>
> Fixes: 79caa5fad47c ("SUNRPC: Cache cred of process creating the rpc_client")
> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>

Tested-by: Ido Schimmel <idosch@mellanox.com>

Thanks a lot!
