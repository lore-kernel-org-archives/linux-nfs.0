Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D852C001B0
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Jul 2023 08:38:28 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230236AbjGLIi1 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 12 Jul 2023 04:38:27 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:34972 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S232608AbjGLIh4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Jul 2023 04:37:56 -0400
Received: from smtp-out1.suse.de (smtp-out1.suse.de [IPv6:2001:67c:2178:6::1c])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id A782A2133
        for <linux-nfs@vger.kernel.org>; Wed, 12 Jul 2023 01:37:05 -0700 (PDT)
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by smtp-out1.suse.de (Postfix) with ESMTPS id 5EDA2219D5;
        Wed, 12 Jul 2023 08:37:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
        t=1689151024;
        h=from:from:reply-to:reply-to:date:date:message-id:message-id:to:to:
         cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=PwIB4EjBCdPzbaaebmHSMNR+h/nXcQYOZ9xH2Ae7lrA=;
        b=Shc0UzGibA1C/eM4zoPayvRzl18wTuk79wzeU3v7gvvTdgZYZCSxLA4Vmn6X0n7ggtyyIU
        3PCQdSnjmetLA05pQgbEpl27uSRgeEScj4lerIU/4CBpG1n5ouAyopUpGCpy0+IKOz8ZpS
        bme/1HjaMertlMuWD3UQwHXxYESYCDs=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
        s=susede2_ed25519; t=1689151024;
        h=from:from:reply-to:reply-to:date:date:message-id:message-id:to:to:
         cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=PwIB4EjBCdPzbaaebmHSMNR+h/nXcQYOZ9xH2Ae7lrA=;
        b=PTP+oFp2kZswCB/kMSt8GWluCdfvIJIsUtBXSLKGpOUhlZr3GWNXwVP+ZMTMt56TXn52UK
        c0TJFIConf2MwuDw==
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by imap2.suse-dmz.suse.de (Postfix) with ESMTPS id E5A5113336;
        Wed, 12 Jul 2023 08:37:03 +0000 (UTC)
Received: from dovecot-director2.suse.de ([192.168.254.65])
        by imap2.suse-dmz.suse.de with ESMTPSA
        id vx6YNi9mrmRtTAAAMHmgww
        (envelope-from <pvorel@suse.cz>); Wed, 12 Jul 2023 08:37:03 +0000
Date:   Wed, 12 Jul 2023 10:37:02 +0200
From:   Petr Vorel <pvorel@suse.cz>
To:     Cyril Hrubis <chrubis@suse.cz>
Cc:     ltp@lists.linux.it,
        Olga Kornievskaia <olga.kornievskaia@gmail.com>,
        Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: [LTP] [PATCH 1/1] runtest/net.nfs: Run nfs02_06 on TCP only
Message-ID: <20230712083702.GB756025@pevik>
Reply-To: Petr Vorel <pvorel@suse.cz>
References: <20230622084648.490498-1-pvorel@suse.cz>
 <ZK5bnATPwNd-kmvO@yuki>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ZK5bnATPwNd-kmvO@yuki>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Cyril,

thanks a lot, merged!

Kind regards,
Petr
