Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89FD9C433FE
	for <linux-nfs@archiver.kernel.org>; Fri,  4 Nov 2022 21:22:05 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229681AbiKDVWE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 4 Nov 2022 17:22:04 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:36618 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229679AbiKDVWD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Nov 2022 17:22:03 -0400
Received: from smtp-out1.suse.de (smtp-out1.suse.de [IPv6:2001:67c:2178:6::1c])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 3ACD04E412
        for <linux-nfs@vger.kernel.org>; Fri,  4 Nov 2022 14:22:00 -0700 (PDT)
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by smtp-out1.suse.de (Postfix) with ESMTPS id D9A9B21872;
        Fri,  4 Nov 2022 21:21:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
        t=1667596918;
        h=from:from:reply-to:reply-to:date:date:message-id:message-id:to:to:
         cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=UhVMltezdX5TTdlMmbZgrh8J0fbd7JPXfeLxhllMy58=;
        b=b57GNW+Muq21KShnZi9n5h2suO5fDyb7zhcO/RB20MXftgzpVkNAzKSIh9ObSkzS/A2Lzr
        RorMU8geLnZnke1/xF5L+/2px7PiZoeWuQDxLHOrzYZFyT5XzjuKiFUfMqYwtzGUTRxrul
        fHm/TBvp7bfnjRHu/eRi62jji/0OVUg=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
        s=susede2_ed25519; t=1667596918;
        h=from:from:reply-to:reply-to:date:date:message-id:message-id:to:to:
         cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=UhVMltezdX5TTdlMmbZgrh8J0fbd7JPXfeLxhllMy58=;
        b=SnWO2SSd0dHuam/ALwqCEx5mbw8QpASSW/Amsz5IlsiGDSTnX5u9kXPRj1zSdowQXNsZIS
        QVxiZiP9u37w3mAw==
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by imap2.suse-dmz.suse.de (Postfix) with ESMTPS id 954241346F;
        Fri,  4 Nov 2022 21:21:58 +0000 (UTC)
Received: from dovecot-director2.suse.de ([192.168.254.65])
        by imap2.suse-dmz.suse.de with ESMTPSA
        id lE5IIXaCZWPOAgAAMHmgww
        (envelope-from <pvorel@suse.cz>); Fri, 04 Nov 2022 21:21:58 +0000
Date:   Fri, 4 Nov 2022 22:21:56 +0100
From:   Petr Vorel <pvorel@suse.cz>
To:     Jeff Layton <jlayton@kernel.org>
Cc:     chuck.lever@oracle.com, linux-nfs@vger.kernel.org,
        regressions@lists.linux.dev,
        Torsten Hilbrich <torsten.hilbrich@secunet.com>
Subject: Re: [PATCH v2] nfsd: fix net-namespace logic in
 __nfsd_file_cache_purge
Message-ID: <Y2WCdDAGt1OEFzL7@pevik>
Reply-To: Petr Vorel <pvorel@suse.cz>
References: <20221031154921.500620-1-jlayton@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20221031154921.500620-1-jlayton@kernel.org>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi all,

> If the namespace doesn't match the one in "net", then we'll continue,
> but that doesn't cause another rhashtable_walk_next call, so it will
> loop infinitely.

> Fixes: ce502f81ba88 ("NFSD: Convert the filecache to use rhashtable")

Adding this to regression tracker.
https://linux-regtracking.leemhuis.info/tracked-regression/

#regzbot ^introduced ce502f81ba88
#regzbot ignore-activity

Kind regards,
Petr

> Reported-by: Petr Vorel <pvorel@suse.cz>
> Signed-off-by: Jeff Layton <jlayton@kernel.org>
> ---
>  fs/nfsd/filecache.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)

> The v1 patch applies cleanly to v6.0, but not to Chuck's for-next
> branch. This one should be suitable there.
> diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
> index 98c6b5f51bc8..4a8aa7cd8354 100644
> --- a/fs/nfsd/filecache.c
> +++ b/fs/nfsd/filecache.c
> @@ -890,9 +890,8 @@ __nfsd_file_cache_purge(struct net *net)

>  		nf = rhashtable_walk_next(&iter);
>  		while (!IS_ERR_OR_NULL(nf)) {
> -			if (net && nf->nf_net != net)
> -				continue;
> -			nfsd_file_unhash_and_dispose(nf, &dispose);
> +			if (!net || nf->nf_net == net)
> +				nfsd_file_unhash_and_dispose(nf, &dispose);
>  			nf = rhashtable_walk_next(&iter);
>  		}
