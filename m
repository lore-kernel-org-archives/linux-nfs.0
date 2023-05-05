Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EAF9BC77B7C
	for <linux-nfs@archiver.kernel.org>; Fri,  5 May 2023 12:56:47 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231788AbjEEM4r (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 5 May 2023 08:56:47 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:58534 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231641AbjEEM4q (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 5 May 2023 08:56:46 -0400
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.220.28])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id B1DC2160AC
        for <linux-nfs@vger.kernel.org>; Fri,  5 May 2023 05:56:44 -0700 (PDT)
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by smtp-out1.suse.de (Postfix) with ESMTPS id 63DD3220A2;
        Fri,  5 May 2023 12:56:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
        t=1683291403;
        h=from:from:reply-to:reply-to:date:date:message-id:message-id:to:to:
         cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=5N8+vUpUXN5oOdiVRYjzFSaDJitbej+9E8pwUj8pS0Q=;
        b=25aynr06HyY9h3nmk7cGo2B/OVH1YuBDoA2IinViQqPs9yb6BOiLhnRCGQoEOgoNeu2IwT
        9fW2L1GVoai4H948EkCdpXg4pp9N4mL2tTaZR3D5ajZaLP/kwJnOw/HNW1vd/TwCm3ptzo
        mwUsORi0tIRhj5zvP3Nk+MZKg7MzYO4=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
        s=susede2_ed25519; t=1683291403;
        h=from:from:reply-to:reply-to:date:date:message-id:message-id:to:to:
         cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=5N8+vUpUXN5oOdiVRYjzFSaDJitbej+9E8pwUj8pS0Q=;
        b=ezptzd+BMcB5d9Q1EeU1LpLPPjwOJJf96SsWjbWZQLgTjPCqNe4SkRd8xb8zYusAs+JIzo
        kWSWxN+JCEmDFIBg==
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by imap2.suse-dmz.suse.de (Postfix) with ESMTPS id 2857E13513;
        Fri,  5 May 2023 12:56:43 +0000 (UTC)
Received: from dovecot-director2.suse.de ([192.168.254.65])
        by imap2.suse-dmz.suse.de with ESMTPSA
        id jFn9Bwv9VGTJRQAAMHmgww
        (envelope-from <pvorel@suse.cz>); Fri, 05 May 2023 12:56:43 +0000
Date:   Fri, 5 May 2023 14:56:41 +0200
From:   Petr Vorel <pvorel@suse.cz>
To:     ltp@lists.linux.it
Cc:     NeilBrown <neilb@suse.de>, Cyril Hrubis <chrubis@suse.cz>,
        linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
Subject: Re: [PATCH v5 4/5] nfs03.sh: Lower down the default values
Message-ID: <20230505125641.GA15306@pevik>
Reply-To: Petr Vorel <pvorel@suse.cz>
References: <20230504131414.3826283-1-pvorel@suse.cz>
 <20230504131414.3826283-5-pvorel@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20230504131414.3826283-5-pvorel@suse.cz>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi,

I'm rejecting this patch, because current patchset is not running on tmpfs.
I will double check on ppc64le anyway, when including any more filesystem
to check if size is big enough.

Kind regards,
Petr
