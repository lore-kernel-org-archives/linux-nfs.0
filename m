Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85A23C433EF
	for <linux-nfs@archiver.kernel.org>; Mon, 28 Feb 2022 03:00:17 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231686AbiB1DAw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 27 Feb 2022 22:00:52 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:49064 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231558AbiB1DAw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Feb 2022 22:00:52 -0500
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.220.28])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 3252A3A5CB
        for <linux-nfs@vger.kernel.org>; Sun, 27 Feb 2022 19:00:13 -0800 (PST)
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by smtp-out1.suse.de (Postfix) with ESMTPS id CD55821107;
        Mon, 28 Feb 2022 03:00:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1646017211; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=oHRzmjmOQRwrczEl5cn+/4pPpiWmRGeE4ByFDiWhXKg=;
        b=HiPvxh3iwln/l4kLO8LFNiKOJdzLjVWsuqGiVEddWMyZ5TQUE+M4elTHJa6xjG/8WvbVV+
        4HI6BZhj6jaEz9+oDqBbShPJKCSRGYIEY3PqpPD2DnrLG73L1Mwt8UGiJtxQeaab/IJ9mO
        SM8NjBeysvfcgUwE1ua8B0rTYCFsLxs=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1646017211;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=oHRzmjmOQRwrczEl5cn+/4pPpiWmRGeE4ByFDiWhXKg=;
        b=Q4MTEINar/4umDFA+RNdve9eNdrbVL2s049CRk7TgGkKwvwfvNyqzAoBU8jY4L8rWKm59x
        PnrT9OR5uGHeGaAA==
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by imap2.suse-dmz.suse.de (Postfix) with ESMTPS id 9D439139BD;
        Mon, 28 Feb 2022 03:00:09 +0000 (UTC)
Received: from dovecot-director2.suse.de ([192.168.254.65])
        by imap2.suse-dmz.suse.de with ESMTPSA
        id tU51Frk6HGIgWwAAMHmgww
        (envelope-from <neilb@suse.de>); Mon, 28 Feb 2022 03:00:09 +0000
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
From:   "NeilBrown" <neilb@suse.de>
To:     "Olga Kornievskaia" <olga.kornievskaia@gmail.com>
Cc:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v10 10/13] sunrpc: add dst_attr attributes to the sysfs
 xprt directory
In-reply-to: <20210608195922.88655-11-olga.kornievskaia@gmail.com>
References: <20210608195922.88655-1-olga.kornievskaia@gmail.com>,
 <20210608195922.88655-11-olga.kornievskaia@gmail.com>
Date:   Mon, 28 Feb 2022 14:00:03 +1100
Message-id: <164601720393.12951.15824905969343983450@noble.neil.brown.name>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, 09 Jun 2021, Olga Kornievskaia wrote:
> From: Olga Kornievskaia <kolga@netapp.com>
> 
> Allow to query and set the destination's address of a transport.
> Setting of the destination address is allowed only for TCP or RDMA
> based connections.
> 
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  include/linux/sunrpc/xprt.h |   1 +
>  net/sunrpc/sysfs.c          | 105 ++++++++++++++++++++++++++++++++++++
>  net/sunrpc/xprt.c           |   4 +-
>  net/sunrpc/xprtmultipath.c  |   2 -
>  4 files changed, 109 insertions(+), 3 deletions(-)
> 
....
> +static ssize_t rpc_sysfs_xprt_dstaddr_store(struct kobject *kobj,
> +					    struct kobj_attribute *attr,
> +					    const char *buf, size_t count)
> +{
> +	struct rpc_xprt *xprt = rpc_sysfs_xprt_kobj_get_xprt(kobj);
> +	struct sockaddr *saddr;
> +	char *dst_addr;
> +	int port;
> +	struct xprt_addr *saved_addr;
> +	size_t buf_len;
> +
> +	if (!xprt)
> +		return 0;
> +	if (!(xprt->xprt_class->ident == XPRT_TRANSPORT_TCP ||
> +	      xprt->xprt_class->ident == XPRT_TRANSPORT_RDMA)) {
> +		xprt_put(xprt);
> +		return -EOPNOTSUPP;
> +	}
> +
> +	if (wait_on_bit_lock(&xprt->state, XPRT_LOCKED, TASK_KILLABLE)) {
> +		count = -EINTR;
> +		goto out_put;
> +	}

A bit late to this party, however...
This use of wait_on_bit_lock() is not safe.  Wake_up events are only
generated on XPRT_LOCKED when connect completes (xprt_unlock_connect())
and when xprt_autoclose() runs.
Most of the time when a socket is active, this flag is often set and
cleared without any wakeup - or without a wakeup which would wake this
waiter.  There is usually an rpc_wakeup_first_on_queue().

So if this sysfs function is called while XPRT_LOCKED it set, it will
block until killed or the connection is closed.

xs_enable_swap() has a similar problem, and this has failed in practice.

An easy fix would be to add a wake_up_bit() call in xprt_clear_locked()
so that we always get that wakeup.  I'm not sure that is a good idea
though, is this wakeup is almost always unnecessary.

For xs_enable_swap() a better solution is to use ->recv_mutex to provide
the required exclusion.

It isn't clear to me what exclusion this function actually needs, so I
cannot suggest an alternate way to provide it.

rpc_sysfs_xprt_state_change() has the same problem.

NeilBrown
