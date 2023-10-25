Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 521EEC0032E
	for <linux-nfs@archiver.kernel.org>; Wed, 25 Oct 2023 16:28:35 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232695AbjJYQ2e (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 25 Oct 2023 12:28:34 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:59692 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229630AbjJYQ2d (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Oct 2023 12:28:33 -0400
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id B1F3791;
        Wed, 25 Oct 2023 09:28:31 -0700 (PDT)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8F301C433C9;
        Wed, 25 Oct 2023 16:28:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1698251311;
        bh=mrHjaT4q6kssAF2OM/Fu1vwtXIetFcoYLYr87oCTnHU=;
        h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
        b=UwEshaNTsjGOW9nwZ9mfu5KgLNKpJljF1eNcXgynlUeRTVQOwPwf7ZBAYIhm6NXHr
         6bRa/OUqNpS77MRwzLMaaOEretgcaxpYAHt/ehWFlcRPlJ5EJnGbqqfTvGv/gG3tsA
         UsSs4CQ7atMJytcQWwYO9Jbp+OMlBOyvOP7X0ei15D2ratX65XbMJGKZXKDrq48mlT
         wQTpWexmD4oOtE6+ZOZmRfPlYTCXC+0wfT6IMF625aS0HepBhmoC9SwMLJfVbP1b8c
         VKo7I50Zm/xwKz8qBkW3ENU+buxDspUnznjC+2g0V2nGYqImKVOmY7JZfc1ncfX/Tp
         JRqx8Jo7glB3g==
Date:   Wed, 25 Oct 2023 09:28:29 -0700
From:   Jakub Kicinski <kuba@kernel.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Christophe JAILLET <christophe.jaillet@wanadoo.fr>,
        jlayton@kernel.org, neilb@suse.de, kolga@netapp.com,
        Dai.Ngo@oracle.com, tom@talpey.com,
        trond.myklebust@hammerspace.com, anna@kernel.org,
        davem@davemloft.net, edumazet@google.com, pabeni@redhat.com,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: Re: [PATCH net v2] net: sunrpc: Fix an off by one in
 rpc_sockaddr2uaddr()
Message-ID: <20231025092829.6034bfcd@kernel.org>
In-Reply-To: <ZTkmm/clAvIdr+6W@tissot.1015granger.net>
References: <31b27c8e54f131b7eabcbd78573f0b5bfe380d8c.1698184674.git.christophe.jaillet@wanadoo.fr>
        <ZTkmm/clAvIdr+6W@tissot.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, 25 Oct 2023 10:30:51 -0400 Chuck Lever wrote:
> Should these two be taken via the NFS client tree or do you intend
> to include them in some other tree?

FWIW we're not intending to take these. If only get_maintainer
understood tree designations :(
