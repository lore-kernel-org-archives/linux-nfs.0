Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02BE7C83F3E
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Sep 2023 21:04:58 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S234807AbjIEVFB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 5 Sep 2023 17:05:01 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:58116 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S233595AbjIEVFA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Sep 2023 17:05:00 -0400
Received: from smtp-out2.suse.de (smtp-out2.suse.de [IPv6:2001:67c:2178:6::1d])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 5D88BB3
        for <linux-nfs@vger.kernel.org>; Tue,  5 Sep 2023 14:04:57 -0700 (PDT)
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by smtp-out2.suse.de (Postfix) with ESMTPS id 1E1422009D;
        Tue,  5 Sep 2023 21:04:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1693947896; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=FnkBhRxrytkN46ygS60AD0WugqZQMuB1BAunUyEfD9o=;
        b=YIqHi8p4p7ZbFS3wwy4SubL5aQGOeXKjfZPsJl35bdnOH/Hda9NeUrNB+PvwfTXA9ftSvJ
        WsZCzd8OBjsWl56WRiAlcoFAVBHP68i1rxrqgkoNDcCPUwnwihj5a3xeiR5SW9s7J70Pje
        LzYoNblYmIc4vvb4NZX8O+zCyMo6fsQ=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1693947896;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=FnkBhRxrytkN46ygS60AD0WugqZQMuB1BAunUyEfD9o=;
        b=D03Qb7t7E9mWGXh9eWOtGBQVHOTASdiCntFX96iHJDMywOibZocVqYF1ejLTqYpI76bHvR
        Ty4bhQkXqTkUHuDA==
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by imap2.suse-dmz.suse.de (Postfix) with ESMTPS id CF0D013911;
        Tue,  5 Sep 2023 21:04:54 +0000 (UTC)
Received: from dovecot-director2.suse.de ([192.168.254.65])
        by imap2.suse-dmz.suse.de with ESMTPSA
        id ZbMAIPaX92SRHgAAMHmgww
        (envelope-from <neilb@suse.de>); Tue, 05 Sep 2023 21:04:54 +0000
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
From:   "NeilBrown" <neilb@suse.de>
To:     "Chuck Lever III" <chuck.lever@oracle.com>
Cc:     "Jeff Layton" <jlayton@kernel.org>,
        "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/3] Revisions for topic-sunrpc-thread-scheduling
In-reply-to: <0B88EBEB-48DB-4729-9FBC-7DD0F46FBEC2@oracle.com>
References: <20230905014011.25472-1-neilb@suse.de>,
 <0B88EBEB-48DB-4729-9FBC-7DD0F46FBEC2@oracle.com>
Date:   Wed, 06 Sep 2023 07:04:50 +1000
Message-id: <169394789065.22057.12148966276391309480@noble.neil.brown.name>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, 06 Sep 2023, Chuck Lever III wrote:
> 
> > On Sep 4, 2023, at 9:38 PM, NeilBrown <neilb@suse.de> wrote:
> > 
> > This a resend of two recently sent patches (1 and 3) with
> > review comments addressed, plus a new patch (2) which renames
> > some function names for improved consistency.
> > 
> > Thanks,
> > NeilBrown
> > 
> > [PATCH 1/3] lib: add light-weight queuing mechanism.
> > [PATCH 2/3] SUNRPC: rename some functions from rqst_ to svc_thread_
> > [PATCH 3/3] SUNRPC: only have one thread waking up at a time
> 
> Applied these and the remaining patches from the previous
> series. No build problems with this set. I'll test them
> for a bit and then post the latest version of the whole
> series for further review.

Thanks a lot!
NeilBrown
