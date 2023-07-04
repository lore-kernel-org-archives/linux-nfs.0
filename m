Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C8881EB64DC
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Jul 2023 00:45:32 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229450AbjGDApb (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Jul 2023 20:45:31 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:40378 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230299AbjGDApa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Jul 2023 20:45:30 -0400
Received: from smtp-out2.suse.de (smtp-out2.suse.de [IPv6:2001:67c:2178:6::1d])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 5B20B130
        for <linux-nfs@vger.kernel.org>; Mon,  3 Jul 2023 17:45:29 -0700 (PDT)
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by smtp-out2.suse.de (Postfix) with ESMTPS id 3B0E8201C7;
        Tue,  4 Jul 2023 00:45:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1688431526; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=HOqxe8Tz7lwjA5cA/nwOQ37/1QIy7WCaBDy3m8dHEGw=;
        b=ygR1fpPJA86MX3wuWS2k5xceht8nVSgPljTNI6MbZ+bwVNx1b1tGZwThXnbpiznstNWekE
        GIflkBoCMTQXQjXFCKHzpmqvzMVVKLM478V1pdmQlj4AE80gYVz6Ho2EquCUm/+h1aqpPg
        O7Y7KJimlblzIY9fArRdm5U4YSLl4pg=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1688431526;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=HOqxe8Tz7lwjA5cA/nwOQ37/1QIy7WCaBDy3m8dHEGw=;
        b=xaBznBGFMbTnWSnb1Fptq8DOxPzdqVgZzRCD83SwIzpQO4MClX3YGTzt0vzFLUiBp5ridP
        K82QY/ZHfUWdA1Cg==
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by imap2.suse-dmz.suse.de (Postfix) with ESMTPS id 0D8D713276;
        Tue,  4 Jul 2023 00:45:23 +0000 (UTC)
Received: from dovecot-director2.suse.de ([192.168.254.65])
        by imap2.suse-dmz.suse.de with ESMTPSA
        id EdWRK6Nro2SxbQAAMHmgww
        (envelope-from <neilb@suse.de>); Tue, 04 Jul 2023 00:45:23 +0000
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
From:   "NeilBrown" <neilb@suse.de>
To:     "Chuck Lever" <cel@kernel.org>
Cc:     linux-nfs@vger.kernel.org, "Chuck Lever" <chuck.lever@oracle.com>,
        lorenzo@kernel.org, jlayton@redhat.com, david@fromorbit.com
Subject: Re: [PATCH v2 4/9] SUNRPC: Count ingress RPC messages per svc_pool
In-reply-to: <168842927591.139194.16920372497489479670.stgit@manet.1015granger.net>
References: <168842897573.139194.15893960758088950748.stgit@manet.1015granger.net>,
 <168842927591.139194.16920372497489479670.stgit@manet.1015granger.net>
Date:   Tue, 04 Jul 2023 10:45:20 +1000
Message-id: <168843152047.8939.5788535164524204707@noble.neil.brown.name>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, 04 Jul 2023, Chuck Lever wrote:
> From: Chuck Lever <chuck.lever@oracle.com>
> 
> To get a sense of the average number of transport enqueue operations
> needed to process an incoming RPC message, re-use the "packets" pool
> stat. Track the number of complete RPC messages processed by each
> thread pool.

If I understand this correctly, then I would say it differently.

I think there are either zero or one transport enqueue operations for
each incoming RPC message.  Is that correct?  So the average would be in
(0,1].
Wouldn't it be more natural to talk about the average number of incoming
RPC messages processed per enqueue operation?  This would be typically
be around 1 on a lightly loaded server and would climb up as things get
busy. 

Was there a reason you wrote it the way around that you did?

NeilBrown
