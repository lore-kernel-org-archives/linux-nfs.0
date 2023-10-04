Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4038E7C4E5
	for <linux-nfs@archiver.kernel.org>; Wed,  4 Oct 2023 17:09:58 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S243627AbjJDRJ7 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 4 Oct 2023 13:09:59 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:49272 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S243548AbjJDRJ7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Oct 2023 13:09:59 -0400
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id C7F4195
        for <linux-nfs@vger.kernel.org>; Wed,  4 Oct 2023 10:09:56 -0700 (PDT)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2AE56C433C8;
        Wed,  4 Oct 2023 17:09:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1696439396;
        bh=EejapxRAgzw+TAYKfTQScOAAgVEo1P7QSBw6SBgbl0E=;
        h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
        b=Ien6Kfh8QrpLdbtZd/84HBk4hJcAVbWO4B9tT1IHnB8HiSZkRqG/4G4HyPjC+V6nC
         r2rrjQbcNaNRW/luHjanjXTAjjDFM9ssYAbsV1W/a+fxikguz9MPnUYz/MwV5742Zc
         PMXucSW8D5dB4yYFEY43ytaZi0JF8W1QQ5QXpnlLhiESD08WKWsQJ7h5zzI1KVDjSE
         NtXxCDaNJ1+SmPq20YwQwUNirS8n2zGrM8jpBzTAdmyva/adGSSd1JdGCfjLciIIng
         TXaLjK9MksYoYdUytDhL5UKMmjeOW7OXGFEW1uDoG5tF7rt8Y6gecyxtyzVcdmDx4/
         pCBe691JRHiBg==
Date:   Wed, 4 Oct 2023 10:09:55 -0700
From:   Jakub Kicinski <kuba@kernel.org>
To:     Lorenzo Bianconi <lorenzo@kernel.org>
Cc:     linux-nfs@vger.kernel.org, lorenzo.bianconi@redhat.com,
        jlayton@kernel.org, neilb@suse.de, chuck.lever@oracle.com,
        netdev@vger.kernel.org
Subject: Re: [PATCH v3] NFSD: convert write_threads, write_maxblksize and
 write_maxconn to netlink commands
Message-ID: <20231004100955.32417c33@kernel.org>
In-Reply-To: <27646a34a3ddac3e0b0ad9b49aaf66b3cee5844f.1695766257.git.lorenzo@kernel.org>
References: <27646a34a3ddac3e0b0ad9b49aaf66b3cee5844f.1695766257.git.lorenzo@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, 27 Sep 2023 00:13:15 +0200 Lorenzo Bianconi wrote:
> +int nfsd_nl_threads_set_doit(struct sk_buff *skb, struct genl_info *info)
> +{
> +	u32 nthreads;
> +	int ret;
> +
> +	if (!info->attrs[NFSD_A_CONTROL_PLANE_THREADS])
> +		return -EINVAL;

Consider using GENL_REQ_ATTR_CHECK(), it will auto-add nice error
message to the reply on error.

> +	nthreads = nla_get_u32(info->attrs[NFSD_A_CONTROL_PLANE_THREADS]);
> +
> +	ret = nfsd_svc(nthreads, genl_info_net(info), get_current_cred());
> +	return ret == nthreads ? 0 : ret;
> +}
> +
> +static int nfsd_nl_get_dump(struct sk_buff *skb, struct netlink_callback *cb,
> +			    int cmd, int attr, u32 val)

YNL will dutifully return a list for every dump. If you're only getting
a single reply 'do' will be much better.
