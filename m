Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2034AC43334
	for <linux-nfs@archiver.kernel.org>; Fri, 17 Jun 2022 14:49:25 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1343920AbiFQOtY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 17 Jun 2022 10:49:24 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:53728 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1382860AbiFQOtX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Jun 2022 10:49:23 -0400
Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.220.29])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 3C5B85676A
        for <linux-nfs@vger.kernel.org>; Fri, 17 Jun 2022 07:49:22 -0700 (PDT)
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by smtp-out2.suse.de (Postfix) with ESMTPS id EF29F1F897;
        Fri, 17 Jun 2022 14:49:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
        t=1655477360; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=0VCxPlolhiC1IQnTrRwMTYu+ztu26XZNqKF7eHfgqcY=;
        b=KC/vx/TpNW90b9u6oLYDA4NnFDH4c4m0W3zyZD7cayWGwP22503pJXBo/aQ/BMhywNG3al
        MgbWD54p8QEv8TQcSaPh2/bodsasVsQ3xX0DEW0emYEFdyYHIELHSfa26ZMmImB+1RHRBg
        T7mGhCZ+G57kU3Za1ZUpg8o6qjHYjmw=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
        s=susede2_ed25519; t=1655477360;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=0VCxPlolhiC1IQnTrRwMTYu+ztu26XZNqKF7eHfgqcY=;
        b=E6KSozKHYA7OBXuIlRThyCkb9ICiyptXyEAj5iH6uupzN7B0C2nwY1mj/CKIFOP3GjWngG
        JDqkeHK/sCzI8tBA==
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by imap2.suse-dmz.suse.de (Postfix) with ESMTPS id D17201348E;
        Fri, 17 Jun 2022 14:49:20 +0000 (UTC)
Received: from dovecot-director2.suse.de ([192.168.254.65])
        by imap2.suse-dmz.suse.de with ESMTPSA
        id 2NPwMXCUrGKyOAAAMHmgww
        (envelope-from <chrubis@suse.cz>); Fri, 17 Jun 2022 14:49:20 +0000
Date:   Fri, 17 Jun 2022 16:51:30 +0200
From:   Cyril Hrubis <chrubis@suse.cz>
To:     Petr Vorel <pvorel@suse.cz>
Cc:     ltp@lists.linux.it, linux-nfs@vger.kernel.org
Subject: Re: [LTP] [RFC][PATCH v2 9/9] nfs: Use TST_ALL_FILESYSTEMS=1
Message-ID: <YqyU8goDyTwJjXM4@yuki>
References: <20220609214223.4608-1-pvorel@suse.cz>
 <20220609214223.4608-10-pvorel@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20220609214223.4608-10-pvorel@suse.cz>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi!
> +
> +	systemctl restart nfs-server

I wonder do we stil have to care for systems without systemd?

We do have daemonlib.sh in LTP that has restart_daemon() function that
branches to systemctl|service|/etc/init.d/ that is used by a few tests.

-- 
Cyril Hrubis
chrubis@suse.cz
