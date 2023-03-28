Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0029CC6FD18
	for <linux-nfs@archiver.kernel.org>; Tue, 28 Mar 2023 13:23:19 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232720AbjC1NXS (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 28 Mar 2023 09:23:18 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:40412 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S232548AbjC1NXP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Mar 2023 09:23:15 -0400
Received: from smtp-out2.suse.de (smtp-out2.suse.de [IPv6:2001:67c:2178:6::1d])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id D542FD3
        for <linux-nfs@vger.kernel.org>; Tue, 28 Mar 2023 06:23:10 -0700 (PDT)
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by smtp-out2.suse.de (Postfix) with ESMTPS id 898FE1F8B8;
        Tue, 28 Mar 2023 13:23:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
        t=1680009789;
        h=from:from:reply-to:reply-to:date:date:message-id:message-id:to:to:
         cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=9kIZldL9DC/HWWMxCKKSH9nuMpZLU/I/S+0SivZ0W8I=;
        b=nrN0tAFBasEihch+SogrT++p1gHqKWhdJiHUqNstCwHFByY8FlRTFq9Hf/xHueoZmtXud0
        QNY7WIYJpv1MV1anKHwLcMlgjptQcPU/UlUIPQw3DEoldpO+vFUEI+Lcdb39fz3qxzqrNG
        f47XW2Z5pl79sfH4EJ9W8ks6PhtKnrg=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
        s=susede2_ed25519; t=1680009789;
        h=from:from:reply-to:reply-to:date:date:message-id:message-id:to:to:
         cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=9kIZldL9DC/HWWMxCKKSH9nuMpZLU/I/S+0SivZ0W8I=;
        b=yreTaBo1knFXC0j6if0G/XnJ+e90nad/qzCcjXQqRypA8Yb+lDWUTzeWxtxfbhAOaLw89n
        qziRKrBAyyGp2xAA==
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by imap2.suse-dmz.suse.de (Postfix) with ESMTPS id 0254F1390B;
        Tue, 28 Mar 2023 13:23:08 +0000 (UTC)
Received: from dovecot-director2.suse.de ([192.168.254.65])
        by imap2.suse-dmz.suse.de with ESMTPSA
        id if/1OTzqImTDUwAAMHmgww
        (envelope-from <pvorel@suse.cz>); Tue, 28 Mar 2023 13:23:08 +0000
Date:   Tue, 28 Mar 2023 15:23:07 +0200
From:   Petr Vorel <pvorel@suse.cz>
To:     Jeff Layton <jlayton@kernel.org>
Cc:     calum.mackay@oracle.com, bfields@fieldses.org,
        ffilzlnx@mindspring.com, linux-nfs@vger.kernel.org,
        Frank Filz <ffilz@redhat.com>
Subject: Re: [pynfs PATCH v2 5/5] LOCK24: fix the lock_seqid in second lock
 request
Message-ID: <20230328132307.GA780540@pevik>
Reply-To: Petr Vorel <pvorel@suse.cz>
References: <20230313112401.20488-1-jlayton@kernel.org>
 <20230313112401.20488-6-jlayton@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20230313112401.20488-6-jlayton@kernel.org>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Jeff,

thanks for fixing a long standing issue.

Tested-by: Petr Vorel <pvorel@suse.cz>
(on openSUSE and SLES)

Kind regards,
Petr
